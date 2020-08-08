using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrintingController : MonoBehaviour
{
    private SlicingPlane slicingPlane;

    private bool isPrinting;
    private bool startedPrinting;
    private bool finishedPrinting;
    private Vector3 targetPosition;
    private Vector3 initialPosition;
    private float printTime = 10;
    private float counter = 0;

    // Start is called before the first frame update
    void Start()
    {
        slicingPlane = GetComponent<SlicingPlane>();
    }

    // Update is called once per frame
    void Update()
    {
        if (startedPrinting)
        {
            isPrinting = true;
            UpdatePrinter();
        }

        if (isPrinting && counter >= printTime)
        {
            isPrinting = false;
            startedPrinting = false;
            counter = 0;
            slicingPlane.meshToSlice.GetComponent<Renderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            slicingPlane.GetComponent<Renderer>().enabled = false;
            slicingPlane.transform.Translate(0, 1, 0);
            slicingPlane.UpdateEquation();
        }
    }   

    public void StartPrinting()
    {
        if (slicingPlane == null)
        {
            slicingPlane = GetComponent<SlicingPlane>();
        }

        counter = 0;

        startedPrinting = true;

        slicingPlane.ResetPlanePosition(false);
        initialPosition = slicingPlane.transform.position;

        slicingPlane.ResetPlanePosition(true);
        targetPosition = slicingPlane.transform.position;

        slicingPlane.ResetPlanePosition(false);

        slicingPlane.GetComponent<Renderer>().enabled = true;
    }

    public void UpdatePrinter()
    {
        Vector3 newPos = Vector3.Lerp(initialPosition, targetPosition, counter / printTime);
        transform.position = newPos;
        slicingPlane.UpdateEquation();
        counter += Time.deltaTime;
    }
}
