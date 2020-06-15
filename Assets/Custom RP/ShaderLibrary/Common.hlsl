#ifndef CUSTOM_COMMON_INCLUDED
#define CUSTOM_COMMON_INCLUDED


#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "UnityInput.hlsl"


#define UNITY_MATRIX_M unity_ObjectToWorld  //模型空间到世界空间
#define UNITY_MATRIX_I_M unity_WorldToObject  //世界空间到模型空间
#define UNITY_MATRIX_V unity_MatrixV  //世界空间到观察空间
#define UNITY_MATRIX_VP unity_MatrixVP   //世界空间到裁剪空间
#define UNITY_MATRIX_P glstate_matrix_projection


#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"  //实例化

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

//=====================
/*
float3 TransformObjectToWorld (float3 positionOS) {  //模型空间到世界空间
    return mul(unity_ObjectToWorld, float4(positionOS, 1.0)).xyz;
}
    
float4 TransformWorldToHClip (float3 positionWS) {   //世界空间到裁剪空间
    return mul(unity_MatrixVP, float4(positionWS, 1.0));
}

float3 TransformWorldToView(float3 positionWS)   //世界空间到观察空间
{
    return mul(unity_MatrixV, float4(positionWS, 1.0)).xyz;
}


float4 TransformObjectToHClip(float3 positionOS)   //模型空间到裁剪空间
{
    // More efficient than computing M*VP matrix product
    return mul(unity_MatrixVP, mul(unity_ObjectToWorld, float4(positionOS, 1.0)));
}
*/
//=====================
//以上方法也包含在：#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"




float Square (float v) {
    return v * v;  //平方
}







#endif


