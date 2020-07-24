#!/usr/bin/env python

"""The setup script."""

from setuptools import (
    setup,
    find_packages,
    Extension
)
from setupext import check_for_openmp
import os
import numpy as np
from Cython.Build import cythonize

if check_for_openmp() is True:
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

with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = ['setuptools>=19.6', 'numpy>=1.10.4']

setup_requirements = ['pytest-runner', ]

test_requirements = ['pytest>=3', ]

setup(
    author="Navaneeth Suresh",
    author_email='navaneeths1998@gmail.com',
    python_requires='>=3.5',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
    ],
    description="EWAH Bool Array utils for yt",
    ext_modules = cythonize(extensions),
    install_requires=requirements,
    license="BSD license",
    long_description=readme + '\n\n' + history,
    include_package_data=True,
    package_data = {'ewah_bool_utils': ['*.pxd']},
    keywords='ewah_bool_utils',
    name='ewah_bool_utils',
    packages=find_packages(include=['ewah_bool_utils', 'ewah_bool_utils.*']),
    setup_requires=setup_requirements,
    test_suite='tests',
    tests_require=test_requirements,
    url='https://github.com/themousepotato/ewah_bool_utils',
    version='0.1.0',
    zip_safe=False,
)
