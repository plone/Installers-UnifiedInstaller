#!/usr/bin/env python
import doctest
import subprocess
import unittest
import os
import shutil
import socket
import sys
import tempfile

try:
    # py3
    PY = 3
    from urllib.request import urlopen
except ImportError:
    # py 2
    PY = 2
    from urllib2 import urlopen

withPython = os.environ.get("WITH_PYTHON", "/usr/bin/python3")
print("Run installer tests using Python: {}".format(withPython))

tempdir = os.environ.get("WITH_TEMP", None)
if tempdir is None:
    tempdir = os.path.join(tempfile.mkdtemp())
tempdir = os.path.abspath(tempdir)


def safestr(value):
    if PY == 3 and isinstance(value, bytes):
        return value.decode()
    if PY == 2 and isinstance(value, unicode):
        return value.encode()
    return value


def doCommand(command, forever=False):
    p = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=not forever
    )
    if forever:
        return p
    out, err = p.communicate()
    return (out, err, p.returncode)


def checkport(server="127.0.0.1", port=8080):
    a_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    location = (server, port)
    result_of_check = a_socket.connect_ex(location)
    a_socket.close()
    return result_of_check == 0


doctest.ELLIPSIS_MARKER = "-etc-"
OPTION_FLAGS = doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE
GLOBS = {
    "withPython": withPython,
    "urlopen": urlopen,
    "safestr": safestr,
    "doCommand": doCommand,
    "checkport": checkport,
}
CWD = os.path.abspath(os.path.dirname(__file__))
TESTFILES = []
if os.name == "nt":
    TESTFILES.append(os.path.join(CWD, "tests-install-windows.rst"))
else:
    TESTFILES.append(os.path.join(CWD, "tests-install-unix.rst"))

for idx, testfile in enumerate(TESTFILES):
    os.chdir(CWD)  # start always here!
    print("-" * 60)
    print("run doctest {0} : {1}".format(idx, testfile))
    print("-" * 60)
    tmpdirname = os.path.join(tempdir, str(idx))
    if os.path.exists(tmpdirname):
        shutil.rmtree(tmpdirname)
    os.mkdir(tmpdirname)
    print("Created temporary directory", tmpdirname)
    GLOBS["testTarget"] = tmpdirname
    result = doctest.testfile(
        testfile,
        module_relative=False,
        optionflags=OPTION_FLAGS,
        verbose=True,
        globs=GLOBS,
    )
    shutil.rmtree(tmpdirname)
    if result.failed:
        print("Failed.")
        exit(1)

print("Done.")
