# Test the invoking Python to see if it's a good candidate
# for running Zope 2.12.x / Plone 4.2.x.
#

from distutils.sysconfig import get_python_inc
from i18n import _print

import sys
import os.path

passed = True

# check version
vi = sys.version_info[:3]
if vi[0] == 2 and vi < (2, 7, 9) or vi[0] == 3 and vi < (3, 6, 0):
    _print("Failed: Python version must be 2.7.9+ or 3.6.0+.")
    # not much point in further testing.
    sys.exit(1)

include_dir = os.path.join(get_python_inc(plat_specific=1))
if not os.path.isfile(os.path.join(include_dir, "Python.h")):
    _print("Failed: We need to be able to use Python.h, which is missing.")
    _print("You may be able to resolve this by installing the python-dev package.")
    passed = False

try:
    import xml.parsers.expat

    xml.parsers.expat
except ImportError:
    _print("Failed: Python must include xml.parsers.expat module.")
    _print("This is a separate package on some platforms.\n")
    passed = False

try:
    import zlib

    zlib
    try:
        zlib.compress(b"test")
    except LookupError:
        _print("Failed: Python zlib is not working.\n")
        passed = False
except ImportError:
    _print("Failed: Python must include zlib module.\n")
    passed = False

try:
    import _ssl

    _ssl
except ImportError:
    if "--without-ssl=yes" in sys.argv:
        _print("Warning: This Python does not have ssl support.")
    else:
        _print("Failed: This Python does not have ssl support.")
        _print("If you want to disable this check, add --without-ssl=yes")
        _print("to the command line.")
        passed = False

try:
    import readline

    readline
except ImportError:
    _print("Warning: This Python does not have readline support.")
    _print(
        "It may still be usable for Zope, but interacting directly with Python will be painful.\n"
    )

if not passed:
    sys.exit(1)

sys.exit(0)
