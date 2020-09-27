#!/usr/bin/env python
import doctest
import unittest
import os

try:
    # py3
    from urllib.request import urlopen
except ImportError:
    # py 2
    from urllib2 import urlopen

withPython = os.environ.get("WITH_PYTHON", "/usr/bin/python3")
print("Run installer tests using Python: {}".format(withPython))

doctest.ELLIPSIS_MARKER = "-etc-"
OPTION_FLAGS = doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE
GLOBS = {"withPython": withPython, "urlopen": urlopen}
TESTFILES = [
    "tests-install.txt",
    #    "tests-py2build.txt",
    #    "tests-py3build.txt",
]
for testfile in TESTFILES:
    print("-" * 60)
    print("run doctests in {}".format(testfile))
    print("-" * 60)
    doctest.testfile(testfile, optionflags=OPTION_FLAGS, globs=GLOBS)

print("Done.")
