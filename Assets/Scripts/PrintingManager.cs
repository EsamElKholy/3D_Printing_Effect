using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintingManager : MonoBehaviour
{
    public GameObject slicingPlanePrefab;
    public List<GameObject> meshesPrefabs = new List<GameObject>();

    public List<GameObject> meshes = new List<GameObject>();
    private List<SlicingPlane> slicingPlanes = new List<SlicingPlane>();

    public List<GameObject> tempMeshes = new List<GameObject>();
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

    public float rotationSpeed = 50;
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
                var tempRends = tempMeshes[i].GetComponentsInChildren<Renderer>();
                foreach (var rend in tempRends)
                {
                    rend.enabled = false;
                }
            }
        }

        if (Input.GetMouseButtonUp(0) && placeObject)
        {
            if (reset)
            {
                reset = false;
            }
            else if (placeObject)
            {
                placeObject = false;
                var controllers = PlaceObject();

                foreach (var controller in controllers)
                {
                    if (controller)
                    {
                        controller.StartPrinting();
                    }
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
                var mr = mesh.GetComponentsInChildren<Renderer>();

                for (int j = 0; j < mr.Length; j++)
                {
                    mr[j].enabled = true;
                }

                for (int i = 0; i < tempMeshes.Count; i++)
                {
                    if (i != currentObjectIndex)
                    {
                        var meshRenderers = tempMeshes[i].GetComponentsInChildren<Renderer>();
                        for (int j = 0; j < meshRenderers.Length; j++)
                        {
                            meshRenderers[j].enabled = false;
                        }
                    }
                }

                if (mesh)
                {
                    var slicers = mesh.GetComponentsInChildren<MeshSlicer>();
                    mesh.transform.position = rayHitPos;
                    float lowestY = 10000;
                    foreach (var slicer in slicers)
                    {
                        if (slicer)
                        {
                            slicer.ActivateOutlineHologramShader();
                            slicer.slicingPlane.ResetPlanePosition(false);
                            if (slicer.slicingPlane.transform.position.y <= lowestY)
                            {
                                lowestY = slicer.slicingPlane.transform.position.y;
                            }
                        }
                    }

                    if (Input.GetKey(KeyCode.E))
                    {
                        mesh.transform.Rotate(Vector3.up, -rotationSpeed * Time.deltaTime, Space.World);
                    }

                    if (Input.GetKey(KeyCode.Q))
                    {
                        mesh.transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime, Space.World);
                    }

                    var length = Mathf.Abs(mouseRayHit.transform.position.y - lowestY);

                    mesh.transform.position = new Vector3(rayHitPos.x, rayHitPos.y + length, rayHitPos.z);

                    foreach (var m in mesh.GetComponentsInChildren<Renderer>())
                    {
                        m.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    }
                }
            }
        }          
    }

    public List<PrintingController> PlaceObject()
    {
        List<PrintingController> controllers = new List<PrintingController>();

        if (tempMeshes.Count > 0)
        {
            var mesh = Instantiate<GameObject>(tempMeshes[currentObjectIndex].gameObject);
            mesh.name = tempMeshes[currentObjectIndex].gameObject.name;

            var slicers = mesh.GetComponentsInChildren<MeshSlicer>();

            foreach (var slicer in slicers)
            {
                slicer.ActivatePrintingShader();

                slicer.slicingPlane = null;
            }

            var tempRends = tempMeshes[currentObjectIndex].GetComponentsInChildren<Renderer>();
            var meshRenderers = mesh.GetComponentsInChildren<Renderer>();
            for (int i = 0; i < tempRends.Length; i++)
            {
                var newMat = new Material(tempRends[i].sharedMaterials[0]);
                for (int j = 0; j < tempRends[i].sharedMaterials.Length; j++)
                {
                    meshRenderers[i].materials[j] = newMat;
                }
            }
          
            meshes.Add(mesh);

            UpdateMeshes();

            for (int i = 0; i < tempRends.Length; i++)
            {
                tempRends[i].enabled = false;
            }

            foreach (var slicer in slicers)
            {
                var controller = slicer.slicingPlane.GetComponent<PrintingController>();
                if (controller)
                {
                    controllers.Add(controller);
                }
            }
        }

        placeObject = false;

        return controllers;
    }

    public void UpdateAllMeshes()
    {
        UpdateTempMeshes();
        UpdateMeshes();
    }

    public void UpdateTempMeshes()
    {
        tempMeshes = new List<GameObject>();

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
            tempMeshes.Add(mesh);
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
            var renderers = mesh.GetComponentsInChildren<Renderer>();
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            if (meshSlicers.Length == 0 || meshSlicers.Length != renderers.Length)
            {
                for (int i = 0; i < renderers.Length; i++)
                {
                    if (renderers[i].GetComponent<MeshSlicer>() == null)
                    {
                        renderers[i].gameObject.AddComponent<MeshSlicer>();
                    }
                }
            }

            meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            foreach (var meshSlicer in meshSlicers)
            {
                if (meshSlicer.slicingPlane == null)
                {
                    var slicingPlane = AddSlicingPlane(true);

                    if (slicingPlane)
                    {
                        meshSlicer.slicingPlane = slicingPlane;
                        slicingPlane.meshToSlice = meshSlicer.gameObject;
                        slicingPlane.root = mesh;
                        slicingPlane.name = mesh.name + "_Plane";
                    }
                }
            }

            foreach (var ren in renderers)
            {
                ren.enabled = false;
            }
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
            var renderers = mesh.GetComponentsInChildren<Renderer>();
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            if (meshSlicers.Length == 0 || meshSlicers.Length != renderers.Length)
            {
                for (int i = 0; i < renderers.Length; i++)
                {
                    if (renderers[i].GetComponent<MeshSlicer>() == null)
                    {
                        renderers[i].gameObject.AddComponent<MeshSlicer>();
                    }
                }
            }

            meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            foreach (var meshSlicer in meshSlicers)
            {
                if (meshSlicer.slicingPlane == null)
                {
                    var slicingPlane = AddSlicingPlane(false);

                    if (slicingPlane)
                    {
                        meshSlicer.slicingPlane = slicingPlane;
                        slicingPlane.meshToSlice = meshSlicer.gameObject;
                        slicingPlane.root = mesh;
                    }
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
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();
            foreach (var meshSlicer in meshSlicers)
            {
                ResetSlicingPlanePosition(meshSlicer, toTop);
            }
        }

        foreach (var mesh in meshes)
        {
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();
            foreach (var meshSlicer in meshSlicers)
            {
                ResetSlicingPlanePosition(meshSlicer, toTop);
            }
        }
    }

    public void ResetAllSlicingPlanesSize()
    {
        foreach (var mesh in tempMeshes)
        {
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            foreach (var meshSlicer in meshSlicers)
            {
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

        foreach (var mesh in meshes)
        {
            var meshSlicers = mesh.GetComponentsInChildren<MeshSlicer>();

            foreach (var meshSlicer in meshSlicers)
            {
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
}
