#ifndef CUSTOM_UNLIT_PASS_INCLUDED
#define CUSTOM_UNLIT_PASS_INCLUDED


#include "../ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"


//批处理用
/*
cbuffer UnityPerMaterial {
    float4 _BaseColor;
}
*/

//实例化
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)



struct Attributes {     //用作vs的输入
    float3 positionOS : POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings {   //用作vs的输出，fs的输入
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


//顶点着色器
Varyings UnlitPassVertex (Attributes input) {

    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input); //设置实例化
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz); //模型空间->世界空间
    output.positionCS = TransformWorldToHClip(positionWS); //世界空间->裁剪空间
    
    return output;
    //return TransformObjectToHClip(input.positionOS.xyz); //模型空间->裁剪空间

}




//片元着色器
float4 UnlitPassFragment (Varyings input) : SV_TARGET {

    UNITY_SETUP_INSTANCE_ID(input);
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);

}





#endif


