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
