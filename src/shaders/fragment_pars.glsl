
//Light

//use mediump float;
precision mediump float;

uniform vec3 lightPosition;
uniform vec3 lightColor;
uniform float uTime;

varying vec4 fragColor;

varying float v_Displacement;




//In GLSL, you can't create a 'Texture Coordinate' function exactly like the one in Blender, 
//since it's an environment-specific concept. However, 
//you can replicate the functionality using attributes and varying variables 
//to pass the necessary data from the vertex shader to the fragment shader.
//
//To mimic the 'Object' output of the 'Texture Coordinate' node, you can pass object 
//space coordinates from the vertex shader to the fragment shader.

//WEBGL 1.0
//varying vec3 v_ObjectSpacePosition;

//WEBGL 2.0
varying vec3 v_ObjectSpacePosition;

//Now, you can use v_ObjectSpacePosition in your fragment shader 
//as the equivalent of the 'Object' output from the 'Texture Coordinate' 
//node in Blender. This will give you the object space position for each fragment,
//which you can then use as input for other functions in your GLSL shader.


//Bump Funciton



vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {

	vec3 vSigmaX = dFdx( surf_pos.xyz );
	vec3 vSigmaY = dFdy( surf_pos.xyz );
	vec3 vN = surf_norm; // normalized

	vec3 R1 = cross( vSigmaY, vN );
	vec3 R2 = cross( vN, vSigmaX );

	float fDet = dot( vSigmaX, R1 ) * faceDirection;

	vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
	return normalize( abs( fDet ) * surf_norm - vGrad );

}
//Random function

float random(vec3 seed) {
    return fract(sin(dot(seed, vec3(12.9898, 78.233, 54.53))) * 43758.5453);
}

// Implement your custom functions based on the Blender node setup
// ...
//Mapping: Consisting of rotation, translation and scale




mat4 rotationMatrix(vec3 angles) {
    float sX = sin(angles.x);
    float cX = cos(angles.x);
    float sY = sin(angles.y);
    float cY = cos(angles.y);
    float sZ = sin(angles.z);
    float cZ = cos(angles.z);

    mat4 rotationX = mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, cX, -sX, 0.0),
        vec4(0.0, sX, cX, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    mat4 rotationY = mat4(
        vec4(cY, 0.0, sY, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(-sY, 0.0, cY, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    mat4 rotationZ = mat4(
        vec4(cZ, -sZ, 0.0, 0.0),
        vec4(sZ, cZ, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    return rotationZ * rotationY * rotationX;
}

mat4 translationMatrix(vec3 translation) {
    return mat4(
        vec4(1.0, 0.0, 0.0, translation.x),
        vec4(0.0, 1.0, 0.0, translation.y),
        vec4(0.0, 0.0, 1.0, translation.z),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 scaleMatrix(vec3 scale) {
    return mat4(
        vec4(scale.x, 0.0, 0.0, 0.0),
        vec4(0.0, scale.y, 0.0, 0.0),
        vec4(0.0, 0.0, scale.z, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

vec3 mapping(vec3 coord, vec3 translation, vec3 rotation, vec3 scale) {
    // Create the transformation matrix
    mat4 transformMatrix = scaleMatrix(scale) * rotationMatrix(rotation) * translationMatrix(translation);

    // Apply the transformation to the input coordinates
    vec4 transformedCoord = transformMatrix * vec4(coord, 1.0);

    return transformedCoord.xyz;
}

//Here's a quick recap of each function:
//
//    rotationMatrix: Computes sine and cosine values for the input Euler angles, creates separate rotation matrices for each axis (x, y, z), and combines them by multiplying the matrices together.
//    translationMatrix: Creates a translation matrix by placing the input translation values directly into the matrix as the last column.
//    scaleMatrix: Creates a scale matrix by placing the input scale values along the main diagonal of the matrix.
//___________________________________________________________________________-

//Vector Curves::

// Interpolate between two points using a cubic Bezier curve
float cubicBezier(float t, float p0, float p1, float p2, float p3) {
    float oneMinusT = 1.0 - t;
    return pow(oneMinusT, 3.0) * p0 +
           3.0 * pow(oneMinusT, 2.0) * t * p1 +
           3.0 * oneMinusT * pow(t, 2.0) * p2 +
           pow(t, 3.0) * p3;
}

//vec3 vectorCurves(vec3 coord, vec2[4] curveR, vec2[4] curveG, vec2[4] curveB) {
//    vec3 result;
//
//    // Calculate the interpolated value for each component using cubicBezier function
//    result.x = cubicBezier(coord.x, curveR[0].x, curveR[1].x, curveR[2].x, curveR[3].x);
//    result.y = cubicBezier(coord.y, curveG[0].x, curveG[1].x, curveG[2].x, curveG[3].x);
//    result.z = cubicBezier(coord.z, curveB[0].x, curveB[1].x, curveB[2].x, curveB[3].x);
//
//    return result;
//}

vec3 vectorCurves(vec3 coord, vec2 curveX[4], vec2 curveY[4], vec2 curveZ[4]) {
  vec3 result= coord;

  float t;
  // X curve
  if (coord.x < curveX[1].x) {
    t = coord.x / curveX[1].x;
    result.x = curveX[0].y * (1.0 - t) + curveX[1].y * t;
  } else {
    t = (coord.x - curveX[1].x) / (curveX[2].x - curveX[1].x);
    result.x = curveX[1].y * (1.0 - t) + curveX[2].y * t;
  }

  // Y curve
  if (coord.y < curveY[1].x) {
    t = coord.y / curveY[1].x;
    result.y = curveY[0].y * (1.0 - t) + curveY[1].y * t;
  } else {
    t = (coord.y - curveY[1].x) / (curveY[2].x - curveY[1].x);
    result.y = curveY[1].y * (1.0 - t) + curveY[2].y * t;
  }

  // Z curve
  if (coord.z < curveZ[1].x) {
    t = coord.z / curveZ[1].x;
    result.z = curveZ[0].y * (1.0 - t) + curveZ[1].y * t;
  } else {
    t = (coord.z - curveZ[1].x) / (curveZ[2].x - curveZ[1].x);
    result.z = curveZ[1].y * (1.0 - t) + curveZ[2].y * t;
  }

  return result;
}

//A cubic Bezier curve is defined by 4 control points: P0, P1, P2, and P3.
//Each vec2 element in the array represents one of these control points.
//In the vectorCurves() function, we pass these arrays of control points as arguments,
//and the function calculates the interpolated value for each component (R, G, B) using the cubicBezier() function.
//
//___________________________________________________________________________-

// mix Overlay:

//vec3 mixOverlay(vec3 baseColor, vec3 blendColor, float factor) {
//    vec3 result;
//
//    for (int i = 0; i < 3; ++i) {
//        if (baseColor[i] < 0.5) {
//            result[i] = 2.0 * baseColor[i] * blendColor[i];
//        } else {
//            result[i] = 1.0 - 2.0 * (1.0 - baseColor[i]) * (1.0 - blendColor[i]);
//        }
//    }
//
//    // Linearly interpolate between the base color and the result based on the mix factor
//    return mix(baseColor, result, factor);
//}

vec3 mixOverlay(vec3 baseColor, float blendValue, float factor) {
    vec3 result;

    for (int i = 0; i < 3; ++i) {
        if (baseColor[i] < 0.5) {
            result[i] = 2.0 * baseColor[i] * blendValue;
        } else {
            result[i] = 1.0 - 2.0 * (1.0 - baseColor[i]) * (1.0 - blendValue);
        }
    }

    // Linearly interpolate between the base color and the result based on the mix factor
    return mix(baseColor, result, factor);
}
//The function iterates over the three color channels (R, G, B) of the baseColor and blendColor vectors.
//For each channel, it checks if the base color's value is less than 0.5.
//If it is, it applies the Multiply blend mode by multiplying the base color's value by the blend color's value and multiplying the result by 2.
//If the base color's value is 0.5 or higher, it applies the Screen blend mode by inverting both colors, multiplying them, doubling the result, and then inverting the result back.
//
//After calculating the resulting color for each channel, the function uses the built-in mix() function to linearly interpolate between the original base color and the blended color based on the mix factor. 
//This interpolation allows for smooth transitions between the original and blended colors.

//___________________________________________________________________________-
// Voronoi Texture:

float voronoiTexture(vec3 coord, float scale, float randomness) {
    vec3 cell = floor(coord * scale);
    float dist = 1e30;
    
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            for (int z = -1; z <= 1; z++) {
                vec3 neighbor = cell + vec3(x, y, z);
                vec3 randomOffset = vec3(random(neighbor), random(neighbor + 0.3), random(neighbor + 0.6));
                vec3 point = (neighbor + mix(randomOffset, randomOffset * randomness, 0.5)) / scale;
                //vec3 point = (neighbor + mix(randomOffset, randomness, 0.5)) / scale;
                dist = min(dist, distance(coord, point));
            }
        }
    }
    return dist;
}

//This function takes three input arguments:
//
//    coord: The input coordinate, usually a 3D position.
//    scale: Controls the scale of the Voronoi pattern.
//    randomness: Controls the randomness of the Voronoi cell points.
//
//The function calculates the Voronoi cell the input coordinate belongs to and iterates over the neighboring cells.
// For each neighboring cell, it calculates a random offset and the Voronoi point position based on the randomness parameter.
// It then calculates the distance between the input coordinate and the Voronoi point and updates the minimum distance found so far.
//
//Finally, the function returns the minimum distance, which can be used as the output of the Voronoi Texture node.

//___________________________________________________________________________-


//Perlin Noise:

//#pragma BLENDER_REQUIRE(gpu_shader_common_hash.glsl)

/* ***** Jenkins Lookup3 Hash Functions ***** */

/* Source: http://burtleburtle.net/bob/c/lookup3.c */

#define rot(x, k) (((x) << (k)) | ((x) >> (32 - (k))))

#define mix(a, b, c) \
  { \
    a -= c; \
    a ^= rot(c, 4); \
    c += b; \
    b -= a; \
    b ^= rot(a, 6); \
    a += c; \
    c -= b; \
    c ^= rot(b, 8); \
    b += a; \
    a -= c; \
    a ^= rot(c, 16); \
    c += b; \
    b -= a; \
    b ^= rot(a, 19); \
    a += c; \
    c -= b; \
    c ^= rot(b, 4); \
    b += a; \
  }

#define final(a, b, c) \
  { \
    c ^= b; \
    c -= rot(b, 14); \
    a ^= c; \
    a -= rot(c, 11); \
    b ^= a; \
    b -= rot(a, 25); \
    c ^= b; \
    c -= rot(b, 16); \
    a ^= c; \
    a -= rot(c, 4); \
    b ^= a; \
    b -= rot(a, 14); \
    c ^= b; \
    c -= rot(b, 24); \
  }

uint hash_uint(uint kx)
{
  uint a, b, c;
  a = b = c = 0xdeadbeefu + (1u << 2u) + 13u;

  a += kx;
  final(a, b, c);

  return c;
}

uint hash_uint2(uint kx, uint ky)
{
  uint a, b, c;
  a = b = c = 0xdeadbeefu + (2u << 2u) + 13u;

  b += ky;
  a += kx;
  final(a, b, c);

  return c;
}

uint hash_uint3(uint kx, uint ky, uint kz)
{
  uint a, b, c;
  a = b = c = 0xdeadbeefu + (3u << 2u) + 13u;

  c += kz;
  b += ky;
  a += kx;
  final(a, b, c);

  return c;
}

uint hash_uint4(uint kx, uint ky, uint kz, uint kw)
{
  uint a, b, c;
  a = b = c = 0xdeadbeefu + (4u << 2u) + 13u;

  a += kx;
  b += ky;
  c += kz;
  mix(a, b, c);

  a += kw;
  final(a, b, c);

  return c;
}

#undef rot
#undef final
#undef mix

uint hash_int(int kx)
{
  return hash_uint(uint(kx));
}

uint hash_int2(int kx, int ky)
{
  return hash_uint2(uint(kx), uint(ky));
}

uint hash_int3(int kx, int ky, int kz)
{
  return hash_uint3(uint(kx), uint(ky), uint(kz));
}

uint hash_int4(int kx, int ky, int kz, int kw)
{
  return hash_uint4(uint(kx), uint(ky), uint(kz), uint(kw));
}

/* Hashing uint or uint[234] into a float in the range [0, 1]. */

float hash_uint_to_float(uint kx)
{
  return float(hash_uint(kx)) / float(0xFFFFFFFFu);
}

float hash_uint2_to_float(uint kx, uint ky)
{
  return float(hash_uint2(kx, ky)) / float(0xFFFFFFFFu);
}

float hash_uint3_to_float(uint kx, uint ky, uint kz)
{
  return float(hash_uint3(kx, ky, kz)) / float(0xFFFFFFFFu);
}

float hash_uint4_to_float(uint kx, uint ky, uint kz, uint kw)
{
  return float(hash_uint4(kx, ky, kz, kw)) / float(0xFFFFFFFFu);
}

/* Hashing float or vec[234] into a float in the range [0, 1]. */

float hash_float_to_float(float k)
{
  return hash_uint_to_float(floatBitsToUint(k));
}

float hash_vec2_to_float(vec2 k)
{
  return hash_uint2_to_float(floatBitsToUint(k.x), floatBitsToUint(k.y));
}

float hash_vec3_to_float(vec3 k)
{
  return hash_uint3_to_float(floatBitsToUint(k.x), floatBitsToUint(k.y), floatBitsToUint(k.z));
}

float hash_vec4_to_float(vec4 k)
{
  return hash_uint4_to_float(
      floatBitsToUint(k.x), floatBitsToUint(k.y), floatBitsToUint(k.z), floatBitsToUint(k.w));
}

/* Hashing vec[234] into vec[234] of components in the range [0, 1]. */

vec2 hash_vec2_to_vec2(vec2 k)
{
  return vec2(hash_vec2_to_float(k), hash_vec3_to_float(vec3(k, 1.0)));
}

vec3 hash_vec3_to_vec3(vec3 k)
{
  return vec3(
      hash_vec3_to_float(k), hash_vec4_to_float(vec4(k, 1.0)), hash_vec4_to_float(vec4(k, 2.0)));
}

vec4 hash_vec4_to_vec4(vec4 k)
{
  return vec4(hash_vec4_to_float(k.xyzw),
              hash_vec4_to_float(k.wxyz),
              hash_vec4_to_float(k.zwxy),
              hash_vec4_to_float(k.yzwx));
}

/* Hashing float or vec[234] into vec3 of components in range [0, 1]. */

vec3 hash_float_to_vec3(float k)
{
  return vec3(
      hash_float_to_float(k), hash_vec2_to_float(vec2(k, 1.0)), hash_vec2_to_float(vec2(k, 2.0)));
}

vec3 hash_vec2_to_vec3(vec2 k)
{
  return vec3(
      hash_vec2_to_float(k), hash_vec3_to_float(vec3(k, 1.0)), hash_vec3_to_float(vec3(k, 2.0)));
}

vec3 hash_vec4_to_vec3(vec4 k)
{
  return vec3(hash_vec4_to_float(k.xyzw), hash_vec4_to_float(k.zxwy), hash_vec4_to_float(k.wzyx));
}

/* Other Hash Functions */

float integer_noise(int n)
{
  /* Integer bit-shifts for these calculations can cause precision problems on macOS.
   * Using uint resolves these issues. */
  uint nn;
  nn = (uint(n) + 1013u) & 0x7fffffffu;
  nn = (nn >> 13u) ^ nn;
  nn = (uint(nn * (nn * nn * 60493u + 19990303u)) + 1376312589u) & 0x7fffffffu;
  return 0.5 * (float(nn) / 1073741824.0);
}

float wang_hash_noise(uint s)
{
  s = (s ^ 61u) ^ (s >> 16u);
  s *= 9u;
  s = s ^ (s >> 4u);
  s *= 0x27d4eb2du;
  s = s ^ (s >> 15u);

  return fract(float(s) / 4294967296.0);
}

/* clang-format off */
#define FLOORFRAC(x, x_int, x_fract) { float x_floor = floor(x); x_int = int(x_floor); x_fract = x - x_floor;}
/* clang-format on */

/* Bilinear Interpolation:
 *
 * v2          v3
 *  @ + + + + @       y
 *  +         +       ^
 *  +         +       |
 *  +         +       |
 *  @ + + + + @       @------> x
 * v0          v1
 */
float bi_mix(float v0, float v1, float v2, float v3, float x, float y)
{
  float x1 = 1.0 - x;
  return (1.0 - y) * (v0 * x1 + v1 * x) + y * (v2 * x1 + v3 * x);
}

/* Trilinear Interpolation:
 *
 *   v6               v7
 *     @ + + + + + + @
 *     +\            +\
 *     + \           + \
 *     +  \          +  \
 *     +   \ v4      +   \ v5
 *     +    @ + + + +++ + @          z
 *     +    +        +    +      y   ^
 *  v2 @ + +++ + + + @ v3 +       \  |
 *      \   +         \   +        \ |
 *       \  +          \  +         \|
 *        \ +           \ +          +---------> x
 *         \+            \+
 *          @ + + + + + + @
 *        v0               v1
 */
float tri_mix(float v0,
              float v1,
              float v2,
              float v3,
              float v4,
              float v5,
              float v6,
              float v7,
              float x,
              float y,
              float z)
{
  float x1 = 1.0 - x;
  float y1 = 1.0 - y;
  float z1 = 1.0 - z;
  return z1 * (y1 * (v0 * x1 + v1 * x) + y * (v2 * x1 + v3 * x)) +
         z * (y1 * (v4 * x1 + v5 * x) + y * (v6 * x1 + v7 * x));
}

float quad_mix(float v0,
               float v1,
               float v2,
               float v3,
               float v4,
               float v5,
               float v6,
               float v7,
               float v8,
               float v9,
               float v10,
               float v11,
               float v12,
               float v13,
               float v14,
               float v15,
               float x,
               float y,
               float z,
               float w)
{
  return mix(tri_mix(v0, v1, v2, v3, v4, v5, v6, v7, x, y, z),
             tri_mix(v8, v9, v10, v11, v12, v13, v14, v15, x, y, z),
             w);
}

float fade(float t)
{
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float negate_if(float value, uint condition)
{
  return (condition != 0u) ? -value : value;
}

float noise_grad(uint hash, float x)
{
  uint h = hash & 15u;
  //float g = 1.0 + float(h & 7u);
  float g = 1.0 + float(h & 7u);
  //float g = 1u + (h & 7u);
  return negate_if(g, h & 8u) * x;
}

float noise_grad(uint hash, float x, float y)
{
  uint h = hash & 7u;
  float u = h < 4u ? x : y;
  float v = 2.0 * (h < 4u ? y : x);
  return negate_if(u, h & 1u) + negate_if(v, h & 2u);
}

float noise_grad(uint hash, float x, float y, float z)
{
  uint h = hash & 15u;
  float u = h < 8u ? x : y;
  float vt = ((h == 12u) || (h == 14u)) ? x : z;
  float v = h < 4u ? y : vt;
  return negate_if(u, h & 1u) + negate_if(v, h & 2u);
}

float noise_grad(uint hash, float x, float y, float z, float w)
{
  uint h = hash & 31u;
  float u = h < 24u ? x : y;
  float v = h < 16u ? y : z;
  float s = h < 8u ? z : w;
  return negate_if(u, h & 1u) + negate_if(v, h & 2u) + negate_if(s, h & 4u);
}

float noise_perlin(float x)
{
  int X;
  float fx;

  FLOORFRAC(x, X, fx);

  float u = fade(fx);

  float r = mix(noise_grad(hash_int(X), fx), noise_grad(hash_int(X + 1), fx - 1.0), u);

  return r;
}

float noise_perlin(vec2 vec)
{
  int X, Y;
  float fx, fy;

  FLOORFRAC(vec.x, X, fx);
  FLOORFRAC(vec.y, Y, fy);

  float u = fade(fx);
  float v = fade(fy);

  float r = bi_mix(noise_grad(hash_int2(X, Y), fx, fy),
                   noise_grad(hash_int2(X + 1, Y), fx - 1.0, fy),
                   noise_grad(hash_int2(X, Y + 1), fx, fy - 1.0),
                   noise_grad(hash_int2(X + 1, Y + 1), fx - 1.0, fy - 1.0),
                   u,
                   v);

  return r;
}

float noise_perlin(vec3 vec)
{
  int X, Y, Z;
  float fx, fy, fz;

  FLOORFRAC(vec.x, X, fx);
  FLOORFRAC(vec.y, Y, fy);
  FLOORFRAC(vec.z, Z, fz);

  float u = fade(fx);
  float v = fade(fy);
  float w = fade(fz);

//  float r = tri_mix(noise_grad(hash_int3(X, Y, Z), fx, fy, fz),
//                    noise_grad(hash_int3(X + 1, Y, Z), fx - 1, fy, fz),
//                    noise_grad(hash_int3(X, Y + 1, Z), fx, fy - 1, fz),
//                    noise_grad(hash_int3(X + 1, Y + 1, Z), fx - 1, fy - 1, fz),
//                    noise_grad(hash_int3(X, Y, Z + 1), fx, fy, fz - 1),
//                    noise_grad(hash_int3(X + 1, Y, Z + 1), fx - 1, fy, fz - 1),
//                    noise_grad(hash_int3(X, Y + 1, Z + 1), fx, fy - 1, fz - 1),
//                    noise_grad(hash_int3(X + 1, Y + 1, Z + 1), fx - 1, fy - 1, fz - 1),
//                    u,
//                    v,
//                    w);
float r = tri_mix(noise_grad(hash_int3(X, Y, Z), fx, fy, fz),
                  noise_grad(hash_int3(X + 1, Y, Z), fx - 1.0, fy, fz),
                  noise_grad(hash_int3(X, Y + 1, Z), fx, fy - 1.0, fz),
                  noise_grad(hash_int3(X + 1, Y + 1, Z), fx - 1.0, fy - 1.0, fz),
                  noise_grad(hash_int3(X, Y, Z + 1), fx, fy, fz - 1.0),
                  noise_grad(hash_int3(X + 1, Y, Z + 1), fx - 1.0, fy, fz - 1.0),
                  noise_grad(hash_int3(X, Y + 1, Z + 1), fx, fy - 1.0, fz - 1.0),
                  noise_grad(hash_int3(X + 1, Y + 1, Z + 1), fx - 1.0, fy - 1.0, fz - 1.0),
                  u,
                  v,
                  w);
  return r;
}

float noise_perlin(vec4 vec)
{
  int X, Y, Z, W;
  float fx, fy, fz, fw;

  FLOORFRAC(vec.x, X, fx);
  FLOORFRAC(vec.y, Y, fy);
  FLOORFRAC(vec.z, Z, fz);
  FLOORFRAC(vec.w, W, fw);

  float u = fade(fx);
  float v = fade(fy);
  float t = fade(fz);
  float s = fade(fw);

  float r = quad_mix(
      noise_grad(hash_int4(X, Y, Z, W), fx, fy, fz, fw),
      noise_grad(hash_int4(X + 1, Y, Z, W), fx - 1.0, fy, fz, fw),
      noise_grad(hash_int4(X, Y + 1, Z, W), fx, fy - 1.0, fz, fw),
      noise_grad(hash_int4(X + 1, Y + 1, Z, W), fx - 1.0, fy - 1.0, fz, fw),
      noise_grad(hash_int4(X, Y, Z + 1, W), fx, fy, fz - 1.0, fw),
      noise_grad(hash_int4(X + 1, Y, Z + 1, W), fx - 1.0, fy, fz - 1.0, fw),
      noise_grad(hash_int4(X, Y + 1, Z + 1, W), fx, fy - 1.0, fz - 1.0, fw),
      noise_grad(hash_int4(X + 1, Y + 1, Z + 1, W), fx - 1.0, fy - 1.0, fz - 1.0, fw),
      noise_grad(hash_int4(X, Y, Z, W + 1), fx, fy, fz, fw - 1.0),
      noise_grad(hash_int4(X + 1, Y, Z, W + 1), fx - 1.0, fy, fz, fw - 1.0),
      noise_grad(hash_int4(X, Y + 1, Z, W + 1), fx, fy - 1.0, fz, fw - 1.0),
      noise_grad(hash_int4(X + 1, Y + 1, Z, W + 1), fx - 1.0, fy - 1.0, fz, fw - 1.0),
      noise_grad(hash_int4(X, Y, Z + 1, W + 1), fx, fy, fz - 1.0, fw - 1.0),
      noise_grad(hash_int4(X + 1, Y, Z + 1, W + 1), fx - 1.0, fy, fz - 1.0, fw - 1.0),
      noise_grad(hash_int4(X, Y + 1, Z + 1, W + 1), fx, fy - 1.0, fz - 1.0, fw - 1.0),
      noise_grad(hash_int4(X + 1, Y + 1, Z + 1, W + 1), fx - 1.0, fy - 1.0, fz - 1.0, fw - 1.0),
      u,
      v,
      t,
      s);

  return r;
}

/* Remap the output of noise to a predictable range [-1, 1].
 * The scale values were computed experimentally by the OSL developers.
 */
float noise_scale1(float result)
{
  return 0.2500 * result;
}

float noise_scale2(float result)
{
  return 0.6616 * result;
}

float noise_scale3(float result)
{
  return 0.9820 * result;
}

float noise_scale4(float result)
{
  return 0.8344 * result;
}

/* Safe Signed And Unsigned Noise */

float snoise(float p)
{
  float r = noise_perlin(p);
  return (isinf(r)) ? 0.0 : noise_scale1(r);
}

float noise(float p)
{
  return 0.5 * snoise(p) + 0.5;
}

float snoise(vec2 p)
{
  float r = noise_perlin(p);
  return (isinf(r)) ? 0.0 : noise_scale2(r);
}

float noise(vec2 p)
{
  return 0.5 * snoise(p) + 0.5;
}

float snoise(vec3 p)
{
  float r = noise_perlin(p);
  return (isinf(r)) ? 0.0 : noise_scale3(r);
}

float noise(vec3 p)
{
  return 0.5 * snoise(p) + 0.5;
}

float snoise(vec4 p)
{
  float r = noise_perlin(p);
  return (isinf(r)) ? 0.0 : noise_scale4(r);
}

float noise(vec4 p)
{
  return 0.5 * snoise(p) + 0.5;
}

// Noise from youtube tutorial 

//	Classic Perlin 3D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float noisePerlin(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

//___________________________________________________________________________-


// Gradient Texture



vec3 sphericalGradientTexture(vec3 position, vec3 center, float radius, vec3 innerColor, vec3 outerColor) {
    float distanceToCenter = distance(position, center);
    float normalizedDistance = clamp(distanceToCenter / radius, 0.0, 1.0);
    return mix(innerColor, outerColor, normalizedDistance);
}

// This function takes the position at which you want to sample the gradient, the center of the sphere, the radius of the sphere,
// and the inner and outer colors. It calculates the distance from the position to the center and normalizes it by dividing it by the radius.
// Then, it uses the mix function to interpolate between the inner and outer colors based on the normalized distance.
//___________________________________________________________________________-

// Color Ramp 

//vec3 colorRamp(float value, vec3 color0, vec3 color1, vec3 color2, float position1, float position2) {
    //vec3 outputColor;

    //if (value <= position1) {
        //outputColor = mix(color0, color1, value / position1);
    //} else if (value <= position2) {
        //outputColor = mix(color1, color2, (value - position1) / (position2 - position1));
    //} else {
        //outputColor = color2;
    //}

    //return outputColor;
//}
vec3 colorRamp(float value, vec3 inputColor, float position1, float position2) {
    vec3 outputColor;

    if (value <= position1) {
        outputColor = mix(vec3(0.0), inputColor, value / position1);
    } else if (value <= position2) {
        outputColor = mix(inputColor, vec3(1.0), (value - position1) / (position2 - position1));
    } else {
        outputColor = vec3(1.0);
    }

    return outputColor;
}
//This function takes an input value, three colors (color0, color1, and color2), and two positions (position1 and position2) as arguments.
// It then uses the mix function to interpolate between the colors based on the input value.
//___________________________________________________________________________

struct Volume {
    vec3 color;
    float density;
    float anisotropy;
};

Volume createPrincipledVolume(vec3 color, float density, float anisotropy) {
    Volume volume;
    volume.color = color;
    volume.density = density;
    volume.anisotropy = anisotropy;
    return volume;
}

uniform float uTestUniform;

uniform vec2 uCurvex1;
uniform vec2 uCurvex2;
uniform vec2 uCurvex3;
uniform vec2 uCurvex4;

uniform vec2 uCurvey1;
uniform vec2 uCurvey2;
uniform vec2 uCurvey3;
uniform vec2 uCurvey4;

uniform vec2 uCurvez1;
uniform vec2 uCurvez2;
uniform vec2 uCurvez3;
uniform vec2 uCurvez4;

uniform float uVoronoiScale_1;
uniform float uVoronoiScale_2;
uniform float uVoronoiScale_3;

uniform float uVoronoiRandomness_1;
uniform float uVoronoiRandomness_2;
uniform float uVoronoiRandomness_3;

uniform float uFactor_1;
uniform float uFactor_2;
uniform float uFactor_3;

uniform float uGradientOuterR;
uniform float uGradientInnerR;

uniform float uGradientOuterG;
uniform float uGradientInnerG;

uniform float uGradientOuterB;
uniform float uGradientInnerB;

uniform float uRampLuminanceR;
uniform float uRampLuminanceG;
uniform float uRampLuminanceB;

uniform float uRampPos1;
uniform float uRampPos2;

