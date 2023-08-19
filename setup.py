import os
import sys

import numpy as np
from Cython.Build import cythonize
from setuptools import Extension, setup

from setupext import check_for_openmp

if check_for_openmp():
    omp_args = ["-fopenmp"]
else:
    omp_args = None

if os.name == "nt":
    std_libs = []
else:
    std_libs = ["m"]

define_macros = [
    ("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION"),
]
if sys.version_info >= (3, 9):
    # keep in sync with runtime requirements (pyproject.toml)
    define_macros.append(("NPY_TARGET_VERSION", "NPY_1_18_API_VERSION"))
else:
    pass

extensions = [
    Extension(
        "ewah_bool_utils.ewah_bool_wrap",
        ["ewah_bool_utils/ewah_bool_wrap.pyx"],
        define_macros=define_macros,
        include_dirs=["ewah_bool_utils", "ewah_bool_utils/cpp", np.get_include()],
        language="c++",
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
