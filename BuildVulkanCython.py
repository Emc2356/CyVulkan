import ctypes

from typing import List

import subprocess
from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np

import shlex
from pathlib import Path
import platform
import shutil
import sys
import os
import ctypes

includes: List[str] = [".", np.get_include()]

libraries: List[str] = []
library_dirs = []

language = "c++"

define_macros = []
undef_macros = []
extra_compile_args: List[str] = []

vulkan_sdk_path: str

if platform.system() == "Windows":
    includes.append("Dependencies\\WIN\\GLFW\\include")
    includes.append("Dependencies\\GLOBAL\\glm")
    includes.append("src\\")

    if not Path("C:\\VulkanSDK").exists():
        raise FileNotFoundError("C:\\VulkanSDK doesnt exist")

    vulkan_sdk_path = "C:\\VulkanSDK\\" + os.listdir("C:\\VulkanSDK")[~0]

    includes.append(f"{vulkan_sdk_path}\\Include")

    library_dirs.append(f"{vulkan_sdk_path}\\Lib")
    library_dirs.append("Dependencies\\WIN\\GLFW\\lib-vc2022")

    libraries.append("User32.lib")
    libraries.append("Gdi32.lib")
    libraries.append("Shell32.lib")
    libraries.append("glfw3.lib")
    libraries.append("vulkan-1.lib")

    libraries = list(map(lambda s: s.removesuffix(".lib"), libraries))

    define_macros.append(("GLFW_INCLUDE_VULKAN", None))

    extra_compile_args.append("/std:c++17")
else:
    raise NotImplementedError("not done for the rest of the platforms cause i dont know how (-_-).")

extensions = [
    Extension(
        name="main",
        sources=["src/main.pyx"],
        language=language,
        include_dirs=includes,
        libraries=libraries,
        library_dirs=library_dirs,
        define_macros=define_macros,
        undef_macros=undef_macros,
        extra_compile_args=extra_compile_args,
    ),
]


def consume_arg(arg: str) -> bool:
    if arg in sys.argv:
        sys.argv.remove(arg)
        return True
    return False


def build():
    global extensions

    run = consume_arg("-r")

    Path("build").mkdir(exist_ok=True, parents=True)

    if consume_arg("-h"):
        print("Build CyOpenGL library subcommands:")
        print("    -a, it gives the annotations of the cython file and then builds the library")
        print("    -CyDep, it makes all of the pxd files from C headers")
        print("    -r, it runs the generated .pyd file")
        sys.exit(0)

    if consume_arg("-CyDep"):
        from scripts.generate_pxd_files import (
            generate_glfw_pxd,
            generate_vulkan_pxd,
        )
        if platform.system() == "Windows":
            generate_glfw_pxd(
                Path("Dependencies/WIN/GLFW/include/GLFW/glfw3.h").absolute(),
                Path("src/CyGlfw.pxd").absolute(),
            )

            generate_vulkan_pxd(
                Path(f"{vulkan_sdk_path}/Include/vulkan/vulkan_core.h").absolute(),
                Path("src/CyVulkan.pxd").absolute(),
            )
        else:
            raise NotImplementedError("not done for the rest of the platforms cause i dont know how to do the build above (-_-).")

    if consume_arg("-a"):
        for file in Path("src").iterdir():
            if file.suffix == ".pyx":
                cmd = [
                    "cython",
                    file.__str__(),
                    "-a",
                    "-o",
                    file.with_suffix('.html').__str__(),
                ]
                print(f"[CMD] {shlex.join(cmd)}")
                subprocess.call(cmd)

    if len(sys.argv) == 1:
        sys.argv.append("build_ext")
        sys.argv.append("--inplace")

    setup(ext_modules=cythonize(extensions))

    for file in Path("src").iterdir():
        if file.suffix == ".pyx":
            if file.with_suffix(".c").exists():
                print(f"removing {file.with_suffix('.c')}...")
                os.remove(file.with_suffix(".c"))
            if file.with_suffix(".cpp").exists():
                print(f"removing {file.with_suffix('.cpp')}...")
                os.remove(file.with_suffix(".cpp"))

    try:
        shutil.rmtree("build")
    except OSError:
        pass

    if run:
        import main
        print("==============================")
        main.main()


if __name__ == "__main__":
    build()
