    
    
    vec3 coords = normal;
    coords.y += uTime;
    vec3 noisePattern = vec3(noisePerlin(coords));
    float pattern = wave(noisePattern + uTime);

    //Varyings

    v_Position = position;
    v_Normal = normal;
    v_Uv = uv;
    v_Displacement = pattern;

    //MVP
    float displacement = v_Displacement / 3.0;

    transformed += normalize(objectNormal) * displacement;
