

//void main() {


    normal = perturbNormalArb(- vViewPosition, normal, vec2(dFdx(v_Displacement), dFdy(v_Displacement)), 1.0);

    //gl_FragColor = vec4(v_ObjectSpacePosition * 0.5 + 0.5, 1.0); // Normalize the coordinates to the [0, 1] range
      // Apply Mapping to the object coordinates
    vec3 mappedCoordinates = mapping(v_ObjectSpacePosition, vec3(0.0), vec3(1.0), vec3(0.0));

    // Apply Vector Curves to the mapped coordinates
   // vec2 curveX[4] = vec2[](vec2(0.0, 0.0), vec2(0.25, 0.25), vec2(0.5, 0.5), vec2(1.0, 1.0));
   // vec2 curveY[4] = vec2[](vec2(0.0, 0.0), vec2(0.25, 0.25), vec2(0.5, 0.5), vec2(1.0, 1.0));
   // vec2 curveZ[4] = vec2[](vec2(-0.6272, 0.0), vec2(-0.6272, 0.33), vec2(0.3375, 0.67), vec2(0.3375, 1.0));

    vec2 curveX[4] = vec2[](uCurvex1, uCurvex2, uCurvex3, uCurvex4);
    vec2 curveY[4] = vec2[](uCurvey1, uCurvey2, uCurvey3, uCurvey4);
    vec2 curveZ[4] = vec2[](uCurvez1, uCurvez2, uCurvez3, uCurvez4);

    vec3 curvedCoordinates = vectorCurves(mappedCoordinates, curveX, curveY, curveZ);

    // Get Distance from the Voronoi Texture using object coordinates as input
    //float distanceVoronoi1 = voronoiTexture(v_ObjectSpacePosition, 1.2, 1.0);

    float distanceVoronoi1 = voronoiTexture(v_ObjectSpacePosition, uVoronoiScale_1, uVoronoiRandomness_1);
    // mix the result of Vector Curves and Distance from Voronoi Texture using the Overlay function
    //vec3 mixOverlay1 = mixOverlay(curvedCoordinates, distanceVoronoi1, 0.85);

    vec3 mixOverlay1 = mixOverlay(curvedCoordinates, distanceVoronoi1, uFactor_1);

    // Get Distance from a second Voronoi Texture using object coordinates as input
    float distanceVoronoi2 = voronoiTexture(v_ObjectSpacePosition, uVoronoiScale_2, uVoronoiRandomness_2);

    // mix the result of the first Overlay function and Distance from the second Voronoi Texture using another Overlay function
    vec3 mixOverlay2 = mixOverlay(mixOverlay1, distanceVoronoi2, uFactor_2);

    // Get Color from the Noise Texture using object coordinates as input
    //vec3 colorNoise = noise_perlin(v_ObjectSpacePosition);

    float noiseValue = noisePerlin(v_ObjectSpacePosition);
    vec3 colorNoise = vec3(noiseValue, noiseValue, noiseValue);
    
    // Get Distance from a third Voronoi Texture using the Color from the Noise Texture as input
    //float distanceVoronoi3 = voronoiTexture(colorNoise, uVoronoiScale_3, uVoronoiRandomness_3);

    float distanceVoronoi3 = voronoiTexture(v_ObjectSpacePosition, uVoronoiScale_3, uVoronoiRandomness_3);

    // mix the result of the second Overlay function and Distance from the third Voronoi Texture using another Overlay function
    vec3 mixOverlay3 = mixOverlay(mixOverlay2, distanceVoronoi3, sin(uTime) * uFactor_3);

    // Get Color from the Gradient Texture using the result of the third Overlay function as input
    vec3 center = vec3(0.0, 0.0, 0.0);
    float radius = 1.0;
    vec3 innerColor = vec3(uGradientInnerR, uGradientInnerG, uGradientInnerB);
    vec3 outerColor = vec3(uGradientOuterR, uGradientOuterG, uGradientOuterB);

    vec3 gradientColor = sphericalGradientTexture(mixOverlay3, center, radius, innerColor, outerColor);

    // Apply the Color Ramp to the Gradient Texture's color output
    float luminance = dot(gradientColor, vec3(uRampLuminanceR, uRampLuminanceG, uRampLuminanceB));
    float position1 = uRampPos1;
    float position2 = uRampPos2;
    vec3 rampColor = colorRamp(luminance, gradientColor, position1, position2);
    
    // Approximate the Principled Volume using the Color Ramp's output
    Volume volume = createPrincipledVolume(rampColor, 1.0, 0.0);


//    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    
   //WEB GL 1.0
    //gl_FragColor = vec4(volume.color, 1.0);

//WEB GL 2.0

    //fragColor = vec4(volume.color, 1.0);

    //gl_FragColor = vec4(vec3(v_Displacement), 1.0);
//}