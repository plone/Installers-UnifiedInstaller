# Unified Plone installer build script
# Copyright (c) 2008-2021 Plone Foundation. Licensed under GPL v 2.
#

INSTALLER_PWD=`pwd`
CWD="$INSTALLER_PWD"

# Path for Root install
#
# Path for server-mode install of Python/Zope/Plone
if [ `uname` = "Darwin" ]; then
    PLONE_HOME=/Applications/Plone
else
    PLONE_HOME=/opt/plone
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

# default user/group ids for root installs; ignored in non-root.
DAEMON_USER=plone_daemon
BUILDOUT_USER=plone_buildout
PLONE_GROUP=plone_group

# End of commonly configured options.
#################################################

readonly FOR_PLONE=5.2.12
readonly WANT_PYTHON=3.8
readonly ELIGIBLE_PYTHONS='2.7 3.6 3.7 3.8'

PACKAGES_DIR="${INSTALLER_PWD}/packages"
readonly ONLINE_PACKAGES_DIR=opackages
readonly HSCRIPTS_DIR="${INSTALLER_PWD}/helper_scripts"
readonly TEMPLATE_DIR="${INSTALLER_PWD}/buildout_templates"

readonly VIRTUALENV_TB=virtualenv-16.7.10.tar.gz
readonly VIRTUALENV_DIR=virtualenv-16.7.10
readonly NEED_CUSTOM_SETUPTOOLS=no

readonly NEED_XML2="2.7.8"
readonly NEED_XSLT="1.1.26"

DEBUG_OPTIONS=no

# Add message translations below:
case $LANG in
    # es_*)
    #     . helper_scripts//locales/es/LC_MESSAGES/messages.sh
    #     ;;
    *)
        # default to English
        . "${HSCRIPTS_DIR}/locales/en/LC_MESSAGES/messages.sh"
        ;;
esac

if [ `whoami` = "root" ]; then
    ROOT_INSTALL=1
else
    ROOT_INSTALL=0
    # set paths to local versions
    PLONE_HOME="$LOCAL_HOME"
    DAEMON_USER="$USER"
    BUILDOUT_USER="$USER"
fi


PKG="$PACKAGES_DIR"

. "${INSTALLER_PWD}/helper_scripts/shell_utils.sh"

usage () {
    eval "echo \"$USAGE_MESSAGE\""
    if [ "$1" ]; then
        eval "echo \"***\" \"$@\""
    fi
    exit 1
}


#########################################################
# Pick up options from command line
#
#set defaults
INSTALL_STANDALONE=0
INSTANCE_NAME=""
WITH_PYTHON=""
WITH_ZOPE=""
RUN_BUILDOUT=1
SKIP_TOOL_TESTS=0
INSTALL_LOG="$ORIGIN_PATH/install.log"
CLIENT_COUNT=2
TEMPLATE=buildout
WITHOUT_SSL="no"
INSTALL_ZEO=0

USE_WHIPTAIL=0
if [ "$BASH_VERSION" ]; then
    . "${INSTALLER_PWD}/helper_scripts/whipdialog.sh"
    USE_WHIPTAIL=1
fi

for option
do
    optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`

    case $option in
        --with-python=* | -with-python=* | --withpython=* | -withpython=* )
            if [ "$optarg" ]; then
                WITH_PYTHON="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --target=* | -target=* )
            if [ "$optarg" ]; then
                PLONE_HOME="$optarg"
                USE_WHIPTAIL=0
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --instance=* | -instance=* )
            if [ "$optarg" ]; then
                INSTANCE_NAME="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --var=* | -var=* )
            if [ "$optarg" ]; then
                INSTANCE_VAR="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --backup=* | -backup=* )
            if [ "$optarg" ]; then
                BACKUP_DIR="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --user=* | -user=* )
            usage $BAD_USER_OPTION
            ;;

        --daemon-user=* | -daemon-user=* )
            if [ "$optarg" ]; then
                DAEMON_USER="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --owner=* | -owner=* )
            if [ "$optarg" ]; then
                BUILDOUT_USER="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --group=* | -group=* )
            if [ "$optarg" ]; then
                PLONE_GROUP="$optarg"
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --template=* )
            if [ "$optarg" ]; then
                TEMPLATE="$optarg"
                if [ ! -f "${TEMPLATE_DIR}/$TEMPLATE" ] && \
                   [ ! -f "${TEMPLATE_DIR}/${TEMPLATE}.cfg" ]; then
                   usage "$BAD_TEMPLATE"
                fi
            else
                echo "Problem at $option"
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

        --password=* | -password=* )
            if [ "$optarg" ]; then
                PASSWORD="$optarg"
                USE_WHIPTAIL=0
            else
                echo "Problem at $option"
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
                echo "Problem at $option"
                usage
            fi
            ;;

        --clients=* | --client=* )
            if [ "$optarg" ]; then
                CLIENT_COUNT="$optarg"
                USE_WHIPTAIL=0
            else
                echo "Problem at $option"
                usage
            fi
            ;;

        --debug-options )
            DEBUG_OPTIONS=yes
            ;;

        --help | -h )
            usage
            USE_WHIPTAIL=0
            ;;

        *)
            case $option in
                zeo* | cluster )
                    INSTALL_ZEO=1
                    USE_WHIPTAIL=0
                    ;;
                standalone* | nozeo | stand-alone | sa )
                    INSTALL_STANDALONE=1
                    USE_WHIPTAIL=0
                    ;;
                none )
                    echo "$NO_METHOD_SELECTED"
                    INSTALL_STANDALONE=1
                    RUN_BUILDOUT=0
                    ;;
                *)
                echo "Problem at $option"
                    usage
                    ;;
            esac
        ;;
    esac
done

whiptail_goodbye() {
    echo "$POLITE_GOODBYE"
    exit 0
}

if [ $USE_WHIPTAIL -eq 1 ]; then

    if ! WHIPTAIL \
        --title="$WELCOME" \
        --yesno \
        "$DIALOG_WELCOME"; then
        whiptail_goodbye
    fi


    if [ "X$WITH_PYTHON" == "X" ]; then
        CANDIDATE_PYTHONS=""
        PYTHONS_FOUND=0
        for A_PYTHON in $ELIGIBLE_PYTHONS; do
            CANDIDATE=`which python$A_PYTHON  2> /dev/null`
            if [ $? -eq 0 ]; then
                PYTHONS_FOUND=$(( PYTHONS_FOUND + 1 ))
                if [ "X$CANDIDATE_PYTHONS" != "X" ]; then
                    CANDIDATE_PYTHONS="$CANDIDATE_PYTHONS#$CANDIDATE"
                else
                    CANDIDATE_PYTHONS="$CANDIDATE"
                fi
            fi
        done

        if [ $PYTHONS_FOUND -eq 1 ]; then
            WITH_PYTHON="$CANDIDATE_PYTHONS"
        fi
        if [ $PYTHONS_FOUND -gt 1 ]; then
            if ! WHIPTAIL --title="$CHOOSE_PYTHON_TITLE" --menu "$CHOOSE_PYTHON_EXPLANATION" --choices="$CANDIDATE_PYTHONS"; then
                exit 0
            fi
            WITH_PYTHON="$WHIPTAIL_RESULT"
        fi
    fi

    if ! WHIPTAIL \
        --title="$INSTALL_TYPE_MSG" \
        --menu \
        --choices="$INSTALL_TYPE_CHOICES" \
        "$CHOOSE_CONFIG_MSG"; then
        whiptail_goodbye
    fi
    case $WHIPTAIL_RESULT in
        Standalone*)
            INSTALL_STANDALONE=1
            METHOD=standalone
            ;;
        ZEO*)
            INSTALL_ZEO=1
            METHOD=zeocluster
            ;;
    esac

    if [ $INSTALL_ZEO -eq 1 ]; then
        if ! WHIPTAIL \
            --title="$CHOOSE_CLIENTS_TITLE" \
            --menu \
            --choices="$CLIENT_CHOICES" \
            "$CHOOSE_CLIENTS_PROMPT" ; then
            whiptail_goodbye
        fi
        CLIENT_COUNT=$WHIPTAIL_RESULT
        if [ "X$CLIENT_COUNT" != "X" ]; then
            CCHOICE="\\\n    --clients=$CLIENT_COUNT"
        fi
    fi

    # hack alert -- nasty quoting
    INSTALL_DIR_PROMPT=$(eval "echo \"$INSTALL_DIR_PROMPT\"")
    if ! WHIPTAIL \
        --title="$INSTALL_DIR_TITLE" \
        --inputbox \
        "$INSTALL_DIR_PROMPT"; then
        whiptail_goodbye
    fi
    if [ "X$WHIPTAIL_RESULT" != "X" ]; then
        PLONE_HOME="$WHIPTAIL_RESULT"
    fi

    if ! WHIPTAIL \
        --title="$PASSWORD_TITLE" \
        --passwordbox \
        "$PASSWORD_PROMPT"; then
        whiptail_goodbye
    fi
    PASSWORD="$WHIPTAIL_RESULT"
    if [ "X$PASSWORD" != "X" ]; then
        PCHOICE="\\\n    --password=\"*****...\""
    fi

    WHIPTAIL \
        --title="$Q_CONTINUE" \
        --yesno \
        "$CONTINUE_PROMPT
install.sh $METHOD \\
    --target=\"$PLONE_HOME\" \\
    --with-python=$WITH_PYTHON $PCHOICE $CCHOICE"
    if [ $? -gt 0 ]; then
        whiptail_goodbye
    fi
fi

if [ $INSTALL_STANDALONE -eq 0 ] && [ $INSTALL_ZEO -eq 0 ]; then
    usage
fi
echo


if [ $ROOT_INSTALL -eq 1 ]; then
    if ! which sudo > /dev/null; then
        echo $SUDO_REQUIRED_MSG
	echo
        exit 1
    fi
    SUDO="sudo -H -u $BUILDOUT_USER -E"
else
    SUDO=""
fi


# Most files and directories we install should
# be group/world readable. We'll set individual permissions
# where that isn't adequate
umask 022
# Make sure CDPATH doesn't spoil cd
unset CDPATH


# set up the OS X / FreeBSD build environments unless already existing
if [ "x$CFLAGS" = 'x' ]; then
    if [ `uname` = "Darwin" ]; then
        if [ -d /opt/local ]; then
            # include MacPorts directories, which typically have additional
            # and later libraries
            export CFLAGS='-I/opt/local/include'
            export CPPFLAGS=$CFLAGS
            export LDFLAGS='-L/opt/local/lib'
        fi
    fi
    if [ `uname` = "FreeBSD" ]; then
        export CFLAGS='-I/usr/local/include'
        export CPPFLAGS=$CFLAGS
        export LDFLAGS='-L/usr/local/lib'
    fi
fi


if [ $SKIP_TOOL_TESTS -eq 0 ]; then
    # Abort install if this script is not run from within it's parent folder
    if [ ! -x "$PACKAGES_DIR" ] || [ ! -x "$HSCRIPTS_DIR" ]; then
	eval "echo \"$MISSING_PARTS_MSG\""
        exit 1
    fi

    # Abort install if no cc
    which cc > /dev/null
    if [ $? -gt 0 ]; then
        echo "$NO_GCC_MSG"
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
        echo "$PREFLIGHT_FAILED_MSG"
        exit 1
    fi
    # suck in the results as shell variables that we can test.
    . ./buildenv.sh
fi


# Begin the process of finding a viable Python or creating one
# if it can't be found.

CANDIDATE_PYTHON=`ls $PLONE_HOME/Python-*/bin/python[23] 2> /dev/null`
if [ $? -eq 0 ] ; then
    echo found exiting py
    # There is a Python that was probably built by the installer;
    # use it.
    HAVE_PYTHON=yes
    if [ "X$WITH_PYTHON" != "X" ]; then
        echo "$IGNORING_WITH_PYTHON"
    fi
    if [ "X$BUILD_PYTHON" != "Xno" ]; then
        echo "$IGNORING_BUILD_PYTHON"
        BUILD_PYTHON=no
    fi
    cd `ls -d $PLONE_HOME/Python-*`
    PY_HOME=`pwd`
    cd "$CWD"
    WITH_PYTHON=`ls $PY_HOME/bin/python[23]`
fi

# shared message for need python
python_usage () {
    eval "echo \"$NEED_INSTALL_PYTHON_MSG\""
    exit 1
}


# if OpenBSD, apologize and surrender
if [ `uname` = "OpenBSD" ]; then
    eval "echo\"$SORRY_OPENBSD\""
    exit 1
fi

    # no build Python specified

if [ "X$WITH_PYTHON" = "X" ]; then
    # try to find a Python
    WITH_PYTHON=`which python${WANT_PYTHON}`
    if [ $? -gt 0 ] || [ "X$WITH_PYTHON" = "X" ]; then
        eval "echo \"$PYTHON_NOT_FOUND\""
        python_usage
        exit 1
    fi
fi

# We have a Python, let's see if it's viable.
if [ -x "$WITH_PYTHON" ] && [ ! -d "$WITH_PYTHON" ]; then
    eval "echo \"$TESTING_WITH_PYTHON\""
    if "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py --without-ssl=${WITHOUT_SSL}; then
        eval "echo \"$WITH_PYTHON_IS_OK\""
        echo
        # if the supplied Python is adequate, we don't need to build libraries
        WITHOUT_SSL="yes"
    else
        eval "echo \"$WITH_PYTHON_IS_BAD\""
        python_usage
    fi
else
    eval "echo \"$WITH_PYTHON_NOT_EX\""
    python_usage
fi


# Normalize WITH_PYTHON to a full pathname
PY_DIR=`dirname "$WITH_PYTHON"`
PY_BASE=`basename "$WITH_PYTHON"`
cd "$PY_DIR"
PY_DIR=`pwd`
cd "$INSTALLER_PWD"
WITH_PYTHON="${PY_DIR}/${PY_BASE}"


#############################
# Preflight dependency checks
# Binary path variables may have been filled in by literal paths or
# by 'which'. 'which' negative results may be empty or a message.

if [ $SKIP_TOOL_TESTS -eq 0 ]; then

    # Abort install if no gcc
    if [ "x$CC" = "x" ] ; then
        echo
        echo $MISSING_GCC
        exit 1
    fi

    # Abort install if no g++
    if [ "x$CXX" = "x" ] ; then
        echo
        echo $MISSING_GPP
        exit 1
    fi

    # Abort install if no make
    if [ "X$have_make" != "Xyes" ] ; then
        echo
        echo $MISSING_MAKE
        exit 1
    fi

    # Abort install if no tar
    if [ "X$have_tar" != "Xyes" ] ; then
        echo
        echo $MISSING_TAR
        exit 1
    fi

    # Abort install if no patch
    if [ "X$have_patch" != "Xyes" ] ; then
        echo
        echo $MISSING_PATCH
        exit 1
    fi

    # Abort install if no gunzip
    if [ "X$have_gunzip" != "Xyes" ] ; then
        echo
        echo $MISSING_GUNZIP
        exit 1
    fi

    # Abort install if no bunzip2
    if [ "X$have_bunzip2" != "Xyes" ] ; then
        echo
        echo $MISSING_BUNZIP2
        exit 1
    fi

    if [ "X$HAVE_LIBZ" != "Xyes" ] && [ "X$BUILD_PYTHON" != "Xno" ] ; then
        echo $NEED_INSTALL_LIBZ_MSG
        exit 1
    fi

    if [ "X$HAVE_LIBJPEG" != "Xyes" ] && [ "X$BUILD_PYTHON" != "Xno" ] ; then
        echo $NEED_INSTALL_LIBJPEG_MSG
        exit 1
    fi

    if [ "$INSTALL_LXML" = "no" ] && [ "X$BUILD_PYTHON" != "Xno" ]; then
        # check for libxml2 / libxslt

        XSLT_XML_MSG () {
            eval "echo \"$MISSING_MINIMUM_XSLT\""
        }

        if [ "x$XSLT_CONFIG" = "x" ]; then
            echo
            echo $MISSING_XML2_DEV
            XSLT_XML_MSG
            exit 1
        fi
        if [ "x$XML2_CONFIG" = "x" ]; then
            echo
            echo $MISSING_XSLT_DEV
            XSLT_XML_MSG
            exit 1
        fi
        if ! config_version xml2 $NEED_XML2; then
            eval "echo \"$BAD_XML2_VERSION\""
            XSLT_XML_MSG
            exit 1
        fi
        if ! config_version xslt $NEED_XSLT; then
            eval "echo \"$BAD_XSLT_VERSION\""
            XSLT_XML_MSG
            exit 1
        fi
        FOUND_XML2=`xml2-config --version`
        FOUND_XSLT=`xslt-config --version`
    fi
fi # not skip tool tests


######################################
# Pre-install messages
if [ $ROOT_INSTALL -eq 1 ]; then
    eval "echo \"$ROOT_INSTALL_CHOSEN\""
else
    eval "echo \"$ROOTLESS_INSTALL_CHOSEN\""
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
    echo "PWD=$INSTALLER_PWD"
    echo "CWD=$CWD"
    echo "PKG=$PKG"
    echo "WITH_PYTHON=$WITH_PYTHON"
    echo "BUILD_PYTHON=$BUILD_PYTHON"
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
    eval "echo \"$CANNOT_WRITE_LOG\""
    INSTALL_LOG="/dev/stdout"
else
    eval "echo \"$LOGGING_MSG\""
    echo "Detailed installation log" > "$INSTALL_LOG"
    echo "Starting at `date`" >> "$INSTALL_LOG"
fi
seelog () {
    eval "echo \"$SEE_LOG_EXIT_MSG\""
    exit 1
}


eval "echo \"$INSTALLING_NOW\""


#######################################
# create os users for root-level install
if [ $ROOT_INSTALL -eq 1 ]; then
    # source user/group utilities
    . "${INSTALLER_PWD}/helper_scripts/user_group_utilities.sh"

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
    if [ $ROOT_INSTALL -eq 1 ]; then
        chown "$BUILDOUT_USER:$PLONE_GROUP" "$PLONE_HOME"
        chmod g+s "$PLONE_HOME"
    fi

    # normalize $PLONE_HOME so we can use it in prefixes
    if [ $? -gt 0 ] || [ ! -x "$PLONE_HOME" ]; then
        eval "echo \"$CANNOT_CREATE_HOME\""
        exit 1
    fi
    cd "$PLONE_HOME"
    PLONE_HOME=`pwd`
fi

cd "$CWD"


# The main install may be done via sudo (if a root install). If it is,
# our current directory may become unreachable. So, copy the resources
# we'll need into a tmp directory inside the install destination.
WORKDIR="${PLONE_HOME}/tmp"
mkdir "$WORKDIR" > /dev/null 2>&1
cd "${INSTALLER_PWD}"
cp -R buildout_templates "$WORKDIR"
cp -R base_skeleton "$WORKDIR"
cp -R helper_scripts "$WORKDIR"
cp -R packages "$WORKDIR"
PACKAGES_DIR="${WORKDIR}/packages"
PKG="$PACKAGES_DIR"
if [ $ROOT_INSTALL -eq 1 ]; then
    chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$WORKDIR"
    find "$WORKDIR" -type d -exec chmod g+s {} \;
fi


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
    eval "echo \"$INSTANCE_HOME_EXISTS\""
    exit 1
fi

cd "$CWD"


# Create and check a Python virtualenv
PYBNAME=`basename "$WITH_PYTHON"`
PY_HOME="$INSTANCE_HOME"
echo $CREATING_VIRTUALENV|tee -a "$INSTALL_LOG"
PYTHON_MAJOR=`$WITH_PYTHON --version 2>&1|awk '{print $2}'|head -c 1`
if [ "2" = "$PYTHON_MAJOR" ]; then
    cd "$PKG"
    tar xf $VIRTUALENV_TB
    cd $VIRTUALENV_DIR
    $SUDO "$WITH_PYTHON" virtualenv.py "$PY_HOME"  2>> "$INSTALL_LOG"
    cd "$PKG"
    rm -r $VIRTUALENV_DIR
else
    $SUDO "$WITH_PYTHON" -m venv "$PY_HOME"  2>> "$INSTALL_LOG"
fi
PY=$PY_HOME/bin/python
if [ ! -x "$PY" ]; then
    eval "echo \"$VIRTUALENV_CREATION_FAILED\""|tee -a "$INSTALL_LOG"
    exit 1
fi
if [ $ROOT_INSTALL -eq 1 ]; then
    chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$PY_HOME"
fi
echo "Virtualenv successfully created" >> "$INSTALL_LOG"

cd "$CWD"
if ! "$WITH_PYTHON" "$HSCRIPTS_DIR"/checkPython.py --without-ssl=${WITHOUT_SSL}; then
    echo $VIRTUALENV_BAD|tee -a "$INSTALL_LOG"
    exit 1
fi

if [ -f "${WORKDIR}/base_skeleton/requirements.txt" ]; then
    echo $INSTALLING_REQUIREMENTS|tee -a "$INSTALL_LOG"
    $SUDO "${PY_HOME}/bin/pip" install -r "${WORKDIR}/base_skeleton/requirements.txt" >> "$INSTALL_LOG" 2>&1
    if [ $? -gt 0 ]; then
        echo $INSTALLING_REQUIREMENTS_FAILED|tee -a "$INSTALL_LOG"
        seelog
        exit 1
    fi
fi

# Create the buildout cache
BUILDOUT_CACHE="$PLONE_HOME/buildout-cache"
BUILDOUT_DIST="$PLONE_HOME/buildout-cache/downloads/dist"
if [ -f "${PKG}/buildout-cache.tar.bz2" ]; then
    if [ -x "$BUILDOUT_CACHE" ]; then
        eval "echo \"$FOUND_BUILDOUT_CACHE\""|tee -a "$INSTALL_LOG"
    else
        echo "$UNPACKING_BUILDOUT_CACHE"|tee -a "$INSTALL_LOG"
        cd $PLONE_HOME
        tar xf "${PKG}/buildout-cache.tar.bz2"
        # # compile .pyc files in cache
        # echo "Compiling .py files in egg cache"
        # "$PY" "$PLONE_HOME"/Python*/lib/python*/compileall.py "$BUILDOUT_CACHE"/eggs > /dev/null 2>&1
    fi
    if [ ! -x "$BUILDOUT_CACHE"/eggs ]; then
        echo $BUILDOUT_CACHE_UNPACK_FAILED
        seelog
        exit 1
    fi
    if [ $ROOT_INSTALL -eq 1 ]; then
        chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$BUILDOUT_CACHE"
    fi
    FORCE_BUILD_FROM_CACHE=yes
else
    mkdir "$BUILDOUT_CACHE" > /dev/null 2>&1
    mkdir "$BUILDOUT_CACHE"/eggs > /dev/null 2>&1
    mkdir "$BUILDOUT_CACHE"/extends > /dev/null 2>&1
    mkdir "$BUILDOUT_CACHE"/downloads > /dev/null 2>&1
    if [ $ROOT_INSTALL -eq 1 ]; then
        chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$BUILDOUT_CACHE"
    fi
    FORCE_BUILD_FROM_CACHE=no
fi


# copy docs
if [ -x "$CWD/Plone-docs" ] && [ ! -x "$PLONE_HOME/Plone-docs" ]; then
    echo "Copying Plone-docs"
    cp -R "$CWD/Plone-docs" "$PLONE_HOME/Plone-docs"
    if [ $ROOT_INSTALL -eq 1 ]; then
        chown -R "$BUILDOUT_USER:$PLONE_GROUP" "$PLONE_HOME/Plone-docs"
    fi
fi


cd "$CWD"

########################
# Instance install steps
########################

cd "$WORKDIR"

################################################
# Install the zeocluster or stand-alone instance
if [ $INSTALL_ZEO -eq 1 ]; then
    INSTALL_METHOD="cluster"
elif [ $INSTALL_STANDALONE -eq 1 ]; then
    INSTALL_METHOD="standalone"
    CLIENT_COUNT=0
fi

echo "Create buildout: $INSTALL_METHOD" |tee -a "$INSTALL_LOG"

$SUDO "$PY" "${HSCRIPTS_DIR}/create_instance.py" \
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
    "--force_build_from_cache=$FORCE_BUILD_FROM_CACHE" \
    "--clients=$CLIENT_COUNT" 2>&1 >>"$INSTALL_LOG"

if [ $? -gt 0 ]; then
    echo $BUILDOUT_FAILED|tee -a "$INSTALL_LOG"
    seelog
    exit 1
fi
echo $BUILDOUT_SUCCESS|tee -a "$INSTALL_LOG"

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
            eval "echo \"$INSTALL_COMPLETE\""|tee -a "$INSTALL_LOG"
            cat $PWFILE
        else
            eval "echo \"$BUILDOUT_SKIPPED_OK\""|tee -a "$INSTALL_LOG"
        fi
        echo $NEED_HELP_MSG
    fi
    echo "Finished at `date`" >> "$INSTALL_LOG"
else
    eval "echo \"$REPORT_ERRORS_MSG\""|tee -a "$INSTALL_LOG"
    exit 1
fi
