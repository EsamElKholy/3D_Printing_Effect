using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffect : MonoBehaviour
{
    public Shader outlineShader;
    public Shader simpleShader;
    public string outlineLayerName;

    private Camera attachedCamera;
    private Camera tempCamera;

    private Material outlineMaterial;
    
    // Start is called before the first frame update
    void Start()
    {
        attachedCamera = GetComponent<Camera>();

        if (attachedCamera.transform.childCount == 0 || (attachedCamera.transform.GetChild(0).GetComponent<Camera>() == null))
        {
            tempCamera = new GameObject().AddComponent<Camera>();
            tempCamera.transform.SetParent(transform);
            tempCamera.name = "Outline Camera";
            tempCamera.enabled = false;
        }

        outlineMaterial = new Material(outlineShader);
    }    

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (tempCamera && attachedCamera)
        {
            tempCamera.CopyFrom(attachedCamera);
            tempCamera.clearFlags = CameraClearFlags.Color;
            tempCamera.backgroundColor = Color.black;

            tempCamera.cullingMask = 1 << LayerMask.NameToLayer(outlineLayerName);

            RenderTexture tempRT = new RenderTexture(source.width, source.height, 0, RenderTextureFormat.Default);

            tempRT.Create();

            tempCamera.targetTexture = tempRT;

            outlineMaterial.SetTexture("_SceneTex", source);

            tempCamera.RenderWithShader(simpleShader, "");

            Graphics.Blit(tempRT, destination, outlineMaterial);

            tempRT.Release();
        }
    }
}
