==========================
Plone 5: Unified Installer
==========================

The Plone Unified Installer is a source-installation kit that installs Plone
and its dependencies from source on most Unix-like platforms. The kit includes
Plone and Zope and will download components like Python if needed. Python is
installed in a way that will not change or interfere with your system Python.

**Important: Back up your existing Plone site prior to running the installer
or running buildout to update.**

Features
--------

- checks for needed dependencies
- choose between zeo and standalone install
- choose between user and root install
- create system user and group for running plone
- ...

Installation
------------

Download the Installer

.. code-block:: bash

  > wget --no-check-certificate https://launchpad.net/plone/5.0/5.0/+download/Plone-5.0-UnifiedInstaller.tgz

Extract the downloaded file

.. code-block:: bash

  > tar -xf Plone-5.0-UnifiedInstaller.tgz

Go the folder containing installer script

.. code-block:: bash

  > cd Plone-5.0-UnifiedInstaller

Run script

.. code-block:: bash

  > ./install.sh $OPTION

Please see http://docs.plone.org/manage/installing/installation.html/unified-unix-installer/options for a overview about all different options.

.. note:: For certain install options you will have to run the installer with sudo or as root.

Documentation
-------------

Full documentation for end users can be found in the "docs" folder, and is also available online at http://docs.plone.org/foo/bar


Contribute
----------

- Issue Tracker: https://github.com/plone//Installers-UnifiedInstaller/issues
- Source Code: https://github.com/plone//Installers-UnifiedInstaller
- Documentation: http://docs.plone.org/manage/installing/installation.html/unified-unix-installer

Support
-------

If you are having issues, please let us know.
We have our community space at: https://community.plone.org/c/installer


License
-------

The project is licensed under the GPLv2.














