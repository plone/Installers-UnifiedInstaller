#!/bin/sh
#
# Unified Plone installer build script
# Copyright (c) 2008-2013 Plone Foundation. Licensed under GPL v 2.
#

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
#
# --without-ssl
#   Optional. Allows the build to proceed without ssl dependency tests.
#
# --with-site-packages
#   When --with-python is used to specify a python, that python is isolated
#   via virtualenv without site packages. Set the --with-site-
#   packages flag if you want to include system packages.
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
# --libjpeg=auto|yes|no
# --readline=auto|yes|no
# --static-lxml
#   Forces a static build of libxml2 and libxslt dependencies. Requires
#   Internet access to download components.


# Path for Root install
#
# Path for server-mode install of Python/Zope/Plone
if [ `uname` = "Darwin" ]; then
    PLONE_HOME=/Applications/Plone
else
    PLONE_HOME=/usr/local/Plone
fi
# Path options for Non-Root install
#
# Path for install of Python/Zope/Plone
LOCAL_HOME="$HOME/Plone"

# if we create a ZEO cluster, it will go here (inside $PLONE_HOME):
ZEOCLUSTER_HOME=zeocluster
# a stand-alone (non-zeo) instance will go here (inside $PLONE_HOME):
RINSTANCE_HOME=zinstance

INSTALL_LXML=no
INSTALL_ZLIB=auto
INSTALL_JPEG=auto
if [ `uname` = "Darwin" ]; then
  # Darwin ships with a readtext rather than readline; it doesn't work.
  INSTALL_READLINE=yes
else
  INSTALL_READLINE=auto
fi

# default user/group ids for root installs; ignored in non-root.
DAEMON_USER=plone_daemon
BUILDOUT_USER=plone_buildout
PLONE_GROUP=plone_group

# End of commonly configured options.
#################################################

readonly FOR_PLONE=4.3.2
readonly WANT_PYTHON=2.7

readonly PACKAGES_DIR=packages
readonly ONLINE_PACKAGES_DIR=opackages
readonly HSCRIPTS_DIR=helper_scripts
readonly TEMPLATE_DIR=buildout_templates

readonly PYTHON_URL=http://python.org/ftp/python/2.7.5/Python-2.7.5.tar.bz2
readonly PYTHON_MD5=6334b666b7ff2038c761d7b27ba699c1
readonly PYTHON_TB=Python-2.7.5.tar.bz2
readonly PYTHON_DIR=Python-2.7.5
readonly JPEG_TB=jpegsrc.v9.tar.bz2
readonly JPEG_DIR=jpeg-9
readonly READLINE_TB=readline-6.2.tar.bz2
readonly READLINE_DIR=readline-6.2
readonly VIRTUALENV_TB=virtualenv-1.10.1.tar.gz
readonly VIRTUALENV_DIR=virtualenv-1.10.1

readonly NEED_XML2="2.7.8"
readonly NEED_XSLT="1.1.26"

DEBUG_OPTIONS=no

if [ `whoami` = "root" ]; then
    ROOT_INSTALL=1
else
    ROOT_INSTALL=0
    # set paths to local versions
    PLONE_HOME="$LOCAL_HOME"
    DAEMON_USER="$USER"
    BUILDOUT_USER="$USER"
fi


# Capture current working directory for build script
ORIGIN_PATH=`pwd`
# change to directory with script
PWD=`dirname $0`
cd $PWD
# normalize
PWD=`pwd`
CWD="$PWD"
PKG="$CWD/$PACKAGES_DIR"

. helper_scripts/shell_utils.sh

usage () {
    echo
    echo "Usage: [sudo] `basename $0` [options] standalone|zeo"
    echo
    echo "Install methods available:"
    echo "   standalone - install standalone zope instance"
    echo "   zeo        - install zeo cluster"
    echo
    echo "Use sudo (or run as root) for server-mode install."
    echo
    echo "Options (see top of install.sh for complete list):"
    echo
    echo "--with-python=/full/path/to/python-${WANT_PYTHON}"
    echo "  Path to the Python-${WANT_PYTHON} that you wish to use with Plone."
    echo "  virtualenv will be used to isolate the install."
    echo
    echo "--build-python"
    echo "  If you do not have a suitable Python available, the installer will"
    echo "  build one for you if you set this option. Requires Internet access"
    echo "  to download Python source."
    echo
    echo "--password=InstancePassword"
    echo "  If not specified, a random password will be generated."
    echo
    echo "--target=pathname"
    echo "  Use to specify top-level path for installs. Plone instances"
    echo "  and Python will be built inside this directory"
    echo "  (default is $PLONE_HOME)"
    echo
    echo "--clients=client-count"
    echo "  Use with the "zeo" install method to specify the number of Zope"
    echo "  clients you wish to create. Default is 2."
    echo
    echo "--instance=instance-name"
    echo "  Use to specify the name of the operating instance to be created."
    echo "  This will be created inside the target directory."
    echo "  Default is 'zinstance' for standalone, 'zeocluster' for ZEO."
    echo
    echo "--daemon-user=user-name"
    echo "  In a server-mode install, sets the effective user for running the"
    echo "  instance. Default is 'plone_daemon'. Ignored for non-server-mode installs."
    echo
    echo "--owner=owner-name"
    echo "  In a server-mode install, sets the overall owner of the installation."
    echo "  Default is 'buildout_user'. This is the user id that should be employed"
    echo "  to run buildout or make src or product changes."
    echo "  Ignored for non-server-mode installs."
    echo
    echo "--group=group-name"
    echo "  In a server-mode install, sets the effective group for the daemon and"
    echo "  buildout users. Default is 'plone_group'."
    echo "  Ignored for non-server-mode installs."
    echo
    echo "--template=template-name"
    echo "  Specifies the buildout.cfg template filename. The template file must"
    echo "  be in the ${TEMPLATE_DIR} subdirectory. Defaults to buildout.cfg."
    echo
    echo "--static-lxml"
    echo "  Forces a static built of libxml2 and libxslt dependencies. Requires"
    echo "  Internet access to download components."
    echo
    echo "Read the top of install.sh for more install options."
    exit 1
}


#########################################################
# Pick up options from command line
#
#set defaults
INSTALL_ZEO=0
INSTALL_STANDALONE=0
INSTANCE_NAME=""
WITH_PYTHON=""
BUILD_PYTHON="no"
WITH_ZOPE=""
RUN_BUILDOUT=1
SKIP_TOOL_TESTS=0
INSTALL_LOG="$ORIGIN_PATH/install.log"
CLIENT_COUNT=2
TEMPLATE=buildout
WITHOUT_SSL="no"


for option
do
    optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`

    case $option in
        --with-python=* | -with-python=* | --withpython=* | -withpython=* )
            if [ "$optarg" ]; then
                WITH_PYTHON="$optarg"
            else
                usage
            fi
            ;;

        --build-python | --build-python=* )
            if [ "$optarg" ]; then
                BUILD_PYTHON="$optarg"
                if [ $BUILD_PYTHON != 'yes'] && [ $BUILD_PYTHON != 'no']; then
                    echo "Bad option for --build-python"
                    usage
                fi
            else
                BUILD_PYTHON="yes"
            fi
            ;;

        --with-site-packages )
            WITH_SITE_PACKAGES=yes
            ;;

        --target=* | -target=* )
            if [ "$optarg" ]; then
                PLONE_HOME="$optarg"
            else
                usage
            fi
            ;;

        --instance=* | -instance=* )
            if [ "$optarg" ]; then
                INSTANCE_NAME="$optarg"
            else
                usage
            fi
            ;;

        --var=* | -var=* )
            if [ "$optarg" ]; then
                INSTANCE_VAR="$optarg"
            else
                usage
            fi
            ;;

        --backup=* | -backup=* )
            if [ "$optarg" ]; then
                BACKUP_DIR="$optarg"
            else
                usage
            fi
            ;;

        --user=* | -user=* )
            echo "Did you want '--daemon-user' instead of '--user'?"
            usage
            ;;

        --daemon-user=* | -daemon-user=* )
            if [ "$optarg" ]; then
                DAEMON_USER="$optarg"
            else
                usage
            fi
            ;;

        --owner=* | -owner=* )
            if [ "$optarg" ]; then
                BUILDOUT_USER="$optarg"
            else
                usage
            fi
            ;;

        --group=* | -group=* )
            if [ "$optarg" ]; then
                PLONE_GROUP="$optarg"
            else
                usage
            fi
            ;;

        --jpeg=* | --libjpeg=* )
            if [ "$optarg" ]; then
                INSTALL_JPEG="$optarg"
            else
                usage
            fi
            ;;

        --readline=* | --libreadline=* )
            if [ "$optarg" ]; then
                INSTALL_READLINE="$optarg"
            else
                usage
            fi
            ;;

        --template=* )
            if [ "$optarg" ]; then
                TEMPLATE="$optarg"
                if [ ! -f "${TEMPLATE_DIR}/$TEMPLATE" ] && \
                   [ ! -f "${TEMPLATE_DIR}/${TEMPLATE}.cfg" ]; then
                   echo "Unable to find $TEMPLATE or ${TEMPLATE}.cfg in $TEMPLATE_DIR"
                   usage
                fi
            else
                usage
            fi
            ;;

        --static-lxml | --static-lxml=* )
            if [ "$optarg" ]; then
                INSTALL_LXML="$optarg"
            else
                INSTALL_LXML="yes"
            fi
            ;;

        --without-ssl | --without-ssl=* )
            if [ "$optarg" ]; then
                WITHOUT_SSL="$optarg"
            else
                WITHOUT_SSL="yes"
            fi
            ;;

        --password=* | -password=* )
            if [ "$optarg" ]; then
                PASSWORD="$optarg"
            else
                usage
            fi
            ;;

        --nobuild* | --no-build*)
            RUN_BUILDOUT=0
            ;;

        --skip-tool-tests )
            SKIP_TOOL_TESTS=1
            # don't test for availability of gnu build tools
            # this is mainly meant to be used when binaries
            # are known to be installed already
            ;;

        --install-log=* | --log=* )
            if [ "$optarg" ]; then
                INSTALL_LOG="$optarg"
            else
                usage
            fi
            ;;

        --clients=* | --client=* )
            if [ "$optarg" ]; then
                CLIENT_COUNT="$optarg"
            else
                usage
            fi
            ;;

        --debug-options )
            DEBUG_OPTIONS=yes
            ;;

        --help | -h )
            usage
            ;;

        *)
            case $option in
                zeo* | cluster )
                    INSTALL_ZEO=1
                    ;;
                standalone* | nozeo | stand-alone | sa )
                    INSTALL_STANDALONE=1
                    ;;
                none )
                    echo No template selected. Will use standalone template
                    echo for convenience, but not run bin/buildout.
                    INSTALL_STANDALONE=1
                    RUN_BUILDOUT=0
                    ;;
                *)
                    usage
                    ;;
            esac
        ;;
    esac
done

if [ "X$WITH_PYTHON" != "X" ] && [ "X$BUILD_PYTHON" = "Xyes" ]; then
    echo "--with-python and --build-python may not be employed at the same time."
fi

if [ $INSTALL_STANDALONE -eq 0 ] && [ $INSTALL_ZEO -eq 0 ]; then
    usage
fi
echo


if [ $ROOT_INSTALL -eq 1 ]; then
    if ! which sudo > /dev/null; then
        echo "sudo utility is required to do a server-mode install."
        echo
        exit 1
    fi
    SUDO="sudo -u $BUILDOUT_USER -E"
else
    SUDO=""
fi


# Most files and directories we install should
# be group/world readable. We'll set individual permissions
# where that isn't adequate
umask 022
# Make sure CDPATH doesn't spoil cd
unset CDPATH


# set up the common build environment unless already existing
if [ "x$CFLAGS" = 'x' ]; then
    export CFLAGS='-fPIC'
    if [ `uname` = "Darwin" ] && [ -d /opt/local ]; then
        # include MacPorts directories, which typically have additional
        # and later libraries
        export CFLAGS='-fPIC -I/opt/local/include'
        export CPPFLAGS=$CFLAGS
        export LDFLAGS='-L/opt/local/lib'
    fi
fi


if [ $SKIP_TOOL_TESTS -eq 0 ]; then
    # Abort install if this script is not run from within it's parent folder
    if [ ! -x "$PACKAGES_DIR" ] || [ ! -x "$HSCRIPTS_DIR" ]; then
        echo ""
        echo "The install script directory must contain"
        echo "$PACKAGES_DIR and $HSCRIPTS_DIR subdirectories."
        echo ""
        exit 1
    fi

    # Abort install if no cc
    which cc > /dev/null
    if [ $? -gt 0 ]; then
        echo
        echo "Error: gcc is required for the install."
        echo "See README.txt for dependencies."
        exit 1
    fi

    # build environment setup
    # use configure (renamed preflight) to create a build environment file
    # that will allow us to check for headers and tools the same way
    # that the cmmi process will.
    if [ -f ./buildenv.sh ]; then
        rm -f ./buildenv.sh
    fi
    sh ./preflight -q
    if [ $? -gt 0 ] || [ ! -f "buildenv.sh" ]; then
        echo ""
        echo "Unable to run preflight check. Basic build tools are missing."
        echo "You may get more information about what went wrong by running"
        echo "sh ./preflight"
        echo "Aborting installation."
        echo ""
        exit 1
    fi
    # suck in the results as shell variables that we can test.
    . ./buildenv.sh
fi

if [ -x "$PLONE_HOME/Python-${WANT_PYTHON}/bin/python" ] ; then
    HAVE_PYTHON=yes
    if [ "X$WITH_PYTHON" != "X" ]; then
        echo "We already have a Python environment for this target; ignoring --with-python."
        WITH_PYTHON=''
    fi
    if [ "X$BUILD_PYTHON" = "Xyes" ]; then
        echo "We already have a Python environment for this target; ignoring --build-python."
        BUILD_PYTHON=no
    fi
else
    HAVE_PYTHON=no

    # shared message for need python
    python_usage () {
        echo
        echo "Please do one of the following:"
        echo "1) Install python${WANT_PYTHON} as a system 'dev' package;"
        echo "2) Use --with-python=... option to point the installer to a useable python; or"
        echo "3) Use the --build-python option to tell the installer to build Python."
        exit 1
    }

    if [ "X$BUILD_PYTHON" = "Xyes" ]; then
        # if OpenBSD, apologize and surrender
        if [ `uname` = "OpenBSD" ]; then
            echo "\n***Aborting***"
            echo "Sorry, but the Unified Installer can't build a Python ${WANT_PYTHON} for OpenBSD."
            echo "There are way too many platform-specific patches required."
            echo "Please consider installing the Python ${WANT_PYTHON} port and re-run installer."
            exit 1
        fi

        # check to see if we've what we need to build a suitable python
        # Abort install if no libz
        if [ "X$HAVE_LIBZ" != "Xyes" ] ; then
            echo
            echo "Unable to find libz library and headers. These are required to build Python."
            echo "Please use your system package or port manager to install libz dev."
            echo "(Debian/Ubuntu zlibg-dev)"
            echo "Exiting now."
            exit 1
        fi

        if [ "X$WITHOUT_SSL" != "Xyes" ]; then
            if [ "X$HAVE_LIBSSL" != "Xyes" ]; then
                echo
                echo "Unable to find libssl or openssl/ssl.h."
                echo "libssl and its development headers are required for Plone."
                echo "Please install your platform's openssl-dev package"
                echo "and try again."
                echo "(If your system is using an SSL other than openssl or is"
                echo "putting the libraries/headers in an unconventional place,"
                echo "you may need to set CFLAGS/CPPFLAGS/LDFLAGS environment variables"
                echo "to specify the locations.)"
                echo "If you want to install Plone without SSL support, specify"
                echo "--without-ssl on the installer command line."
                exit 1
            fi
        fi

    else
        if [ "X$WITH_PYTHON" = "X" ]; then
            # try to find a Python
            WITH_PYTHON=`which python${WANT_PYTHON}`
            if [ $? -gt 0 ] || [ "X$WITH_PYTHON" = "X" ]; then
                echo "Unable to find python${WANT_PYTHON} on system exec path."
                python_usage
            fi
        fi
        # check our python
        if [ -x "$WITH_PYTHON" ] && [ ! -d "$WITH_PYTHON" ]; then
            echo "Testing $WITH_PYTHON for Zope/Plone requirements...."
            if "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py --without-ssl=${WITHOUT_SSL}; then
                echo "$WITH_PYTHON looks OK. We'll try to use it."
                echo
                # if the supplied Python is adequate, we don't need to build libraries
                INSTALL_ZLIB=no
                INSTALL_READLINE=no
                WITHOUT_SSL="yes"
            else
                echo
                echo "$WITH_PYTHON does not meet the requirements for Zope/Plone."
                python_usage
            fi
        else
            echo "Error: '$WITH_PYTHON' is not an executable. It should be the filename of a Python binary."
            python_usage
        fi
    fi
fi

#############################
# Preflight dependency checks
# Binary path variables may have been filled in by literal paths or
# by 'which'. 'which' negative results may be empty or a message.

if [ $SKIP_TOOL_TESTS -eq 0 ]; then

    # Abort install if no gcc
    if [ "x$CC" = "x" ] ; then
        echo
        echo "Note: gcc is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no g++
    if [ "x$CXX" = "x" ] ; then
        echo
        echo "Note: g++ is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no make
    if [ "X$have_make" != "Xyes" ] ; then
        echo
        echo "Note: make is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no tar
    if [ "X$have_tar" != "Xyes" ] ; then
        echo
        echo "Note: gnu tar is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no patch
    if [ "X$have_patch" != "Xyes" ] ; then
        echo
        echo "Note: gnu patch program is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no gunzip
    if [ "X$have_gunzip" != "Xyes" ] ; then
        echo
        echo "Note: gunzip is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no bunzip2
    if [ "X$have_bunzip2" != "Xyes" ] ; then
        echo
        echo "Note: bunzip2 is required for the install. Exiting now."
        exit 1
    fi

    if [ "$INSTALL_LXML" = "no" ]; then
        # check for libxml2 / libxslt

        XSLT_XML_MSG () {
            echo
            echo "Plone installation requires the development versions of libxml2 and libxslt."
            echo "libxml2 must be version $NEED_XML2 or greater; libxslt must be $NEED_XSLT or greater."
            echo "Ideally, you should install these as dev package libraries before running install.sh."
            echo "If -- and only if -- these packages are not available for your platform, you may"
            echo "try adding --static-lxml=yes to your install.sh command line to force a"
            echo "local, static build of these libraries. This will require Internet access for the"
            echo "installer to download the extra source"
            echo "Installation aborted."
        }

        if [ "x$XSLT_CONFIG" = "x" ]; then
            echo
            echo "Unable to find libxml2 development libraries."
            XSLT_XML_MSG
            exit 1
        fi
        if [ "x$XML2_CONFIG" = "x" ]; then
            echo
            echo "Unable to find libxslt development libraries."
            XSLT_XML_MSG
            exit 1
        fi
        if ! config_version xml2 $NEED_XML2; then
            echo "We need development version $NEED_XML2 of libxml2. Not found."
            XSLT_XML_MSG
            exit 1
        fi
        if ! config_version xslt $NEED_XSLT; then
            echo "We need development version $NEED_XSLT of libxslt. Not found."
            XSLT_XML_MSG
            exit 1
        fi
        FOUND_XML2=`xml2-config --version`
        FOUND_XSLT=`xslt-config --version`
    fi
fi # not skip tool tests


if [ "X$INSTALL_JPEG" = "Xauto" ] ; then
    if [ "X$HAVE_LIBJPEG" = "Xyes" ] ; then
        INSTALL_JPEG=no
    else
        INSTALL_JPEG=yes
    fi
fi

if [ "X$INSTALL_READLINE" = "Xauto" ] ; then
    if [ "X$HAVE_LIBREADLINE" = "Xyes" ] ; then
        INSTALL_READLINE=no
    else
        INSTALL_READLINE=yes
    fi
fi


######################################
# Pre-install messages
if [ $ROOT_INSTALL -eq 1 ]; then
    echo "Root install method chosen. Will install for use by users:"
    echo "  ZEO & Client Daemons:      $DAEMON_USER"
    echo "  Code Resources & buildout: $BUILDOUT_USER"
else
    echo "Rootless install method chosen. Will install for use by system user $USER"
fi
echo

######################################
# DEBUG OPTIONS
if [ "X$DEBUG_OPTIONS" = "Xyes" ]; then
    echo "Installer Variables:"
    echo "PLONE_HOME=$PLONE_HOME"
    echo "LOCAL_HOME=$LOCAL_HOME"
    echo "ZEOCLUSTER_HOME=$ZEOCLUSTER_HOME"
    echo "RINSTANCE_HOME=$RINSTANCE_HOME"
    echo "INSTALL_LXML=$INSTALL_LXML"
    echo "INSTALL_ZLIB=$INSTALL_ZLIB"
    echo "INSTALL_JPEG=$INSTALL_JPEG"
    echo "INSTALL_READLINE=$INSTALL_READLINE"
    echo "DAEMON_USER=$DAEMON_USER"
    echo "BUILDOUT_USER=$BUILDOUT_USER"
    echo "PLONE_GROUP=$PLONE_GROUP"
    echo "FOR_PLONE=$FOR_PLONE"
    echo "WANT_PYTHON=$WANT_PYTHON"
    echo "PACKAGES_DIR=$PACKAGES_DIR"
    echo "ONLINE_PACKAGES_DIR=$ONLINE_PACKAGES_DIR"
    echo "HSCRIPTS_DIR=$HSCRIPTS_DIR"
    echo "ROOT_INSTALL=$ROOT_INSTALL"
    echo "PLONE_HOME=$PLONE_HOME"
    echo "DAEMON_USER=$DAEMON_USER"
    echo "BUILDOUT_USER=$BUILDOUT_USER"
    echo "ORIGIN_PATH=$ORIGIN_PATH"
    echo "PWD=$PWD"
    echo "CWD=$CWD"
    echo "PKG=$PKG"
    echo "WITH_PYTHON=$WITH_PYTHON"
    echo "BUILD_PYTHON=$BUILD_PYTHON"
    echo "HAVE_PYTHON=$HAVE_PYTHON"
    echo "CC=$CC"
    echo "CPP=$CPP"
    echo "CXX=$CXX"
    echo "GREP=$GREP"
    echo "have_bunzip2=$have_bunzip2"
    echo "have_gunzip=$have_gunzip"
    echo "have_tar=$have_tar"
    echo "have_make=$have_make"
    echo "have_patch=$have_patch"
    echo "XML2_CONFIG=$XML2_CONFIG"
    echo "XSLT_CONFIG=$XSLT_CONFIG"
    echo "HAVE_LIBZ=$HAVE_LIBZ"
    echo "HAVE_LIBJPEG=$HAVE_LIBJPEG"
    echo "HAVE_LIBSSL=$HAVE_LIBSSL"
    echo "HAVE_SSL2=$HAVE_SSL2"
    echo "HAVE_LIBREADLINE=$HAVE_LIBREADLINE"
    echo "FOUND_XML2=$FOUND_XML2"
    echo "FOUND_XSLT=$FOUND_XSLT"
    echo ""
    exit 0
fi


# set up log
if [ -f "$INSTALL_LOG" ]; then
    rm -f "$INSTALL_LOG"
fi
touch "$INSTALL_LOG" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "Unable to write to ${INSTALL_LOG}; detailed log will go to stdout."
    INSTALL_LOG="/dev/stdout"
else
    echo "Detailed installation log being written to $INSTALL_LOG"
    echo "Detailed installation log" > "$INSTALL_LOG"
    echo "Starting at `date`" >> "$INSTALL_LOG"
fi
seelog () {
    echo
    echo "Installation has failed."
    echo "See the detailed installation log at $INSTALL_LOG"
    echo "to determine the cause."
    exit 1
}


echo "Installing Plone ${FOR_PLONE} at $PLONE_HOME"
echo ""


#######################################
# create os users for root-level install
if [ $ROOT_INSTALL -eq 1 ]; then
    # source user/group utilities
    . helper_scripts/user_group_utilities.sh

    # see if we know how to do this on this platfrom
    check_ug_ability

    create_group $PLONE_GROUP
    create_user $DAEMON_USER $PLONE_GROUP
    check_user $DAEMON_USER $PLONE_GROUP
    create_user $BUILDOUT_USER $PLONE_GROUP
    check_user $BUILDOUT_USER $PLONE_GROUP

fi # if $ROOT_INSTALL


#######################################
# create plone home
if [ ! -x "$PLONE_HOME" ]; then
    mkdir "$PLONE_HOME"
    # normalize $PLONE_HOME so we can use it in prefixes
    if [ $? -gt 0 ] || [ ! -x "$PLONE_HOME" ]; then
        echo "Unable to create $PLONE_HOME"
        echo "Please check rights and pathnames."
        echo
        echo "Installation has failed."
        exit 1
    fi
    cd "$PLONE_HOME"
    PLONE_HOME=`pwd`
fi

cd "$CWD"


cd "$PLONE_HOME"
PLONE_HOME=`pwd`
# More paths
if [ ! "x$INSTANCE_NAME" = "x" ]; then
    # override instance home
    if echo "$INSTANCE_NAME" | grep "/"; then
        # we have a full destination, not just a name.
        # normalize
        ZEOCLUSTER_HOME=$INSTANCE_NAME
        RINSTANCE_HOME=$INSTANCE_NAME
    else
        ZEOCLUSTER_HOME=$PLONE_HOME/$INSTANCE_NAME
        RINSTANCE_HOME=$PLONE_HOME/$INSTANCE_NAME
    fi
else
    ZEOCLUSTER_HOME=$PLONE_HOME/$ZEOCLUSTER_HOME
    RINSTANCE_HOME=$PLONE_HOME/$RINSTANCE_HOME
fi

# Determine and check instance home
if [ $INSTALL_ZEO -eq 1 ]; then
    INSTANCE_HOME=$ZEOCLUSTER_HOME
elif [ $INSTALL_STANDALONE -eq 1 ]; then
    INSTANCE_HOME=$RINSTANCE_HOME
fi
if [ -x "$INSTANCE_HOME" ]; then
    echo "Instance target $INSTANCE_HOME already exists; aborting install."
    exit 1
fi

cd "$CWD"

if  [ "X$INSTALL_ZLIB" = "Xyes" ] || \
    [ "X$INSTALL_JPEG" = "Xyes" ] || \
    [ "X$INSTALL_READLINE" = "Xyes" ]
then
    NEED_LOCAL=1
else
    NEED_LOCAL=0
fi


if [ "X$WITH_PYTHON" != "X" ] && [ "X$HAVE_PYTHON" = "Xno" ]; then
    PYBNAME=`basename "$WITH_PYTHON"`
    PY_HOME=$PLONE_HOME/Python-2.7
    cd "$PKG"
    untar $VIRTUALENV_TB
    cd $VIRTUALENV_DIR
    if [ "X$WITH_SITE_PACKAGES" = "Xyes" ]; then
        echo "Creating python virtual environment with site packages."
        "$WITH_PYTHON" virtualenv.py "$PY_HOME"
    else
        echo "Creating python virtual environment, no site packages."
        "$WITH_PYTHON" virtualenv.py "$PY_HOME"
    fi
    cd "$PKG"
    rm -r $VIRTUALENV_DIR
    PY=$PY_HOME/bin/python
    if [ ! -x "$PY" ]; then
        echo "\nFailed to create virtual environment for $WITH_PYTHON"
        exit 1
    fi
    cd "$PY_HOME"/bin
    if [ ! -x python ]; then
        # add a symlink so that it's easy to use
        ln -s "$PYBNAME" python
    fi
    cd "$CWD"
    if ! "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py --without-ssl=${WITHOUT_SSL}; then
        echo
        echo "Python created with virtualenv no longer passes baseline"
        echo "tests."
        echo "You may need to omit --with-python and let the Unified Installer"
        echo "build its own Python. "
        exit 1
    fi
else # use already-placed python or build one
    PY_HOME=$PLONE_HOME/Python-2.7
    PY=$PY_HOME/bin/python
    if [ -x "$PY" ]; then
        # no point in installing zlib -- too late!
        INSTALL_ZLIB=no
    fi
fi


# Now we know where our Python is, and may finish setting our paths
LOCAL_HOME="$PY_HOME"
EI="$PY_HOME/bin/easy_install"
BUILDOUT_CACHE="$PLONE_HOME/buildout-cache"
BUILDOUT_DIST="$PLONE_HOME/buildout-cache/downloads/dist"

if [ ! -x "$LOCAL_HOME" ]; then
    mkdir "$LOCAL_HOME"
fi
if [ ! -x "$LOCAL_HOME" ]; then
    echo "Unable to create $LOCAL_HOME"
    exit 1
fi

. helper_scripts/build_libjpeg.sh

if [ ! -x "$PY" ]; then
    . helper_scripts/build_readline.sh

    if [ `uname` = "Darwin" ]; then
        # Remove dylib files that will prevent static linking,
        # which we need for relocatability
        rm -f "$PY_HOME/lib/"*.dylib
    fi

    # download python tarball if necessary
    cd "$PKG"
    if [ ! -f $PYTHON_TB ]; then
        echo "Downloading Python source from $PYTHON_URL"
        download $PYTHON_URL $PYTHON_TB $PYTHON_MD5
    fi
    cd "$CWD"

    . helper_scripts/build_python.sh

    # The virtualenv kit has copies of setuptools and pip
    echo "Installing setuptools..."
    cd "$PKG"
    untar $VIRTUALENV_TB
    cd $VIRTUALENV_DIR/virtualenv_support
    untar setuptools*.tar.gz
    cd setuptools*
    "$PY" setup.py install >> "$INSTALL_LOG" 2>&1
    if [ ! -x "$EI" ]; then
        echo "$EI missing. Aborting."
        seelog
        exit 1
    fi
    cd ..
    untar pip*.tar.gz
    cd pip*
    "$PY" setup.py install >> "$INSTALL_LOG" 2>&1
    cd "$PKG"
    rm -r $VIRTUALENV_DIR

    if [ ! -x "$EI" ]; then
        echo "$EI missing. Aborting."
        seelog
        exit 1
    fi
    if "$PY" "$CWD/$HSCRIPTS_DIR"/checkPython.py --without-ssl=${WITHOUT_SSL}; then
        echo "Python build looks OK."
    else
        echo
        echo "***Aborting***"
        echo "The built Python does not meet the requirements for Zope/Plone."
        echo "Check messages and the install.log to find out what went wrong."
        echo
        echo "See the 'Built Python does not meet requirements' section of"
        echo "README.txt for more information about this error."
        exit 1
    fi
fi


# From here on, we don't want any ad-hoc cflags or ldflags, as
# they will foul the modules built via distutils
unset CFLAGS
unset LDFLAGS


if [ -f "${PKG}/buildout-cache.tar.bz2" ]; then
    if [ -x "$BUILDOUT_CACHE" ]; then
        echo "Found existing buildout cache at $BUILDOUT_CACHE; skipping step."
    else
        echo "Unpacking buildout cache to $BUILDOUT_CACHE"
        cd $PLONE_HOME
        untar "${PKG}/buildout-cache.tar.bz2"
        # # compile .pyc files in cache
        # echo "Compiling .py files in egg cache"
        # "$PY" "$PLONE_HOME"/Python*/lib/python*/compileall.py "$BUILDOUT_CACHE"/eggs > /dev/null 2>&1
    fi
    if [ ! -x "$BUILDOUT_CACHE"/eggs ]; then
        echo "Buildout cache unpack failed. Unable to continue."
        seelog
        exit 1
    fi
else
    mkdir "$BUILDOUT_CACHE"
    mkdir "$BUILDOUT_CACHE"/eggs
    mkdir "$BUILDOUT_CACHE"/extends
    mkdir "$BUILDOUT_CACHE"/downloads
fi

if [ -x "$CWD/Plone-docs" ] && [ ! -x "$PLONE_HOME/Plone-docs" ]; then
    echo "Copying Plone-docs"
    cp -R "$CWD/Plone-docs" "$PLONE_HOME/Plone-docs"
fi


cd "$CWD"

# The main install may be done via sudo (if a root install). If it is,
# our current directory may become unreachable. So, copy the resources
# we'll need into a tmp directory inside the install destination.
WORKDIR="${PLONE_HOME}/tmp"
mkdir "$WORKDIR" > /dev/null 2>&1
cp -R ./buildout_templates "$WORKDIR"
cp -R ./base_skeleton "$WORKDIR"
cp -R ./helper_scripts "$WORKDIR"

########################
# Instance install steps
########################

cd "$WORKDIR"

if [ $ROOT_INSTALL -eq 1 ]; then
    echo "Setting $PLONE_HOME ownership to $BUILDOUT_USER:$PLONE_GROUP"
    chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$PLONE_HOME"
    # let's have whatever we create from now on sticky group'd
    chmod g+s "$PLONE_HOME"
    # including things copied from the work directory
    find "$WORKDIR" -type d -exec chmod g+s {} \;
fi

################################################
# Install the zeocluster or stand-alone instance
if [ $INSTALL_ZEO -eq 1 ]; then
    INSTALL_METHOD="cluster"
elif [ $INSTALL_STANDALONE -eq 1 ]; then
    INSTALL_METHOD="standalone"
    CLIENT_COUNT=0
fi
$SUDO "$PY" "$WORKDIR/helper_scripts/create_instance.py" \
    "--uidir=$WORKDIR" \
    "--plone_home=$PLONE_HOME" \
    "--instance_home=$INSTANCE_HOME" \
    "--daemon_user=$DAEMON_USER" \
    "--buildout_user=$BUILDOUT_USER" \
    "--root_install=$ROOT_INSTALL" \
    "--run_buildout=$RUN_BUILDOUT" \
    "--install_lxml=$INSTALL_LXML" \
    "--itype=$INSTALL_METHOD" \
    "--password=$PASSWORD" \
    "--instance_var=$INSTANCE_VAR" \
    "--backup_dir=$BACKUP_DIR" \
    "--template=$TEMPLATE" \
    "--clients=$CLIENT_COUNT" 2>> "$INSTALL_LOG"
if [ $? -gt 0 ]; then
    echo "Buildout failed. Unable to continue"
    seelog
    exit 1
fi
echo "Buildout completed"

if [ $ROOT_INSTALL -eq 0 ]; then
    # for non-root installs, restrict var access.
    # root installs take care of this during buildout.
    chmod 700 "$INSTANCE_HOME/var"
fi

cd "$CWD"
# clear our temporary directory
rm -r "$WORKDIR"

PWFILE="$INSTANCE_HOME/adminPassword.txt"
RMFILE="$INSTANCE_HOME/README.html"

#######################
# Conclude installation
if [ -d "$PLONE_HOME" ]; then
    if [ $SKIP_TOOL_TESTS -eq 0 ]; then
        echo " "
        echo "#####################################################################"
        if [ $RUN_BUILDOUT -eq 1 ]; then
            echo "######################  Installation Complete  ######################"
            echo " "
            echo "Plone successfully installed at $PLONE_HOME"
            echo "See $RMFILE"
            echo "for startup instructions"
            echo " "
            cat $PWFILE
        else
            echo "Buildout was skipped at your request, but the installation is"
            echo "otherwise complete and may be found at $PLONE_HOME"
        fi
        echo " "
        echo " "
        echo "- If you need help, ask the mailing lists or #plone on irc.freenode.net."
        echo "- The live support channel also exists at http://plone.org/chat"
        echo "- You can read/post to the lists via http://plone.org/forums"
        echo " "
        echo "- Submit feedback and report errors at http://dev.plone.org/plone"
        echo '(For install problems, specify component "Installer (Unified)")'
        echo " "
    fi
    echo "Finished at `date`" >> "$INSTALL_LOG"
else
    echo "There were errors during the install.  Please read readme.txt and try again."
    echo "To report errors with the installer, visit http://dev.plone.org/plone"
    echo 'and specify component "Installer (Unified).'
    exit 1
fi

cd "$ORIGIN_PATH"
