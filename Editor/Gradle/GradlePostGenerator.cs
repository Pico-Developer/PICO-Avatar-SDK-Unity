#if UNITY_EDITOR
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Android;
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace StarkSDKSpace
{
    public class GradlePostGeneratorForDemo : IPostGenerateGradleAndroidProject
    {
        public int callbackOrder { get; }
        public static bool buildHomeCenter = false;

        public void OnPostGenerateGradleAndroidProject(string path)
        {
            Debug.Log($"OnPostGenerateGradleAndroidProject : {path}");
            if (buildHomeCenter)
            {
                Debug.Log($"OnPostGenerateGradleAndroidProject_HomeCenter");
                OnPostGenerateGradleAndroidProject_HomeCenter(path);
                return;
            }
        }


        private void OnPostGenerateGradleAndroidProject_HomeCenter(string path)
        {
            var rootPath = Path.Combine(Application.dataPath, "..", path, "..");
            rootPath = Path.GetFullPath(rootPath);

            // 修改 ./unityLibrary/build.gradle
            {
                var filePath = $"{rootPath}/unityLibrary/build.gradle";
                var text = File.ReadAllText(filePath);
                var reg = new Regex("(implementation.+)");
    
                var deps_local_debug = @"
    implementation 'com.bytedance.pico:matrix.ones:5.5.0.common'
    configurations {
        all*.exclude group: 'com.google.code.gson', module: 'gson'
        all*.exclude group: 'com.android.support', module: 'support-compat'
    }
                ";

    //            var deps = @"
    //implementation 'com.bytedance:effectsdk:10.4.0_dev_3_unity_202111082130_54f9b1f0d77'
    //implementation 'com.ss.ttm:ttffmpeg:1.1.27.10-boringssl'
    //            ";
                text = reg.Replace(text, $"$1{deps_local_debug}", 1);
                File.WriteAllText(filePath, text);
                
            }
            UnityEngine.Debug.Log("change unityLibrary/build.gradle");
            // 修改 ./build.gradle
            {
                var filePath = $"{rootPath}/build.gradle";
                var text = @"buildscript {
                    repositories {
                        maven {
                            url 'http://maven.byted.org/repository/android_public/'
                        }
                        maven {
                            url 'https://maven.byted.org/repository/bytedance_android/'
                        }
                        google()
                        jcenter()
                    }
                    dependencies {
                        classpath 'com.android.tools.build:gradle:3.4.1'
                    }
                }
                allprojects {
                    repositories {
                        maven {
                            url 'http://maven.byted.org/repository/android_public/'
                        }
                        maven {
                            url 'https://maven.byted.org/repository/bytedance_android/'
                        }
                        maven {
                            url 'http://stone-maven.bytedance.net/repository/maven-public/'
                        }
                        google()
                        jcenter()
                        flatDir {
                            dirs ""${project(':unityLibrary').projectDir}/libs""
                        }
                    }
                }
                task clean(type: Delete) {
                    delete rootProject.buildDir
                }";
                File.WriteAllText(filePath, text);
            }
            UnityEngine.Debug.Log("change root/build.gradle");
        }
    }
#endif
}
