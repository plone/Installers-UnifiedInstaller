=======
Windows
=======

Requirements
============

- `Python 2.7.x x86-64 MSI Installer <https://www.python.org/downloads/windows/>`_ -- choose the "Windows x86-64 MSI installer" for the latest Python 2.7.
- `Microsoft Visual C++ Compiler for Python 2.7 <http://aka.ms/vcpython27>`_ -- this is a subset of MS VC++ that provides a full development kit for the Windows version of Python 2.7.x.

Installing Python
-----------------
- Choose either *Install for all users* or *Install just for me*.
- On the installer's "Customize Python 2.7.x (64-bit)" page, scroll down and click on the option to ``Add python.exe to Path``.

After installing, make sure ``python.exe`` is in your PATH.

To test if it is in your PATH, type "python" and hit Return; if you see a message
``'python' is not recognized as an internal or external command, operable program or batch file``
then it is not in your PATH and you may have to restart Windows.

You can add it to your PATH manually with the command ``PATH=$PATH;c:\Python27``.

.. image:: _static/customize-python-setup-add-to-path.jpg
   :alt: Picture of Python Installer

Installing Plone
================

