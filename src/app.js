import * as THREE from 'three'
import { addPass, useCamera, useGui, useRenderSize, useScene, useTick } from './render/init.js'
// import postprocessing passes
import { SavePass } from 'three/examples/jsm/postprocessing/SavePass.js'
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'
import { BlendShader } from 'three/examples/jsm/shaders/BlendShader.js'
import { CopyShader } from 'three/examples/jsm/shaders/CopyShader.js'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'

import vertexPars from './shaders/vertex_pars.glsl'
import vertexMain from './shaders/vertex_main.glsl'

import fragmentPars from './shaders/fragment_pars.glsl'
import fragmentMain from './shaders/fragment_main.glsl'

//import vertexShader from './shaders/cloud-vert.glsl'
//import fragmentShader from './shaders/cloud-frag.glsl'

import vertexShader from './shaders/alternative-cloud-vert.glsl'
import fragmentShader from './shaders/alternative-cloud-frag.glsl'

const startApp = () => {
  console.log('Starting app...')
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('webgl2');
  const renderer = new THREE.WebGLRenderer({ canvas: canvas, context: context });
  
  const scene = useScene()
  const camera = useCamera()
  const gui = useGui()
  const { width, height } = useRenderSize()

  camera.lookAt(scene.position)
  // settings
//  const MOTION_BLUR_AMOUNT = 0.725
  const MOTION_BLUR_AMOUNT = 0

  // lighting

  const dirLight = new THREE.DirectionalLight('#526cff', 0.6)
  dirLight.position.set(5, 5, 5)

  const ambientLight = new THREE.AmbientLight('#4255ff', 1)

  //const ambientLight = new THREE.AmbientLight(0xffffff, 10);
  scene.add(dirLight, ambientLight)
  //scene.add(ambientLight)
//scene.add(dirLight)
  // Uniforms
  const myUniforms = {
    uTestUniform: { value: 0.0 },
  }

  const curvesUniforms = {
    uCurvex1 : { value: new THREE.Vector2(0.0, 0.0) },
    uCurvex2 : { value: new THREE.Vector2(0.25, 0.25) },
    uCurvex3 : { value: new THREE.Vector2(0.5, 0.5) },
    uCurvex4 : { value: new THREE.Vector2(1.0, 1.0) },
    
    uCurvey1 : { value: new THREE.Vector2(0.0, 0.0) },
    uCurvey2 : { value: new THREE.Vector2(0.25, 0.25) },
    uCurvey3 : { value: new THREE.Vector2(0.5, 0.5) },
    uCurvey4 : { value: new THREE.Vector2(1.0, 1.0) },
    
    uCurvez1 : { value: new THREE.Vector2(-0.6272, 0.0) },
    uCurvez2 : { value: new THREE.Vector2(-0.6272, 0.33) },
    uCurvez3 : { value: new THREE.Vector2(0.3375, 0.67) },
    uCurvez4 : { value: new THREE.Vector2(0.3375, 1.0) },

  }


  // first Voronoi uniforms

  const uVoronoi1 = {
    uVoronoiScale_1 : { value: -1.2},
    uVoronoiRandomness_1 : { value: 0.75}
  }

  // First mix overlay

  const uMixOverlay1 = {
    uFactor_1: { value: 0.66},
  }
  // Second Voronoi uniforms

  const uVoronoi2 = {
    uVoronoiScale_2 : { value: 3.2},
    uVoronoiRandomness_2 : { value: 1.0}
  }

  // Second mix overlay

  const uMixOverlay2 = {
    uFactor_2: { value: 0.35},
  }

  // Third Voronoi uniforms

  const uVoronoi3 = {
    uVoronoiScale_3 : { value: -1.0},
    uVoronoiRandomness_3 : { value: 0.332}
  }

  // Third mix overlay

  const uMixOverlay3 = {
    uFactor_3: { value: 0.1},
  }


  //Gradient texture color

  const uGradientInnerColor = {
    uGradientInnerR : { value: 1.0},
    uGradientInnerG : { value: 0.764},
    uGradientInnerB : { value: 0.62},
  }
  const uGradientOuterColor= {
    uGradientOuterR : { value: 0.320},
    uGradientOuterG : { value: 0.332},
    uGradientOuterB : { value: 0.150},
  }

// Color ramp
//Luminance

  const uColorRamp= {
    uRampLuminanceR : { value: 0.299},
    uRampLuminanceG : { value: 0.587},
    uRampLuminanceB : { value: 0.114},
    uRampPos1 : { value: 0.3},
    uRampPos2 : { value: 0.7},
  }


  // meshes

  const geometry = new THREE.BoxGeometry(5, 5, 1)

  const geometry2 = new THREE.IcosahedronGeometry(5, 100)
  console.log(geometry.attributes)
  
//  const material = new THREE.ShaderMaterial({
//    vertexShader: alternativeVertexShader,
//    fragmentShader: alternativeFragmentShader,
//  })
  
//  const material = new THREE.RawShaderMaterial({
//    glslVersion : THREE.GLSL3,
//    vertexShader: vertexShader,
//    fragmentShader: fragmentShader,
//    uniforms: { ...curvesUniforms,
//                ...myUniforms, 
//                ...uVoronoi1, 
//                ...uMixOverlay1, 
//                ...uVoronoi2, 
//                ...uMixOverlay2, 
//                ...uVoronoi3, 
//                ...uMixOverlay3, 
//                ...uGradientInnerColor, 
//                ...uGradientOuterColor, 
//                ...uColorRamp }
//  })
  
   const material = new THREE.MeshStandardMaterial ({
     onBeforeCompile: (shader) => { 
       //shader.vertexShader = vertexShader
       //shader.fragmentShader = fragmentShader


       const parsVertexString = /* glsl*/ '#include <displacementmap_pars_vertex>'
       shader.vertexShader = shader.vertexShader.replace(parsVertexString, 
         parsVertexString + vertexPars)
       
       const mainVertexString = /* glsl*/ '#include <displacementmap_vertex>'
       shader.vertexShader = shader.vertexShader.replace(mainVertexString,
         mainVertexString + vertexMain)

       console.log(shader.vertexShader)

       const parsFragmentString = /* glsl*/ '#include <bumpmap_pars_fragment>'
       shader.fragmentShader = shader.fragmentShader.replace(parsFragmentString,
         parsFragmentString + fragmentPars)

       const mainFragmentString = /* glsl*/ '#include <normal_fragment_maps>'
       shader.fragmentShader = shader.fragmentShader.replace(mainFragmentString,
         mainFragmentString + fragmentMain)


       console.log(shader.fragmentShader)
       material.userData.shader = shader
       
       shader.uniforms.uTime = { value: 0.0 }
     }
 
 })

 //material2.uniforms.uTime = { value: 0.0 }
//const boxMesh = new THREE.Mesh(geometry, material)
  //const ico = new THREE.Mesh(geometry2, material2)
 // const ico2 = new THREE.Mesh(geometry2, material3)
  
  //scene.add(boxMesh)

  const ico = new THREE.Mesh(geometry2, material)
  scene.add(ico)




  // GUI
  const cameraFolder = gui.addFolder('Camera')
  cameraFolder.add(camera.position, 'z', 0, 60)
  camera.position.z = 15
  cameraFolder.open()

  const cloudFolder = gui.addFolder('Cloud')
  const curvesSubFolder = cloudFolder.addFolder('Curves')

  const FirstVoronoiSubFolder = cloudFolder.addFolder('First Voronoi')
  const FirstMixSubfolder = cloudFolder.addFolder('First Mix')

  const SecondVoronoiSubFolder = cloudFolder.addFolder('Second Voronoi')
  const SecondMixSubFolder = cloudFolder.addFolder('Second Mix')

  const ThirdVoronoiSubFolder = cloudFolder.addFolder('Third Voronoi')
  const ThirdMixSubFolder = cloudFolder.addFolder('Third Mix')

  const GradientSubFolder = cloudFolder.addFolder('Gradient')
  const ColorRampSubFolder = cloudFolder.addFolder('Color Ramp')
  
 // curvesSubFolder.add(curvesUniforms.uCurvex1.value, 'x',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvex2.value, 'y',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvex3.value, 'x',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvex4.value, 'y',  -1.0, 1.0)

 // curvesSubFolder.add(curvesUniforms.uCurvey1.value, 'x',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvey2.value, 'y',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvey3.value, 'x',  -1.0, 1.0)
 // curvesSubFolder.add(curvesUniforms.uCurvey4.value, 'y',  -1.0, 1.0)

 // curvesSubFolder.add(curvesUniforms.uCurvez1.value, 'x',  -1.0, 1.0)
  curvesSubFolder.add(curvesUniforms.uCurvez2.value, 'y',  -1.0, 1.0)
  curvesSubFolder.add(curvesUniforms.uCurvez3.value, 'x',  0, 1.0)
 //curvesSubFolder.add(curvesUniforms.uCurvez4.value, 'y',  -1.0, 1.0)
  
  FirstVoronoiSubFolder.add(uVoronoi1.uVoronoiScale_1, 'value', -1.0, 1.0).name('Scale')
  FirstVoronoiSubFolder.add(uVoronoi1.uVoronoiRandomness_1, 'value', 0.0, 1.0).name('Randomness')

  FirstMixSubfolder.add(uMixOverlay1.uFactor_1, 'value', 0.0, 1.0).name('Factor')

  SecondVoronoiSubFolder.add(uVoronoi2.uVoronoiScale_2, 'value', -4.0, 4.0).name('Scale')
  SecondVoronoiSubFolder.add(uVoronoi2.uVoronoiRandomness_2, 'value', 0.0, 1.0).name('Randomness')

  SecondMixSubFolder.add(uMixOverlay2.uFactor_2, 'value', 0.0, 1.0).name('Factor')
  
  ThirdVoronoiSubFolder.add(uVoronoi3.uVoronoiScale_3, 'value', -1.0, 1.0).name('Scale')
  ThirdVoronoiSubFolder.add(uVoronoi3.uVoronoiRandomness_3, 'value', 0.0, 1.0).name('Randomness')

  ThirdMixSubFolder.add(uMixOverlay3.uFactor_3, 'value', 0.0, 1.0).name('Factor')

  GradientSubFolder.add(uGradientOuterColor.uGradientOuterR, 'value', 0.0, 1.0)
  GradientSubFolder.add(uGradientOuterColor.uGradientOuterG, 'value', 0.0, 1.0)
  GradientSubFolder.add(uGradientOuterColor.uGradientOuterB, 'value', 0.0, 1.0)
  GradientSubFolder.add(uGradientInnerColor.uGradientInnerR, 'value', 0.0, 1.0)
  GradientSubFolder.add(uGradientInnerColor.uGradientInnerG, 'value', 0.0, 1.0)
  GradientSubFolder.add(uGradientInnerColor.uGradientInnerB, 'value', 0.0, 1.0)

  ColorRampSubFolder.add(uColorRamp.uRampPos1, 'value', 0.0, 1.0)
  ColorRampSubFolder.add(uColorRamp.uRampPos2, 'value', 0.0, 1.0)
  ColorRampSubFolder.add(uColorRamp.uRampLuminanceR, 'value', 0.0, 1.0)
  ColorRampSubFolder.add(uColorRamp.uRampLuminanceG, 'value', 0.0, 1.0)
  ColorRampSubFolder.add(uColorRamp.uRampLuminanceB, 'value', 0.0, 1.0)
  
  cloudFolder.add(myUniforms.uTestUniform, 'value', 0.0, 1.0)
  cloudFolder.open()

  // postprocessing
  const renderTargetParameters = {
    minFilter: THREE.LinearFilter,
    magFilter: THREE.LinearFilter,
    stencilBuffer: false,
  }

  // save pass
  const savePass = new SavePass(new THREE.WebGLRenderTarget(width, height, renderTargetParameters))

  // blend pass
  const blendPass = new ShaderPass(BlendShader, 'tDiffuse1')
  blendPass.uniforms['tDiffuse2'].value = savePass.renderTarget.texture
  blendPass.uniforms['mixRatio'].value = MOTION_BLUR_AMOUNT

  // output pass
  const outputPass = new ShaderPass(CopyShader)
  outputPass.renderToScreen = true

  // adding passes to composer
  //addPass(blendPass)
  //addPass(savePass)
  //addPass(outputPass)

  //Postprocessing

  //addPass(new UnrealBloomPass(new THREE.Vector2(width, height), 0.7, 0.4, 0.4))

  useTick(({ timestamp, timeDiff }) => {
    //console.log('Updating frame...')
    const time = timestamp / 10000
    //material2.uniforms.uTime.value = time

    
    material.userData.shader.uniforms.uTime.value = time
    console.log(material.userData.shader.vertexShader)
//    Object.assign(
//    material.uniforms,
//    curvesUniforms,
//    myUniforms,
//    uVoronoi1,
//    uMixOverlay1,
//    uVoronoi2,
//    uMixOverlay2,
//    uVoronoi3,
//    uMixOverlay3,
//    uGradientInnerColor,
//    uGradientOuterColor,
//    uColorRamp
//  );

    // Update uniforms with the values from the GUI
  // material.uniforms.uCurvex1.value.copy(curvesUniforms.uCurvex1.value);
  // material.uniforms.uCurvex2.value.copy(curvesUniforms.uCurvex2.value);
  // material.uniforms.uCurvex3.value.copy(curvesUniforms.uCurvex3.value);
  // material.uniforms.uCurvex4.value.copy(curvesUniforms.uCurvex4.value);

  // material.uniforms.uCurvey1.value.copy(curvesUniforms.uCurvey1.value);
  // material.uniforms.uCurvey2.value.copy(curvesUniforms.uCurvey2.value);
  // material.uniforms.uCurvey3.value.copy(curvesUniforms.uCurvey3.value);
  // material.uniforms.uCurvey4.value.copy(curvesUniforms.uCurvey4.value);

  // material.uniforms.uCurvez1.value.copy(curvesUniforms.uCurvez1.value);
  // material.uniforms.uCurvez2.value.copy(curvesUniforms.uCurvez2.value);
  // material.uniforms.uCurvez3.value.copy(curvesUniforms.uCurvez3.value);
  // material.uniforms.uCurvez4.value.copy(curvesUniforms.uCurvez4.value);


  })
}

export default startApp
