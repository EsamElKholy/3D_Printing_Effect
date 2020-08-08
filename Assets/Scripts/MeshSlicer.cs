using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MeshSlicer : MonoBehaviour
{
    public SlicingPlane slicingPlane;

    public Shader outlineHologram;
    public Shader printingShader;

    private Shader activeShader;

    public Color hologramColor;
    public Color outlineColor;

    private new Renderer renderer;
    private Vector4 planeEquation;
    private Material material;

    // Start is called before the first frame update
    void Start()
    {
        outlineHologram = Shader.Find("Custom/OutlinedHologram");
        printingShader = Shader.Find("Custom/PrintingShader");

        renderer = GetComponent<Renderer>();

        if (renderer)
        {
            material = renderer.sharedMaterial;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (slicingPlane)
        {
            slicingPlane.meshToSlice = gameObject;
        }

        UpdateMaterial();
    }

    public void UpdateMaterial()
    {
        if (slicingPlane)
        {
            if (material)
            {
                if (activeShader)
                {
                    material.shader = activeShader;
                }

                slicingPlane.UpdateEquation();
                material.SetVector("_SlicingPlane", slicingPlane.GetEquation());
            }
        }
    }

    public void ActivateOutlineHologramShader()
    {
        activeShader = outlineHologram;
    }

    public void ActivatePrintingShader()
    {
        activeShader = printingShader;
    }
}
