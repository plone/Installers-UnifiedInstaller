#!/usr/bin/env python
import doctest
import unittest
try:
    # py3
    from urllib.request import urlopen
except ImportError:
    from urllib2 import urlopen

doctest.ELLIPSIS_MARKER = "-etc-"
OPTION_FLAGS = doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE

TESTFILES = [
    ("tests-install.txt", "/usr/bin/python2.7"),
#    ("tests-install.txt", "/usr/bin/python3"),
#    ("tests-py2build.txt", ""),
#    ("tests-py2build.txt", ""),
]
for testfile, withPython in TESTFILES:
    print("-" * 60)
    print("run doctests in {}".format(testfile))
    print("-" * 60)
    doctest.testfile(
        testfile, optionflags=OPTION_FLAGS, globs={"withPython": withPython, "urlopen": urlopen}
    )

print("Done.")
