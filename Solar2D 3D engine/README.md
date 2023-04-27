# Q3D Engine
Back in December 2018 I started working on a 3D engine for Solar2D, or Corona SDK as it was named back then. I got a good chunk of this working but it's an incomplete, unoptimised project that I eventually shelved and in May 2022 I released this code for the first time via the Solar2D forums. Another year on, I'm now uploading here to give it a bit more exposure in case there's anybody out there who wants to bring 3D to Solar2D and has the time to continue where I left off.

This was being built as a Lua plugin, so all of the magic is within the plugin folder.
- /plugin/q3dengine.lua is basically an autoloader that pulls everything else from the q3dengine folder in and exposes their functions to the Solar2D project.
- /plugin/q3dengine/ contains a variety of files, each providing functionality as per their name. rendering.lua for example, provides the rendering related functions. These files are all well commented and should be intuitive to expand upon.
- /main.lua contains a sample Solar2D project using this engine. It's a tiny, self explanatory demo that should just run with no modification.

## Features
- Positioning, movement, and rotation of a single camera entity along X, Y, and Z axis.
- Positioning, movement, rotation, and scaling of any number of objects along X, Y, and Z axis.
- Ability to create 3D cubes with enough vertices and normals for reasonable quality per-face perspective texturing.
- Render loop, incorporating all the complex base mechanics of converting 3D geometry to 2D screen space.
- Crude lighting.
- Crude texturing.

## Further development
This is very very much a basic skeleton of an engine. There's a lot of work to do before it's ready for real use. These are just the few bits I'd suggest concentrating on first.
- Currently the engine only supports creating cubes. The addCube() code in objects.lua does this by mapping out the 3D geometry of a cube, and adding other shapes in should just be a case of adding additional functions here to map out the 3D geometry of other objects.
- The cubes were purposefully given more vertices than strictly necessary, because texturing needs these for more realistic perspective distortion. Given the performance implications of Solar2D running on a single thread, and the complexity of mapping out other shapes like this, I'd personally advise simplifying this geometry and removing the texturing support. Just flat colour faces and fewer polygons would be better as a Solar2D 3D engine I feel.
- My intention was to eventually build a function to import .obj files. This is a well documented plain text format and converting the geometry defined within a .obj file into a Q3D object geometry shouldn't be difficult. Basically just the same code as the addCube() function but parsing a file instead of using hard-coded data.
- Depth buffering is definitely needed. Basically, rather than rendering everything in one go, the individual faces should be rendered to a separate canvas and then each pixels z distance measured against an array representing the screen pixels. If that array contains a value, compare it with the new face pixel to see which is closer to the camera. If the new pixel is closer, update the array with the new z, otherwise clear that pixel in the new canvas. Once the whole canvas is tested, then copy it to screen space and move on to the next face. This should resolve intersecting face issues.

## Support
I'm an advocate of open source, FOSS, FSF, and such. Like all other scripts and tools within this repository, this code is provided for free in the hopes it's useful to somebody. If you found this helpful and want to show your support, donations are always greatly appreciated.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N1GXJ1U)
