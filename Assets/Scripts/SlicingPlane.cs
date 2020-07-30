using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlicingPlane : MonoBehaviour
{
    private Plane slicingPlane;
    private Vector4 equation;

    // Start is called before the first frame update
    void Start()
    {
        slicingPlane = new Plane(transform.up, transform.position);
        equation = new Vector4(slicingPlane.normal.x, slicingPlane.normal.y, slicingPlane.normal.z, slicingPlane.distance);
    }

    // Update is called once per frame
    void Update()
    {
        slicingPlane.SetNormalAndPosition(transform.up, transform.position);

        equation.x = slicingPlane.normal.x;
        equation.y = slicingPlane.normal.y;
        equation.z = slicingPlane.normal.z;
        equation.w = slicingPlane.distance;
    }

    public Vector4 GetEquation()
    {
        return equation;
    }
}
