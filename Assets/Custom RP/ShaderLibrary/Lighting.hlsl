#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

//照明功能



float3 GetIncomingLight (Surface surface, Light light) {
    return saturate( dot(surface.normal, light.direction) ) * light.color;  //NdotL点积为负时，用saturate将其clamp为零
}


float3 GetLighting1 (Surface surfaceWS, BRDF brdf, Light light) {
    return GetIncomingLight(surfaceWS, light) * DirectBRDF(surfaceWS, brdf, light);
}


float3 GetLighting (Surface surfaceWS, BRDF brdf, GI gi) {
    
    //float3 color = gi.diffuse * brdf.diffuse;
    float3 color = IndirectBRDF(surfaceWS, brdf, gi.diffuse, gi.specular);

    
    for (int i = 0; i < GetDirectionalLightCount(); i++) {
        color += GetLighting1(surfaceWS, brdf, GetDirectionalLight(i));
    }
    
    return color;
}


#endif


