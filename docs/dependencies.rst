============
Dependencies
============

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

Install libraries prior to running installer. 
Development versions of some packages are required for headers. 
Debian/Ubuntu package names are included below. 
RPM equivalents follow in a separate subsection.

Linux 
-----

Please ensure to have these packages installed.

Debian/Ubuntu:

- build-essential
- libjpeg-dev
- python-dev
- libxml2-dev
- libxslt1-dev

RPM:

- gcc-c++
- patch
- openssl-devel
- libjpeg-devel
- libxslt-devel
- readline-devel
- make
- which

SuSE Linux

.. code-block::

    sudo zypper install gcc-c++ patch openssl-devel libjpeg-devel libxslt-devel readline-devel make which python3-devel bzip2


Other Linux distributions may have slightly different names.

LibXML2/LibXSLT versions
------------------------

Many older systems have inadequate libxslt/libxml libraries. 
There is no point in installing old libraries. Plone requires libxml2 >= 2.7.8 and libxslt 1.1.26. 
In this case, use the ``--static-lxml`` option to get the installer to build and statically link these libraries.

OS X (El Capitan)
-----------------

The XCode command-line tools provides everything except libjpeg. 
Install that via MacPorts or Homebrew.

Optional
--------

Mainly used to support indexing of office-automation documents.

- wv (used to index Word documents)

  `wv <http://wvware.sourceforge.net/>`_
  may be installed after Plone install.

- poppler-utils (used to index PDFs)

  `poppler-utils <http://poppler.freedesktop.org/>`_
  may be installed after Plone install.
