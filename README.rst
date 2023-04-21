============================
Plone 5.2: Unified Installer
============================

Language: `English <README.rst>`_ | `Portuguese(Brazil) <README-pt-br.rst>`_

The Plone Unified Installer installs Plone
and its dependencies from source on most Unix-like platforms and Windows 10.

The kit includes Plone and Zope and will download components like Python if needed.

Python is installed in a way that will not change or interfere with your system Python.

**Important: Back up your existing Plone site prior to running the installer
or running buildout to update.**

Features
========

- Checks for needed dependencies
- Choose between zeo and standalone install
- Choose between user and root install
- Create system user and group for running plone

For a full list of features, please check `the documentation <http://docs.plone.org/manage/installing/installation.html#installing-plone-using-the-unified-unix-installer>`_.

Installation
============

Windows users: please see the separate `Windows Instructions <docs/windows.rst>`_.

Download the Installer:

.. code-block:: shell

  wget --no-check-certificate https://launchpad.net/plone/5.2/5.2.12/+download/Plone-5.2.12-UnifiedInstaller-1.0.tgz

Extract the downloaded file:

.. code-block:: shell

  tar -xf Plone-5.2.12-UnifiedInstaller-1.0.tgz

Go the folder containing installer script:

.. code-block:: shell

  cd Plone-5.2.12-UnifiedInstaller-1.0

Run script:

.. code-block:: shell

   ./install.sh $OPTION

If you run the installer with no option arguments, it will ask a series of questions about basic options.

The installer will search the system path for Python 2.7 and Python 3.x executables that are candidates for creating your installation.
If you wish to specify a particular Python executable, use:

.. code-block:: shell

   ./install.sh --with-python=/usr/bin/python3 [other options]

Substituting the path to your Python 2.7 or 3.5+.

For a full list of options, many of which are not available via the dialog questions, use:

.. code-block:: shell

   ./install.sh --help

**Note:**

   For certain production install options you will have to run the installer with ``sudo`` or as root.

   This is generally not necessary when building development or evaluation systems.

Documentation
=============

Full documentation for end users can be found in the */docs* directory of this repository.

It is also available as part of our `documentation <https://docs.plone.org/manage/installing/installation.html#plone-unified-unix-installer>`_.


Contribute
==========

- Issue Tracker: https://github.com/plone/Installers-UnifiedInstaller/issues
- Source Code: https://github.com/plone/Installers-UnifiedInstaller
- Documentation: https://docs.plone.org/manage/installing/installation.html#plone-unified-unix-installer

Support
=======

If you are having issues, please let us know.

We have our community space at: https://community.plone.org/c/development/installer


License
=======

The project is licensed under the GPLv2.
