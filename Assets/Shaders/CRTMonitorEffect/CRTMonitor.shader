Shader "Hidden/Shader/CRTMonitor"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }
    
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

    // List of properties to control your post process effect
    float _Intensity;
    float _PixelQuantity;
    float _Curve;
    TEXTURE2D_X(_InputTexture);

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        
        float2 currentUv = input.texcoord;
            
        currentUv = CurveUv(currentUv, _Curve);
        currentUv = PixelateUvNode(currentUv, _PixelQuantity, _PixelQuantity);
        
        uint2 crtPosition = currentUv * _ScreenSize.xy;
        float3 crtColor = LOAD_TEXTURE2D_X(_InputTexture, crtPosition).xyz;

        uint2 positionSS = input.texcoord * _ScreenSize.xy;
        float3 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;

        //return float4(outColor, 1);
        return float4(lerp(outColor, crtColor, _Intensity), 1);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "CRTMonitor"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
