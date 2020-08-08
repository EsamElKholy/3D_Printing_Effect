using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LerpAlpha : MonoBehaviour
{
    private Material printerMat;
    private Color hologramColor = Color.clear;
    private bool animate = false;
    private bool isAnimating = false;
    private float animationDuration = 2;
    private float animationCounter = 0;

    // Start is called before the first frame update
    void Start()
    {
        var renderer = GetComponent<Renderer>();

        if (renderer)
        {
            printerMat = renderer.sharedMaterial;

            if (printerMat)
            {
                hologramColor = printerMat.GetColor("_HologramColor");
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        //if (animate)
        //{
        //    isAnimating = true;
        //    animate = false;
        //}

        //if (isAnimating)
        //{
        //    AnimateColor();
        //}
    }

    private void SetColor(Color hologram)
    {
        if (printerMat)
        {
            printerMat.SetColor("_HologramColor", hologram);
        }
    }

    private void AnimateColor()
    {
        if (isAnimating)
        {           
            float hologramA = 0;

            var hologram = printerMat.GetColor("_HologramColor");
            
            {
                hologramA = Mathf.Lerp(0, hologramColor.a+.4f, animationCounter / animationDuration);
                hologram.a = hologramA;
            }     

            if (animationCounter >= animationDuration)
            {
                animationCounter -= Time.deltaTime;
            }
            else if (animationCounter >= 0)
            {
                animationCounter += Time.deltaTime;
            }

            SetColor(hologram);
        }
    }

    public void StartAnimation()
    {
        if (!isAnimating)
        {
            animate = true;
            //animationCounter = 0;
        }
    }

    public void StopAnimation()
    {
        animate = false;
        isAnimating = false;
       // animationCounter = 0;

        SetColor(hologramColor);
    }
}
