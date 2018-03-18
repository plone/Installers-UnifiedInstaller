# Test the invoking Python to see if it's a good candidate
# for running Zope 2.12.x / Plone 4.2.x.
#

from i18n import _

import sys
import os.path

passed = True

# check version
vi = sys.version_info[:3]
if vi < (2, 7, 9) or vi >= (2, 8, 0):
    print _("Failed: Python version must be 2.7.9+.")
    # not much point in further testing.
    sys.exit(1)

if not os.path.isfile(os.path.join(sys.prefix, 'include', 'python2.7', 'Python.h')):
    print _("Failed: We need to be able to use Python.h, which is missing.")
    print _("You may be able to resolve this by installing the python-dev package.")
    passed = False

try:
    import xml.parsers.expat
    xml.parsers.expat
except ImportError:
    print _("Failed: Python must include xml.parsers.expat module.")
    print _("This is a separate package on some platforms.\n")
    passed = False

try:
    import zlib
    zlib
    try:
        'test'.encode('zip')
    except LookupError:
        print _("Failed: Python zlib is not working.\n")
        passed = False
except ImportError:
    print _("Failed: Python must include zlib module.\n")
    passed = False

try:
    import _ssl
    _ssl
except ImportError:
    if '--without-ssl=yes' in sys.argv:
        print _("Warning: This Python does not have ssl support.")
    else:
        print _("Failed: This Python does not have ssl support.")
        print _("If you want to disable this check, add --without-ssl=yes")
        print _("to the command line.")
        passed = False

try:
    import readline
    readline
except ImportError:
    print _("Warning: This Python does not have readline support.")
    print _("It may still be usable for Zope, but interacting directly with Python will be painful.\n")

if not passed:
    sys.exit(1)

sys.exit(0)
