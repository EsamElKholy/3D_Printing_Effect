using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlicingPlane : MonoBehaviour
{
    [HideInInspector]
    public GameObject meshToSlice;
    [HideInInspector]
    public GameObject root;

    private Plane slicingPlane;
    private Vector4 equation;

    // Start is called before the first frame update
    void Start()
    {
        Vector3 up = transform.up;

        slicingPlane = new Plane(up, transform.position);
        equation = new Vector4(slicingPlane.normal.x, slicingPlane.normal.y, slicingPlane.normal.z, slicingPlane.distance);
    }

    // Update is called once per frame
    void Update()
    {
        UpdateEquation();
    }

    public Vector4 GetEquation()
    {
        return equation;
    }

    public void UpdateEquation()
    {
        if (transform)
        {
            Vector3 up = transform.up;
            
            slicingPlane.SetNormalAndPosition(up, transform.position);

            equation.x = slicingPlane.normal.x;
            equation.y = slicingPlane.normal.y;
            equation.z = slicingPlane.normal.z;
            equation.w = slicingPlane.distance;
        }
    }

    public void ResetPlanePosition(bool toTop)
    {
        if (meshToSlice)
        {
            var renderer = meshToSlice.GetComponent<Renderer>();
            var top = KAI.ModelUtils.GetTopCenter(renderer.transform.gameObject);
            var bottom = KAI.ModelUtils.GetBottomCenter(renderer.transform.gameObject);

            if (toTop)
            {
                top.y += Vector3.Distance(top, bottom) * 0.05f;
                transform.position = top;
            }
            else
            {
                bottom.y -= Vector3.Distance(top, bottom) * 0.02f;
                transform.position = bottom;
            }

            UpdateEquation();
            meshToSlice.GetComponent<MeshSlicer>().UpdateMaterial();
        }
    }
}
