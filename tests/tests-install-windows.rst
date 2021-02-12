=======================
Unified Installer Tests
=======================

Note that we are using "-etc-" for the doctest.ELLIPSIS

These tests assume that you have a "plonetest" directory in your $HOME directory.

-----------
Setup stuff
-----------

    >>> import os, os.path, time

This test should be run from the directory with install.sh

    >>> os.chdir(os.path.join(os.getcwd(), '..'))
    >>> os.path.exists('install.sh')
    True

install.sh should be executable
    >>> os.access('install.sh', os.X_OK)
    True


-------------
Usage Message
-------------

Running install.sh with help option should result in a usage message:

    >>> stdout, stderr, returncode = doCommand('.\windows_install.bat --help')
    >>> returncode
    0
    >>> safestr(stderr)
    ''
    >>> print(safestr(stdout))
    -etc-
    usage: -etc-

------------------
Test a ZEO install
------------------

    >>> stdout, stderr, returncode = doCommand('.\windows_install.bat --target={} --password=admin zeo'.format(testTarget))
    >>> returncode
    0

    >>> print(safestr(stderr))
    <BLANKLINE>

    >>> print(safestr(stdout))
    <BLANKLINE>
    -etc-
    Installing Plone 5.2-etc-
    #####################################################################
    <BLANKLINE>
    ######################  Installation Complete  ######################
    <BLANKLINE>
    Plone successfully installed at -etc-
      Username: admin
      Password: admin-etc-

    target should have basic kit
    >>> sorted(os.listdir(testTarget))
    ['buildout-cache', 'zeocluster']

    There should now be a buildout skeleton in zeocluster
    >>> expected = ['.installed.cfg', 'README.html', 'adminPassword.txt', 'base.cfg', 'bin', 'buildout.cfg', 'develop-eggs', 'develop.cfg', 'lxml_static.cfg', 'parts', 'products', 'src', 'var', 'requirements.txt']
    >>> found = os.listdir('%s/zeocluster' % testTarget)
    >>> [s for s in expected if s not in found]
    []

    Parts should contain the needed components
    >>> expected = ['README.txt', 'client1', 'client2', 'zeoserver']
    >>> found = os.listdir('%s/zeocluster/parts' % testTarget)
    >>> [s for s in expected if s not in found]
    []

    parts/README.html should be a warning
    >>> print(open('%s/zeocluster/parts/README.txt' % testTarget).read())
    WARNING:-etc-run bin/buildout-etc-

    We should have an inituser for admin
    >>> print(open('%s/zeocluster/parts/client1/inituser' % testTarget).read())
    admin:{SHA}-etc-

    Check bin contents
    >>> expected = ['backup', 'buildout', 'client1', 'client2', 'plonectl', 'pip', 'python', 'repozo', 'restore', 'snapshotbackup', 'snapshotrestore', 'zeopack', 'zeoserver', 'zopepy']
    >>> found = os.listdir('%s/zeocluster/bin' % testTarget)
    >>> [s for s in expected if s not in found]
    []

    Installing again to the same target should fail
    >>> stdout, stderr, returncode = doCommand('.\windows_install.bat zeo --target=%s --password=admin' % testTarget)
    >>> "already exists; aborting install." in safestr(stdout)
    True

    Check the Python
    ----------------

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

    Since we didn't specify otherwise, this Python should be a virtualenv.
    >>> os.path.exists(os.path.join(testTarget, 'zeocluster', 'bin', 'activate'))
    True


    Run it
    ------

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/zeoserver start' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/client1 start' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/client2 start' % testTarget)
    >>> returncode
    0
    >>> safestr(stderr)
    ''

    >>> time.sleep(30)

    Status check
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl status' % testTarget)

    >>> returncode
    0

    >>> safestr(stderr)
    ''

    Fetch root page via client1
    >>> "Plone is up and running" in urlopen('http://localhost:8080/').read()
    True

    Fetch root page via client2
    >>> "Plone is up and running" in urlopen('http://localhost:8081/').read()
    True

    Check Banner
    >>> print(urlopen('http://localhost:8080/').headers['server'])
    waitress

    Stop it
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl stop' % testTarget)

    >>> returncode
    0

    >>> safestr(stderr)
    ''
