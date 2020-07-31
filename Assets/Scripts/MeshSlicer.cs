using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
        if (material)
        {
            material.SetVector("_SlicingPlane", slicingPlane.GetEquation());
        }
    }
}
