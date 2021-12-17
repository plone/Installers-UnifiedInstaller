=======================
Unified Installer Tests
=======================

Note that we are using "-etc-" for the doctest.ELLIPSIS

These tests assume that you have a "plonetest" directory in your $HOME directory.

-----------
Setup stuff
-----------

    >>> import subprocess, os, os.path, time

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

    >>> stdout, stderr, returncode = doCommand('./install.sh --help')
    >>> returncode
    0
    >>> safestr(stderr)
    ''
    >>> print(safestr(stdout))
    <BLANKLINE>
    Usage: -etc-

------------------
Test a ZEO install
------------------

    >>> stdout, stderr, returncode = doCommand('./install.sh zeo --with-python={} --target={} --password=admin'.format(withPython, testTarget))
    >>> returncode and (stdout + stderr)
    0

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
    ['Plone-docs', 'buildout-cache', 'zeocluster']

    There should now be a buildout skeleton in zeocluster
    >>> expected = ['.installed.cfg', 'README.html', 'adminPassword.txt', 'base.cfg', 'bin', 'buildout.cfg', 'develop-eggs', 'develop.cfg', 'lxml_static.cfg', 'parts', 'products', 'var', 'requirements.txt']
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
    >>> stdout, stderr, returncode = doCommand('./install.sh zeo --with-python={} --target={} --password=admin'.format(withPython, testTarget))
    >>> "ok" if "already exists; aborting install." in safestr(stdout) else stdout
    'ok'

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

    # wait for service
    >>> start = time.time()
    >>> import os
    >>> PLONE_SERVER_START_WAIT = int(os.environ.get('PLONE_SERVER_START_WAIT', 90))
    >>> while not (checkport(server="localhost", port=8080) and checkport(server="localhost", port=8081)):
    ...     time.sleep(1)
    ...     if time.time() - start > PLONE_SERVER_START_WAIT:
    ...         raise RuntimeError("cluster start took longer than {0} seconds".format(PLONE_SERVER_START_WAIT))

    Status check
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl status' % testTarget)
    >>> returncode == 0 or (returncode, stdout)
    True

    >>> safestr(stderr)
    ''

    Fetch root page via client1
    >>> response = urlopen('http://localhost:8080/')
    >>> body = safestr(response.read())
    >>> True if "Plone is up and running" in body else body
    True

    Fetch root page via client2
    >>> response = urlopen('http://localhost:8081/')
    >>> body = safestr(response.read())
    >>> True if "Plone is up and running" in body else body
    True

    Check Banner for WSGI
    >>> print(response.headers['server'])
    waitress

    Stop it
    >>> stdout, stderr, returncode = doCommand('%s/zeocluster/bin/plonectl stop' % testTarget)

    >>> returncode
    0

    >>> safestr(stderr)
    ''
