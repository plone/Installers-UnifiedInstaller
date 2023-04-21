=======
Windows
=======

Introduction
============

Plone's Unified Installer may be used to install Plone on Windows 10 for development, evaluation or testing purposes.
Windows is an uncommon choice for production (live, Internet-connected) purposes; it's possible to do it, but requires Windows integration experience that's not common in the Plone Community. 
Using Windows for development, evaluation, testing and training, though, is no problem.
In any case of questions or problems consult the `Plone Community Forum <https://community.plone.org>`_.

Prerequisites
=============

The Unified Installer is installed and operated via the Windows Command Prompt.
You will need expertise adequate to open a command prompt, navigate the file system and execute programs via the command prompt.
There are many excellent tutorials available, such as `Windows Command Prompt in 15 Minutes <https://www.cs.princeton.edu/courses/archive/spr05/cos126/cmd-prompt.html>`_.

Requirements
============

- Install Python 3.8 from the Windows Store
- Install Visual Studio Build Tools 2019. 
  Go to the Microsoft Store, search for Visual Studio. 
  You'll directed to a Microsoft web page, scroll down to the search bar and search for "Build Tools 2019". 
  Download and install the Visual Studio installer, search again in there for build tool and install them.
- Internet access: the installation process needs access to the Internet in order to install additional packages from the Python Package Index (PyPI) and installation configuration from dist.plone.org.

Download the Plone Unified Installer
====================================

Download the Plone Unified Installer from https://plone.org/download - choose the file ending with zip.
Keep track of the download location.


Installing Plone
================

Unpacking the installer
-----------------------

Select the downloaded file in Windows File Explorer and right click on it, in the menu select Extract All.

Running the installer
---------------------

Open a command prompt. Both are fine, cmd.exe or PowerShell.

Change your current directory to the unpacked archive's directory and execute the Windows install batch routine:

.. code-block:: bat

    cd Plone-5.2.12-UnifiedInstaller-1.0
    dir
    windows_install.bat standalone --password=admin

Options
.......

Run ``windows-install.bat`` with a "--help" argument to get an options listing::

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

Expect the installer to take a considerable amount of time to run, with very few messages after the build begins.
At the end of the install, expect a message like::

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

If you see anything different, look for error messages.
You may need to read the install log on disk.

You will probably also get a dialog from Windows Defender,
prompting you to allow network access for Python. 
For development purposes, [access to private networks](images/Plone-Windows-Firewall.png) is sufficient.

Once installed, expect Plone (and buildout if you're doing development) to work as generally documented.
You will, of course, need to use Windows pathnames (substitute "\" for "/") rather than Unix forms.
