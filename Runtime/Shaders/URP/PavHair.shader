Shader "PAV/URP/Hair"
{
    Properties
    {
        _ColorBase("Diffuse", Color) = (255, 255, 255, 1)
        _Spec("Specular", Range(0, 0.1)) = 0.01
//        _CustomVec_0("Gloss1 Gloss2 Shift1 Shift2", Vector) = (27, 24, 0, 0) // Gloss1 // Gloss2 // Shift1 // Shift2
//        _CustomVec_1("FresnelPow SpecularPow ", Vector) = (7, 5, 0, 0)
        _Gloss1 ("Gloss1", Float)= 27
        _Gloss2 ("Gloss2", Float)= 24
        _Shift1("Shift1", Float)= 0
        _Shift2 ("Shift2", Float)= 0
        _FresnelPow ("FresnelPow", Float)= 7
        _SpecularPow ("SpecularPow", Float)= 3
        _NoiseTex("NoiseTex" , 2D) = "white"{} // Noise map
        
        _SpecularAAScreenSpaceVariance("Specular AA Screen Space Variance", Range(0,1)) = 0.1
        _SpecularAAThreshold("Specular AA Threshold", Range(0,1)) = 0.2
        
        _BaseMap ("MainTex", 2D) = "white" {}
        _ColorRegionMap("ColorRegionMap", 2D) = "black" {}
        _UsingAlbedoHue("UsingAlbedoHue", Float) = 0
        _ColorRegion1("ColorRegion1", Vector) = (0,0,0,0) // (H,S,V,alpha) 0~1, 0~2, 0~2, 0~1
        _ColorRegion2("ColorRegion2", Vector) = (0,0,0,0) // (H,S,V,alpha) 0~1, 0~2, 0~2, 0~1
        _ColorRegion3("ColorRegion3", Vector) = (0,0,0,0) // (H,S,V,alpha) 0~1, 0~2, 0~2, 0~1
        _ColorRegion4("ColorRegion4", Vector) = (0,0,0,0) // (H,S,V,alpha) 0~1, 0~2, 0~2, 0~1

        // BlendMode
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("Src", Float) = 1.0
        [HideInInspector] _DstBlend("Dst", Float) = 0.0
        [HideInInspector] _ZWrite("ZWrite", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalRenderPipeline"
            "Queue" = "AlphaTest"
            "IgnoreProjector" = "True"
            "RenderType" = "TransparentCutout"
        }

        Blend[_SrcBlend][_DstBlend]
        ZWrite[_ZWrite]
        Cull[_Cull]

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM

            #pragma target 4.5
            // #pragma multi_compile _ PAV_VERTEX_FROM_BUFFER
            // #pragma multi_compile _ PAV_MERGED_TEXTURE

            #pragma vertex vert
            #pragma fragment frag

            #include "Universal/ShaderLibrary/Lighting.hlsl" 
            #include "Universal/ShaderLibrary/Core.hlsl"
            

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorBase;
            float _Spec;
            float _Gloss1 ;
            float _Gloss2 ;
            float _Shift1 ;
            float _Shift2 ;
            float _FresnelPow ;
            float _SpecularPow ;
            float _AdditiveGI;

            half4 _ColorRegion1;
			half4 _ColorRegion2;
			half4 _ColorRegion3;
			half4 _ColorRegion4;
            half _UsingAlbedoHue;
            half _ShaderType;
            half _SpecularAAScreenSpaceVariance;
            half _SpecularAAThreshold;
            float  _BaseColorAmplify;
            float4 _CustomVec_0;
            float4 _CustomVec_1;
            float4 _CustomVec_2;
            float4 _CustomVec_3;
            float4 _CustomVec_4;
            float4 _CustomVec_5;
            float4 _CustomVec_6;
            float4 _CustomVec_7;
            float4 _CustomVec_8;
            float  _MipBias;
            CBUFFER_END

            #include "Universal/ShaderLibrary/SurfaceInput.hlsl"

            TEXTURE2D(_NoiseTex);SAMPLER(sampler_NoiseTex);

            struct a2v
            {
                float4 vertex : POSITION; // Vertex data.
                float4 uv : TEXCOORD0; // UV data.
                float3 normal : NORMAL; // Normal data.
                float4 tangent : TANGENT; // Tangent data.
                PAV_VERTEX_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION; // Screen-space vertex position.
                float3 uv : TEXCOORD0; // UV0
                float4 posWS : TEXCOORD2; // World-space vertex position.
                float3 nDirWS : TEXCOORD3; // World-space normal direction.
                float3 tDirWS : TEXCOORD4; // World-space tangent direction.
                float3 bDirWS : TEXCOORD5; // World-space bitangent direction.
            };

            // Vertex shader.
            v2f vert(a2v v)
            {
                v2f o = (v2f) 0;

                PAV_GET_VERTEX_PNT(v.vid, v.vertex, v.normal, v.tangent);

                o.pos =  TransformObjectToHClip(v.vertex.xyz);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = TransformObjectToWorldNormal(v.normal); // Normal direction, OS to WS.
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // Tangent direction, OS to WS.
                // T is the hair-tip to hair-root direction, which corresponds to the bitangent.
                // The vertex tangent is perpendicular to that direction, so T is derived by crossing tangent and normal.
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS)); // * v.tangent.w // Bitangent direction, T parameter.
                o.uv.xy = v.uv.xy;
              //  PAV_GET_MATERIAL_INDEX(v.vid, o.uv.xyz);

                return o;
            }

            // T is the hair-tip to hair-root direction, which corresponds to bDirWS.
            // The vertex tangent is perpendicular to that direction, so T is derived by crossing tangent and normal.

            // Specular value.
            float StrandSpecular(float3 T, float3 vDir, float3 lDir, float exponent)
            {
                float3 hDir = normalize(vDir + lDir); 
                float dotTH = dot(T, hDir); 
                float sinTH = max(0.01, sqrt(1.0 - pow(dotTH, 2)));
                float dirAtten = smoothstep(-1, 0, dotTH);
                return dirAtten * pow(sinTH, exponent);
            }

            // Bitangent offset.
            float3 AShiftTangent(float3 T, float3 nDir, float shift)
            {
                float3 shiftedT = T + shift * nDir;
                return normalize(shiftedT);
            }

            // Fragment shader.
            float4 frag(v2f i) : SV_Target
            {
                PAV_FLIP_UV_Y(i.uv.xy);
                //PAV_GET_MATERIAL_DATA(i.uv.z);

                
                
                float2 uv = i.uv.xy;
                float4 baseMapColor = PAV_SAMPLE_ALBEDO_ALPHA(uv);
                //float4 noiseColor = PAV_SAMPLE_CUSTOM_MAP(uv, 0);
                float4 noiseColor = SAMPLE_TEXTURE2D(_NoiseTex,sampler_NoiseTex, uv);




                PAV_GET_SHADER_TYPE(shaderType);
            	PAV_GET_USING_ALBEDO_HUE(usingAlbedoHue);
			    PAV_GET_BASE_COLOR_MASK1(colorMask1);
			    PAV_GET_BASE_COLOR_MASK2(colorMask2);
			    PAV_GET_BASE_COLOR_MASK3(colorMask3);
			    PAV_GET_BASE_COLOR_MASK4(colorMask4);
                
  

               // float Alpha = baseMapColor.a;
               // clip(Alpha - 0.5); // Discard pixels when the value is below zero.

                // Get ambient light.
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 lDirWS = normalize(TransformObjectToWorldDir(_MainLightPosition.xyz));
                float3 vDirWS = normalize(GetCameraPositionWS() - i.posWS.xyz);

                float shift = noiseColor.r - 0.5;
                float shift1 = shift - _Shift1;
                float shift2 = shift - _Shift2;

                //Kajiya-Kay Shading
                float3 bDirWS1 = AShiftTangent(i.bDirWS, i.nDirWS, shift1); 
                float3 bDirWS2 = AShiftTangent(i.bDirWS, i.nDirWS, shift2);

                // Primary specular highlight.
                float S1 = StrandSpecular(bDirWS1, vDirWS, lDirWS, _Gloss1);
                // Secondary specular highlight.
                float S2 = StrandSpecular(bDirWS2, vDirWS, lDirWS, _Gloss2);

                Light mylight = GetMainLight();                                // Get the main scene light.
                float4 LightColor = real4(mylight.color,1);                     // Get the main light color.

                
                // specular = primary highlight + secondary highlight.
                float3 specular = LightColor.rgb * _Spec * (S1 + S2 * _ColorBase.rgb);
                specular *= _SpecularPow;

                // Lambert lighting.
               // float3 mintex = baseMapColor.rgb;
                float3 NdotL = dot(i.nDirWS, lDirWS);
                //float3 diffuse =  mintex * LightColor.rgb * _ColorBase.rgb *( (NdotL+1)*0.5); // saturate clamps values to 0~1.

                 float3 diffuse =  LightColor.rgb * baseMapColor *( NdotL*0.5 +0.5);
                //frensel
                float NdotV = saturate(dot(i.nDirWS, vDirWS));
                float frensel = 0.05* pow(1.0 - NdotV, _FresnelPow);
                
				half4 albedoMaskAlpha = PAV_SAMPLE_COLOR_REGIONS(uv);
                float3 SPcolor = diffuse + specular + frensel ;

               float3 color = _ColorBase ;

                 // Apply color replacement.
                
                half3 Color = ApplyAlbedo(SPcolor,color,shaderType,albedoMaskAlpha, colorMask1, colorMask2, colorMask3, colorMask4, usingAlbedoHue);
 
                
                return float4 (Color,1);
            }
            ENDHLSL
            
        }
             UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
     CustomEditor "Pico.Avatar.URPShaderInspector"
}
