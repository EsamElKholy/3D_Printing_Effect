using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CenterPivot : MonoBehaviour
{
    private Material material;
    private Vector4 newPivot;
    // Start is called before the first frame update
    void Start()
    {
        Renderer renderer = GetComponent<Renderer>();

        if (renderer)
        {
            var center = KAI.ModelUtils.GetCenter(gameObject);
            var go = new GameObject("center");
            go.transform.SetParent(transform);
            newPivot.x = center.x;
            newPivot.y = center.y;
            newPivot.z = center.z;
            newPivot.w = 1;
            material = renderer.material;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (material)
        {
            var center = KAI.ModelUtils.GetCenter(gameObject);
            newPivot.x = center.x;
            newPivot.y = center.y;
            newPivot.z = center.z;
            newPivot.w = 1;

            material.SetVector("_CenterPivot", newPivot);
        }
    }
}
