Updating the Unified Installer
==============================

This text is for those wishing to build a new version of the Unified Installer.
It is not meant to help update an installed version of Plone.

Note that 5.2+ does not have a buildout_cache.
This saves steps from previous installers.

Use a text editor to replace old version with new in all text/documentation files and in

::

    helper_scripts/main_install_script.sh
    buildout_templates/buildout.cfg
    buildme.sh

In ``buildout.cfg``, make sure to update version numbers in both extends and find-links sections.

Do not auto-replace in HISTORY.txt.
Instead, add a new section at the top.

Update the version files.

::

    cd base_skeleton
    rm *versions.cfg
    ../fetch_versions.py 5.2.x

Note that fetch_versions updates both buildout version files and the ``requirements.txt``.

Look for the most recent update of virtualenv that is thought to be roughly compatible with the new release.
Be careful here, if it works for you it does not mean it works everywhere!
If the copy in ./packages is out-of-date, download the new one to ./packages and remove the old.
Note that setuptools, etc. will be updated based on the `requirements.txt` file downloaded by `fetch_versions.py` -- so you don't necessarily need a virtualenv that matches.

Run preliminary sanity-check installs, using both Python 2 and 3 (probably the default).

::

    rm ~/Plone
    ./install.sh --with-python=`which python2` zeo
    ./install.sh --with-python=`which python2` standalone

    rm ~/Plone
    ./install.sh --with-python=`which python3` zeo
    ./install.sh --with-python=`which python3` standalone

Make sure these builds succeed.
If they don't, debug.

To run the tests on macOS, use ``Homebrew <https://brew.sh>`_ to install Python dependencies::

    brew install libxml2 libxslt zlib openssl

Set LDFLAGS and CPPFLAGS environment variables so that Python will build correctly from source. Your paths may vary; check the output of your ``brew install`` commands::

    export LDFLAGS="-L/usr/local/opt/libxml2/lib -L/usr/local/opt/libxslt/lib -L/usr/local/opt/zlib/lib -L/usr/local/opt/openssl/lib"
    export CPPFLAGS="-I/usr/local/opt/libxml2/include -I/usr/local/opt/libxslt/include -I/usr/local/opt/zlib/include -I/usr/local/opt/openssl/include"

The tests check for a `plonetest` directory in your home directory, e.g. `/home/steve/plonetest`.
Before running the tests, you should create that directory and update the value of `testTarget` in the "Setup stuff" part of "`tests.txt`.

Run the tests::

    cd tests
    python testall.py testout.txt

Read the test results.
Fix silly problems.
Wash and repeat until clean.

Update the Plone version in ``buildme.sh``, specifically the `BASE_VER` and `INSTALLER_REVISION` variables.

If the `tar` on your system is not from GNU, install GNU tar.
On macOS, use `brew install gnu-tar`.

Update `BASE_VER` and `INSTALLER_REVISION` in `buildme.sh` then build a new installer:

    ./buildme.sh [destination]

where destination is the full or relative path to the working directory to use; defaults to ``~/nobackup/work`.
It does not work in a subdirectory of this directory.

* Upload to Launchpad.
* Update release page to link to new installer.
* Tag and push.

Testing the installer
---------------------

Configurations:

* standalone
* zeo
* Python 2
* Python 3

on these platforms:

* macOS
* Ubuntu LTS
* Debian
* Windows
* FreeBSD

With::

    ./install.sh --target=/home/bla/Plone-standalone-py2 --with-python=`which python2` standalone

    ./install.sh --target=/home/bla/Plone-zeo-py2 --with-python=`which python2` zeo

    ./install.sh --target=/home/bla/Plone-standalone-py3 --with-python=`which python3` standalone

    ./install.sh --target=/home/bla/Plone-zeo-py3 --with-python=`which python3` zeo
