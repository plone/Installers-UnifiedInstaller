==========
Standalone
==========

.. admonition:: Description

   How to install Plone in standalone mode as user (rootless) or as super-user (root).

.. contents:: :local:


For a non-super-user (rootless) installation
============================================

If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at ``$HOME/Plone`` (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone 5.0.4 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:

.. code-block:: bash

  $ ./install.sh standalone

Now the installation process will start, depending on your machine this will take a couple of minutes.

To start Plone:

.. code-block:: bash

  $ $HOME/Plone/zinstance/bin/plonectl start

To stop Plone:

.. code-block:: bash

  $ $HOME/Plone/zinstance/bin/plonectl stop

To restart Plone:

.. code-block:: bash

  $ $HOME/Plone/zinstance/bin/plonectl restart

To check status:

.. code-block:: bash

  $ $HOME/Plone/zinstance/bin/plonectl status

Install Location, Root-less Install
-----------------------------------

- Base install at ``$HOME/Plone``, where ``$HOME`` is the user's home
  directory, by default. This may be changed with the ``--target`` installation
  option. If you change it, you'll also need to change the paths below.

  For a list of possible installation options, please read http://docs.plone.org/manage/installing/installation.html/unified-unix-installer/options.

- Python installed at ``$HOME/Plone/Python-2.7``

Stand-Alone, Root-less Overview
-------------------------------

- Zope Instance installed and configured at ``$HOME/Plone/zinstance``
    Both ``--target`` and ``--name`` options may change this.
- Add-on Products folder at ``$HOME/Plone/zinstance/products``
   (You may also install products via buildout.)
- ``Data.fs`` (ZODB) at ``$HOME/Plone/zinstance/var/filestorage``
- ``adminPassword.txt`` at ``$HOME/zinstance/adminPassword.txt``


For a super-user (root) installation
====================================

If you run the installation with root privileges, it will install
Python/Zope/Plone to **/opt/plone**.

Two Plone users will be created: plone_daemon and plone_buildout. You will
need to start Plone as plone_daemon and run buildout as plone_buildout. The
install will also create a plone_group group that includes both plone users.

To install Plone 5.0.4 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:

.. code-block:: bash

  $ sudo ./install.sh standalone

or on a sudo-less system

.. code-block:: bash

  $ su; ./install.sh standalone

Depending on your machine this will take a couple of minutes.

To start Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zinstance/bin/plonectl start

To stop Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zinstance/bin/plonectl stop

To restart Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zinstance/bin/plonectl restart

To check status:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zinstance/bin/plonectl status


Install Location, Root Install
------------------------------

- Base install at ``/opt/plone`` by default. This may be changed
  with the ``--target`` installation option. If you change it, you'll also need
  to change the paths below.

- Python installed at ``/opt/plone/Python-2.7``

Stand-Alone, Root Overview
--------------------------

- Zope Instance installed and configured at ``/opt/plone/zinstance``
    Both ``--target`` and ``--name`` options may change this.
- Add-on Products folder at ``/opt/plone/zinstance/products``
    (You may also install products via buildout.)
- ``Data.fs`` (ZODB) at ``/opt/plone/zinstance/var/filestorage``
- ``adminPassword.txt`` at ``/opt/plone/zinstance/adminPassword.txt``

Ports
=====

- Zope server runs on port 8080

Edit ``buildout.cfg`` and run ``bin/buildout`` to change port.