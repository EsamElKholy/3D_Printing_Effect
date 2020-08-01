using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MeshSlicer : MonoBehaviour
{
    public SlicingPlane slicingPlane;
    private new Renderer renderer;
    private Vector4 planeEquation;
    private Material material;

    // Start is called before the first frame update
    void Start()
    {
        renderer = GetComponent<Renderer>();

        if (renderer)
        {
            material = renderer.material;
        }
    }

    // Update is called once per frame
    void Update()
    {
        UpdateMaterial();
    }

    public void UpdateMaterial()
    {
        if (slicingPlane)
        {
            if (material)
            {
                slicingPlane.UpdateEquation();
                material.SetVector("_SlicingPlane", slicingPlane.GetEquation());
            }
        }
    }
}
