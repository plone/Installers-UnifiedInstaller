# Test the invoking Python to see if it's a good candidate
# for running Zope 2.12.x / Plone 4.0.x.
#
# $LastChangedDate: 2010-08-27 11:48:43 -0700 (Fri, 27 Aug 2010) $ $LastChangedRevision: 39119 $

import sys, os.path

passed = True

# check version
vi = sys.version_info[:3]
if vi < (2, 6, 0) or vi >= (2, 7, 0) :
    print "Failed: Python version must be 2.6+."
    # not much point in further testing.
    sys.exit(1)

if not os.path.isfile( os.path.join(sys.prefix, 'include', 'python2.6', 'Python.h') ):
    print "Failed: We need to be able to use Python.h, which is missing."
    print "You may be able to resolve this by installing the python-dev package."
    passed = False

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
    try:
        from _imaging import jpeg_decoder
    except ImportError:
            print "Failed: The Python Imaging Library is installed, but the JPEG"
            print "support is not working."
            passed = False
except ImportError:
    print "Warning: the Python Imaging Library is missing."
    print "We'll try to build it, but watch for problems.\n"

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
