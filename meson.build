project(
  'ewah_bool_utils',
  'c', 'cpp', 'cython',
  default_options: [
    # https://mesonbuild.com/Builtin-options.html#core-options
    'cpp_std=c++11',
  ],
  # https://mesonbuild.com/meson-python/reference/meson-compatibility.html#cmdoption-arg-1.6.0
  meson_version: '>=1.6.0',
)

# detect missing dependencies early
py = import('python').find_installation(pure: false)
cpp = meson.get_compiler('cpp')
cy = meson.get_compiler('cython')
cython = find_program(cy.cmd_array()[0])

npy_c_args = [
  # keep in sync with pyproject.toml
  '-DNPY_TARGET_VERSION=NPY_1_23_API_VERSION',
  '-DNPY_NO_DEPRECATED_API=NPY_1_23_API_VERSION',
]

_numpy_dep = dependency('numpy')
np_dep = declare_dependency(
    dependencies: _numpy_dep,
    compile_args: npy_c_args,
)

ewah_dep = declare_dependency(
    include_directories: 'src/ewah_bool_utils/cpp',
)

py.extension_module(
    'ewah_bool_wrap',
    'src/ewah_bool_utils/ewah_bool_wrap.pyx',
    subdir: 'ewah_bool_utils',
    install: true,
    dependencies: [np_dep, ewah_dep],
    cpp_args: npy_c_args,
    limited_api: py.language_version(),
    override_options: ['cython_language=cpp'],
)

py.extension_module(
    'api', 
    'src/ewah_bool_utils/api.pyx',    
    subdir: 'ewah_bool_utils',
    install: true,
    dependencies: [np_dep, ewah_dep],
    cpp_args: npy_c_args,
    limited_api: py.language_version(),
    override_options: ['cython_language=cpp'],
)

py.extension_module(
    '_testing',
    'src/ewah_bool_utils/_testing.pyx',
    subdir: 'ewah_bool_utils',
    install: true,
    dependencies: [np_dep, ewah_dep],
    cpp_args: npy_c_args,
    limited_api: py.language_version(),
    override_options: ['cython_language=cpp'],
)

py.extension_module(
    'morton_utils',
    'src/ewah_bool_utils/morton_utils.pyx',
    subdir: 'ewah_bool_utils',
    install: true,
    dependencies: [np_dep],
    c_args: npy_c_args,
    limited_api: py.language_version(),
)

py.install_sources(
    'src/ewah_bool_utils/__init__.py',
    subdir: 'ewah_bool_utils',
)

py.install_sources(
    'tests/__init__.py',
    'tests/test_ewah_bool_utils.py',    
    subdir: 'tests',
)

# include headers as easily locatable data files
# to allow yt to link from a wheel
install_data(
    'src/ewah_bool_utils/cpp/boolarray.h',
    'src/ewah_bool_utils/cpp/ewah-inl.h',
    'src/ewah_bool_utils/cpp/ewah.h',
    'src/ewah_bool_utils/cpp/ewahutil.h',
    'src/ewah_bool_utils/cpp/runninglengthword.h',
    # keep in sync with ewah_bool_utils/__init__.py::get_include
    install_dir: py.get_install_dir() / 'headers',
)
install_data(
    'src/ewah_bool_utils/ewah_bool_array.pxd',
    'src/ewah_bool_utils/ewah_bool_array.pxd',
    'src/ewah_bool_utils/ewah_bool_wrap.pxd',
    'src/ewah_bool_utils/morton_utils.pxd',
    install_dir: py.get_install_dir() / 'ewah_bool_utils',
)
