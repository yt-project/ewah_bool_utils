from setuptools import (
    setup,
    find_packages,
    Extension
)
from setupext import check_for_openmp
import os
import numpy as np
from Cython.Build import cythonize

if check_for_openmp():
    omp_args = ['-fopenmp']
else:
    omp_args = None

if os.name == "nt":
    std_libs = []
else:
    std_libs = ["m"]

extensions = [
    Extension("ewah_bool_utils.ewah_bool_wrap",
              ["ewah_bool_utils/ewah_bool_wrap.pyx"],
              include_dirs=["ewah_bool_utils",
                            "ewah_bool_utils/cpp",
                            np.get_include()],
              language="c++"),
    Extension("ewah_bool_utils.morton_utils",
              ["ewah_bool_utils/morton_utils.pyx"],
              extra_compile_args=omp_args,
              extra_link_args=omp_args,
              libraries=std_libs,
              include_dirs=[np.get_include()])
]


setup(
    ext_modules = cythonize(extensions),
)
