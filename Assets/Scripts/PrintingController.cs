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
    private string initialLayer;

    // Start is called before the first frame update
    void Start()
    {
        slicingPlane = GetComponent<SlicingPlane>();
        initialLayer = LayerMask.LayerToName(slicingPlane.meshToSlice.gameObject.layer);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyUp(KeyCode.Space))
        {
            StartPrinting();
        }

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
        }
    }   

    public void StartPrinting()
    {
        counter = 0;

        startedPrinting = true;

        slicingPlane.ResetPlanePosition(false);
        initialPosition = slicingPlane.transform.position;

        slicingPlane.ResetPlanePosition(true);
        targetPosition = slicingPlane.transform.position;

        slicingPlane.ResetPlanePosition(false);
    }

    public void UpdatePrinter()
    {
        Vector3 newPos = Vector3.Lerp(initialPosition, targetPosition, counter / printTime);
        transform.position = newPos;
        slicingPlane.UpdateEquation();
        counter += Time.deltaTime;
    }
}
