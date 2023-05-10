# Cloud Shader Research Summary

This research project focuses on the creation and manipulation of shaders resembling using a series of steps and techniques.

## Procedural Cloud Generation and Fragment Shader

1. **Procedural cloud generation in Blender**: The process began with creating a cloud in Blender proceduraly by following tutorials.
2. **Refactoring the node map into GLSL**: The node map of the resulting cloud in Blender was refactored into GLSL for real-time rendering using OpenGL or WebGL. The refactored shader consists of Voronoi textures, mix overlays, and a color ramp.
3. **Visualizing the cloud with three.js**: The cloud was visualized inside a browser using three.js, a JavaScript wrapper for WebGL and OpenGL, due to its minimal rendering times and rapid visualization capabilities.The resulting fragment shader, which defines the appearance of the cloud, was projected onto a geometry created within three.js.
4. **Attempting to alter a volume with a fragment shader**: By following [this]('https://www.youtube.com/watch?v=oKbCaj1J6EI&t=244s') tutorial I tried to alter the geometry generated with three.js with the vertex shader.

## Exploring Vertex Shader Manipulation

After creating the cloud fragment shader, the next step involved exploring the manipulation of the **vertex shader**. The previously mentioned tutorial was followed to achieve this, resulting in a separate experimentation with vertex shader manipulation.

## Repository Structure

The repository contains two separate branches for the different shader experimentations:

- `fragment-cloud`: This branch contains the work related to the cloud fragment shader, including the procedural generation in Blender, refactoring into GLSL, and visualization with three.js.
- `vertex-cloud`: This branch focuses on the exploration and manipulation of the vertex shader following the tutorial.
[
By separating the fragment shader and vertex shader experimentations into different branches, the repository maintains a clear and organized structure for each aspect of the research project.

## Conclusions

I believe that GLSL is a viable choice for creating non-compiled cloud shader files that could potentially be uploaded to a blockchain. However, it's also clear that the learning curve for achieving visually appealing results with GLSL is quite steep.

I suggest to hire a dedicated GLSL programmer who could make the process easier without compromising on the visual quality of the clouds.

The research also highlighted key differences between working with GLSL files directly in OpenGL and within the three.js framework. In three.js, the shader is 'injected' into the framework's internal structure. This solution, while functional, may not be sustainable or elegant. There's a risk that future updates to the three.js file structure could potentially break the functionality of the program.

I think a more robust aternative would be to have separate GLSL files for the fragment shader and the vertex shader. These files could be fetched and rendered natively in OpenGL by a binary program written in openFrameworks. This approach would likely offer greater stability, circumventing the potential issues of shader injection in three.js.

## Repository Access and Usage

You can find the repository for this project at [https://github.com/acastles91/shaders-test](https://github.com/acastles91/shaders-test).

To clone the repository and start the three.js app, follow these steps:

```bash
# Clone the repository:
git clone https://github.com/acastles91/shaders-test.git

# Change into the cloned directory:
cd shaders-test

# Choose the desired branch:

# For the fragment cloud shader:
git checkout fragment-cloud

# For the vertex cloud shader:
git checkout vertex-cloud

# Install the required dependencies:
npm install

# Start the three.js app:
npm run start

