==============================
Plone 4.2.3: Unified Installer
==============================

The Plone Unified Installer is a source-installation kit that installs
Plone and its dependencies from source on most Unix-like platforms. The
kit includes Plone, Zope and Python. Python is installed in a way that
will not change or interfere with your system Python.

This version includes Plone 4.2.3, Zope 2.13.x, and Python 2.7.x.

Feedback/bugs to: http://dev.plone.org/plone; component: Installer (Unified)

For a guide to installing and maintaining Plone, see
http://collective-docs.readthedocs.org/en/latest/index.html#installing-and-maintaining-plone-sites

If you are a deploying Plone for production, read
``Basics of Plone Production Deployment <http://collective-docs.readthedocs.org/en/latest/hosting/basics/index.html>`_
before continuing.

*Important:* Back up your existing Plone site prior to running the installer
or running buildout to update.

Outline of this document
------------------------
    Installation Instructions
        For a super-user (root) installation
        For a non-super-user (rootless) installation
    Installation Options
    Dependencies
    Recommended Libraries and Utilities
    Install Location, Root Install
    Install Location, Root-less Install
    Startup/Shutdown/Restart/Status instructions
        Root Install
        Root-less Install
    Ports
    Post-installation Instructions
    Root Install Notes
    Updating After Installation
        Customizing the installation
    Third-party products installed
    Platform Notes
        Mac OS X Server
        Solaris
        OpenBSD/NetBSD
    Uninstall Instructions
    Backup Instructions
    Coexistence with System Python
    Developer Options
    Installer Bug reports
    Credits


Installation Instructions
=========================
The installer will compile Python, Zope, and key required libraries from
source. (Basic build tools and common libraries are required. See
"Dependencies" and "Recommended Libraries" below.)

PLEASE NOTE: You have the option to run the installation as root or a
normal user. There are serious security implications to this choice.

The non-root method produces an install that will run the Zope server
with the same privileges as the installing user. This is probably not an
acceptable security profile for a production server, but may be
acceptable for testing and development purposes or if you create an
unprivileged user exclusively for this purpose.

The 'root' method produces an install that runs the Zope server as a
distinct user identity with minimal privileges (unless you add them).
Providing adequate security for a production server requires many more
steps, but this is a better starting point.

PLEASE NOTE: You have the option to install Plone as a standalone
(single-instance) setup or as a clustered (ZEO) setup.

The clustered (ZEO) setup will take advantage of multi-core CPUs and is
recommended for a production deployment, while the standalone method is
easier for a desktop-based development setup.

For more detail on both root/non-root and ZEO/standalone choices, see
"Installing on Linux / Unix / BSD":http://plone.org/documentation/manual/installing-plone/installing-on-linux-unix-bsd
in the Plone.Org documentation section.


For a super-user (root) installation
------------------------------------
If you run the installation with root privileges, it will install
Python/Zope/Plone to /usr/local/Plone

[Darwin (OS X) Note: Under Darwin, the default installation is to
/Applications/Plone for the root install. Please replace /usr/local with
/Applications in the instructions below.]

A "plone" user will be added, and Zope will be configured to
run under that user id. You will need to start Zope as root or via sudo.

To install Plone 4.2 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:
	>> sudo ./install.sh standalone (or `su; ./install.sh standalone` on a sudo-less system)

To install Plone 4.2 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command:
	>> sudo ./install.sh zeo (or `su; ./install.sh zeo` on a sudo-less system)


For a non-super-user (rootless) installation
--------------------------------------------
If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at $HOME/Plone (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone 4.2 in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:
	>> ./install.sh standalone

To install Plone 4.2 in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command:
	>> ./install.sh zeo


Installation Options
====================
Usage: [sudo] install.sh [options] standalone|zeo

Install methods available:
   standalone - install standalone zope instance
   zeo        - install zeo cluster

Use sudo (or run as root) for root install.

Options:
--target=pathname
  Use to specify top-level path for installs. Plone instances
  and Python will be built inside this directory.
  Default is /usr/local/Plone for root install,
  $HOME/Plone for non-root.

  PLEASE NOTE: Your pathname should not include spaces.

--instance=instance-name
  Use to specify the name of the operating instance to be created.
  This will be created inside the target directory.
  Default is 'zinstance' for standalone, 'zeocluster' for ZEO.

--clients=client-count
  Use with the "zeo" install method to specify the number of Zope
  clients you wish to create. Default is 2.

--user=user-name In a root install, sets the effective user for running the
  instance. Default is 'plone'. Ignored for non-root installs. You should always
  use the same user within a given target.

--with-python=/full/path/to/python2.7
  If you have an already built Python that's adequate to run
  Zope / Plone, you may specify it here.
  virtualenv will be used to isolate the copy used for the install.
  The specified Python will need to have been built with support
  for libz and libjpeg and include the Python Imaging Library.

--password=InstancePassword
  If not specified, a random password will be generated.

--libjpeg=(auto|yes|no)
  Overrides the automatic determination of whether and where to
  install the libjpeg JPEG library.

--readline=(auto|yes|no)
  Optional. Installs a local readline library. Only necessary
  on platforms with odd libraries (like OS X Leopard).

--static-lxml
  Optional. Forces a static build of libxml2 and libxslt. Requires an
  Internet connection.

Note that you may run install.sh repeatedly for the same target so long
as you either use a different installation method or specify different
instance names. Installations to the same target will share the same Python
and egg/download cache.


Upgrade From Plone 2.5 or Non-Buildout 3.x
==========================================
See UPGRADING.txt


Dependencies
============
1) gcc
2) g++ (gcc-c++)
3) GNU make
4) GNU tar
5) gunzip and bunzip2
6) posix-compliant /bin/sh


Libraries and Utilities
=======================
Install libraries prior to running installer.
Development versions of some packages are required for headers. Debian/Ubuntu
package names are included below.

Required
--------
* Build Essentials (gcc, make)
     build-essential
* zlib (GZ compression), dev version
     zlibg-dev
* libssl (SSL support)
     Unless you use --with-python
     libssl-dev
* libxml2, libxslt,  dev versions
    Unless you specify --static-lxml
    libxml2-dev
    libxslt1-dev

Recommended
-----------
* libjpeg (jpeg support)
     The Unified Installer will install this for you if necessary,
     but system libraries are usually preferable.
     libjpeg-dev
* readline (Python command-line history)
     The Unified Installer will install this for you if necessary,
     but system libraries are preferable.
     libreadline5-dev readline-common
* wv (used to index Word documents)
     wv
     <http://wvware.sourceforge.net/>
     May be installed after Plone install.
* poppler-utils (used to index PDFs)
     poppler-utils
     <http://poppler.freedesktop.org/>
     May be installed after Plone install.

Install Location, Root Install
==============================
- Base install at /usr/local/Plone by default. This may be changed
  with the --target installation option. If you change it, you'll also need
  to change the paths below.
- Python installed at /usr/local/Plone/Python-2.7
- For ZEO Cluster
	- ZEO cluster (server and 2 clients) installed and configured at /usr/local/Plone/zeocluster
	  Both --target and --name options may change this.
	- Add-on Products folder at /usr/local/Plone/zeocluster/products.
	  (You may also install products via buildout.)
	- Data.fs (ZODB) at /usr/local/Plone/zeocluster/var/filestorage
	- adminPassword.txt at /usr/local/Plone/zeocluster/adminPassword.txt
- For Stand-Alone:
	- Zope Instance installed and configured at /usr/local/Plone/zinstance
	  Both --target and --name options may change this.
	- Add-on Products folder at /usr/local/Plone/zinstance/products
	  (You may also install products via buildout.)
	- Data.fs (ZODB) at /usr/local/Plone/zinstance/var/filestorage
	- adminPassword.txt at /usr/local/Plone/zinstance/adminPassword.txt


Install Location, Root-less Install
===================================
- Base install at $HOME/Plone, where $HOME is the user's home
  directory, by default. This may be changed with the --target installation
  option. If you change it, you'll also need to change the paths below.
- Python installed at $HOME/Plone/Python-2.7
- For ZEO Cluster
	- ZEO cluster (server and 2 clients) installed and configured at $HOME/Plone/zeocluster
	  Both --target and --name options may change this.
	- Add-on Products folder at $HOME/Plone/zeocluster/products
	  (You may also install products via buildout.)
	- Data.fs (ZODB) at $HOME/Plone/zeocluster/var/filestorage
	- adminPassword.txt at $HOME/Plone/zeocluster/adminPassword.txt
- For Stand-Alone:
	- Zope Instance installed and configured at $HOME/Plone/zinstance
	  Both --target and --name options may change this.
	- Add-on Products folder at $HOME/Plone/zinstance/products
	  (You may also install products via buildout.)
	- Data.fs (ZODB) at $HOME/Plone/zinstance/var/filestorage
	- adminPassword.txt at $HOME/zinstance/adminPassword.txt


Startup/Shutdown/Restart/Status instructions
=====================================

Root Install
------------
Stand-Alone:
	To start Plone,
		>> sudo /usr/local/Plone/zinstance/bin/plonectl start

	To stop Plone,
		>> sudo /usr/local/Plone/zinstance/bin/plonectl stop

	To check status,
		>> sudo /usr/local/Plone/zinstance/bin/plonectl status

ZEO Cluster:
	To start Plone,
		>> sudo /usr/local/Plone/zeocluster/bin/plonectl start

	To stop Plone,
		>> sudo /usr/local/Plone/zeocluster/bin/plonectl stop

	To restart Plone,
		>> sudo /usr/local/Plone/zeocluster/bin/plonectl restart

	To check status,
		>> sudo /usr/local/Plone/zeocluster/bin/plonectl status

Root-less Install
-----------------
Stand-Alone:
	To start Plone,
		>> $HOME/Plone/zinstance/bin/plonectl start

	To stop Plone,
		>> $HOME/Plone/zinstance/bin/plonectl stop

	To check status,
		>> $HOME/Plone/zinstance/bin/plonectl status

ZEO Cluster:
	To start Plone,
		>> $HOME/Plone/zeocluster/bin/plonectl start

	To stop Plone,
		>> $HOME/Plone/zeocluster/bin/plonectl stop

	To restart Plone,
		>> $HOME/Plone/zeocluster/bin/plonectl restart

	To check status,
		>> $HOME/Plone/zeocluster/bin/plonectl status


Ports
=====
Stand-Alone:
	- Zope server runs on port 8080

	Edit buildout.cfg and run bin/buildout to change port.

ZEO Cluster:
	- ZEO server runs on port 8100
	- ZEO client1 runs on port 8080
	- ZEO client2 runs on port 8081

	Edit buildout.cfg and run bin/buildout to change ports.


Post-installation instructions
==============================
You should be able to view the welcome page at::

    http://localhost:8080/

That page offers options to create a new Plone site and to use the Zope
Management Interface (ZMI) for lower-level control. Among the ZMI options
is the ability to create additional Plone instances inside the Zope
Zope object database.

(Use the admin password provided at yourinstance/adminPassword.txt)

Select "Plone site" from the "Add item" drop-down menu near top right to
add a Plone site. This only needs to be done once for each Plone site
you wish to add.

To change the admin password, click the "Password" link for the admin
user at::

    http://localhost:8080/acl_users/users/manage_users

Password changes will not be reflected in adminPassword.txt.

Root Install Notes
==================

If you install as root, the installer will set you instance up for operation
under a specific user id. The id, "plone" unless you specify otherwise, will be
created if it doesn't exist.

The Zope daemon will be set up run under this user id, and the user will be the
owner of the files in the instance and buildout cache subdirectories.

This means that you will need to prefix your start/stop/buildout commands with:

sudo -u plone

to make sure they run under the correct user id.

If you try to start Zope as root, it will automatically switch effective ID to
the configured user. However, you'll need to be sure to run buildout
(for configuration updates) via sudo. Running buildout as root is a security
risk.


Updating After Installation
===========================
Always back up your installation before customizing or updating.

Customizing the installation
----------------------------
You may control most aspects of your installation, including
changing ports and adding new packages and products by editing the
buildout.cfg file in your instance home.

See Martin Aspelli's excellent tutorial
"Managing projects with zc.buildout":http://plone.org/documentation/tutorial/buildout
for information on buildout options.

Apply settings by running bin/buildout in your buildout installation directory.


Third-party products installed
==============================
- PIL (Python Imaging Library)
- libjpeg (JPEG library)
- libreadline (terminal mode command-line and prompt editing)
- Cheetah, Paste, PasteDeploy, PasteScript, ZopeSkel
- lxml, libxml2, libxslt
- The buildout recipe also installs elementtree


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


Mac OS X Server
~~~~~~~~~~~~~~~
If you are using LDAP for directory services, the install.sh script may be
unable to reliably create users and groups.

In a custom environment such as this, scripted creation of users and groups
for a root installation of Plone may be inappropriate.

You can use Workgroup Manager (Apple Server Admin Tools) to create
groups that are typical to a production installation of Plone:
   plone
   zeo

then create users with UIDs below 500:
   plone
   zeo

For each user:
 * match the Primary Group ID to the corresponding group
 * decide whether to allow a shell
 * specify the path to the home directory.

For root installation of a ZEO cluster on Mac OS X, custom paths might be:

/Applications/Plone/homes/plone
/Applications/Plone/homes/zeo

-- when scripted installation of Plone proceeds,
   it will make that directory hierarchy for you.

After you configure users and groups to suit your planned use of Plone,
you can re-run install.sh.


Solaris (need further check)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to compile Python 2.6 and so on with Sun cc other than GNU cc,
you have to set an environmental variable CC=/your/Sun/cc.


OpenBSD/NetBSD
~~~~~~~~~~~~~~
The Unified Installer is not smart enough to install Python 2.6.x on
OpenBSD/NetBSD; it just requires too many platform-specific patches.

Alternatively, you may install for OpenBSD by preinstalling Python 2.6 packages,
then telling the Unified Installer to use the preinstalled Python.

Test builds on OpenBSD 4.2 succeeded with the following packages pre-installed:

bzip2-1.0.4          block-sorting file compressor, unencumbered
python-2.7.3         interpreted object-oriented programming language
python-expat-2.6.7   expat module for Python

If you are unable to install python-expat-2.6.7, you may need to install the
xbase file set, which includes expat in some versions of OpenBSD (4.2).

Then, when you run the Unified Installer, add the command-line argument:

    --with-python=/usr/local/bin/python2.7


Uninstall instructions
======================
1) Stop Plone
2) Remove folder /usr/local/Plone or $HOME/Plone


Backup instructions
===================
1) Stop Plone
2) Back up folder /usr/local/Plone or $HOME/Plone
   >> tar -zcvf Plone-backup.tgz /usr/local/Plone

Live backup is possible. See http://plone.org/documentation/how-to/backup-plone


Coexistence with System Python
==============================
The Python installed by the Unified Installer should *not* interfere with
any other Python on your system.  The Installer bundles Python 2.7.3,
placing it at /usr/local/Plone/Python-2.7 or $HOME/Plone/Python-2.7.


Developer Options
=================
After installation, read the instructions at the top of the develop.cfg
file at the top of the instance directory. This provides support for building
a development environment.


Installer Bug reports
=====================
Please use the Plone issue tracker at http://dev.plone.org/plone for all
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
