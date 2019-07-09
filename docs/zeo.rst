===
Zeo
===

.. admonition:: Description

   How to install Plone in zeo mode as user (rootless) or as super-user (root).

.. contents:: :local:

The clustered (ZEO) setup will take advantage of multi-core CPUs and is
recommended for a production deployment, while the standalone method is
easier for development or testing.

For a non-super-user (rootless) installation
============================================

If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at ``$HOME/Plone`` (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone 5.2 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command::

.. code-block:: bash

  $ ./install.sh zeo

Startup/Shutdown/Restart/Status instructions
--------------------------------------------

To start Plone:

.. code-block:: bash

  $ $HOME/Plone/zeocluster/bin/plonectl start

To stop Plone:

.. code-block:: bash

  $ $HOME/Plone/zeocluster/bin/plonectl stop

To restart Plone:

.. code-block:: bash

  $  $HOME/Plone/zeocluster/bin/plonectl restart

To check status:

.. code-block:: bash

  $ $HOME/Plone/zeocluster/bin/plonectl status

Install Location, Root-less Install
-----------------------------------

- ZEO cluster (server and 2 clients) installed and configured at
    ``$HOME/Plone/zeocluster``
    Both ``--target`` and ``--name`` options may change this.
- Add-on Products folder at ``$HOME/Plone/zeocluster/products``
    (You may also install products via buildout.)
- ``Data.fs`` (ZODB) at ``$HOME/Plone/zeocluster/var/filestorage``
- ``adminPassword.txt`` at ``$HOME/Plone/zeocluster/adminPassword.txt``

For a super-user (root) installation
=====================================

If you run the installation with root privileges, it will install
Python/Zope/Plone to ``/opt/plone``.

Two Plone users will be created: plone_daemon and plone_buildout. You will
need to start Plone as plone_daemon and run buildout as plone_buildout. The
install will also create a plone_group group that includes both plone users.

To install Plone 5.2 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command:

.. code-block:: bash

  $ sudo ./install.sh zeo

or on a sudo-less system:

.. code-block:: bash

  $ su; ./install.sh zeo

The "sudo" utility is required for a root install. This security utility is
included with most recent Unix workalikes and is easily installed on other
systems. On BSD-heritage systems, this in the security directory of the ports
collection.

Startup/Shutdown/Restart/Status instructions
--------------------------------------------

To start Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zeocluster/bin/plonectl start

To stop Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zeocluster/bin/plonectl stop

To restart Plone:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zeocluster/bin/plonectl restart

To check status:

.. code-block:: bash

  $ sudo -u plone_daemon /opt/plone/zeocluster/bin/plonectl status

test

Install Location, Root Install
------------------------------

- ZEO cluster (server and 2 clients) installed and configured at
    ``/opt/plone/zeocluster``
    Both ``--target`` and ``--name`` options may change this.
- Add-on Products folder at ``/opt/plone/zeocluster/`` products.
    (You may also install products via buildout.)
- ``Data.fs`` (ZODB) at ``/opt/plone/zeocluster/var/filestorage``
- ``adminPassword.txt`` at ``/opt/plone/zeocluster/adminPassword.txt``

Ports
=====

ZEO Cluster
------------

- ZEO server runs on port 8100
- ZEO client1 runs on port 8080
- ZEO client2 runs on port 8081
- ...

Edit ``buildout.cfg`` and run ``bin/buildout`` to change ports.
