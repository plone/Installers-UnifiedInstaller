=======
Windows
=======

Introduction
============

The Plone Unified Installer may be used to install Plone on Windows 10 for development, evaluation or testing purposes.
Windows is an uncommon choice for production (live, Internet-connected) purposes; it's possible to do so, but requires Windows integration experience that's not common in the Plone Community.

Prerequisites
=============

The Unified Installer is installed and operated via the Windows Command Prompt.
You will need expertise adequate to open a command prompt, navigate the file system and execute programs via the command prompt.
There are many excellent tutorials available, such as `Windows Command Prompt in 15 Minutes <https://www.cs.princeton.edu/courses/archive/spr05/cos126/cmd-prompt.html>`_.

Requirements
============

- `Python 2.7.x x86-64 MSI Installer <https://www.python.org/downloads/windows/>`_ -- choose the "Windows x86-64 MSI installer" for the latest Python 2.7.
- `Microsoft Visual C++ Compiler for Python 2.7 <http://aka.ms/vcpython27>`_ -- this is a subset of MS VC++ that provides a full development kit for the Windows version of Python 2.7.x.
- Tar, a compressed archive utility, for Windows. This has been a standard part of Windows since build 17063. You may check for its existence by executing ``tar`` from a command prompt.
- Internet access. Unlike the Linux/Unix install, the Windows install needs access to the Internet in order to install additional packages from the Python Package Index (PyPI).

Check for tar first. If it's not available, update your copy of Windows.
Next, install Python, using the instructions below to make sure you choose the right options.
Finally, install the MSVC++ Compiler for Python 2.7. There are no options in this install.


Installing Python
-----------------

- Choose either *Install for all users* or *Install just for me*.
- On the installer's "Customize Python 2.7.x (64-bit)" page, scroll down and click on the option to ``Add python.exe to Path``.

After installing, make sure ``python.exe`` is in your PATH.

To test if it is in your PATH, type "python" and hit Return; if you see a message
``'python' is not recognized as an internal or external command, operable program or batch file``
then it is not in your PATH and you may have to restart Windows.

You can add it to your PATH manually with the command ``PATH=$PATH;c:\Python27``.


Download the Plone Unified Installer
====================================

Download the Plone Unified Installer from https://plone.org/download.
Keep track of the download location.


Installing Plone
================

Unpacking the installer
-----------------------

Open the Windows Command Prompt. Change your current directory to the download location and use ``tar`` to unpack the download.

.. code-block:: bat

    cd Download
    tar xf Plone-5.1.x-UnifiedInstaller.tgz

Substitute your version number as needed.

Running the installer
---------------------

Change your current directory to the unpacked archive's directory and execute the Windows install batch routine:

.. code-block:: bat

    cd Plone-5.1.x-UnifiedInstaller
    windows_install.bat standalone --password admin

Options
.......

Run ``windows-install.bat`` with a "--help" argument to get an options listing:

.. code-block:: bat

    windows_install.bat --help
    usage: windows_install.py [-h] [--password PASSWORD] [--target TARGET]
                              [--instance INSTANCE] [--clients CLIENTS]
                              {zeo,standalone}

    Plone instance creation utility

    positional arguments:
      {zeo,standalone}     Instance type to create.

    optional arguments:
      -h, --help           show this help message and exit
      --password PASSWORD  Instance password; If not specified, a random password
                           will be generated.
      --target TARGET      Use to specify top-level path for installs. Plone
                           instances will be built inside this directory. Default
                           is \Users\steve\Plone.
      --instance INSTANCE  Use to specify the name of the operating instance to be
                           created. This will be created inside the target
                           directory. Default is "zinstance" for standalone,
                           "zeocluster" for ZEO.
      --clients CLIENTS    Use with the "zeo" install method to specify the number
                           of Zope clients you wish to create. Default is 2.

Results
-------

.. code-block:: bat

    ######################  Installation Complete  ######################

    Plone successfully installed at \Users\steve\Plone\zinstance
    See \Users\steve\Plone\zinstance\README.html
    for startup instructions.

    Use the account information below to log into the Zope Management Interface
    The account has full 'Manager' privileges.

      Username: admin
      Password: admin

    This account is created when the object database is initialized. If you change
    the password later (which you should!), you'll need to use the new password.

    Use this account only to create Plone sites and initial users. Do not use it
    for routine login or maintenance.
