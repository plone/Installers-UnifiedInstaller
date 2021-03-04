=======================
Unified Installer Tests
=======================

Note that we are using "-etc-" for the doctest.ELLIPSIS

These tests assume that you have a "plonetest" directory in your $HOME directory.

-----------
Setup stuff
-----------

    >>> import os, os.path, time

This test should be run from the directory with windows_install.bat

    >>> os.chdir(os.path.join(os.getcwd(), '..'))
    >>> os.path.exists('windows_install.bat')
    True

windows_install.bat should be executable
    >>> os.access('windows_install.bat', os.X_OK)
    True


-------------
Usage Message
-------------

Running windows_install.bat with help option should result in a usage message:

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

    >>> stdout, stderr, returncode = doCommand('.\windows_install.bat --target {0} --password admin zeo'.format(testTarget))
    >>> returncode
    0

    >>> print(safestr(stdout).replace("\r", ""))
    -etc-
    ######################  Installation Complete  ######################
    <BLANKLINE>
    Plone successfully installed at -etc-
    -etc-

target should have basic kit::

    >>> contents = os.listdir(testTarget)
    >>> 'buildout-cache' in contents
    True

    >>> 'zeocluster' in contents
    True

    >>> len([x for x in contents if x.startswith('py')])
    1

There should now be a buildout skeleton in zeocluster::

    >>> expected = ['.installed.cfg', 'README.html', 'adminPassword.txt', 'base.cfg', 'bin', 'buildout.cfg', 'develop-eggs', 'develop.cfg', 'lxml_static.cfg', 'parts', 'products', 'var', 'requirements.txt']
    >>> found = os.listdir('%s\zeocluster' % testTarget)
    >>> [s for s in expected if s not in found]
    []

Parts should contain the needed components::

    >>> expected = ['client1', 'client2', 'zeoserver']
    >>> found = os.listdir('%s\zeocluster\parts' % testTarget)
    >>> [s for s in expected if s not in found]
    []

We should have an inituser for admin::

    >>> print(open('%s/zeocluster/parts/client1/inituser' % testTarget).read())
    admin:{SHA}-etc-

Check bin contents::

    >>> expected = ['runwsgi.exe', 'zeoserver_runzeo.bat', 'zeopack.exe', 'zopepy.exe']
    >>> found = os.listdir('%s/zeocluster/bin' % testTarget)
    >>> [s for s in expected if s not in found]
    []

Installing again to the same target should fail::

    >>> stdout, stderr, returncode = doCommand('.\windows_install.bat --target {0} --password admin zeo'.format(testTarget))
    >>> "already exists. Delete it if you wish" in safestr(stdout) or safestr(stdout)
    True

Check the Python
----------------

::

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


Run it
------

::

    >> zeo = doCommand('{}/zeocluster/bin/zeoserver_runzeo.bat'.format(testTarget), forever=True)
    >> client1 = doCommand('{target}/zeocluster/bin/runwsgi.exe -dv {target}/zeocluster/parts/client1/etc/wsgi.ini'.format(target=testTarget), forever=True)
    >> client2 = doCommand('{target}/zeocluster/bin/runwsgi.exe -dv {target}/zeocluster/parts/client2/etc/wsgi.ini'.format(target=testTarget), forever=True)
    >> programs = zeo, client1, client2
    >> cycles = 60
    
    
    
    >> for count in range(cycles):
    ..     time.sleep(1)
    ..     for program in programs:
    ..         if program.poll() != None:
    ..             print(programm.stderr)
    ..             raise RuntimeError(safestr(programm.stderr))
    ..     if checkport(port=8080) and checkport(port=8081):
    ..         print("ok")
    ..         break
    .. else:
    ..    print("No connection after ~{}secs.\n".format(cycles))
    ..    for program in programs:
    ..       program.kill()
    ..       print("#" * 80 + "\n")
    ..       print(safestr(program.stdout.read()))
    ..       print("+" * 80 + "\n")
    ..       print(safestr(program.stderr.read()))
   ok
    
Fetch root page via client1::

    >> "Plone is up and running" in urlopen('http://localhost:8080/').read()
    True

Fetch root page via client2::

    >> "Plone is up and running" in urlopen('http://localhost:8081/').read()
    True

Check Banner::

    >> print(urlopen('http://localhost:8080/').headers['server'])
    waitress

Stop it
-------
::

    >> for program in programs:
    ..     programm.kill()
