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


----------------------
Test building Python 3
----------------------

    First, clean out prior work
    >>> if os.path.exists(testTarget): shutil.rmtree(testTarget)

    >>> stdout, stderr, returncode = doCommand('./install.sh zeo --target=%s --password=admin --build-python=3' % testTarget)
    >>> returncode and (stdout + stderr)
    0

    >>> print(stdout.decode())
    <BLANKLINE>
    Rootless install method chosen. Will install for use by system user -etc-
    -etc-
    Installing Python-3.6.-etc- This takes a while...
    -etc-
    Python build looks OK.
    -etc-
    Plone successfully installed at -etc-
    -etc-

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "import readline"' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "import zlib"' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from PIL._imaging import jpeg_decoder"' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from PIL._imaging import zip_decoder"' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zopepy -c "from lxml import etree"' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    This Python should not be a virtualenv.
    >>> os.path.exists(os.path.join(testTarget, 'Python-3.6', 'bin', 'activate'))
    False


    Run it
    ------

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zeoserver start' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/client1 start' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/client2 start' % testTarget)
    >>> returncode
    0
    >>> stderr.decode()
    ''

    >>> time.sleep(30)

    Status check
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl status' % testTarget)

    >>> returncode
    0

    >>> stderr.decode()
    ''
Let's set up a convenience function for executing a command line
and getting stdout, stderr and return code.

    >>> def doCommand(command):
    ...    p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    ...    out, err = p.communicate()
    ...    return (out, err, p.returncode)
e via client1
    >>> urlopen('http://localhost:8080/').read()
    '-etc-Plone is up and running-etc-'

    Fetch root page via client2
    >>> urlopen('http://localhost:8081/').read()
    '-etc-Plone is up and running-etc-'

    Check Banner
    >>> print(urlopen('http://localhost:8080/').headers['server'])
    waitress

    Stop it
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl stop' % testTarget)

    >>> returncode
    0

    >>> stderr.decode()
    ''
