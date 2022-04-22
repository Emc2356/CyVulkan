from typing import List
from pathlib import Path

import sys
import os
import re


re_C_comments = re.compile(r"(\"[^\"]*\"(?!\\))|(//[^\n]*$|/(?!\\)\*[\s\S]*?\*(?!\\)/)", flags=re.DOTALL)
re_two_lf = re.compile("\n\n")
re_three_lf = re.compile("\n\n\n")
re_C_typedef_function_pointer = re.compile(
    r"^typedef\s+(\bunsigned\b|\bsigned\b|\bstruct\b|)(\s+|)\w+(\s+|)(\*+|)(\s+|)\((\s+|)\*(\s+|)\w+(\s+|)\)(\s+|)\(((\s+|)(\bunsigned\b|\bsigned\b|\bstruct\b|)(\s|)+\w+(\s+|)(\*+|)(\s+|)\w+(\s+|)(,|))+\);",
    flags=0 | 0
)
re_C_typedef_struct = re.compile(
    r"^(typedef\s+struct\s+\w+\s+)\{(((\s+|)(const|)(\s+|)(signed|unsigned|struct|)(\s+|)\w+(\s+|)((\*|\s)+|)\s+\w+(\s+|)(\[\d+\]|)+\;)+(\s+|))\}((\s+)(\*+|)(\s+|)\w+(\s+|)(\,|))+\;",
    flags=re.MULTILINE | 0,
)
re_C_define_int = re.compile(r"(#define)\s+(?P<name>\w+)(\s*(?P<value>(0x)?\d+)?)")
re_C_undef = re.compile(r"(#define)\s+(?P<name>\w+)")
re_C_define_str = re.compile(r"""(#define)\s+(?P<name>\w+)(\s*(?P<value>".*")?)""")
re_C_inline_typedef_struct = re.compile(r"typedef\s+struct\s+(?P<from>\w+)\s+(?P<to>\w+);")


def generate_glfw_pxd(glfw_header: Path, dest: Path):
    data = glfw_header.read_text()
    data = re_three_lf.sub("\n", re_C_comments.sub("", data))

    with dest.open("w") as f:
        f.truncate(0)
        f.write("# WARNING: auto generated code, do not edit directly\n")
        f.write("\n")
        f.write("from libc.stdint cimport uint64_t, uint32_t\n")
        f.write("from CyVulkan cimport *\n")
        f.write("\n")
        f.write("cdef extern from \"<GLFW/glfw3.h>\" nogil:\n")

        define_ints = []
        skips = 0
        lines = data.split("\n")
        for i, line in enumerate(lines):
            if skips:
                skips -= 1
                continue

            if any(expr in line for expr in ("#include", "#if", "#elif", "#else", "#endif", "defined(")):
                continue
            elif line.startswith("#define"):
                match = re_C_define_int.match(line)
                if match is not None and match.group("name").startswith("GLFW_"):
                    define_ints.append(match.group("name"))
                elif match is not None and not match.group("name").startswith("_"):
                    raise NotImplementedError(line)
                else:
                    continue
            elif line.startswith("#undef"):
                try:
                    define_ints.remove(re_C_undef.match(line).group("name"))
                except ValueError:
                    pass
            elif line.startswith("GLFWAPI "):
                line = line[len("GLFWAPI "):].strip().replace("(void)", "()").replace(";", "")
                f.write(f"    {line}\n")
            elif line.startswith("typedef"):
                match = re_C_inline_typedef_struct.match(line)
                if match is not None:
                    # inline struct that is like `typedef struct Dir Dir;`
                    f.write(f"    ctypedef struct {match.group('to')}:\n")
                    f.write(f"        pass\n")
                elif "struct" not in line:
                    # function pointer
                    f.write(f"    c{line}\n".replace("(void)", "()").replace(";", ""))
                else:
                    contents = ""
                    while True:
                        i += 1
                        line = lines[i]

                        if "}" in line:
                            name = line.strip().removeprefix("}").removesuffix(";").lstrip().rstrip()
                            break
                        if "{" in line or line.lstrip().rstrip().strip() == "":
                            skips += 1
                            continue

                        contents += f"        {line.strip().lstrip().rstrip().removesuffix(';')}\n".replace("struct ", "")
                        skips += 1
                    skips += 1
                    f.write(f"    ctypedef struct {name}:\n")
                    f.write(contents)
        for name in define_ints:
            f.write(f"    int {name}\n")


def generate_vulkan_pxd(vulkan_header: Path, dest: Path):
    vulkan_cdef_header = (Path(os.getcwd()) / "vulkan.cdef.h") \
        if Path(os.getcwd()).name == "scripts" else\
        Path(os.getcwd()) / "scripts" / "vulkan.cdef.h"

    vulkan_header_data = vulkan_header.read_text()
    vulkan_header_data = re.sub(r"\b\(void\)\b", "", vulkan_header_data)

    vulkan_cdef_header_data = vulkan_cdef_header.read_text()
    vulkan_cdef_header_data = re.sub(r"(\bconst\b|\b\(void\)\b)", "", vulkan_cdef_header_data)

    with dest.open("w") as f:
        f.truncate(0)
        f.write("# WARNING: auto generated code, do not edit directly\n")
        f.write("\n")
        f.write("from libc.stdint cimport int32_t, uint8_t, uint32_t, uint64_t\n")
        f.write("from libc.stddef cimport wchar_t\n")
        f.write("\n")
        f.write("cdef extern from \"<vulkan/vulkan.h>\" nogil:\n")
        f.write("    uint32_t VK_MAKE_API_VERSION(uint32_t variant, uint32_t major, uint32_t minor, uint32_t patch)\n")
        f.write("    uint32_t VK_MAKE_VERSION(uint32_t major, uint32_t minor, uint32_t patch)\n")
        f.write("    uint32_t VK_API_VERSION_VARIANT(int version)\n")
        f.write("    uint32_t VK_API_VERSION_MAJOR(int version)\n")
        f.write("    uint32_t VK_API_VERSION_MINOR(int version)\n")
        f.write("    uint32_t VK_API_VERSION_PATCH(int version)\n")
        f.write("    uint32_t VK_VERSION_MAJOR(int version)\n")
        f.write("    uint32_t VK_VERSION_MINOR(int version)\n")
        f.write("    uint32_t VK_VERSION_PATCH(int version)\n")
        f.write("    ctypedef struct AHardwareBuffer:\n")
        f.write("        pass\n")
        f.write("    ctypedef struct wl_display:\n")
        f.write("        pass\n")
        f.write("    ctypedef struct wl_surface:\n")
        f.write("        pass\n")
        f.write("    ctypedef struct ANativeWindow:\n")
        f.write("        pass\n")
        f.write("    \n")

        define_names = set()
        defines = ""

        for line in vulkan_header_data.split("\n"):
            stripped_line = line.lstrip()

            if stripped_line.startswith("#define VK"):
                define_name = stripped_line[len("#define") + 1:]
                col = 0

                while col < len(define_name) and define_name[col] != " ":
                    col += 1

                define_name_cut = define_name[:col]

                if "(" in define_name_cut:
                    # ignore function-like macros
                    continue

                if define_name_cut in define_names or not define_name_cut.startswith("VK"):
                    continue
                define_names.add(define_name_cut)
                typ = ""
                try:
                    i = 0
                    while col+i < len(define_name) and define_name[col+i] != "\"":
                        i += 1
                        if define_name[col+i] == "\"":
                            typ = "char*"
                            break
                    else:
                        raise IndexError
                except IndexError:
                    typ = "int"

                defines += f"    {typ} {define_name_cut}\n"

        f.write(defines)

        skips = 0

        lines = vulkan_cdef_header_data.split("\n")
        for i, line in enumerate(lines):
            if skips:
                skips -= 1
                continue

            if line.startswith("typedef struct"):
                if line[~0] == ";":
                    # probably of the nature `typedef struct DIR DIR;`
                    f.write(
                        f"    ctypedef struct {line[:-1].split(' ')[~0].replace('*', '')}:\n"
                        f"        pass\n"
                    )
                else:
                    contents = ""
                    while True:
                        i += 1
                        line = lines[i]

                        if "}" in line:
                            name = line.strip().removeprefix("}").removesuffix(";").lstrip().rstrip()
                            break

                        contents += f"        {line.strip().lstrip().rstrip().removesuffix(';')}\n".replace("struct ", "")
                        skips += 1
                    skips += 1
                    f.write(f"    ctypedef struct {name}:\n")
                    f.write(contents)

                    # unhandled_data += line + "\n"
            elif line.startswith("typedef enum"):
                name = line[len("typedef enum") + 1:]
                col = 0
                while col < len(name) and name[col] != " ":
                    col += 1

                name = name[:col]

                f.write(f"    cdef enum {name}:\n")
                while True:
                    i += 1
                    line = lines[i]

                    if "}" in line:
                        break

                    f.write(f"        {line.lstrip().replace(',', '')}\n")
                    skips += 1
                skips += 1
            elif line.startswith("typedef union"):
                contents = ""
                while True:
                    i += 1
                    line = lines[i]
                    skips += 1

                    if "}" in line:
                        name = line.strip().removeprefix("}").removesuffix(";").lstrip().rstrip()
                        break

                    contents += f"        {line.strip().lstrip().rstrip().removesuffix(';')}\n".replace("struct ",
                                                                                                        "")
                    # f.write(f"        {line.lstrip().replace(',', '')}\n")
                f.write(f"    ctypedef union {name}:\n")
                f.write(contents)
            elif line.startswith("typedef"):
                if line[~0] == ";":
                    if "android" in line.lower():
                        print(f"[LOG] skipping: `{line}`")
                    f.write(f"    c{line}\n".replace("struct ", "").replace("(void)", "()"))
                else:
                    # probably a multi-line function pointer as we have handled the reset
                    gathered = "    c" + line.lstrip() + "\n"
                    while True:
                        i += 1
                        line = lines[i]
                        skips += 1

                        gathered += "        " + line.lstrip() + "\n"

                        if ")" in line:
                            break

                    f.write(gathered)
            else:
                if line.strip() == "":
                    continue
                # probably a function
                gathered = "    cdef " + line.lstrip() + "\n"
                while True:
                    i += 1
                    if i >= len(lines): break
                    line = lines[i]
                    skips += 1

                    gathered += "        " + line.lstrip().replace("struct ", "") + "\n"

                    if ")" in line:
                        break

                f.write(gathered)
