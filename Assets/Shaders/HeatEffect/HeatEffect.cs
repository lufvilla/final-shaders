using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

[Serializable, VolumeComponentMenu("Custom/HeatEffect")]
public sealed class HeatEffect : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Range(0f, 0.5f), Tooltip("Set heat intensity")]
    public FloatParameter intensity = new FloatParameter(0);
    
    [Tooltip("Set noise texture")]
    public TextureParameter noise = new TextureParameter(null);

    [Range(-10f, 10f), Tooltip("Set X scroll Speed")]
    public FloatParameter speedX = new FloatParameter(0);

    [Range(-10f, 10f), Tooltip("Set Y scroll Speed")]
    public FloatParameter speedY = new FloatParameter(0);
    
    
    private Material m_Material;
    
    public bool IsActive() => m_Material != null;
    
    public override void Setup()
    {
        if (Shader.Find("Custom/HeatEffect") != null)
            m_Material = new Material(Shader.Find("Custom/HeatEffect"));
    }
    
    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetTexture("_MainTex", source);
        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_NoiseTex", noise.value);
        m_Material.SetFloat("_SpeedX", speedX.value);
        m_Material.SetFloat("_SpeedY", speedY.value);

        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }
    
    public override void Cleanup() => CoreUtils.Destroy(m_Material);
}