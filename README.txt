==============================
Plone 4.3.3: Unified Installer
==============================

The Plone Unified Installer is a source-installation kit that installs Plone
and its dependencies from source on most Unix-like platforms. The kit includes
Plone and Zope and will download components like Python if needed. Python is
installed in a way that will not change or interfere with your system Python.

This version includes Plone 4.3.3, Zope 2.13.x, and uses Python 2.7.x.

Feedback/bugs to `Plone Development Workspace <https://dev.plone.org>`_
for component: **Installer (Unified)**

For a guide to installing and maintaining Plone, see
`Installing and maintaining Plone sites
<http://developer.plone.org/index.html#installing-and-maintaining-plone-sites>`_

If you are a deploying Plone for production, read
`Basics of Plone Production Deployment
<https://developer.plone.org/reference_manuals/active/deployment/index.html>`_
before continuing.

:Important: Back up your existing Plone site prior to running the installer
  or running buildout to update.

Outline of this document
------------------------

- `Installation Instructions`_

  - `For a non-super-user (rootless) installation`_
  - `For a super-user (root) installation`_

- `Installation Options`_
- `Upgrade From Plone 2.5 or Non-Buildout 3.x`_
- `Utility Dependencies`_
- `Libraries Required`_

  - `Required if you use your system Python 2.7.x`_
  - `Required if you need to build Python 2.7.x`_
  - `LibXML2/LibXSLT versions`_
  - `RPM Equivalents`_
  - `Optional`_

- `Install Location, Root Install`_
- `Install Location, Root-less Install`_
- `Startup/Shutdown/Restart/Status instructions`_

  - `Root Install`_
  - `Root-less Install`_

- `Ports`_
- `Post-installation Instructions`_
- `Root Install Notes`_
- `Installation Errors`_

  - `Errors building dependencies`_
  - `Built Python does not meet requirements`_

- `Updating After Installation`_

  - `Customizing the installation`_

- `Third-party products installed`_

- `Platform Notes`_

  - `Mac OS X`_
  - `Mac OS X Server`_
  - `MacPorts`_
  - `OpenBSD/NetBSD`_
  - `Unix/Solaris/etc.`_
  - `Installing behind HTTP proxies`_

- `Uninstall Instructions`_
- `Backup Instructions`_
- `Coexistence with System Python`_
- `Developer Options`_
- `Custom buildout.cfg Template`_
- `Installer Bug reports`_
- `Credits`_


Installation Instructions
=========================

The installer will compile Python, Zope, and key required libraries from
source on an as-needed basis. (Basic build tools and common libraries are
required. See `Utility Dependencies`_ and `Libraries Required`_ below.

:PLEASE NOTE: You have the option to run the installation as root or a
  normal user. There are serious security implications to this choice.

The non-root method produces an install that will run the Zope server with the
same privileges as the installing user. This is probably not an acceptable
security profile for a production server, but is much easier for testing and
development purposes or if you take care to set  users and privileges
yourself.

The 'root' method produces an install that runs the Zope server as a
distinct user identity with minimal privileges (unless you add them).
Providing adequate security for a production server requires many more
steps, but this is a better starting point.

:PLEASE NOTE: You have the option to install Plone as a standalone
  (single-instance) setup or as a clustered (ZEO) setup.

The clustered (ZEO) setup will take advantage of multi-core CPUs and is
recommended for a production deployment, while the standalone method is
easier for development or testing.

For more detail on both root/non-root and ZEO/standalone choices, see
`Installing on Linux / Unix / BSD
<http://plone.org/documentation/manual/installing-plone/installing-on-linux-unix-bsd>`_
in the Plone.org documentation section.


For a non-super-user (rootless) installation
--------------------------------------------

If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at ``$HOME/Plone`` (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone 4.3.3 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command::

    >> ./install.sh standalone

To install Plone 4.3.3 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command::

    >> ./install.sh zeo


For a super-user (root) installation
------------------------------------

If you run the installation with root privileges, it will install
Python/Zope/Plone to ``/usr/local/Plone``.

[Darwin (OS X) Note: Under Darwin, the default installation is to
/Applications/Plone for the root install. Please replace /usr/local with
/Applications in the instructions below.]

Two Plone users will be created: plone_daemon and plone_buildout. You will
need to start Plone as plone_daemon and run buildout as plone_buildout. The
install will also create a plone_group group that includes both plone users.

To install Plone 4.3.3 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command::

  >> sudo ./install.sh standalone

  or on a sudo-less system::

  >> su; ./install.sh standalone

To install Plone 4.3.3 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command::

  >> sudo ./install.sh zeo

  or on a sudo-less system::

  >> su; ./install.sh zeo

The "sudo" utility is required for a root install. This security utility is
included with most recent Unix workalikes and is easily installed on other
systems. On BSD-heritage systems, this in the security directory of the ports
collection.


Installation Options
====================

:Usage: ``[sudo] install.sh [options] standalone|zeo``

Install methods available:

:standalone:  install standalone zope instance
:zeo:         install zeo cluster

Use sudo (or run as root) for root install.

Options
-------

--target=pathname
  Use to specify top-level path for installs. Plone instances
  and Python will be built inside this directory.
  Default is ``/usr/local/Plone`` for root install,
  ``$HOME/Plone`` for non-root.

  PLEASE NOTE: Your pathname should not include spaces.

--instance=instance-name
  Use to specify the name of the operating instance to be created.
  This will be created inside the target directory.
  Default is 'zinstance' for standalone, 'zeocluster' for ZEO.

--clients=client-count
  Use with the "zeo" install method to specify the number of Zope
  clients you wish to create. Default is 2.

--daemon-user=user-name
  In a root install, sets the effective system user for running the
  instance. Default is 'plone_daemon'.
  Ignored for non-root installs.

--owner=owner-name
  In a server-mode install, sets the overall system owner of the installation.
  Default is 'plone_buildout'. This is the user id that should be employed
  to run buildout or make src or product changes.
  Ignored for non-root installs.

--group=group-name
  In a server-mode install, sets the effective system group for the daemon and
  buildout users. Default is 'plone_group'.
  Ignored for non-server-mode installs.

--with-python=</full/path/to/python2.7>
  If you have an already built Python that's adequate to run
  Zope / Plone, you may specify it here.
  virtualenv will be used to isolate the copy used for the install.
  The specified Python will need to have been built with support
  for libz and libjpeg and include the Python Imaging Library.

--build-python
  If you do not have a suitable Python available, the installer will
  build one for you if you set this option. Requires Internet access
  to download Python source.

--password=InstancePassword
  If not specified, a random password will be generated.

--libjpeg=<auto|yes|no>
  Overrides the automatic determination of whether and where to
  install the libjpeg JPEG library.

--readline=<auto|yes|no>
  Optional. Installs a local readline library. Only necessary
  on platforms with odd libraries (like OS X Leopard).

--without-ssl
  Optional. Allows the build to proceed without ssl dependency tests.

--static-lxml
  Forces a static build of lxml's libxml2 and libxslt dependencies. Requires
  Internet access to download components.

Note that you may run install.sh repeatedly for the same target so long
as you either use a different installation method or specify different
instance names. Installations to the same target will share the same Python
and egg/download cache.


Upgrade From Plone 2.5 or Non-Buildout 3.x
==========================================

See `UPGRADING.txt <UPGRADING.txt>`_


Utility Dependencies
====================

Most of these are included with system "build" kits.

- gcc
- g++ (gcc-c++)
- GNU make
- GNU tar
- patch
- gunzip and bunzip2
- posix-compliant /bin/sh
- curl or wget

Libraries Required
==================

Install libraries prior to running installer. Development versions of some
packages are required for headers. Debian/Ubuntu package names are included
below. RPM equivalents follow in a separate subsection.

Required if you use your system Python 2.7.x
--------------------------------------------

- build-essential
- libjpeg-dev
- python-dev
- libxml2-dev
- libxslt1-dev

Required if you need to build Python 2.7.x
------------------------------------------

- build-essential
- libssl-dev
- libz-dev
- libjpeg-dev
- readline-dev
- libxml2-dev
- libxslt1-dev

LibXML2/LibXSLT versions
------------------------

Many older systems have inadequate libxslt/libxml libraries. There is no point
in installing old libraries. Plone requires libxml2 >= 2.7.8 and
libxslt 1.1.26. In this case, use the ``--static-lxml`` option to get the
installer to build and statically link these libraries.

RPM Equivalents
---------------

These are the RPM equivalents for the Debian/Ubuntu packages listed above:

- gcc-c++
- patch
- openssl-devel
- libjpeg-devel
- libxslt-devel
- readline-devel
- make
- which

Optional
--------

Mainly used to support indexing of office-automation documents.

- wv (used to index Word documents)

  `wv <http://wvware.sourceforge.net/>`_
  may be installed after Plone install.

- poppler-utils (used to index PDFs)

  `poppler-utils <http://poppler.freedesktop.org/>`_
  may be installed after Plone install.

Install Location, Root Install
==============================

- Base install at ``/usr/local/Plone`` by default. This may be changed
  with the ``--target`` installation option. If you change it, you'll also need
  to change the paths below.

- Python installed at ``/usr/local/Plone/Python-2.7``

- For ZEO Cluster:

  - ZEO cluster (server and 2 clients) installed and configured at
    ``/usr/local/Plone/zeocluster``
    Both ``--target`` and ``--name`` options may change this.
  - Add-on Products folder at ``/usr/local/Plone/zeocluster/`` products.
    (You may also install products via buildout.)
  - ``Data.fs`` (ZODB) at ``/usr/local/Plone/zeocluster/var/filestorage``
  - ``adminPassword.txt`` at ``/usr/local/Plone/zeocluster/adminPassword.txt``

- For Stand-Alone:

  - Zope Instance installed and configured at ``/usr/local/Plone/zinstance``
    Both ``--target`` and ``--name`` options may change this.
  - Add-on Products folder at ``/usr/local/Plone/zinstance/products``
    (You may also install products via buildout.)
  - ``Data.fs`` (ZODB) at ``/usr/local/Plone/zinstance/var/filestorage``
  - ``adminPassword.txt`` at ``/usr/local/Plone/zinstance/adminPassword.txt``


Install Location, Root-less Install
===================================

- Base install at ``$HOME/Plone``, where ``$HOME`` is the user's home
  directory, by default. This may be changed with the ``--target`` installation
  option. If you change it, you'll also need to change the paths below.

- Python installed at ``$HOME/Plone/Python-2.7``

- For ZEO Cluster:

  - ZEO cluster (server and 2 clients) installed and configured at
    ``$HOME/Plone/zeocluster``
    Both ``--target`` and ``--name`` options may change this.
  - Add-on Products folder at ``$HOME/Plone/zeocluster/products``
    (You may also install products via buildout.)
  - ``Data.fs`` (ZODB) at ``$HOME/Plone/zeocluster/var/filestorage``
  - ``adminPassword.txt`` at ``$HOME/Plone/zeocluster/adminPassword.txt``

- For Stand-Alone:

  - Zope Instance installed and configured at ``$HOME/Plone/zinstance``
    Both ``--target`` and ``--name`` options may change this.
  - Add-on Products folder at ``$HOME/Plone/zinstance/products``
    (You may also install products via buildout.)
  - ``Data.fs`` (ZODB) at ``$HOME/Plone/zinstance/var/filestorage``
  - ``adminPassword.txt`` at ``$HOME/zinstance/adminPassword.txt``


Startup/Shutdown/Restart/Status instructions
============================================

Root Install
------------

To start Plone::

    >> sudo -u plone_daemon /usr/local/Plone/zeocluster/bin/plonectl start

To stop Plone::

    >> sudo -u plone_daemon /usr/local/Plone/zeocluster/bin/plonectl stop

To restart Plone::

    >> sudo -u plone_daemon /usr/local/Plone/zeocluster/bin/plonectl restart

To check status::

    >> sudo -u plone_daemon /usr/local/Plone/zeocluster/bin/plonectl status

Replace "zeocluster" with "zinstance" or your instance name if this wasn't a
standard zeo install.

Root-less Install
-----------------

To start Plone::

    >> $HOME/Plone/zeocluster/bin/plonectl start

To stop Plone::

    >> $HOME/Plone/zeocluster/bin/plonectl stop

To restart Plone::

    >> $HOME/Plone/zeocluster/bin/plonectl restart

To check status::

    >> $HOME/Plone/zeocluster/bin/plonectl status

Replace "zeocluster" with "zinstance" or your instance name if this wasn't a
standard zeo install.


Ports
=====

- Stand-Alone:

  - Zope server runs on port 8080

    Edit ``buildout.cfg`` and run ``bin/buildout`` to change port.

- ZEO Cluster:

  - ZEO server runs on port 8100
  - ZEO client1 runs on port 8080
  - ZEO client2 runs on port 8081
  - ...

Edit ``buildout.cfg`` and run ``bin/buildout`` to change ports.


Post-installation instructions
==============================
You should be able to view the welcome page at http://localhost:8080/

That page offers options to create a new Plone site and to use the Zope
Management Interface (ZMI) for lower-level control. Among the ZMI options
is the ability to create additional Plone instances inside the Zope
Zope object database.

(Use the admin password provided at ``yourinstance/adminPassword.txt``)

Select "Plone site" from the "Add item" drop-down menu near top right to
add a Plone site. This only needs to be done once for each Plone site
you wish to add.

To change the admin password, click the "Password" link for the admin
user at http://localhost:8080/acl_users/users/manage_users

Password changes will not be reflected in ``adminPassword.txt``

Root Install Notes
==================

If you install as root, the installer will set you instance up for operation
under specific user and group ids.

:user: plone_daemon

    This user id will be used to own the "var" and "backup" components of
    the install. You should run Plone using this user id::

      sudo -u plone_daemon bin/plonectl start

:user: plone_buildout

    This user id will own everything else in your installation. You must
    run buildout using this user id::

      sudo -u plone_buildout bin/buildout

:group: plone_group

The id, "plone" unless you specify otherwise, will be
created if it doesn't exist.

The Zope daemon will be set up run under this user id, and the user will be the
owner of the files in the instance and buildout cache subdirectories.

This means that you will need to prefix your start/stop/buildout commands with::

    sudo -u plone

to make sure they run under the correct user id.

If you try to start Zope as root, it will automatically switch effective ID to
the configured user. However, you'll need to be sure to run buildout
(for configuration updates) via sudo. Running buildout as root is a security
risk.


Installation Errors
===================

The installer may fail for a variety of reasons. If the error message is not
helpful, check the detailed installation log, install.log, to look for
problems. You may be able to get help on the #plone IRC channel on
freenode.net, or from the plone-users or plone-setup mailing lists.
See `Plone Support Center <http://plone.org/support>`_.
If you suspect the error is due to a bug in the installer,
see the `Installer Bug Reports`_ section below.

Errors building dependencies
----------------------------

If the install fails while trying to build a library like libjpeg or readline,
the best thing to do is nearly always to install an up-to-date system library
to meet the dependency. Then clean up the aborted install and try again.

Built Python does not meet requirements
---------------------------------------

This error is usually caused by a failure of the Python build to find system
libraries. This should only happen, though, if the Unified Installer itself
*did* find the libraries. Otherwise, the installation would have failed much
earlier.

On Debian, Ubuntu systems, the likely cause is that your system is not
accurately reporting its "multiarch" architecture. This seems to mainly happen
on systems that have been upgraded from development versions.

Other systems may just be using unexpected locations for libraries. This is
common on systems that have uncomfortable relationships with the GNU toolset
and install GNU tools in separate locations.

Whatever the cause, the general solution is to tell the Python setup routines
about the unexpected library location using the LDPATH environment variable.
For example, if your readline library was in ``/usr/lib/oddspot``,
you could try running the installer with a command like::

    LDPATH="-L/usr/lib/oddspot" ./install.sh zeo ...


Updating After Installation
===========================

Always back up your installation before customizing or updating.

Customizing the installation
----------------------------
You may control most aspects of your installation, including
changing ports and adding new packages and products by editing the
``buildout.cfg`` file in your instance home.

See tutorial `Managing projects with Buildout
<https://plone.org/documentation/manual/developer-manual/managing-projects-with-buildout>`_
for information on buildout options.

Apply settings by running ``bin/buildout`` in your buildout installation
directory.


Third-party products installed
==============================

- PIL (Python Imaging Library)
- libjpeg (JPEG library)
- libreadline (terminal mode command-line and prompt editing)
- Cheetah, Paste, PasteDeploy, PasteScript, ZopeSkel
- lxml, libxml2, libxslt


Platform Notes
==============
The install script requires a POSIX-compliant version of sh. If your
version of sh fails on test expressions, you may need to edit the
install script to specify use of zsh, bash or a later version of sh.

The install script requires several GNU build utilities such as gcc,
g++, make, gunzip, bunzip2 and tar.

The install script tries to find readline and libjpeg libraries.
If it can't find them, it installs them locally in the target directory.
If the library detection code in the installation script doesn't meet your
needs, you may force a particular choice by editing the script.

Note that readline installation is forced on OS X, where the default
readline library is incomplete.

Mac OS X
~~~~~~~~

OS X users will generally need to install XCode and XCode Command Line Tools.
Some have had luck using Homebrew to provide GNU build tools.
We only test with XCode.

XCode command-line tools have a separate step in recent versions of XCode.
If you seem to be missing gcc, you've missed that install step.

Building Python libraries with C-language components requires an extra step in XCode 5.1+.
See Apple's release notes for 5.1. https://developer.apple.com/library/mac/releasenotes/DeveloperTools/RN-Xcode/xc5_release_notes/xc5_release_notes.html#//apple_ref/doc/uid/TP40001051-CH2-SW1
The Unified Installer takes care of this for you when building the initial Plone, but you need to supply the environment flags when adding new Python eggs that have C-language components.

MacPorts
~~~~~~~~

If you're using MacPorts, it's probably best to follow an all-or-nothing
strategy: either use ports to pre-install all the dependencies (Python-2.7,
libxml2, libxslt, readline and libjpg), or don't use it at all.

Mac OS X Server
~~~~~~~~~~~~~~~

If you are using LDAP for directory services, the install.sh script may be
unable to reliably create users and groups.

In a custom environment such as this, scripted creation of users and groups
for a root installation of Plone may be inappropriate.

You can use Workgroup Manager (Apple Server Admin Tools) to create
groups that are typical to a production installation of Plone:

- plone
- zeo

then create users with UIDs below 500:

- plone
- zeo

For each user:
- match the Primary Group ID to the corresponding group
- decide whether to allow a shell
- specify the path to the home directory.

For root installation of a ZEO cluster on Mac OS X, custom paths might be:

- ``/Applications/Plone/homes/plone``
- ``/Applications/Plone/homes/zeo``

when scripted installation of Plone proceeds,
it will make that directory hierarchy for you.

After you configure users and groups to suit your planned use of Plone,
you can re-run install.sh.

OpenBSD/NetBSD
~~~~~~~~~~~~~~

The Unified Installer is not smart enough to install Python 2.7.x on
OpenBSD/NetBSD; it just requires too many platform- specific patches. Instead
of having the installer build Python, just make sure Python 2.7 is
preinstalled with system packages or ports.

Test builds on OpenBSD 4.2 succeeded with the following packages pre-installed:

bzip2-1.0.4
  block-sorting file compressor, unencumbered

python-2.7.3
  interpreted object-oriented programming language

python-expat-2.6.7
  expat module for Python

If you are unable to install python-expat-2.6.7, you may need to install the
xbase file set, which includes expat in some versions of OpenBSD (4.2).

Unix/Solaris/etc.
~~~~~~~~~~~~~~~~~

If you're using an \*nix system that does not use GNU build tools, you probably
already know that installing open-source software based on GNU tools requires
some extra work. Ideally, you'll have already installed the full GNU build
tool kit and become proficient with specifying compile and link paths to them
via CFLAGS and LDFLAGS. Expect to use those skills when installing Plone. If
CFLAGS/LDFLAGS/CPPFLAGS are in the environment when the installer is run, it
will use them rather than set its own. As with other environments, preinstall
as many dependencies as possible.

Installing behind HTTP proxies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The installer should not need to access network resources for most installs,
as it includes the needed components. However, if you need to use the static
xml build, network access will be required. Network access will also be
required when you run buildout later.

If you're behind an HTTP proxy, you're going to need to take special measures
to access the larger network.

As with Python setuptools in general, indicate an HTTP proxy by setting the
http_proxy environment variable::

    export http_proxy=http://192.168.1.25:80

before running the installer or buildout.

If you are using `sudo`, an extra step is needed to make sure the environment
variable passes to the invoked command. Use::

    sudo -E ./install.sh ...

or::

    sudo -E -u plone_buildout bin/buildout

to pass the execution environment via sudo.


Uninstall instructions
======================
1) Stop Plone
2) Remove folder ``/usr/local/Plone`` or ``$HOME/Plone``


Backup instructions
===================
1) Stop Plone
2) Back up folder ``/usr/local/Plone`` or ``$HOME/Plone``::

   >> tar -zcvf Plone-backup.tgz /usr/local/Plone

Live backup is possible.
See `Backup Plone <https://plone.org/documentation/kb/backup-plone>`_


Coexistence with System Python
==============================
The Python installed by the Unified Installer should *not* interfere with
any other Python on your system.  The Installer bundles Python 2.7.6,
placing it at ``/usr/local/Plone/Python-2.7`` or ``$HOME/Plone/Python-2.7``


Developer Options
=================
After installation, read the instructions at the top of the ``develop.cfg``
file at the top of the instance directory. This provides support for building
a development environment.


Custom buildout.cfg Template
============================

You may specify ``--template=`` to pick a file to use as a template for the
``buildout.cfg`` file. The file must be located in buildout_templates,
and should be generally modified on the ``buildout.cfg`` included with the
installer.
The safest customizations will be to add eggs, parts or version pinnings.

The purpose of this option is to allow for feature packaging for particular
use cases with common add-on needs.


Installer Bug reports
=====================
Please use the Plone issue tracker at https://dev.plone.org for all
bug reports. Specify the "Installer (Unified)" component.


Credits
=======
The Unified Installer was originally developed for Plone 2.5 by Kamal Gill.
Adaptation to Plone 3.x, 4.x and buildout: Steve McMahon (steve@dcn.org)
Maintainer for Plone 3.x, 4.x: Steve McMahon

Thanks to Martin Aspeli and Wichert Akkerman for vital hints and suggestions
with the buildout version.

Thanks for Naotaka Jay Hotta for suggesting -- and offering an initial
implementation for -- stand-alone and cluster configuration options.

Thanks to Larry T of the Davis Plone Group for the first implementation
of the rootless install.

Thanks to Barry Page and Larry Pitcher for their work on the init scripts.
