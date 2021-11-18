#! /usr/bin/env python
# encoding: utf-8

import os
import sys
import platform
import subprocess
from distutils.core import setup, Command
from distutils.extension import Extension
from distutils.command.build_ext import build_ext
from distutils.version import LooseVersion
from efl import __version__, __version_info__ as vers

script_path = os.path.dirname(os.path.abspath(__file__))


# python-efl version (change in efl/__init__.py)
RELEASE = __version__
VERSION = "%d.%d" % (vers[0], vers[1] if vers[2] < 99 else vers[1] + 1)

# dependencies
CYTHON_MIN_VERSION = "0.23.5"
CYTHON_BLACKLIST = ()
EFL_MIN_VER = RELEASE
ELM_MIN_VER = RELEASE

# Add git commit count for dev builds
if vers[2] == 99:
    try:
        call = subprocess.Popen(["git", "rev-list", "--count", "HEAD"],
                                stdout=subprocess.PIPE)
        out, err = call.communicate()
        count = out.decode("utf-8").strip()
        RELEASE += "a" + count
    except Exception:
        RELEASE += "a0"


# Force default visibility. See phab T504
if os.getenv("CFLAGS") is not None and "-fvisibility=" in os.environ["CFLAGS"]:
    os.environ["CFLAGS"] += " -fvisibility=default"


# === Sphinx ===
try:
    from sphinx.setup_command import BuildDoc
except ImportError:
    class BuildDoc(Command):
        description = "build docs using sphinx, that must be installed."
        version = ""
        release = ""
        user_options = []

        def initialize_options(self):
            pass

        def finalize_options(self):
            pass

        def run(self):
            print("Error: sphinx not found")


# === pkg-config ===
def pkg_config(name, require, min_vers=None):
    try:
        sys.stdout.write("Checking for " + name + ": ")

        call = subprocess.Popen(["pkg-config", "--modversion", require],
                                stdout=subprocess.PIPE)
        out, err = call.communicate()
        if call.returncode != 0:
            raise SystemExit("Did not find " + name + " with 'pkg-config'.")

        ver = out.decode("utf-8").strip()
        if min_vers is not None:
            assert (LooseVersion(ver) >= LooseVersion(min_vers)) is True

        call = subprocess.Popen(["pkg-config", "--cflags", require],
                                stdout=subprocess.PIPE)
        out, err = call.communicate()
        cflags = out.decode("utf-8").split()

        call = subprocess.Popen(["pkg-config", "--libs", require],
                                stdout=subprocess.PIPE)
        out, err = call.communicate()
        libs = out.decode("utf-8").split()

        sys.stdout.write("OK, found " + ver + "\n")

        cflags = list(set(cflags))

        return (cflags, libs)
    except (OSError, subprocess.CalledProcessError):
        raise SystemExit("Did not find " + name + " with 'pkg-config'.")
    except (AssertionError):
        raise SystemExit("%s version mismatch. Found: %s  Needed %s" % (
                         name, ver, min_vers))


# === setup.py clean_generated_files command ===
class CleanGenerated(Command):
    description = "Clean C and html files generated by Cython"
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        for lib in ("eo", "evas", "ecore", "ecore_x", "ecore_input", "ecore_con",
                    "edje", "emotion", "elementary", "ethumb", "dbus_mainloop",
                    "utils"):
            lib_path = os.path.join(script_path, "efl", lib)
            for root, dirs, files in os.walk(lib_path):
                for f in files:
                    if f.endswith((".c", ".html")) and f != "e_dbus.c":
                        self.remove(os.path.join(root, f))

    def remove(self, fullpath):
        print("removing %s" % fullpath.replace(script_path, "").lstrip('/'))
        os.remove(fullpath)


# === setup.py uninstall command ===
RECORD_FILE = "installed_files-%d.%d.txt" % sys.version_info[:2]
class Uninstall(Command):
    description = 'remove all the installed files recorded at installation time'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def remove_entry(self, entry):
        if os.path.isfile(entry):
            try:
                print("removing file %s" % entry)
                os.unlink(entry)
            except OSError as e:
                print(e)
                return

            directory = os.path.dirname(entry)
            while os.listdir(directory) == []:
                try:
                    print("removing empty directory %s" % directory)
                    os.rmdir(directory)
                except OSError as e:
                    print(e)
                    break
                directory = os.path.dirname(directory)

    def run(self):
        if not os.path.exists(RECORD_FILE):
            print('ERROR: No %s file found!' % RECORD_FILE)
        else:
            for entry in open(RECORD_FILE).read().split():
                self.remove_entry(entry)


# === setup.py test command ===
class Test(Command):
    description = 'Run all the available unit tests using efl in build/'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import unittest

        sys.path.insert(0, "build/lib.%s-%s-%d.%d" % (
                            platform.system().lower(), platform.machine(),
                            sys.version_info[0], sys.version_info[1]))
        if "efl" in sys.modules:
            del sys.modules["efl"]

        loader = unittest.TestLoader()
        suite = loader.discover('./tests')
        runner = unittest.TextTestRunner(verbosity=1, buffer=True)
        result = runner.run(suite)


# === use cython or pre-generated C files ===
USE_CYTHON = False
if os.getenv("DISABLE_CYTHON") is not None:
    if os.path.exists(os.path.join(script_path, "efl/eo/efl.eo.c")):
        USE_CYTHON = False
    else:
        sys.exit(
            "You have requested to use pregenerated files with DISABLE_CYTHON\n"
            "but the files are not available!\n"
            "Unset DISABLE_CYTHON from your build environment and try again.")
elif os.getenv("ENABLE_CYTHON") is not None:
    USE_CYTHON = True
elif not os.path.exists(os.path.join(script_path, "efl/eo/efl.eo.c")):
    USE_CYTHON = True
elif os.path.exists(os.path.join(script_path, "Makefile")):
    USE_CYTHON = True


ext_modules = []
py_modules = []
packages = ["efl"]
common_cflags = [
    "-fno-var-tracking-assignments",  # seems to lower the mem used during build
    "-Wno-misleading-indentation",  # not needed (we don't indent the C code)
    "-Wno-deprecated-declarations",  # we bind deprecated functions
    "-Wno-unused-variable",  # eo_instance_from_object() is unused
    "-Wno-format-security",  # some cc don't like the way cython use EINA_LOG macros
    # "-Werror", "-Wfatal-errors"  # use this to stop build on first warnings
]
# remove clang unknown flags
if os.getenv("CC") == "clang":
    common_cflags.remove('-fno-var-tracking-assignments')


if set(("build", "build_ext", "install", "bdist", "sdist")) & set(sys.argv):
    sys.stdout.write("Python-EFL: %s\n" % RELEASE)

    # === Python ===
    sys.stdout.write("Checking for Python: ")
    py_ver = sys.version_info
    py_ver = "%s.%s.%s" % (py_ver[0], py_ver[1], py_ver[2])
    if sys.hexversion < 0x020600f0:
        raise SystemExit("too old. Found: %s  Need at least 2.6.0" % py_ver)
    else:
        sys.stdout.write("OK, found %s\n" % py_ver)

    # === Cython ===
    sys.stdout.write("Checking for Cython: ")
    if USE_CYTHON:
        # check if cython is installed
        try:
            from Cython.Distutils import Extension, build_ext
            from Cython.Build import cythonize
            import Cython.Compiler.Options
        except ImportError:
            raise SystemExit("not found! Needed >= %s" % (CYTHON_MIN_VERSION))

        # check min version
        if LooseVersion(Cython.__version__) < LooseVersion(CYTHON_MIN_VERSION):
            raise SystemExit("too old! Found %s  Needed %s" % (
                             Cython.__version__, CYTHON_MIN_VERSION))

        # check black-listed releases
        if Cython.__version__.startswith(CYTHON_BLACKLIST):
            raise SystemExit("found %s, it's broken! Need another release" %
                             Cython.__version__)

        sys.stdout.write("OK, found %s\n" % Cython.__version__)
        module_suffix = ".pyx"
        # Stop compilation on first error
        Cython.Compiler.Options.fast_fail = True
        # Generates HTML files with annotated source
        Cython.Compiler.Options.annotate = False
        # Set to False to disable docstrings
        Cython.Compiler.Options.docstrings = True

    else:
        sys.stdout.write("not needed, using pre-generated C files\n")
        module_suffix = ".c"

    # === Eina ===
    eina_cflags, eina_libs = pkg_config('Eina', 'eina', EFL_MIN_VER)

    # === Eo ===
    eo_cflags, eo_libs = pkg_config('Eo', 'eo', EFL_MIN_VER)
    eo_ext = Extension("efl.eo",
                       ["efl/eo/efl.eo" + module_suffix],
                       define_macros=[
                            ('EFL_BETA_API_SUPPORT', 1),
                            ('EFL_EO_API_SUPPORT', 1)
                        ],
                       include_dirs=['include/'],
                       extra_compile_args=eo_cflags + common_cflags,
                       extra_link_args=eo_libs + eina_libs
                      )
    ext_modules.append(eo_ext)

    # === Utilities ===
    utils_ext = [
        Extension("efl.utils.deprecated",
                  ["efl/utils/deprecated" + module_suffix],
                  include_dirs=['include/'],
                  extra_compile_args=eina_cflags + common_cflags,
                  extra_link_args=eina_libs),
        Extension("efl.utils.conversions",
                 ["efl/utils/conversions" + module_suffix],
                  include_dirs=['include/'],
                  extra_compile_args=eo_cflags + common_cflags,
                  extra_link_args=eo_libs + eina_libs),
        Extension("efl.utils.logger",
                  ["efl/utils/logger" + module_suffix],
                  include_dirs=['include/'],
                  extra_compile_args=eina_cflags + common_cflags,
                  extra_link_args=eina_libs),
    ]
    ext_modules.extend(utils_ext)
    py_modules.append("efl.utils.setup")
    packages.append("efl.utils")

    # === Evas ===
    evas_cflags, evas_libs = pkg_config('Evas', 'evas', EFL_MIN_VER)
    evas_ext = Extension("efl.evas",
                         ["efl/evas/efl.evas" + module_suffix],
                         define_macros=[
                            ('EFL_BETA_API_SUPPORT', 1),
                            ('EFL_EO_API_SUPPORT', 1)
                         ],
                         include_dirs=['include/'],
                         extra_compile_args=evas_cflags + common_cflags,
                         extra_link_args=evas_libs + eina_libs + eo_libs)
    ext_modules.append(evas_ext)

    # === Ecore ===
    ecore_cflags, ecore_libs = pkg_config('Ecore', 'ecore', EFL_MIN_VER)
    ecore_file_cflags, ecore_file_libs = pkg_config('EcoreFile', 'ecore-file',
                                                    EFL_MIN_VER)
    ecore_ext = Extension("efl.ecore",
                          ["efl/ecore/efl.ecore" + module_suffix],
                          include_dirs=['include/'],
                          extra_compile_args=list(set(ecore_cflags +
                                                      ecore_file_cflags +
                                                      common_cflags)),
                          extra_link_args=ecore_libs + ecore_file_libs +
                                          eina_libs + evas_libs)
    ext_modules.append(ecore_ext)

    # === Ecore Input ===
    ecore_input_cflags, ecore_input_libs = pkg_config('EcoreInput',
                                                      'ecore-input',
                                                      EFL_MIN_VER)
    ecore_input_ext = Extension("efl.ecore_input",
                            ["efl/ecore_input/efl.ecore_input" + module_suffix],
                            include_dirs=['include/'],
                            extra_compile_args=list(set(ecore_cflags +
                                                        ecore_file_cflags +
                                                        ecore_input_cflags +
                                                        common_cflags)),
                            extra_link_args=ecore_libs + ecore_file_libs +
                                            ecore_input_libs)
    ext_modules.append(ecore_input_ext)

    # === Ecore Con ===
    ecore_con_cflags, ecore_con_libs = pkg_config('EcoreCon', 'ecore-con',
                                                  EFL_MIN_VER)
    ecore_con_ext = Extension("efl.ecore_con",
                              ["efl/ecore_con/efl.ecore_con" + module_suffix],
                              include_dirs=['include/'],
                              extra_compile_args=list(set(ecore_cflags +
                                                          ecore_file_cflags +
                                                          ecore_con_cflags +
                                                          common_cflags)),
                              extra_link_args=ecore_libs + ecore_file_libs +
                                              ecore_con_libs + eina_libs)
    ext_modules.append(ecore_con_ext)

    # === Ecore X ===
    try:
        ecore_x_cflags, ecore_x_libs = pkg_config('EcoreX', 'ecore-x',
                                                  EFL_MIN_VER)
    except SystemExit:
        print("Not found, will not be built")
    else:
        ecore_x_ext = Extension("efl.ecore_x",
                                ["efl/ecore_x/efl.ecore_x" + module_suffix],
                                include_dirs=['include/'],
                                extra_compile_args=list(set(ecore_cflags +
                                                            ecore_file_cflags +
                                                            ecore_x_cflags +
                                                            ecore_input_cflags +
                                                            common_cflags)),
                                extra_link_args=ecore_libs + ecore_file_libs +
                                                ecore_x_libs + ecore_input_libs +
                                                eina_libs + evas_libs)
        ext_modules.append(ecore_x_ext)

    # === Ethumb ===
    ethumb_cflags, ethumb_libs = pkg_config('Ethumb', 'ethumb', EFL_MIN_VER)
    ethumb_ext = Extension("efl.ethumb",
                           ["efl/ethumb/efl.ethumb" + module_suffix],
                           include_dirs=['include/'],
                           extra_compile_args=ethumb_cflags + common_cflags,
                           extra_link_args=ethumb_libs + eina_libs)
    ext_modules.append(ethumb_ext)

    # === Ethumb Client ===
    ethumb_client_cflags, ethumb_client_libs = pkg_config('Ethumb_Client',
                                                'ethumb_client', EFL_MIN_VER)
    ethumb_client_ext = Extension("efl.ethumb_client",
                                  ["efl/ethumb/efl.ethumb_client" + module_suffix],
                                  include_dirs=['include/'],
                                  extra_compile_args=ethumb_client_cflags +
                                                     common_cflags,
                                  extra_link_args=ethumb_client_libs + eina_libs)
    ext_modules.append(ethumb_client_ext)

    # === Edje ===
    edje_cflags, edje_libs = pkg_config('Edje', 'edje', EFL_MIN_VER)
    edje_ext = Extension("efl.edje",
                         ["efl/edje/efl.edje" + module_suffix],
                         include_dirs=['include/'],
                         extra_compile_args=edje_cflags + common_cflags,
                         extra_link_args=edje_libs + eina_libs + evas_libs)
    ext_modules.append(edje_ext)

    # === Edje_Edit ===
    edje_edit_ext = Extension("efl.edje_edit",
                              ["efl/edje_edit/efl.edje_edit" + module_suffix],
                              define_macros=[('EDJE_EDIT_IS_UNSTABLE_AND_I_KNOW_ABOUT_IT', None)],
                              include_dirs=['include/'],
                              extra_compile_args=edje_cflags + common_cflags,
                              extra_link_args=edje_libs + eina_libs + evas_libs)
    ext_modules.append(edje_edit_ext)

    # === Emotion ===
    emotion_cflags, emotion_libs = pkg_config('Emotion', 'emotion', EFL_MIN_VER)
    emotion_ext = Extension("efl.emotion",
                            ["efl/emotion/efl.emotion" + module_suffix],
                            include_dirs=['include/'],
                            extra_compile_args=emotion_cflags + common_cflags,
                            extra_link_args=emotion_libs + eina_libs + evas_libs)
    ext_modules.append(emotion_ext)

    # === dbus mainloop integration ===
    dbus_cflags, dbus_libs = pkg_config('DBus', 'dbus-python', "0.83.0")
    dbus_ml_ext = Extension("efl.dbus_mainloop",
                            ["efl/dbus_mainloop/efl.dbus_mainloop" + module_suffix,
                             "efl/dbus_mainloop/e_dbus.c"],
                            extra_compile_args=list(set(dbus_cflags +
                                                        ecore_cflags +
                                                        common_cflags)),
                            extra_link_args=dbus_libs + ecore_libs)
    ext_modules.append(dbus_ml_ext)

    # === Elementary ===
    elm_cflags, elm_libs = pkg_config('Elementary', 'elementary', ELM_MIN_VER)
    e = Extension("efl.elementary.__init__",
                  ["efl/elementary/__init__" + module_suffix],
                  define_macros=[
                    ('EFL_BETA_API_SUPPORT', 1),
                    ('EFL_EO_API_SUPPORT', 1)
                  ],
                  include_dirs=["include/"],
                  extra_compile_args=elm_cflags + common_cflags,
                  extra_link_args=elm_libs + eina_libs + eo_libs + evas_libs)
    ext_modules.append(e)

    packages.append("efl.elementary")

    # Cythonize all the external modules (if needed)
    if USE_CYTHON:
        ext_modules = cythonize(ext_modules,
                                include_path=["include"],
                                compiler_directives={
                                    #"c_string_type": "unicode",
                                    #"c_string_encoding": "utf-8",
                                    "embedsignature": True,
                                    "binding": True,
                                    "language_level": 2,
                                })


setup(
    name="python-efl",
    fullname="Python bindings for Enlightenment Foundation Libraries",
    description="Python bindings for Enlightenment Foundation Libraries",
    long_description=open(os.path.join(script_path, 'README.md')).read(),
    version=RELEASE,
    author='Davide Andreoli, Kai Huuhko, and others',
    author_email="dave@gurumeditation.it, kai.huuhko@gmail.com",
    contact="Enlightenment developer mailing list",
    contact_email="enlightenment-devel@lists.sourceforge.net",
    url="http://www.enlightenment.org",
    license="GNU Lesser General Public License (LGPL)",
    keywords="efl wrapper binding enlightenment eo evas ecore edje emotion elementary ethumb",
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: X11 Applications',
        'Environment :: Console :: Framebuffer',
        'Intended Audience :: End Users/Desktop',
        'License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)',
        'Operating System :: POSIX',
        'Programming Language :: C',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Software Development :: User Interfaces',
        'Topic :: Software Development :: Widget Sets',
    ],
    cmdclass={
        'test': Test,
        'build_doc': BuildDoc,
        'clean_generated_files': CleanGenerated,
        'uninstall': Uninstall,
        'build_ext': build_ext,
    },
    command_options={
        'build_doc': {
            'version': ('setup.py', VERSION),
            'release': ('setup.py', RELEASE),
        },
        'install': {
            'record': ('setup.py', RECORD_FILE),
        },
    },
    packages=packages,
    ext_modules=ext_modules,
    py_modules=py_modules,
)
