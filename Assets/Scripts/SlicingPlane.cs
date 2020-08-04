using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlicingPlane : MonoBehaviour
{
    [HideInInspector]
    public GameObject meshToSlice;

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
            transform.position = meshToSlice.transform.position;

            var renderer = meshToSlice.GetComponent<Renderer>();

            float xExtent = renderer.bounds.extents.x;
            float yExtent = renderer.bounds.extents.y;
            float zExtent = renderer.bounds.extents.z;

            if (toTop)
            {
                transform.Translate(xExtent + (xExtent * 0.1f), yExtent + (yExtent * 0.1f), -zExtent - (zExtent * 0.1f));
            }
            else
            {
                transform.Translate(-xExtent - (xExtent * 0.1f), -yExtent - (yExtent * 0.1f), zExtent + (zExtent * 0.1f));
            }

            UpdateEquation();
            meshToSlice.GetComponent<MeshSlicer>().UpdateMaterial();
        }
    }
}
