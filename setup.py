import os
from distutils.ccompiler import get_default_compiler

import numpy as np
from Cython.Build import cythonize
from setuptools import Extension, setup

from setupext import check_for_openmp

if check_for_openmp():
    omp_args = ["-fopenmp"]
else:
    omp_args = None

cpp11_args = ["-std=c++11" if get_default_compiler() != "msvc" else "/std:c++11"]

if os.name == "nt":
    std_libs = []
else:
    std_libs = ["m"]

define_macros = [
    ("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION"),
    # keep in sync with runtime requirements (pyproject.toml)
    ("NPY_TARGET_VERSION", "NPY_1_19_API_VERSION"),
]

extensions = [
    Extension(
        "ewah_bool_utils.ewah_bool_wrap",
        ["ewah_bool_utils/ewah_bool_wrap.pyx"],
        define_macros=define_macros,
        include_dirs=["ewah_bool_utils", "ewah_bool_utils/cpp", np.get_include()],
        language="c++",
        extra_compile_args=cpp11_args,
    ),
    Extension(
        "ewah_bool_utils.morton_utils",
        ["ewah_bool_utils/morton_utils.pyx"],
        define_macros=define_macros,
        extra_compile_args=omp_args,
        extra_link_args=omp_args,
        libraries=std_libs,
        include_dirs=[np.get_include()],
    ),
    Extension(
        "ewah_bool_utils._testing",
        ["ewah_bool_utils/_testing.pyx"],
        include_dirs=["ewah_bool_utils", "ewah_bool_utils/cpp", np.get_include()],
        define_macros=define_macros,
        extra_compile_args=["-O3"],
        language="c++",
    ),
]


setup(
    ext_modules=cythonize(
        extensions,
        compiler_directives={"language_level": 3},
    ),
)
