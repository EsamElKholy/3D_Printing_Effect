using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintingManager : MonoBehaviour
{
    public GameObject slicingPlanePrefab;
    public List<GameObject> meshesPrefabs = new List<GameObject>();

    public List<Renderer> meshes = new List<Renderer>();
    private List<SlicingPlane> slicingPlanes = new List<SlicingPlane>();

    public List<Renderer> tempMeshes = new List<Renderer>();
    private List<SlicingPlane> tempSlicingPlanes = new List<SlicingPlane>();

    private int lastMeshesCount = 0;
    private Ray mouseRay;
    private RaycastHit mouseRayHit;
    private Camera mainCam;
    private Vector3 rayHitPos;
    private bool inPlacementMode = false;
    private bool placeObject = false;
    private int currentObjectIndex = 0;
    private bool reset = false;    

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

        if (Input.GetKeyUp(KeyCode.Escape))
        {
            reset = true;
            for (int i = 0; i < tempMeshes.Count; i++)
            {
                tempMeshes[i].enabled = false;
            }
        }

        if (Input.GetMouseButtonUp(0) && placeObject)
        {
            if (reset)
            {
                reset = false;
                var lerpAlpha = tempMeshes[currentObjectIndex].GetComponent<LerpAlpha>();
                //lerpAlpha.StopAnimation();
            }
            else if (placeObject)
            {
                placeObject = false;
                var controller = PlaceObject();

                if (controller)
                {
                    controller.StartPrinting();
                }
            }
        }

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
                if (Input.GetMouseButton(0) && !reset)
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
            placeObject = true;
            rayHitPos = mouseRayHit.point;

            if (Input.GetKeyUp(KeyCode.T))
            {
                currentObjectIndex++;
            }

            if (currentObjectIndex >= tempMeshes.Count)
            {
                currentObjectIndex = 0;
            }

            if (tempMeshes.Count > 0)
            {
                var mesh = tempMeshes[currentObjectIndex];
                mesh.enabled = true;

                for (int i = 0; i < tempMeshes.Count; i++)
                {
                    if (i != currentObjectIndex)
                    {
                        tempMeshes[i].enabled = false;
                    }
                }

                if (mesh)
                {
                    var slicer = mesh.GetComponent<MeshSlicer>();
                    
                    if (slicer)
                    {
                        //var lerpAlpha = slicer.GetComponent<LerpAlpha>();
                        //lerpAlpha.StartAnimation();
                        slicer.ActivateOutlineHologramShader();
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
    }

    public PrintingController PlaceObject()
    {
        PrintingController controller = null;

        if (tempMeshes.Count > 0)
        {
            var mesh = Instantiate<GameObject>(tempMeshes[currentObjectIndex].gameObject);
            mesh.name = tempMeshes[currentObjectIndex].gameObject.name;
            MeshSlicer slicer = mesh.GetComponent<MeshSlicer>();
            slicer.ActivatePrintingShader();

            slicer.slicingPlane = null;

            var meshRenderer = mesh.GetComponent<Renderer>();
            meshRenderer.material = new Material(tempMeshes[currentObjectIndex].sharedMaterial);
            meshes.Add(meshRenderer);

            UpdateMeshes();           

            tempMeshes[currentObjectIndex].enabled = false;

            controller = mesh.GetComponent<MeshSlicer>().slicingPlane.GetComponent<PrintingController>();
        }

        placeObject = false;

        return controller;
    }

    public void UpdateAllMeshes()
    {
        UpdateTempMeshes();
        UpdateMeshes();
    }

    public void UpdateTempMeshes()
    {
        tempMeshes = new List<Renderer>();

        GameObject tempMeshesRoot = null;

        for (int i = 0; i < transform.childCount; i++)
        {
            if (transform.GetChild(i).name == "TEMP_MESHES_ROOT")
            {
                DestroyImmediate(transform.GetChild(i).gameObject);
            }
        }

        if (tempMeshesRoot == null)
        {
            tempMeshesRoot = new GameObject("TEMP_MESHES_ROOT");
            tempMeshesRoot.transform.SetParent(transform);
        }

        for (int i = 0; i < meshesPrefabs.Count; i++)
        {
            var mesh = Instantiate<GameObject>(meshesPrefabs[i], tempMeshesRoot.transform);
            mesh.name = meshesPrefabs[i].name;
            tempMeshes.Add(mesh.GetComponent<Renderer>());
        }

        GameObject tempRoot = null;

        for (int i = 0; i < transform.childCount; i++)
        {
            if (transform.GetChild(i).name == "TEMP")
            {
                tempRoot = transform.GetChild(i).gameObject;
                DestroyImmediate(tempRoot);
            }
        }

        if (tempRoot == null)
        {
            tempRoot = new GameObject("TEMP");
            tempRoot.transform.SetParent(transform);
        }

        tempSlicingPlanes.Clear();

        foreach (var mesh in tempMeshes)
        {
            var meshSlicer = mesh.gameObject.GetComponent<MeshSlicer>();

            if (meshSlicer == null)
            {
                meshSlicer = mesh.gameObject.AddComponent<MeshSlicer>();
            }
            
            if (meshSlicer.slicingPlane == null)
            {
                var slicingPlane = AddSlicingPlane(true);

                if (slicingPlane)
                {
                    meshSlicer.slicingPlane = slicingPlane;
                    slicingPlane.meshToSlice = meshSlicer.gameObject;
                    slicingPlane.name = mesh.name + "_Plane";
                }
            }

            mesh.enabled = false;
        }
    }

    public void UpdateMeshes()
    {
        GameObject meshesRoot = null;

        for (int i = 0; i < transform.childCount; i++)
        {
            if (transform.GetChild(i).name == "MESHES_ROOT")
            {
                meshesRoot = transform.GetChild(i).gameObject;
            }
        }

        if (meshesRoot == null)
        {
            meshesRoot = new GameObject("MESHES_ROOT");
            meshesRoot.transform.SetParent(transform);
        }

        for (int i = 0; i < meshes.Count; i++)
        {
            meshes[i].transform.SetParent(meshesRoot.transform);
        }

        GameObject planesRoot = null;

        for (int i = 0; i < transform.childCount; i++)
        {           
            if (transform.GetChild(i).name == "PLANES_ROOT")
            {
                planesRoot = transform.GetChild(i).gameObject;
            }
        }       

        if (planesRoot == null)
        {
            planesRoot = new GameObject("PLANES_ROOT");
            planesRoot.transform.SetParent(transform);
        }

        slicingPlanes.Clear();

        for (int i = 0; i < planesRoot.transform.childCount; i++)
        {
            var slicingPlane = planesRoot.transform.GetChild(i).GetComponent<SlicingPlane>();

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
                var slicingPlane = AddSlicingPlane(false);

                if (slicingPlane)
                {
                    meshSlicer.slicingPlane = slicingPlane;
                    slicingPlane.meshToSlice = meshSlicer.gameObject;
                }
            }
        }
    }

    private SlicingPlane AddSlicingPlane(bool temp)
    {
        if (slicingPlanePrefab.GetComponent<SlicingPlane>())
        {
            GameObject tempRoot = null;
            GameObject planesRoot = null;

            for (int i = 0; i < transform.childCount; i++)
            {
                if (transform.GetChild(i).name == "TEMP")
                {
                    tempRoot = transform.GetChild(i).gameObject;
                }

                if (transform.GetChild(i).name == "PLANES_ROOT")
                {
                    planesRoot = transform.GetChild(i).gameObject;
                }
            }

            if (tempRoot == null)
            {
                tempRoot = new GameObject("TEMP");
                tempRoot.transform.SetParent(transform);
            }

            if (planesRoot == null)
            {
                planesRoot = new GameObject("PLANES_ROOT");
                planesRoot.transform.SetParent(transform);
            }

            if (temp)
            {
                var slicingPlaneGO = Instantiate<GameObject>(slicingPlanePrefab, tempRoot.transform);
                slicingPlaneGO.transform.localScale = new Vector3(100, 100, 100);
                var slicingPlane = slicingPlaneGO.GetComponent<SlicingPlane>();
                slicingPlanes.Add(slicingPlane);

                return slicingPlane;
            }
            else
            {
                var slicingPlaneGO = Instantiate<GameObject>(slicingPlanePrefab, planesRoot.transform);
                slicingPlaneGO.transform.localScale = new Vector3(100, 100, 100);
                var slicingPlane = slicingPlaneGO.GetComponent<SlicingPlane>();
                slicingPlanes.Add(slicingPlane);

                return slicingPlane;
            }
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
        foreach (var mesh in tempMeshes)
        {
            var meshSlicer = mesh.GetComponent<MeshSlicer>();

            ResetSlicingPlanePosition(meshSlicer, toTop);
        }

        foreach (var mesh in meshes)
        {
            var meshSlicer = mesh.GetComponent<MeshSlicer>();

            ResetSlicingPlanePosition(meshSlicer, toTop);
        }
    }

    public void ResetAllSlicingPlanesSize()
    {
        foreach (var mesh in tempMeshes)
        {
            var meshSlicer = mesh.GetComponent<MeshSlicer>();
            if (meshSlicer)
            {
                if (meshSlicer.slicingPlane)
                {
                    var resizer = meshSlicer.slicingPlane.GetComponent<SlicingPlaneResizer>();
                    resizer.Resize();
                }
            }
        }

        foreach (var mesh in meshes)
        {
            var meshSlicer = mesh.GetComponent<MeshSlicer>();
            if (meshSlicer)
            {
                if (meshSlicer.slicingPlane)
                {
                    var resizer = meshSlicer.slicingPlane.GetComponent<SlicingPlaneResizer>();
                    resizer.Resize();
                }
            }
        }
    }
}
