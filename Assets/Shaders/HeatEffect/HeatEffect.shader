Shader "Custom/HeatEffect"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        sampler2D _NoiseTex;
        float _Intensity;
        float _SpeedX;
        float _SpeedY;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float2 panner = float2(i.texcoord.x + _Time.x * _SpeedX, i.texcoord.y + _Time.x * _SpeedY);

            float2 disp = tex2D(_NoiseTex, panner).xy;
            disp = ((disp * 1.5) - 1) * _Intensity;
            
            return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + disp);
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