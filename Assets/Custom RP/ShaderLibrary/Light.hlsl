#ifndef CUSTOM_LIGHT_INCLUDED
#define CUSTOM_LIGHT_INCLUDED


#define MAX_DIRECTIONAL_LIGHT_COUNT 4  //最大直射光数

CBUFFER_START(_CustomLight)     //为了使场景中光源的数据可在着色器中访问
    int _DirectionalLightCount;
    float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END


struct Light {
    float3 color;
    float3 direction;
};

int GetDirectionalLightCount () {
    return _DirectionalLightCount;
}

Light GetDirectionalLight (int index) {
    Light light;
    light.color = _DirectionalLightColors[index].rgb;    //用rgba和xyzw是一样的
    light.direction = _DirectionalLightDirections[index].xyz;
    return light;
}

#endif


