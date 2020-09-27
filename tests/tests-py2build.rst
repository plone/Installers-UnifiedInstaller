=======================
Unified Installer Tests
=======================

Note that we are using "-etc-" for the doctest.ELLIPSIS

These tests assume that you have a "plonetest" directory in your $HOME directory.

-----------
Setup stuff
-----------

    >>> import os, os.path, shutil, time, tempfile

This test should be run from the directory with install.sh

    >>> os.chdir(os.path.join(os.getcwd(), '..'))
    >>> os.path.exists('install.sh')
    True

install.sh should be executable
    >>> os.access('install.sh', os.X_OK)
    True


-------------------------------------
Test building Python and dependencies
-------------------------------------

    First, clean out prior work
    >>> if os.path.exists(testTarget): shutil.rmtree(testTarget)

    >>> stdout, stderr, returncode = doCommand('./install.sh zeo --target=%s --password=admin --build-python --static-lxml' % testTarget)
    >>> returncode and (stdout + stderr)
    0

    >>> print(safestr(stdout))
    <BLANKLINE>
    Rootless install method chosen. Will install for use by system user -etc-
    -etc-
    Installing Python-2.7.15. This takes a while...
    Python build looks OK.
    -etc-
    Plone successfully installed at -etc-
    -etc-

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "import readline"' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "import zlib"' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from PIL._imaging import jpeg_decoder"' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from PIL._imaging import zip_decoder"' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from lxml import etree"' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    This Python should not be a virtualenv.
    >>> os.path.exists(os.path.join(testTarget, 'Python-2.7', 'bin', 'activate'))
    False


