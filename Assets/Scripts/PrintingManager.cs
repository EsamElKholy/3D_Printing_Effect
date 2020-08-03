using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintingManager : MonoBehaviour
{
    public GameObject slicingPlanePrefab;
    public List<Renderer> meshes = new List<Renderer>(); 
    private List<SlicingPlane> slicingPlanes = new List<SlicingPlane>();
    private int lastMeshesCount = 0;

    // Start is called before the first frame update
    void Start()
    {
        lastMeshesCount = meshes.Count;
    }

    // Update is called once per frame
    void Update()
    {
        if (lastMeshesCount != meshes.Count || slicingPlanes.Count != meshes.Count)
        {
            lastMeshesCount = meshes.Count;
            UpdateMeshes();
        }
    }

    public void UpdateMeshes()
    {
        slicingPlanes.Clear();

        for (int i = 0; i < transform.childCount; i++)
        {
            var slicingPlane = transform.GetChild(i).GetComponent<SlicingPlane>();

            if (slicingPlane)
            {
                if (slicingPlane.meshToSlice == null)
                {
                    DestroyImmediate(slicingPlane.gameObject);
                    i--;
                    continue;
                }

                slicingPlane.name = slicingPlane.meshToSlice.name + " Slicing Plane";

                slicingPlanes.Add(slicingPlane);
            }
        }

        foreach (var mesh in meshes)
        {
            var meshSlicer = mesh.gameObject.GetComponent<MeshSlicer>();

            if (meshSlicer == null)
            {
                meshSlicer = mesh.gameObject.AddComponent<MeshSlicer>();
            }
            
            if (meshSlicer.slicingPlane == null)
            {
                var slicingPlane = AddSlicingPlane();

                if (slicingPlane)
                {
                    meshSlicer.slicingPlane = slicingPlane;
                    slicingPlane.meshToSlice = meshSlicer.gameObject;
                }
            }
        }
    }

    private SlicingPlane AddSlicingPlane()
    {
        if (slicingPlanePrefab.GetComponent<SlicingPlane>())
        {
            var slicingPlaneGO = Instantiate<GameObject>(slicingPlanePrefab, transform);
            slicingPlaneGO.transform.localScale = new Vector3(100, 100, 100);
            var slicingPlane = slicingPlaneGO.GetComponent<SlicingPlane>();
            slicingPlanes.Add(slicingPlane);

            return slicingPlane;
        }

        return null;
    }

    public void ResetSlicingPlanePosition(MeshSlicer meshSlicer, bool toTop)
    {
        if (meshSlicer)
        {
            if (meshSlicer.slicingPlane)
            {
                meshSlicer.slicingPlane.ResetPlanePosition(toTop);
            }
        }
    }

    public void ResetAllSlicingPlanes(bool toTop)
    {
        foreach (var mesh in meshes)
        {
            var meshSlicer = mesh.GetComponent<MeshSlicer>();

            ResetSlicingPlanePosition(meshSlicer, toTop);
        }
    }
}
