# Cloud Shader Research Summary

This research project focuses on the creation and manipulation of cloud shaders using a series of steps and techniques.

## Procedural Cloud Generation and Fragment Shader

1. **Procedural cloud generation in Blender**: The process began with creating a procedural cloud in Blender by following tutorials.
2. **Refactoring the node map into GLSL**: The node map of the resulting cloud in Blender was refactored into GLSL for real-time rendering using OpenGL. The refactored shader consists of Voronoi textures, mix overlays, and a color ramp.
3. **Visualizing the cloud with three.js**: The cloud was visualized inside a browser using three.js, a JavaScript wrapper for WebGL and OpenGL, due to its minimal rendering times and rapid visualization capabilities.
4. **Projecting the shader onto geometry**: The resulting fragment shader, which defines the appearance of the cloud, was projected onto a geometry within three.js.

## Exploring Vertex Shader Manipulation

After creating the cloud fragment shader, the next step involved exploring the manipulation of the **vertex shader**. A tutorial was followed to achieve this, resulting in a separate experimentation with vertex shader manipulation.

## Repository Structure

The repository contains two separate branches for the different shader experimentations:

- `fragment-cloud`: This branch contains the work related to the cloud fragment shader, including the procedural generation in Blender, refactoring into GLSL, and visualization with three.js.
- `vertex-cloud`: This branch focuses on the exploration and manipulation of the vertex shader following the tutorial.

By separating the fragment shader and vertex shader experimentations into different branches, the repository maintains a clear and organized structure for each aspect of the research project.

## Conclusions

Through this research, it has been determined that GLSL is a viable choice for creating non-compiled cloud shader files that could potentially be uploaded to a blockchain. However, it's also been noted that the learning curve for achieving visually appealing results with GLSL is quite steep.

Considering this, it is suggested to **hire a dedicated GLSL programmer** who could expedite the process without compromising on the visual quality of the cloud shaders.

The research also highlighted key differences between working with GLSL files directly in OpenGL and within the three.js framework. In three.js, the shader is 'injected' into the framework's internal structure. This solution, while functional, may not be sustainable or elegant. There's a risk that future updates to the three.js file structure could potentially break the functionality of the program.

In light of these considerations, it seems that a more robust and stable alternative would be to have separate GLSL files for the fragment shader and the vertex shader. These files could be fetched and rendered natively in OpenGL by a binary program written in openFrameworks. This approach would likely offer greater stability, circumventing the potential issues of shader injection in three.js.

## Repository Access and Usage

You can find the repository for this project at [https://github.com/acastles91/shaders-test](https://github.com/acastles91/shaders-test).

To clone the repository and start the three.js app, follow these steps:

\```bash
git clone https://github.com/acastles91/shaders-test.git
\```

\```bash
cd shaders-test
\```

\```bash
git checkout fragment-cloud
\```

OR

\```bash
git checkout vertex-cloud
\```

\```bash
npm install
\```

\```bash
npm run start
\```

After following these steps, the application should be running in your browser.

