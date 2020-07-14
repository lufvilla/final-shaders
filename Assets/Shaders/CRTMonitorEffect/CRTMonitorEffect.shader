Shader "Custom/CRTMonitorEffect"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float _PixelQuantity;
        float _Curve;
        
        float2 PixelateUvNode(float2 uv, float pixelsX, float pixelsY)
        {
            float2 newUv = uv;
            newUv.x *= pixelsX;
            newUv.y *= pixelsY;
            
            newUv.x = round(newUv.x);
            newUv.y = round(newUv.y);
            
            newUv.x /= pixelsY;
            newUv.y /= pixelsX;
            
            return newUv;
        }
        
        float2 CurveUv(float2 uv, float curve)
        {
            float2 newUv = uv;
            
            newUv = (newUv - 0.5) * 2;
            
            newUv.x *= curve + 1.0 + pow(abs(newUv.y) / 4.0, 2);
            newUv.y *= curve + 1.0 + pow(abs(newUv.x) / 3.5, 2);
            
            newUv /= curve + 1.2;
            
            newUv = (newUv / 2.0) + 0.5;
            
            return newUv;
        }

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float2 currentUv = i.texcoord;
            
            currentUv = CurveUv(currentUv, _Curve);
            
            currentUv = PixelateUvNode(currentUv, _PixelQuantity, _PixelQuantity);
            
            // Intenté implementar las "scanlines" del monitor y no pude.
            
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, currentUv);
            return color;
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}