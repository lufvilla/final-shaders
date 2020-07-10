using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
 
[Serializable]
[PostProcess(typeof(CRTMonitorEffectRenderer), PostProcessEvent.AfterStack, "Custom/CRTMonitorEffect")]
public sealed class CRTMonitorEffect : PostProcessEffectSettings
{
    [Range(0f, 2000f), Tooltip("Set screen resolution")]
    public FloatParameter pixelQuantity = new FloatParameter { value = 256 };
    
    [Range(0f, 1f), Tooltip("Set screen curvature")]
    public FloatParameter curve = new FloatParameter { value = 0 };
}
 
public sealed class CRTMonitorEffectRenderer : PostProcessEffectRenderer<CRTMonitorEffect>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/CRTMonitorEffect"));
        sheet.properties.SetFloat("_PixelQuantity", settings.pixelQuantity);
        sheet.properties.SetFloat("_Curve", settings.curve);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}