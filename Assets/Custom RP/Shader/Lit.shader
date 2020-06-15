Shader "Custom RP/Lit" {
    
    Properties {
        _BaseMap("Texture", 2D) = "white" {}
        _BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [Toggle(_CLIPPING)] _Clipping ("Alpha Clipping", Float) = 0 //透明裁剪，默认关
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1  //source 源 【枚举类型参数】
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0  //destination 目标
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1

        _Metallic ("Metallic", Range(0, 1)) = 0  //金属度
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5  //光滑度

        [Toggle(_PREMULTIPLY_ALPHA)] _PremulAlpha ("Premultiply Alpha", Float) = 0 //diffuse乘透明度
    }
    
    SubShader {
        
        Pass {
            
            Tags {
                "LightMode" = "CustomLit"
            }

            Blend [_SrcBlend] [_DstBlend] //透明混合模式
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma target 3.5 //避免为编译OpenGL ES 2.0
            #pragma shader_feature _CLIPPING  //裁剪
            #pragma shader_feature _PREMULTIPLY_ALPHA //预乘透明度（diffuse）
            #pragma multi_compile_instancing  //实例化
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #include "LitPass.hlsl"
            
            
            
            
            ENDHLSL
        }
    }

    CustomEditor "CustomShaderGUI"
}
