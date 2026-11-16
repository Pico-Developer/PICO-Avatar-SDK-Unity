#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

namespace Pico.Avatar
{
	public class EnumFlagsAttribute : PropertyAttribute
	{
	}

	[CustomPropertyDrawer(typeof(EnumFlagsAttribute))]
	public class EnumFlagsAttributeDrawer : PropertyDrawer
	{
		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			// Draw a multi-value enum field. 0 selects none, -1 selects all, and other values are enum flag sums.
			// Enum value = 2 ^ current index.
			// Default sequence: 0^2 = 1, 1^2 = 2, 4, 16, ...
			property.intValue = EditorGUI.MaskField(position, label, property.intValue
				, property.enumNames);
		}
	}
}
#endif
