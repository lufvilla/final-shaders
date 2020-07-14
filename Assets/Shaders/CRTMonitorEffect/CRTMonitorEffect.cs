using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

[Serializable, VolumeComponentMenu("Custom/CRTMonitorEffect")]
public sealed class CRTMonitorEffect : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Range(0f, 2000f), Tooltip("Set screen resolution")]
    public FloatParameter pixelQuantity = new FloatParameter(256);
    
    [Range(0f, 1f), Tooltip("Set screen curvature")]
    public FloatParameter curve = new FloatParameter(0);
    
    private Material m_Material;
    
    public bool IsActive() => m_Material != null;
    
    public override void Setup()
    {
        if (Shader.Find("Custom/CRTMonitorEffect") != null)
            m_Material = new Material(Shader.Find("Custom/CRTMonitorEffect"));
    }
    
    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetTexture("_MainTex", source);
        m_Material.SetFloat("_PixelQuantity", pixelQuantity.value);
        m_Material.SetFloat("_Curve", curve.value);

        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }
    
    public override void Cleanup() => CoreUtils.Destroy(m_Material);
}