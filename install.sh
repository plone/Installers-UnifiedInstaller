#!/bin/sh
#
# Unified Plone installer build script
# Created by Kamal Gill (kamalgill at mac.com)
# Adapted for Plone 3 and buildout by Steve McMahon (steve at dcn.org)
#
# $LastChangedDate: 2011-08-16 10:04:48 -0700 (Tue, 16 Aug 2011) $ $LastChangedRevision: 51626 $
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
# --with-python=/fullpathtopython2.4
#   If you have an already built Python that's adequate to run
#   Zope / Plone, you may specify it here.
#   virtualenv will be used to isolate the copy used for the install.
# 
# --nobuildout
#   Skip running bin/buildout. You should know what you're doing.
# 
# --with-zope=/fullpathtozope2.10
#   If you have an already built Zope that's adequate to run
#   Plone, you may specify it here.
# 
# Library build control options:
# --libz=auto|global|local|no
# --libjpeg=auto|global|local|no
#
#   auto -   to have this program determine whether or not you need the
#            library installed. If needed, will be installed to $PLONE_HOME.
#   global - to force install to /usr/local/ (requires root)
#   local  - to force install to $PLONE_HOME (or $LOCAL_HOME) for static link
#   no     - to force no install


#################################################
# Commonly configured options:

# Path options for Root install
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

# Locations of required build tools.
# If the right tools aren't being found, edit below to specify the full pathname.
GCC="gcc"
GPP="g++"
GNU_MAKE="make"
# Some tars can't handle deep path trees; GNU tar is safest.
GNU_TAR="tar"
# We need both gunzip and bunzip2 decompression utilities.
GUNZIP="gunzip"
BUNZIP2="bunzip2"

# This install requires the zlib and libjpeg libraries, which are
# usually installed as system libraries.
# You may also override this with the --libz and --libjpeg
# command-line options.
#
# Set the options below to
#   auto -   to have this program determine whether or not you need the
#            library installed. If needed, will be installed to $PLONE_HOME.
#   global - to force install to /usr/local/ (requires root)
#   local  - to force install to $PLONE_HOME (or $LOCAL_HOME) for static link
#   no     - to force no install
INSTALL_ZLIB=auto
INSTALL_JPEG=auto
if [ `uname` = "Darwin" ]; then
	# Darwin ships with a readtext rather than readline; it doesn't work.
	INSTALL_READLINE=local
else
	INSTALL_READLINE=no
fi

# user ids for effective user in root installs; ignored in non-root.
EFFECTIVE_USER=plone
ZEO_USER=zeo

# End of commonly configured options.
#################################################


# This script should be run from the directory containing packages/
# Include the following tarballs in the packages/ directory in the bundle...
PACKAGES_DIR=packages
ONLINE_PACKAGES_DIR=opackages
PYTHON_TB=Python-2.4.6.tar.bz2
PYTHON_DIR=Python-2.4.6
JPEG_TB=jpegsrc.v8c.tar.bz2
JPEG_DIR=jpeg-8c
ZLIB_TB=zlib-1.2.5.tar.bz2
ZLIB_DIR=zlib-1.2.5
READLINE_TB=readline-6.2.tar.bz2
READLINE_DIR=readline-6.2
SETUP_TB=setuptools-0.6c11.tar.gz
SETUP_DIR=setuptools-0.6c11
VENV_TB=virtualenv-1.3.4.tar.gz
VENV_DIR=virtualenv-1.3.4
ZOPE=Zope-2.10.9-final-py2.4
PIL_TB=Pillow-1.7.4.tar.bz2
PIL_DIR=Pillow-1.7.4

HSCRIPTS_DIR=helper_scripts


if [ `whoami` = "root" ]; then
	ROOT_INSTALL=1
	SUDO="sudo"
else
	ROOT_INSTALL=0
	SUDO=""
	# set paths to local versions
	PLONE_HOME=$LOCAL_HOME
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
    echo "Options:"
    echo "--password=InstancePassword"
    echo "  If not specified, a random password will be generated."
    echo
    echo "--target=pathname"
    echo "  Use to specify top-level path for installs. Plone instances"
    echo "  and Python will be built inside this directory"
    echo "  (default is $PLONE_HOME)"
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
    echo "--with-python=/fullpathtopython2.4"
    echo "  If you have an already built Python that's adequate to run"
    echo "  Zope / Plone, you may specify it here."
    echo "  virtualenv will be used to isolate the copy used for the install."
    echo
    echo "--with-zope=/fullpathtozope2.10"
    echo "  If you have an already built Zope that's adequate to run"
    echo "  Plone, you may specify it here."
    echo
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
SEPARATE_ZOPE=0
SKIP_TOOL_TESTS=0
INSTALL_LOG="$ORIGIN_PATH/install.log"


for option
do
    optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`

    case $option in
        --with-python=* | -with-python=* | --withpython=* | -withpython=* )
            if [ "$optarg" ]; then
                WITH_PYTHON=$optarg
            else
                usage
            fi
        ;;

        --with-zope=* | -with-zope=* | --withzope=* | -withzope=* )
            if [ "$optarg" ]; then
                WITH_ZOPE=$optarg
                SEPARATE_ZOPE=1
            else
                usage
            fi
        ;;

        --target=* | -target=* )
            if [ "$optarg" ]; then
                PLONE_HOME=$optarg
            else
                usage
            fi
            ;;

        --instance=* | -instance=* )
            if [ "$optarg" ]; then
                INSTANCE_NAME=$optarg
            else
                usage
            fi
            ;;

        --user=* | -user=* )
            if [ $optarg ]; then
                EFFECTIVE_USER=$optarg
            else
                usage
            fi
            ;;

        --zlib=* | --libz=* )
            if [ $optarg ]; then
                INSTALL_ZLIB=$optarg
            else
                usage
            fi
            ;;

        --jpeg=* | --libjpeg=* )
            if [ $optarg ]; then
                INSTALL_JPEG=$optarg
            else
                usage
            fi
            ;;

        --readline=* | --libreadline=* )
            if [ $optarg ]; then
                INSTALL_READLINE=$optarg
            else
                usage
            fi
            ;;

        --password=* | -password=* )
            if [ $optarg ]; then
                PASSWORD=$optarg
            else
                usage
            fi
            ;;
        
        --nobuild* | --no-build*)
            RUN_BUILDOUT=0
            ;;

        --separate-zope* | --separatezope* )
            SEPARATE_ZOPE=1
            ;;
            
        --skip-tool-tests )
            SKIP_TOOL_TESTS=1 
            # don't test for availability of gnu build tools
            # this is mainly meant to be used when binaries 
            # are known to be installed already
            ;;

        --install-log=* | --log=* )
            if [ $optarg ]; then
                INSTALL_LOG=$optarg
            else
                usage
            fi
            ;;
            
        --enable-universalsdk )
            if [ "$optarg" ]; then
                UNIVERSALSDK=$optarg
            else
                UNIVERSALSDK=/Developer/SDKs/MacOSX10.4u.sdk
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


# set up the common build environment
export CFLAGS='-fPIC'
# special cases:
if [ `uname` = 'Darwin' ]; then
    if [ "x$UNIVERSALSDK" != "x" ];	then
        CFLAGS="-fPIC -isysroot $UNIVERSALSDK -arch ppc -arch i386 -Wl,-syslibroot,$UNIVERSALSDK"
        export MACOSX_DEPLOYMENT_TARGET=10.4
    elif uname -r | grep -q '^10\.'; then
        # we're on Snow Leopard
        export MACOSX_DEPLOYMENT_TARGET=10.6
    elif uname -r | grep -q '^11\.'; then
        # we're on Lion
        export MACOSX_DEPLOYMENT_TARGET=10.7
        export CFLAGS='-arch x86_64 -fPIC'
    fi
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
fi


# set up log
if [ -e "$INSTALL_LOG" ]; then
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
			"$GNU_TAR" -xf "$1" >> "$INSTALL_LOG"
			;;
		*.tgz | *.tar.gz)
			"$GUNZIP" -c "$1" | "$GNU_TAR" -xf - >> "$INSTALL_LOG"
			;;
		*.tar.bz2)
			"$BUNZIP2" -c "$1" | "$GNU_TAR" -xf -  >> "$INSTALL_LOG"
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
if [ ! -e "$PACKAGES_DIR" ]; then
    if [ -e "$ONLINE_PACKAGES_DIR" ]; then
        # we don't have the full packages directory,
        # but do have the less-complete version meant for online install.
        echo "Running in online mode."
        OFFLINE=0
        PACKAGES_DIR=$ONLINE_PACKAGES_DIR
        PKG=$CWD/$PACKAGES_DIR
        INSTALL_ZLIB=no
        INSTALL_JPEG=no
    fi
fi


if [ $OFFLINE -ne 1  ] && [ "x$WITH_PYTHON" = "x" ]; then
    # we don't have a python tarball or a --with-python
    # specification; so let's see if we can find a system
    # python
    WITH_PYTHON=`which python2.4`
    if [ $? -gt 0 ] || [ ! -x "$WITH_PYTHON" ]; then
        echo
        echo "Installation has failed."
        echo "Unable to find a Python 2.4 executable or tarball."
        echo "Use --with-python=... to specify a Python executable."
        exit 1
    fi
fi

# If --with-python has been used, check the argument for our requirements.
if [ "$WITH_PYTHON" ]; then
    if [ -x "$WITH_PYTHON" ] && [ ! -d "$WITH_PYTHON" ]; then
        echo "\nTesting $WITH_PYTHON for Zope/Plone requirements...."
        if "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py
        then
            echo "$WITH_PYTHON looks OK. We'll try to use it."
            echo
            # if the supplied Python is adequate, we don't need to build libraries
            INSTALL_ZLIB=no
            if "$WITH_PYTHON" -c "import _imaging" 2> /dev/null
            then
                INSTALL_JPEG=no
            fi
        else
            echo "\n***Aborting***"
            echo "\n$WITH_PYTHON does not meet the requirements for Zope/Plone."
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
    echo "Sorry, but the Unified Installer can't build a Python 2.4 for OpenBSD."
    echo "There are way too many platform-specific patches required."
    echo "Please consider adding the Python 2.4 packages and re-run using"
    echo "--with-python to use the system Python 2.4.x."
    exit 1
fi


# Check to see if we should be libz & libjpeg;
# and, if we should, can we?
. helper_scripts/checkLibs.sh


#############################
# Preflight dependency checks
# Binary path variables may have been filled in by literal paths or
# by 'which'. 'which' negative results may be empty or a message.

if [ $SKIP_TOOL_TESTS -eq 0 ]; then

    # Abort install if no gcc
    GCC=`which "$GCC"` >> "$INSTALL_LOG" 2>&1
    if [ $? -gt 0 ] || [ ! $GCC ] || [ ! -x $GCC ]; then
    	echo "Note: gcc is required for the install. Exiting now."
    	exit 1
    fi

    # Abort install if no g++
    GPP=`which "$GPP"` >> "$INSTALL_LOG" 2>&1
    if [ $? -gt 0 ] || [ ! "$GPP" ] || [ ! -x "$GPP" ]; then
        echo "Note: g++ is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no make
    GNU_MAKE=`which "$GNU_MAKE"` >> "$INSTALL_LOG" 2>&1
    if [ $? -gt 0 ] || [ ! "$GNU_MAKE" ] || [ ! -x "$GNU_MAKE" ]; then
        echo "Note: make is required for the install. Exiting now."
        exit 1
    fi

    # Abort install if no tar
    GNU_TAR=`which "$GNU_TAR"` >> "$INSTALL_LOG" 2>&1
    if [ $? -gt 0 ] || [ "x$GNU_TAR" = "x" ] || [ ! -x "$GNU_TAR" ]; then
        echo "Note: gnu tar is required for the install. Exiting now."
        exit 1
    fi
fi # not skip tool tests

# Abort install if no gunzip
GUNZIP=`which "$GUNZIP"` >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ] || [ "x$GUNZIP" = "x" ] || [ ! -x "$GUNZIP" ]; then
    echo "Note: gunzip is required for the install. Exiting now."
    exit 1
fi

# Abort install if no bunzip2
BUNZIP2=`which "$BUNZIP2"` >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ] || [ "x$BUNZIP2" = "x" ] || [ ! -x "$BUNZIP2" ]; then
    echo "Note: bunzip2 is required for the install. Exiting now."
    exit 1
fi


######################################
# Pre-install messages
if [ $ROOT_INSTALL -eq 1 ]; then
	echo "Root install method chosen"
else
	echo "Rootless install method chosen. Will install for use by system user $USER"
fi
echo ""
echo "Installing Plone  at $PLONE_HOME"
echo ""


#######################################
# create plone home
if [ ! -x "$PLONE_HOME" ]; then
    mkdir "$PLONE_HOME"
    # normalize $PLONE_HOME so we can use it in prefixes
    cd "$PLONE_HOME"
    PLONE_HOME=`pwd`
fi
if [ ! -x "$PLONE_HOME" ]; then
    echo "Unable to create $PLONE_HOME"
    exit 1
fi

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

if  [ "X$INSTALL_ZLIB" = "Xlocal" ] || [ "X$INSTALL_JPEG" = "Xlocal" ]; then
	NEED_LOCAL=1
else
	NEED_LOCAL=0
fi

if [ $WITH_PYTHON ] # try to use specified python
then
    PYBNAME=`basename "$WITH_PYTHON"`
    PY_HOME=$PLONE_HOME/Python-2.4
    cd "$PKG"
    untar $VENV_TB
    cd $VENV_DIR
    echo "Creating python virtual environment..."
    "$WITH_PYTHON" virtualenv.py "$PY_HOME"
    cd "$PKG"
    rm -r $VENV_DIR
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
else # use already-placed python or build one
    PY_HOME=$PLONE_HOME/Python-2.4
    PY=$PY_HOME/bin/python
    if [ -x "$PY" ]; then
        # no point in installing zlib -- too late!
        INSTALL_ZLIB=no
        # let's see if we've already got PIL
        if "$PY" -c "import _imaging" 2> /dev/null
        then
            INSTALL_JPEG=no
        fi
    fi
fi


# Now we know where our Python is, and may finish setting our paths
LOCAL_HOME=$PY_HOME
EI=$PY_HOME/bin/easy_install
SITE_PACKAGES=$PY_HOME/lib/python2.4/site-packages
BUILDOUT_CACHE=$PLONE_HOME/buildout-cache


if [ ! -x "$LOCAL_HOME" ]; then
    mkdir "$LOCAL_HOME"
fi
if [ ! -x "$LOCAL_HOME" ]; then
    echo "Unable to create $LOCAL_HOME"
    exit 1
fi

. helper_scripts/build_zlib.sh

. helper_scripts/build_libjpeg.sh

. helper_scripts/build_readline.sh


if [ -x "$PY" ]; then
    echo "Python found at $PY; Skipping Python install."
else
    . helper_scripts/build_python.sh
fi


if [ ! -x "$EI" ]; then
    echo "Installing setuptools..."
    cd "$PKG"
    untar "$SETUP_TB"
    cd "$SETUP_DIR"
    "$PY" ./setup.py install >> "$INSTALL_LOG" 2>&1
    cd "$PKG"
    rm -r "$SETUP_DIR"
    if [ ! -x "$EI" ]; then
        echo "$EI missing. Aborting."
        seelog
        exit 1
    fi
fi


"$PY" -c "import _imaging" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "Installing PIL (actually Pillow)"
    cd "$PKG"
    untar "$PIL_TB"
    cd "$PIL_DIR"
    "$PY" ./setup.py install >> "$INSTALL_LOG" 2>&1
    cd "$PKG"
    rm -rf "$PIL_DIR"
    "$PY" -c "import _imaging" > /dev/null
    if [ $? -gt 0 ]; then
        echo "Python imaging support is missing; something went wrong in the PIL or python build."
        seelog
        exit 1
    fi
fi


"$PY" -c "import iniparse" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "Installing iniparse configuration parser"
    cd "$PKG"
    if [ -e iniparse-*.tar.gz ]; then
        "$EI" iniparse-* >> "$INSTALL_LOG" 2>&1
    else
        "$EI" iniparse >> "$INSTALL_LOG" 2>&1
    fi
fi
"$PY" -c "import iniparse" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "iniparse install failed; unable to continue."
    seelog
    exit 1
fi


"$PY" -c "import zc.buildout" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "Installing zc.buildout"
    cd "$PKG"
    if [ -e zc.buildout-*.tar.gz ]; then
        "$EI" zc.buildout-* >> "$INSTALL_LOG" 2>&1
    else
        "$EI" zc.buildout >> "$INSTALL_LOG" 2>&1
    fi
fi
"$PY" -c "import zc.buildout" 2> /dev/null
if [ $? -gt 0 ]; then
    echo "zc.buildout install failed; unable to continue."
    seelog
    exit 1
fi


cd "$CWD"

if [ -e "$PKG"/buildout-cache.tar.bz2 ]; then
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
    mkdir "$BUILDOUT_CACHE"/downloads
fi

if [ $SEPARATE_ZOPE -eq 1 ]; then
    if [ "x$WITH_ZOPE" == "x" ]; then
        MYZOPE="$PLONE_HOME"/"$ZOPE"
    else
        MYZOPE=$WITH_ZOPE
    fi
    if [ -e "$MYZOPE" ]; then
        echo "$MYZOPE found; skipping separate Zope install."
    else
        cd "$PKG"
        echo "Installing separate $ZOPE"
        untar "$BUILDOUT_CACHE"/downloads/"$ZOPE".*
        cd "$ZOPE"
        ./configure --with-python="$PY" --prefix="$MYZOPE" >> "$INSTALL_LOG" 2>&1
        make install >> "$INSTALL_LOG" 2>&1
        cd "$PKG"
        rm -r "$ZOPE"
        if [ ! -x "$MYZOPE"/bin/mkzopeinstance.py ]; then
            echo "Installation of Zope failed. Unable to continue"
            seelog
            exit 1
        fi
    fi
else
    MYZOPE=0
fi # if separate zope


######################
# Postinstall steps
######################


cd "$CWD"

if [ $ROOT_INSTALL -eq 1 ]; then
    . helper_scripts/make_plone_user.sh
    createUser $EFFECTIVE_USER
    if [ $INSTALL_ZEO -eq 1 ]; then
        createUser $ZEO_USER
    fi
fi # if $ROOT_INSTALL

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
        "$ZEO_USER" \
        "$PASSWORD" \
        "$ROOT_INSTALL" \
        "$MYZOPE" \
        "$RUN_BUILDOUT" \
        "$OFFLINE" \
        "cluster"
    if [ $? -gt 0 ]; then
        echo "Buildout failed. Unable to continue"
        seelog
        exit 1
    fi
	PWFILE=$ZEOCLUSTER_HOME/adminPassword.txt
	RMFILE=$ZEOCLUSTER_HOME/README.txt
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
        "$MYZOPE" \
        "$RUN_BUILDOUT" \
        "$OFFLINE" \
        "standalone"
    if [ $? -gt 0 ]; then
        echo "Buildout failed. Unable to continue"
        seelog
        exit 1
    fi
	PWFILE=$RINSTANCE_HOME/adminPassword.txt
	RMFILE=$RINSTANCE_HOME/README.txt
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
