// using UnityEditor;
//
// namespace Pico
// {
//     namespace Avatar
//     {
//         /** Resource Platform and technique leve. */
//         public class ResourcePlatformAndTechniqueLevel
//         {
//             public ResourcePlatform platform
//             {
//                 get
//                 {
//                     return _ResourcePlatform;
//                 }
//                 set
//                 {
//                     _ResourcePlatform = value;
//                 }
//             }
//
//             public ResourceTechniqueLevel techniqueLevel
//             {
//                 get
//                 {
//                     return _ResourceTechniqueLevel;
//                 }
//                 set
//                 {
//                     _ResourceTechniqueLevel = value;
//                 }
//             }
//
//             /** Draw GUI. */
//             public bool DrawGUI()
//             {
//                 //platform
//                 EditorGUI.BeginChangeCheck();
//                 _ResourcePlatform = (ResourcePlatform)EditorGUILayout.Popup("ResourcePlatform", (int)_ResourcePlatform, _ResourcePlatformNames);
//                 if (EditorGUI.EndChangeCheck())
//                 {
//                     return true;
//                 }
//
//
//                 //ResourceTechniqueLevel
//                 EditorGUI.BeginChangeCheck();
//                 _ResourceTechniqueLevel = (ResourceTechniqueLevel)EditorGUILayout.Popup("ResourceTechniqueLevel", (int)_ResourceTechniqueLevel, _ResourceTechniqueLevelNames);
//                 if (EditorGUI.EndChangeCheck())
//                 {
//                     return true;
//                 }
//                 //
//                 return false;
//             }
//
//             private ResourcePlatform _ResourcePlatform = ResourcePlatform.NUM;
//             private ResourceTechniqueLevel _ResourceTechniqueLevel = ResourceTechniqueLevel.Lowest; // Default to the lowest resource level.
//                                                                                                     //
//             private string[] _ResourcePlatformNames = new string[]
//             {
//                 "Any",    // Any = 0,  // Common platform.
//                 "PC",     // PC = 1,    
//                 "Mobile", // Mobile = 2,
//             };
//
//             private string[] _ResourceTechniqueLevelNames = new string[]
//             {
//                 "T0 Lowest",//   Lowest = 0,
//                 "T1 Medium",// Medium = 1,  
//                 "T2 High",  // Full = 2,  
//             };
//         }
//     }
// }
