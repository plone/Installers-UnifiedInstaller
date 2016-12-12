#!/bin/sh

# Usage: [sudo] ./install.sh [options] standalone|zeo|none
#
# Install methods available:
#    standalone - install standalone zope instance
#    zeo        - install zeo cluster
#    none       - will not run final buildout
#
# Use sudo (or run as root) for server-mode install.
#
# Options:
# --password=InstancePassword
#   If not specified, a random password will be generated.
#
# --clients=client-count
#   Use with the "zeo" install method to specify the number of Zope
#   clients you wish to create. Default is 2.
#
# --target=pathname
#   Use to specify top-level path for installs. Plone instances
#   and Python will be built inside this directory
#
# --instance=instance-name
#   Use to specify the name of the operating instance to be created.
#   This will be created inside the target directory if there's
#   no slash in the string..
#   Default is 'zinstance' for standalone, 'zeocluster' for ZEO.
#
# --daemon-user=user-name
#   In a server-mode install, sets the effective user for running the
#   instance. Default is 'plone_daemon'. Ignored for non-server-mode installs.
#
# --owner=owner-name
#   In a server-mode install, sets the overall owner of the installation.
#   Default is 'plone_buildout'. This is the user id that should be employed
#   to run buildout or make src or product changes.
#   Ignored for non-server-mode installs.
#
# --group=group-name
#   In a server-mode install, sets the effective group for the daemon and
#   buildout users. Default is 'plone_group'.
#   Ignored for non-server-mode installs.
#
# --with-python=/fullpathtopython2.7.x
#   If you have an already built Python that's adequate to run
#   Zope / Plone, you may specify it here.
#   virtualenv will be used to isolate the copy used for the install.
#
# --build-python
#   If you do not have a suitable Python available, the installer will
#   build one for you if you set this option. Requires Internet access
#   to download Python source.
#   Make sure that you have enough memory and swap.
#
# --without-ssl
#   Optional. Allows the build to proceed without ssl dependency tests.
#
# --var=pathname
#   Full pathname to the directory where you'd like to put the "var"
#   components of the install. By default target/instance/var.
#
# --backup=pathname
#   Full pathname to the directory where you'd like to put the backup
#   directories for the install. By default target/instance/var.
#
# --template=filename
#   Filename of a .cfg file in buildout_templates that you wish to use
#   to create the destination buildout.cfg file. Defaults to buildout.cfg.
#
# --nobuildout
#   Skip running bin/buildout. You should know what you're doing.
#
# Library build control options:
#
# --static-lxml
#   Forces a static build of libxml2 and libxslt dependencies.
#   Make sure that you have enough memory and swap.
#   Requires Internet access to download components.

# This script is actually just a wrapper to detect bash, and,
# if available, use it.
# Capture current working directory for build script
ORIGIN_PATH=`pwd`
export ORIGIN_PATH
# change to directory with script
PWD=`dirname $0`
cd $PWD
if which bash > /dev/null; then
    bash helper_scripts/main_install_script.sh "$@"
else
    . helper_scripts/main_install_script.sh
fi
cd "$ORIGIN_PATH"
