using System;
using UnityEngine;

[ExecuteInEditMode]
public class RoadTracker : MonoBehaviour
{
    [SerializeField]
    private Material trackerMaterial;
    
    private void Update()
    {
        if (trackerMaterial != null)
        {
            trackerMaterial.SetVector("_TrackerPosition", transform.position);
        }
    }
}
