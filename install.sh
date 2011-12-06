#!/bin/sh
#
# Unified Plone installer build script
# Created by Kamal Gill (kamalgill at mac.com)
# Adapted for Plone 3+ and buildout by Steve McMahon (steve at dcn.org)
#
# $LastChangedDate: 2011-10-10 15:57:37 -0700 (Mon, 10 Oct 2011) $ $LastChangedRevision: 52415 $
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
# --user=user-name
#   In a server-mode install, sets the effective user for running the
#   instance. Default is 'plone'. Ignored for non-server-mode installs.
# 
# --with-python=/fullpathtopython2.6
#   If you have an already built Python that's adequate to run
#   Zope / Plone, you may specify it here.
#   virtualenv will be used to isolate the copy used for the install.
#
# --with-site-packages
#   When --with-python is used to specify a python, that python is isolated
#   via virtualenv using the --no-site-packages argument. Set the --with-site-
#   packages flag if you want to include system packages.
# 
# --nobuildout
#   Skip running bin/buildout. You should know what you're doing.
# 
# Library build control options:
# --libz=auto|yes|no
# --libjpeg=auto|yes|no
# --readline=auto|yes|no
# --lxml=auto|yes|no
#
#   auto -   to have this program determine whether or not you need the
#            library installed. If needed, will be installed to $PLONE_HOME.
#   yes    - to force install to $PLONE_HOME for static link
#   no     - to force no install
#
# lxml note:
# if needed, lxml is built with static xml2 and xslt libraries


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
LOCAL_HOME=$HOME/Plone

# if we create a ZEO cluster, it will go here (inside $PLONE_HOME):
ZEOCLUSTER_HOME=zeocluster
# a stand-alone (non-zeo) instance will go here (inside $PLONE_HOME):
RINSTANCE_HOME=zinstance

INSTALL_LXML=auto
INSTALL_ZLIB=auto
INSTALL_JPEG=auto
if [ `uname` = "Darwin" ]; then
  # Darwin ships with a readtext rather than readline; it doesn't work.
  INSTALL_READLINE=yes
else
  INSTALL_READLINE=auto
fi

# default user ids for effective user in root installs; ignored in non-root.
EFFECTIVE_USER=plone

# End of commonly configured options.
#################################################


# This script should be run from the directory containing packages/
PACKAGES_DIR=packages
ONLINE_PACKAGES_DIR=opackages

HSCRIPTS_DIR=helper_scripts

PYTHON_TB=Python-2.6.7.tar.bz2
PYTHON_DIR=Python-2.6.7
DISTRIBUTE_TB=distribute-0.6.19.tar.gz
DISTRIBUTE_DIR=distribute-0.6.19
JPEG_TB=jpegsrc.v8c.tar.bz2
JPEG_DIR=jpeg-8c
READLINE_TB=readline-6.2.tar.bz2
READLINE_DIR=readline-6.2
ZLIB_TB=zlib-1.2.5.tar.bz2
ZLIB_DIR=zlib-1.2.5
VIRTUALENV_TB=virtualenv-1.6.1.tar.bz2
VIRTUALENV_DIR=virtualenv-1.6.1

# check for PIL and jpeg support
PIL_TEST="from _imaging import jpeg_decoder"

# check for distribute
DISTRIBUTE_TEST="from setuptools import _distribute"

if [ `whoami` = "root" ]; then
    ROOT_INSTALL=1
else
    ROOT_INSTALL=0
    # set paths to local versions
    PLONE_HOME=$LOCAL_HOME
    EFFECTIVE_USER=$USER
fi


# Capture current working directory for build script
ORIGIN_PATH=`pwd`
# change to directory with script
PWD=`dirname $0`
cd $PWD
# normalize
PWD=`pwd`
CWD="$PWD"
PKG=$CWD/$PACKAGES_DIR


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
    echo "  This will be created inside the target directory unless there's"
    echo "  a slash in the specification."
    echo "  Default is 'zinstance' for standalone, 'zeocluster' for ZEO."
    echo
    echo "--user=user-name"
    echo "  In a server-mode install, sets the effective user for running the"
    echo "  instance. Default is 'plone'. Ignored for non-server-mode installs."
    echo
    echo "--with-python=/fullpathtopython2.6"
    echo "  If you have an already built Python that's adequate to run"
    echo "  Zope / Plone, you may specify it here."
    echo "  virtualenv will be used to isolate the copy used for the install."
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
WITH_ZOPE=""
RUN_BUILDOUT=1
SKIP_TOOL_TESTS=0
INSTALL_LOG="$ORIGIN_PATH/install.log"
CLIENT_COUNT=2


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

        --user=* | -user=* )
            if [ "$optarg" ]; then
                EFFECTIVE_USER="$optarg"
            else
                usage
            fi
            ;;

        --zlib=* | --libz=* )
            if [ "$optarg" ]; then
                INSTALL_ZLIB="$optarg"
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

        --lxml=* )
            if [ "$optarg" ]; then
                INSTALL_LXML="$optarg"
            else
                usage
            fi
            ;;

        --without-lxml )
            INSTALL_LXML=no
            ;;

        --without-ssl | --without-openssl )
            WITHOUT_SSL=1
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
            
        --help | -h )
            usage
            ;;

        *)
            case $option in
                zeo* | cluster )
                    echo ZEO Cluster Install selected
                    INSTALL_ZEO=1
                    ;;
                standalone* | nozeo | stand-alone | sa )
                    echo Stand-Alone Zope Instance selected
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

if [ $INSTALL_STANDALONE -eq 0 ] && [ $INSTALL_ZEO -eq 0 ]; then
    usage
fi
echo


if [ $ROOT_INSTALL -eq 1 ]; then
    SUDO="sudo -u $EFFECTIVE_USER"
else
    SUDO=""
fi


# Most files and directories we install should
# be group/world readable. We'll set individual permissions
# where that isn't adequate
umask 022
# Make sure CDPATH doesn't spoil cd
unset CDPATH


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
    test -f ./buildenv.sh && rm -f ./buildenv.sh
    sh ./preflight -q
    if [ $? -gt 0 ] || [ ! -x "buildenv.sh" ]; then
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


# set up log
if [ -f "$INSTALL_LOG" ]; then
    rm "$INSTALL_LOG"
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

untar () {
    # unpack a tar archive, decompressing as necessary.
    # this function is meant to isolate us from problems
    # with versions of tar that don't support .gz or .bz2.
    case "$1" in
        *.tar)
            tar -xf "$1" >> "$INSTALL_LOG"
            ;;
        *.tgz | *.tar.gz)
            gunzip -c "$1" | tar -xf - >> "$INSTALL_LOG"
            ;;
        *.tar.bz2)
            bunzip2 -c "$1" | tar -xf -  >> "$INSTALL_LOG"
            ;;
        *)
            echo "Unable to unpack $1; extension not recognized."
            exit 1
    esac
    if [ $? -gt 0 ]
    then
        seelog
    fi
}


echo


OFFLINE=1
if [ ! -d "$PACKAGES_DIR" ]; then
    if [ -d "$ONLINE_PACKAGES_DIR" ]; then
        # we don't have the full packages directory,
        # but do have the less-complete version meant for online install.
        echo "Running in online mode."
        OFFLINE=0
        PACKAGES_DIR="$ONLINE_PACKAGES_DIR"
        PKG="$CWD/$PACKAGES_DIR"
        INSTALL_ZLIB=no
        INSTALL_JPEG=no
    fi
fi


if [ -x "$PLONE_HOME/Python-2.6/bin/python" ] ; then
    HAVE_PYTHON=yes
    if [ "x$WITH_PYTHON" != "x" ]; then
        echo "We already have a Python environment for this target; ignoring --with-python."
        WITH_PYTHON=''
    fi
fi


# if [ ! -n "$HAVE_PYTHON" ] && [ ! -f "$PACKAGES_DIR/$PYTHON_TB" ] && [ "x$WITH_PYTHON" = "x" ]; then
#     # we don't have a python tarball or a --with-python
#     # specification; so let's see if we can find a system
#     # python
#     WITH_PYTHON=`which python2.6`
#     if [ $? -gt 0 ] || [ ! -x "$WITH_PYTHON" ]; then
#         echo
#         echo "Installation has failed."
#         echo "Unable to find a Python 2.6 executable or tarball."
#         echo "Use --with-python=... to specify a Python executable."
#         exit 1
#     fi
# fi


# If --with-python has been used, check the argument for our requirements.
if [ "$WITH_PYTHON" ]; then
    if [ -x "$WITH_PYTHON" ] && [ ! -d "$WITH_PYTHON" ]; then
        echo "Testing $WITH_PYTHON for Zope/Plone requirements...."
        if "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py
        then
            echo "$WITH_PYTHON looks OK. We'll try to use it."
            echo
            # if the supplied Python is adequate, we don't need to build libraries
            INSTALL_ZLIB=no
            INSTALL_READLINE=no
            WITHOUT_SSL=1
        else
            echo
            echo "***Aborting***"
            echo "$WITH_PYTHON does not meet the requirements for Zope/Plone."
            echo "Specify a more suitable Python, or upgrade your Python and try again."
            echo "You may also omit --with-python and let the Unified Installer"
            echo "build its own Python. "
            exit 1
        fi
    else
        echo "Error: '$WITH_PYTHON' is not an executable. It should be the filename of a Python binary."
        usage
    fi
elif [ `uname` = "OpenBSD" ]; then
    echo "\n***Aborting***"
    echo "Sorry, but the Unified Installer can't build a Python 2.6 for OpenBSD."
    echo "There are way too many platform-specific patches required."
    echo "Please consider adding the Python 2.6 packages and re-run using"
    echo "--with-python to use the system Python 2.6.x."
    exit 1
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
    if [ "$have_make" != "yes" ] ; then
        echo
        echo "Note: make is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no tar
    if [ "$have_tar" != "yes" ] ; then
        echo
        echo "Note: gnu tar is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no patch
    if [ "$have_patch" != "yes" ] ; then
        echo
        echo "Note: gnu patch program is required for the install. Exiting now."
        exit 1
    fi
fi # not skip tool tests

# Abort install if no gunzip
if [ "$have_gunzip" != "yes" ] ; then
    echo
    echo "Note: gunzip is required for the install. Exiting now."
    exit 1
fi

# Abort install if no bunzip2
if [ "$have_bunzip2" != "yes" ] ; then
    echo
    echo "Note: bunzip2 is required for the install. Exiting now."
    exit 1
fi


if [ $INSTALL_ZLIB = "auto" ] ; then
    if [ "$HAVE_LIBZ" = "yes" ] ; then
        INSTALL_ZLIB=no
    else
        INSTALL_ZLIB=yes
    fi
fi

if [ $INSTALL_JPEG = "auto" ] ; then
    if [ "$HAVE_LIBJPEG" = "yes" ] ; then
        INSTALL_JPEG=no
    else
        INSTALL_JPEG=yes
    fi
fi

if [ $INSTALL_READLINE = "auto" ] ; then
    if [ "$HAVE_LIBREADLINE" = "yes" ] ; then
        INSTALL_READLINE=no
    else
        INSTALL_READLINE=yes
    fi
fi

if [ "$HAVE_LIBSSL" != "yes" ] ; then
    echo
    echo "Unable to find libssl or openssl/ssl.h."
    echo "libssl and its development headers are required for Plone."
    echo "If you're sure you have these installed, and are still getting"
    echo "this warning, you may disable the libssl check by adding the"
    echo "--without-ssl flag to the install command line."
    echo "Otherwise, install your platform's openssl-dev libraries and headers"
    echo "and try again."
    echo
    exit 1
fi


######################################
# Pre-install messages
if [ $ROOT_INSTALL -eq 1 ]; then
    echo "Root install method chosen. Will install for use by system user $EFFECTIVE_USER"
else
    echo "Rootless install method chosen. Will install for use by system user $USER"
fi
echo ""
echo "Installing Plone 4.1.3 at $PLONE_HOME"
echo ""


#######################################
# create os users for root-level install
if [ $ROOT_INSTALL -eq 1 ]; then
    . helper_scripts/make_plone_user.sh
    createUser "$EFFECTIVE_USER"
    id "$TARGET_USER" > /dev/null 2>&1
    if [ "$?" != "0" ]; then
        echo "Creating user $TARGET_USER failed"
        echo
        echo "Installation has failed."
        exit 1
    fi
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
    if echo "$INSTANCE_NAME" | grep "/"
    then
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

cd "$CWD"

if  [ "X$INSTALL_ZLIB" = "Xyes" ] || [ "X$INSTALL_JPEG" = "Xyes" ]; then
    NEED_LOCAL=1
else
    NEED_LOCAL=0
fi

if [ "x$WITH_PYTHON" != "x" ] # try to use specified python
then
    PYBNAME=`basename "$WITH_PYTHON"`
    PY_HOME=$PLONE_HOME/Python-2.6
    cd "$PKG"
    untar $VIRTUALENV_TB
    cd $VIRTUALENV_DIR
    if [ "X$WITH_SITE_PACKAGES" = "Xyes" ]; then
        echo "Creating python virtual environment with site packages."
        "$WITH_PYTHON" virtualenv.py "$PY_HOME"
    else
        echo "Creating python virtual environment, no site packages."
        "$WITH_PYTHON" virtualenv.py --no-site-packages "$PY_HOME"
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
    if ! "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py; then
        echo
        echo "Python created with virtualenv no longer passes baseline"
        echo "tests."
        echo "You may need to omit --with-python and let the Unified Installer"
        echo "build its own Python. "
        exit 1
    fi
else # use already-placed python or build one
    PY_HOME=$PLONE_HOME/Python-2.6
    PY=$PY_HOME/bin/python
    if [ -x "$PY" ]; then
        # no point in installing zlib -- too late!
        INSTALL_ZLIB=no
        # let's see if we've already got PIL
        if "$PY" -c "$PIL_TEST" 2> /dev/null
        then
            INSTALL_JPEG=no
        fi
    fi
fi


# Now we know where our Python is, and may finish setting our paths
LOCAL_HOME="$PY_HOME"
EI="$PY_HOME/bin/easy_install"
SITE_PACKAGES="$PY_HOME/lib/python2.6/site-packages"
BUILDOUT_CACHE="$PLONE_HOME/buildout-cache"
BUILDOUT_DIST="$PLONE_HOME/buildout-cache/downloads/dist"


if [ ! -x "$LOCAL_HOME" ]; then
    mkdir "$LOCAL_HOME"
fi
if [ ! -x "$LOCAL_HOME" ]; then
    echo "Unable to create $LOCAL_HOME"
    exit 1
fi


if [ -x "$PY" ]; then
    echo "Python found at $PY; Skipping Python install."
    # also skipping library builds for libraries that have
    # to be built before python.
else
    # set up the common build environment unless already existing
    if [ "x$CFLAGS" = 'x' ]; then
        export CFLAGS='-fPIC'
    fi

    . helper_scripts/build_libjpeg.sh
    . helper_scripts/build_zlib.sh
    . helper_scripts/build_readline.sh

    if [ `uname` = "Darwin" ]; then
        # Remove dylib files that will prevent static linking,
        # which we need for relocatability
        rm -f "$PY_HOME/lib/"*.dylib
    fi

    . helper_scripts/build_python.sh
    echo "Installing distribute..."
    cd "$PKG"
    untar $DISTRIBUTE_TB
    cd "$DISTRIBUTE_DIR"
    "$PY" ./setup.py install >> "$INSTALL_LOG" 2>&1
    cd "$PKG"
    rm -r "$DISTRIBUTE_DIR"
    if [ ! -x "$EI" ]; then
        echo "$EI missing. Aborting."
        seelog
        exit 1
    fi
    if "$PY" "$CWD/$HSCRIPTS_DIR"/checkPython.py
    then
        echo "Python build looks OK."
    else
        echo
        echo "***Aborting***"
        echo "The built Python does not meet the requirements for Zope/Plone."
        echo "Check messages and the install.log to find out what went wrong."
        exit 1
    fi
fi


# From here on, we don't want any ad-hoc cflags or ldflags, as
# they will foul the modules built via distutils
unset CFLAGS
unset LDFLAGS


if [ -f "$PKG"/buildout-cache.tar.bz2 ]; then
    if [ -x "$BUILDOUT_CACHE" ]; then
        echo "Found existing buildout cache at $BUILDOUT_CACHE; skipping step."
    else
        echo "Unpacking buildout cache to $BUILDOUT_CACHE"
        cd $PLONE_HOME
        untar "$PKG"/buildout-cache.tar.bz2
        # compile .pyc files in cache
        echo "Compiling .py files in egg cache"
        "$PY" "$PLONE_HOME"/Python*/lib/python*/compileall.py "$BUILDOUT_CACHE"/eggs > /dev/null 2>&1    
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

######################
# Postinstall steps
######################


cd "$CWD"


if [ "x$PASSWORD" = "x" ]; then
    ##########################
    # Generate random password
    echo "Generating random password ..."
    PASSWORD_SCRIPT=helper_scripts/generateRandomPassword.py
    PASSWORD=`"$PY" $PASSWORD_SCRIPT`
fi


################################################
# Install the zeocluster or stand-alone instance
if [ $INSTALL_ZEO -eq 1 ]; then
    if [ -x "$ZEOCLUSTER_HOME" ]; then
        echo "Instance target $ZEOCLUSTER_HOME already exists; aborting install."
        exit 1
    fi
    "$PY" helper_scripts/create_instance.py \
        "$CWD" \
        "$PLONE_HOME" \
        "$ZEOCLUSTER_HOME" \
        "$EFFECTIVE_USER" \
        "$EFFECTIVE_USER" \
        "$PASSWORD" \
        "$ROOT_INSTALL" \
        "$RUN_BUILDOUT" \
        "$INSTALL_LXML" \
        "$OFFLINE" \
        "cluster" \
        "$INSTALL_LOG" \
        "$CLIENT_COUNT"
    if [ $? -gt 0 ]; then
        echo "Buildout failed. Unable to continue"
        seelog
        exit 1
    fi
    INSTANCE=$ZEOCLUSTER_HOME
elif [ $INSTALL_STANDALONE -eq 1 ]; then
    if [ -x "$RINSTANCE_HOME"  ]; then
        echo "Instance target $RINSTANCE_HOME already exists; aborting install."
        exit 1
    fi
    "$PY" helper_scripts/create_instance.py \
        "$CWD" \
        "$PLONE_HOME" \
        "$RINSTANCE_HOME" \
        "$EFFECTIVE_USER" \
        "0" \
        "$PASSWORD" \
        "$ROOT_INSTALL" \
        "$RUN_BUILDOUT" \
        "$INSTALL_LXML" \
        "$OFFLINE" \
        "standalone" \
        "$INSTALL_LOG" \
        "0"
    if [ $? -gt 0 ]; then
        echo "Buildout failed. Unable to continue"
        seelog
        exit 1
    fi
    INSTANCE=$RINSTANCE_HOME
fi

PWFILE=$INSTANCE/adminPassword.txt
RMFILE=$INSTANCE/README.html

if [ $ROOT_INSTALL -eq 1 ]; then
    echo "Setting instance ownership to $EFFECTIVE_USER"
    chown -R "$EFFECTIVE_USER" "$INSTANCE"
    echo "Setting buildout cache ownership to $EFFECTIVE_USER"
    chown -R "$EFFECTIVE_USER" "$BUILDOUT_CACHE"
    # And the config files
    chown root "$INSTANCE"/*.cfg
    chmod 644 "$INSTANCE"/*.cfg
fi


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
