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
    private Material[] materials = new Material[0];

    // Start is called before the first frame update
    void Start()
    {
        outlineHologram = Shader.Find("Custom/OutlinedHologram");
        printingShader = Shader.Find("Custom/PrintingShader");

        renderer = GetComponent<Renderer>();

        if (renderer)
        {
            materials = renderer.sharedMaterials;
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
            if (!renderer)
            {
                renderer = GetComponent<Renderer>();
            }

            if (renderer)
            {
                if (materials.Length == 0)
                {
                    materials = renderer.sharedMaterials;
                }
            }

            if (materials.Length > 0)
            {
                if (activeShader)
                {
                    for (int i = 0; i < materials.Length; i++)
                    {
                        materials[i].shader = activeShader;
                    }
                }

                for (int i = 0; i < materials.Length; i++)
                {
                    materials[i].SetVector("_SlicingPlane", slicingPlane.GetEquation());
                }

                slicingPlane.UpdateEquation();
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
