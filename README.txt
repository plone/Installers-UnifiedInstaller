================================================
Plone : Unified Installer
================================================

The Plone Unified Installer is a source-installation kit that installs
Plone and its dependencies from source on most Unix-like platforms. The
kit includes Plone, Zope and Python. Python is installed in a way that
will not change or interfere with your system Python.

This version includes Plone , Zope 2.10.7, and Python 2.4.6.

The Unified Installer was originally developed for Plone 2.5 by Kamal Gill.
Adaptation to Plone 3.x and buildout: Steve McMahon (steve@dcn.org)
Maintainer for Plone 3.x: Steve McMahon
Feedback/bugs to: http://dev.plone.org/plone; component: Installer (Unified)

*Important:* Back up your existing Plone site prior to running the installer
or running buildout to update.


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
acceptable for testing and development purposes.

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
"Installing Plone 3 with the Unified Installer":http://plone.org/documentation/tutorial/installing-plone-3-with-the-unified-installer
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

To install Plone  in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:
	>> sudo ./install.sh standalone (or `su; ./install.sh standalone` on a sudo-less system)

To install Plone  in a ZEO Cluster (ZEO server, 2 clients) configuration:

* cd to the installer directory and issue the following command:
	>> sudo ./install.sh zeo (or `su; ./install.sh zeo` on a sudo-less system)


For a non-super-user (rootless) installation
--------------------------------------------
If you run the installation while logged in as a normal (non-root) user,
Python/Zope/Plone will be built at $HOME/Plone (the user's home
directory, Plone subdirectory). You will need to start Zope using
the user identity used for the build, and it will run with the
privileges of that user.

To install Plone  in a stand-alone (single Zope instance) configuration:

* cd to the installer directory and issue the following command:
	>> ./install.sh standalone

To install Plone  in a ZEO Cluster (ZEO server, 2 clients) configuration:

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

--instance=instance-name
  Use to specify the name of the operating instance to be created.
  This will be created inside the target directory.
  Default is 'zinstance' for standalone, 'zeocluster' for ZEO.

--user=user-name
  In a root install, sets the effective user for running the
  instance. Default is 'plone'. Ignored for non-root installs.

--with-python=/full/path/to/python2.4
  If you have an already built Python that's adequate to run
  Zope / Plone, you may specify it here.
  virtualenv will be used to isolate the copy used for the install.
  The specified Python will need to have been built with support
  for libz and libjpeg and include the Python Imaging Library.

--password=InstancePassword
  If not specified, a random password will be generated.

--libz=(local|global|no)
  Overrides the automatic determination of whether and where to
  install the libz compression library.

--libjpeg=(local|global|no)
  Overrides the automatic determination of whether and where to
  install the libjpeg JPEG library.
  
--readline=local
  Optional. Installs a local readline library. Only necessary
  on platforms with odd libraries (like OS X Leopard).

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


Recommended Libraries and Utilities
===================================
Install libraries prior to running installer.
Development versions of some packages are required for headers.

* libssl (SSL support)
     *Strongly recommended.*
     Used by openid and SecureMailHost; needed for https updates.
     libssl-dev
* zlib (GZ compression)
     The Unified Installer will install this for you if necessary,
     but system libraries are usually preferable.
     zlib1g-dev
* libjpeg (jpeg support)
     The Unified Installer will install this for you if necessary,
     but system libraries are usually preferable.
     libjpeg62-dev
* readline (Python command-line history)
     libreadline5-dev readline-common
* libxml2 (used by marshall)
     libxml-dev
* wv (used to index Word documents)
     wv
     <http://wvware.sourceforge.net/>
     May be installed after Plone install.
* xpdf (used to index PDFs)
     xpdf
     <http://www.foolabs.com/xpdf/download.html>
     May be installed after Plone install.


Install Location, Root Install
==============================
- Base install at /usr/local/Plone by default. This may be changed
  with the --target installation option. If you change it, you'll also need
  to change the paths below.
- Python installed at /usr/local/Plone/Python-2.4
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
- Python installed at $HOME/Plone/Python-2.4
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
You should be able to view the Zope Management Interface at::

    http://localhost:8080/manage

And, your new Plone at::

    http://localhost:8080/Plone

(Use the admin password provided at yourinstance/adminPassword.txt)

Select "Plone site" from the "Add item" drop-down menu near top right to
add a Plone site. This only needs to be done once for each Plone site
you wish to add.

To change the admin password, click the "Password" link for the admin
user at::

    http://localhost:8080/acl_users/users/manage_users

Password changes will not be reflected in adminPassword.txt.


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

Updating the installation
-------------------------
To update your installation, backup and run:

bin/buildout -n

from your instance directory. This will bring your installation up-to-date,
possibly updating Zope, Plone, eggs, and product packages in the process.
(The "-n" flag tells buildout to search for newer components.)

Check portal_migration in the ZMI after update to perform version migration
if necessary. You may also need to visit the product installer to update
product versions.


Third-party products installed
==============================
- PIL (Python Imaging Library)
- libjpeg (JPEG library, usually installed to target/Python2.4/lib)
- libz (compression, usually installed to target/Python2.4/lib)
- libxml2-python (required for Marshall support)
- Cheetah, Paste, PasteDeploy, PasteScript, ZopeSkel
- The buildout recipe also installs elementtree


Platform Notes
==============
The install script requires a POSIX-compliant version of sh. If your
version of sh fails on test expressions, you may need to edit the
install script to specify use of zsh, bash or a later version of sh.

The install script requires several GNU build utilities such as gcc,
g++, make, gunzip, bunzip2 and tar. You may need to edit the install
script to specify their locations and names.

The install script tries to find zlib and libjpeg libraries. If it can't
find them, it installs them locally in the target directory. If the
library detection code in the installation script doesn't meet your
needs, you may force a particular choice by editing the script.


Tested on the following operating environments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Ubuntu 7.04, 7.10 Server
- Mac OS X 10.4.x, 10.5.x
  (with Xcode tools; make sure to reinstall XCode when you upgrade to Leopard.
   On Leopard, it's strongly advised to install the MacPorts version of the
   readline library before running the Unified Installer.)
- FreeBSD 6.1
- OpenBSD 4.2 (see note below)

Previous 3-series Unified Installers were tested with the list below, and
will probably work with them.
- Ubuntu 6.06, 6.10 Server
- Solaris 10
  (edit install.sh to specify /bin/zsh or /bin/bash rather than /bin/sh;
   edit tool paths for GNU tools.)
- Fedora Core 6
- Fedora 7 (64-bit PowerPC, x86_64)
- SUSE LES 10

OpenBSD
~~~~~~~
The Unified Installer is not smart enough to install Python 2.4.x on OpenBSD;
it just requires too many platform-specific patches.

Alternatively, you may install for OpenBSD by preinstalling Python 2.4 packages,
then telling the Unified Installer to use the preinstalled Python.

Test builds on OpenBSD 4.2 succeeded with the following packages pre-installed:

bzip2-1.0.4          block-sorting file compressor, unencumbered
python-2.4.4p4       interpreted object-oriented programming language
python-expat-2.4.4p4 expat module for Python

If you are unable to install python-expat-2.4.4p4, you may need to install the
xbase file set, which includes expat in some versions of OpenBSD (4.2). 

Then, when you run the Unified Installer, add the command-line argument:

    --with-python=/usr/local/bin/python2.4
    

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
any other Python on your system.  The Installer bundles Python 2.4.6,
placing it at /usr/local/Plone/Python-2.4 or $HOME/Plone/Python-2.4.


Installer Bug reports
=====================
Please use the Plone issue tracker at http://dev.plone.org/plone for all
bug reports. Specify the "Installer (Unified)" component.


Credits
=======
Thanks to Martin Aspeli and Wichert Akkerman for vital hints and suggestions
with the buildout version.

Thanks for Naotaka Jay Hotta for suggesting -- and offering an initial
implementation for -- stand-alone and cluster configuration options.

Thanks to Larry T of the Davis Plone Group for the first implementation
of the rootless install.

Thanks to Alex Clark and Raphael Ritz for help with creation of a Plone
site in the initial database.

Thanks to the Davis (California) Plone Users Group for helping with
testing.

Thanks to Barry Page and Larry Pitcher for their work on the init scripts.
