using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlicingPlaneResizer : MonoBehaviour
{
    private SlicingPlane slicingPlane;
    private new Renderer renderer;
    private Renderer slicedMesh;

    // Start is called before the first frame update
    void Start()
    {
        slicingPlane = GetComponent<SlicingPlane>();
        renderer = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        Resize();
    }

    public void Resize()
    {
        if (slicingPlane)
        {
            if (slicedMesh == null)
            {
                slicedMesh = slicingPlane.meshToSlice.GetComponent<Renderer>();
            }
        }

        if (slicedMesh)
        {
            var center = KAI.ModelUtils.GetCenter(slicedMesh.gameObject);
           // transform.position = new Vector3(center.x, transform.position.y, center.z);
            Bounds b = renderer.bounds;
            var sA = b.size;
            var sB = slicedMesh.bounds.size;

            float x = sB.x / sA.x;
            float y = sA.y;
            float z = sB.z / sA.z;

            transform.localScale = new Vector3(x * transform.localScale.x, transform.localScale.y, z * transform.localScale.z);
        }
    }
}
