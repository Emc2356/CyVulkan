# Vulkan with C++ and Cython

tutorial: <https://vulkan-tutorial.com/>

to clone the repository  
```console
git clone https://github.com/Emc2356/CyVulkan/ --recursive
```

# Compilation
- GLFW is already present for Windows in [here](./Dependencies/WIN). 
- GLM is already present [here](./Dependencies/GLOBAL/glm) but if you wish to use your own version place it in the same path
- 

compilation on Windows:
- visual studio
- download VulkanSDK from lunarg <https://vulkan.lunarg.com/sdk/home> for your platform, after installation go to the directory that the SDK lives in the Bin subdirectory and run `vkcube.exe`, if the installation was successful then it should run
- run `python BuildVulkanCython.py -h` to see the flags and chose what flags you want (if you are running it for the first time `-cs` flags is recommended):
  - -a, it gives the annotations of the cython file and then builds the extension 
  - -CyDep, it makes all the pxd files from C headers
  - -r, it runs the generated .pyd file
  - -cs, no it isn't C#, it will compile the glsl shaders to SPIR-V
