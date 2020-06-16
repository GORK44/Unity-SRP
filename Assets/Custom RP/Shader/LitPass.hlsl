#ifndef CUSTOM_LIT_PASS_INCLUDED
#define CUSTOM_LIT_PASS_INCLUDED


//#include "../ShaderLibrary/Common.hlsl" // Lit.shader 中已经包含
//#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/GI.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"






//lightMap
#if defined(LIGHTMAP_ON)
    #define GI_ATTRIBUTE_DATA float2 lightMapUV : TEXCOORD1;
    #define GI_VARYINGS_DATA float2 lightMapUV : VAR_LIGHT_MAP_UV;
    #define TRANSFER_GI_DATA(input, output) output.lightMapUV = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    #define GI_FRAGMENT_DATA(input) input.lightMapUV
#else
    #define GI_ATTRIBUTE_DATA
    #define GI_VARYINGS_DATA
    #define TRANSFER_GI_DATA(input, output)
    #define GI_FRAGMENT_DATA(input) 0.0
#endif





struct Attributes {     //用作vs的输入
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;  
    GI_ATTRIBUTE_DATA           //GI
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings {   //用作vs的输出，fs的输入
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float2 baseUV : VAR_BASE_UV;
    GI_VARYINGS_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


//顶点着色器
Varyings LitPassVertex (Attributes input) {

    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input); //设置实例化
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    TRANSFER_GI_DATA(input, output);
    
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz); //模型空间->世界空间
    output.positionCS = TransformWorldToHClip(output.positionWS); //世界空间->裁剪空间

    output.normalWS = TransformObjectToWorldNormal(input.normalOS); //世界空间法线

    //float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    //output.baseUV = input.baseUV * baseST.xy + baseST.zw;
    output.baseUV = TransformBaseUV(input.baseUV); // LitInput里
    
    return output;
    //return TransformObjectToHClip(input.positionOS.xyz); //模型空间->裁剪空间

}




//片元着色器
float4 LitPassFragment (Varyings input) : SV_TARGET {

    UNITY_SETUP_INSTANCE_ID(input);
    //float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    //float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
    //float4 base = baseMap * baseColor;
    float4 base = GetBase(input.baseUV);

    #if defined(_CLIPPING)  //透明裁剪
        clip(base.a - GetCutoff(input.baseUV));
    #endif
    
    //base.rgb = input.normalWS; //输出法线
    //base.rgb = normalize(input.normalWS);  //顶点法线插值后归一化


    Surface surface;  //表面属性：位置，法线，颜色，透明度，金属度，光滑度
    surface.position = input.positionWS;
    surface.normal = normalize(input.normalWS);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS); //视线向量
    surface.color = base.rgb;
    surface.alpha = base.a;
    surface.metallic = GetMetallic(input.baseUV);
    surface.smoothness = GetSmoothness(input.baseUV);
    surface.fresnelStrength = GetFresnel(input.baseUV);

    
    
    #if defined(_PREMULTIPLY_ALPHA)  //预乘切换
        BRDF brdf = GetBRDF(surface, true);
    #else
        BRDF brdf = GetBRDF(surface);
    #endif

    GI gi = GetGI(GI_FRAGMENT_DATA(input), surface, brdf);
    float3 color = GetLighting(surface, brdf, gi);

    return float4(color, surface.alpha);


    //return base;

}





#endif


