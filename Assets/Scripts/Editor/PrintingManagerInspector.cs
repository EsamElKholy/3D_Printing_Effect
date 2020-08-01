using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PrintingManager))]
public class PrintingManagerInspector : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        PrintingManager manager = target as PrintingManager;

        if (GUILayout.Button("Reset slicer to top"))
        {
            manager.ResetAllSlicingPlanes(true);
        }

        if (GUILayout.Button("Reset slicer to buttom"))
        {
            manager.ResetAllSlicingPlanes(false);
        }

        if (GUILayout.Button("Update"))
        {
            manager.UpdateMeshes();
        }
    }
}
