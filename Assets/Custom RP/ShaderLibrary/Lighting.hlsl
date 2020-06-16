﻿#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

//照明功能



float3 GetIncomingLight (Surface surface, Light light) {
    return saturate( dot(surface.normal, light.direction) ) * light.color;  //NdotL点积为负时，用saturate将其clamp为零
}


float3 GetLighting (Surface surface, BRDF brdf, Light light) {
    return GetIncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}


float3 GetLighting (Surface surface, BRDF brdf, GI gi) {
    
    //float3 color = 0.0;
    float3 color = gi.diffuse;
    
    for (int i = 0; i < GetDirectionalLightCount(); i++) {
        color += GetLighting(surface, brdf, GetDirectionalLight(i));
    }
    
    return color;
}


#endif


