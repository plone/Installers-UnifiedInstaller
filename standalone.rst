==========
Standalone
==========

For a non-super-user (rootless) installation
============================================

If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at ``$HOME/Plone`` (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone 5.0b2 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command::

TODO: MISSING COMMANDS

Install Location, Root-less Install
===================================

- Base install at ``$HOME/Plone``, where ``$HOME`` is the user's home
  directory, by default. This may be changed with the ``--target`` installation
  option. If you change it, you'll also need to change the paths below.

- Python installed at ``$HOME/Plone/Python-2.7``

For a super-user (root) installation
====================================

If you run the installation with root privileges, it will install
Python/Zope/Plone to **/opt/plone**.

Two Plone users will be created: plone_daemon and plone_buildout. You will
need to start Plone as plone_daemon and run buildout as plone_buildout. The
install will also create a plone_group group that includes both plone users.

To install Plone 5.0b2 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command::

.. code-block:: bash

  $ sudo ./install.sh standalone

or on a sudo-less system

.. code-block:: bash

  $ su; ./install.sh standalone



