# Test the invoking Python to see if it's a good candidate
# for running Zope 2.10.x / Plone 3.0.x.
#
# $LastChangedDate: 2008-08-03 10:21:34 -0700 (Sun, 03 Aug 2008) $ $LastChangedRevision: 21978 $

import sys, os.path

passed = True

# check version
vi = sys.version_info[:3]
if vi < (2, 4, 2) or vi >= (2, 5, 0) :
    print "Failed: Python version must be 2.4.2+. Python 2.5.x not supported."
    # not much point in further testing.
    sys.exit(1)

try:
    import xml.parsers.expat
except ImportError:
    print "Failed: Python must include xml.parsers.expat module."
    print "This is a separate package on some platforms.\n"
    passed = False

try:
    import zlib
except ImportError:
    print "Failed: Python must include zlib module.\n"
    passed = False

try:
    import _imaging
except ImportError:
    if os.path.isfile( os.path.join(sys.prefix, 'include', 'python2.4', 'Python.h') ):
        print "Warning: the Python Imaging Library is missing."
        print "We'll try to build it, but watch for problems.\n"
    else:
        print "Failed: Python must include Python Imaging Library"
        print "or the headers necessary to build it. Try installing"
        print "your Python development and/or imaging packages.\n"
        passed = False

try:
    import _ssl
except ImportError:
    print "Warning: This Python does not have ssl support."
    print "It may still be usable for Zope, but will not support"
    print "openid, ESMTP+TLS, or updates via https.\n"

try:
    import readline
except ImportError:
    print "Warning: This Python does not have readline support."
    print "It may still be usable for Zope, but interacting directly with Python will be painful.\n"

if not passed:
    sys.exit(1)
