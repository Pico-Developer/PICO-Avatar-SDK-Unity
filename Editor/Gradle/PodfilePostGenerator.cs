#if UNITY_IOS && UNITY_EDITOR
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

public class PostProcessIOS : MonoBehaviour {
    [PostProcessBuildAttribute(45)]
    private static void PostProcessBuild_iOS(BuildTarget target, string buildPath)
    {
        UnityEngine.Debug.LogError("OnPostGenerateGradleAndroidProject NEED BE improved! " );
        return;

        if (target == BuildTarget.iOS)
        {
            using (StreamWriter sw = File.CreateText(buildPath + "/Podfile"))
            {
                sw.WriteLine(@"
require 'bd_pod_extentions'
bd_use_app('toutiao', 'public', 'douyin', 'thirdParty')
bd_use_binary!

target 'UnityFramework' do
    inherit! :search_paths
    pod_binary 'AGFX_pub', '10.65.0.1'
    pod_binary 'audiosdk', '11.12.1-common'
    pod_binary 'EffectSDK_iOS', '10.4.0.1-alpha.0-Unity', :subspecs => ['Core', 'PartModel']
    pod_binary 'gaia_lib_publish', '10.65.0.4-D'
    pod_binary 'IESAppLogger_iOS', '0.1.0'
    pod_binary 'TTNetworkManager', '4.0.60.4'
end
");
            }
        }
    }

    [PostProcessBuild]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string path)
    {
        if (buildTarget == BuildTarget.iOS)
        {
            string projPath = PBXProject.GetPBXProjectPath(path);
            PBXProject pbxProject = new PBXProject();
            pbxProject.ReadFromString(File.ReadAllText(projPath));
            // bitcode
            pbxProject.SetBuildProperty(pbxProject.ProjectGuid(), "ENABLE_BITCODE", "NO");
            // framework
            string framework = pbxProject.TargetGuidByName("UnityFramework");
            pbxProject.AddFrameworkToProject(framework, "CoreLocation.framework", false);
            pbxProject.AddFrameworkToProject(framework, "CoreHaptics.framework", true);
            pbxProject.AddFrameworkToProject(framework, "ARKit.framework", true);
            // sign
            PlayerSettings.iOS.appleEnableAutomaticSigning = true;
            string target = pbxProject.GetUnityMainTargetGuid();//("Unity-iPhone");
            pbxProject.SetTeamId(target, "94XD2KWZSS");
            // save
            File.WriteAllText(projPath, pbxProject.WriteToString());
            // after generated, you need run 'pod install'
        }
    }

}
#endif