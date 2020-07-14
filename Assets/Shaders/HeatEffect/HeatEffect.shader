Shader "Hidden/Shader/HeatEffect"
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

    // List of properties to control your post process effect
    float _Intensity;
    sampler2D _NoiseTex;
    float _SpeedX;
    float _SpeedY;
    TEXTURE2D_X(_InputTexture);

    float4 CustomPostProcess(Varyings input) : SV_Target
    {        
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float2 panner = float2(input.texcoord.x + _Time.x * _SpeedX, input.texcoord.y + _Time.x * _SpeedY);
        float2 dispMap = tex2D(_NoiseTex, panner).rg * (_Intensity * 10);
    
        uint2 positionSS = input.texcoord * _ScreenSize.xy + ((dispMap * 1.5) - 1);
        float3 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;
        return float4(outColor, 1);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "HeatEffect"

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
