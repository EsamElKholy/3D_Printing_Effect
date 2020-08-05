using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintingManager : MonoBehaviour
{
    public GameObject slicingPlanePrefab;
    public List<Renderer> meshes = new List<Renderer>();
    private List<SlicingPlane> slicingPlanes = new List<SlicingPlane>();
    private int lastMeshesCount = 0;
    private Ray mouseRay;
    private RaycastHit mouseRayHit;
    private Camera mainCam;
    private Vector3 rayHitPos;
    private bool inPlacementMode = false;
    private int currentObjectIndex = 0;

    // Start is called before the first frame update
    void Start()
    {
        lastMeshesCount = meshes.Count;
        mainCam = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        inPlacementMode = CastMouseRay();
        PlacementMode(inPlacementMode);

        if (lastMeshesCount != meshes.Count || slicingPlanes.Count != meshes.Count)
        {
            lastMeshesCount = meshes.Count;
            UpdateMeshes();
        }
    }

    public bool CastMouseRay()
    {
       // if (Input.GetKey(KeyCode.LeftControl))
        {
            if (mainCam)
            {
                if (Input.GetMouseButton(0))
                {
                    mouseRay = mainCam.ScreenPointToRay(Input.mousePosition);

                    if (Physics.Raycast(mouseRay, out mouseRayHit, 10000, 1 << LayerMask.NameToLayer("Ground")))
                    {
                        var objHit = mouseRayHit.transform;

                        if (objHit)
                        {
                            if (objHit.tag == "Ground")
                            {
                                return true;
                            }                           
                        }
                    }
                }
            }
        }

        return false;
    }

    private void PlacementMode(bool inPlacement)
    {
        if (inPlacement)
        {
            rayHitPos = mouseRayHit.point;

            if (Input.GetKeyUp(KeyCode.T))
            {
                currentObjectIndex++;
            }

            if (currentObjectIndex >= meshes.Count)
            {
                currentObjectIndex = 0;
            }

            if (meshes.Count > 0)
            {
                var mesh = meshes[currentObjectIndex];

                if (mesh)
                {
                    var slicer = mesh.GetComponent<MeshSlicer>();

                    if (slicer)
                    {
                        mesh.transform.position = rayHitPos;
                        slicer.slicingPlane.ResetPlanePosition(false);
                       
                        var top = KAI.ModelUtils.GetTopCenter(mesh.gameObject);
                        var bottom = KAI.ModelUtils.GetBottomCenter(mesh.gameObject);

                        var length = Mathf.Abs(mouseRayHit.transform.position.y - bottom.y);

                        mesh.transform.position = new Vector3(rayHitPos.x, rayHitPos.y + length + 0.01f, rayHitPos.z);
                        mesh.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    }
                }
            }
        }
        else
        {
            var mesh = meshes[currentObjectIndex];

            if (mesh)
            {
                mesh.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            }
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
