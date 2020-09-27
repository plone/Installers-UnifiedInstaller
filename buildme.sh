#!/bin/sh

# Script to build a UnifiedInstaller tarball
# By default the target built against is the ~/nobackup/work directory.
# You can optionally give the target as the first argument.
# packages should already be updated; particularly the
# build-cache tarball.


# MODIFY THE VARIABLES BELOW TO REFLECT THE NEEDS OF THE NEW VERSION
BASE_VER=5.2.2
INSTALLER_REVISION=""

# The next file has to start with virtualenv* -
# otherwise it need to be changed also in helper_scripts/main_install_script.sh and helper_scripts/windows_install.py
# in ANY CASE the variables VIRTUALENV_TB and VIRTUALENV_DIR helper_scripts/main_install_script.sh need to be edited if changed!
VIRTUALENV_DOWNLOAD=https://files.pythonhosted.org/packages/a4/e3/1f067de470e3a86875ed915438dc3bd781fb0346254f541190a09472b677/virtualenv-16.7.10.tar.gz
VIRTUALENV_FILE=virtualenv-16.7.10.tar.gz
# END OF NECESSARY MODS

CURDIR=`pwd`

WORK_DIR=../`basename $CURDIR`-dist
if [ -n "$1" ]; then
  WORK_DIR=$1
fi
echo "Working directory is $WORK_DIR"

# curl?
if [ ! -n "`which curl`" ]; then
  echo "curl was not found, install curl and try again"
  exit 1
fi

# gnutar, gtar or tar?
if [ -n "`which gnutar`" ]; then
  TAR='gnutar'
elif [ -n "`which gtar`" ]; then
  TAR='gtar'
else
  echo "Using tar, because neither gnutar nor gtar was not found"
  echo "Warning: Using tar rather than gnutar or gtar may have unintended consequences on non GNU-Linux Systems."
  TAR='tar'
fi

TARGET=Plone-${BASE_VER}-UnifiedInstaller${INSTALLER_REVISION}
TARGET_DIR=${WORK_DIR}/${TARGET}
TARGET_TGZ=${WORK_DIR}/${TARGET}.tgz

echo "Remove previous builds"
if [ -e "${TARGET_DIR}" ]; then
  echo "Remove previous build directory"
  rm -r ${TARGET_DIR}
fi
if [ -e "${TARGET_TGZ}" ]; then
  echo "Remove previous build targz"
  rm -r ${TARGET_TGZ}
fi
if [ ! -d "${WORK_DIR}" ]; then
  echo "Create working directory"
  mkdir ${WORK_DIR}
fi

echo "Copy and cleanup new installer"
cp -R $CURDIR/ ${TARGET_DIR}/
rm -rf ${TARGET_DIR}/.git
rm ${TARGET_DIR}/.gitignore
rm ${TARGET_DIR}/buildme.sh
rm ${TARGET_DIR}/preflight.ac
rm ${TARGET_DIR}/update_packages.py
rm ${TARGET_DIR}/to-do.txt
rm ${TARGET_DIR}/install.log
rm ${TARGET_DIR}/config.status
rm ${TARGET_DIR}/config.log
rm ${TARGET_DIR}/buildenv.sh
rm ${TARGET_DIR}/tests/testout.txt
rm -r ${TARGET_DIR}/Plone-docs
rm -r ${TARGET_DIR}/autom4te.cache
rm -r ${TARGET_DIR}/.github
rm ${TARGET_DIR}/packages/Python*

echo "Getting docs"
curl -O  https://github.com/plone/Plone/archive/${BASE_VER}.zip
unzip ${BASE_VER}.zip
rm ${BASE_VER}.zip
mv Plone-${BASE_VER}/docs ${TARGET_DIR}/Plone-docs
rm -rf Plone-${BASE_VER}

echo "Getting virtualenv"
mkdir $TARGET_DIR/packages
cd $TARGET_DIR/packages
curl $VIRTUALENV_DOWNLOAD -o $VIRTUALENV_FILE
cd $CURDIR

echo "Set permissions on new installer..."
find ${TARGET_DIR} -name ".DS_Store" -exec rm {} \;
find ${TARGET_DIR} -name "._*" -exec rm {} \;
find ${TARGET_DIR} -name "*.py[co]" -exec rm -f {} \;
find ${TARGET_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${TARGET_DIR}/install.sh
find ${TARGET_DIR} -type d -exec chmod 755 {} \;

echo "Making tarball"
cd $WORK_DIR
$TAR --owner 0 --group 0 -zcf ${TARGET_TGZ} ${TARGET}
rm -r ${TARGET}

echo "Test unpack of tarball"
$TAR zxf ${TARGET_TGZ}
ls -la ${TARGET}

cd $CURDIR
echo "Build Done"
echo "---------------------------------------------------------------------"
PYTHON=`which python`
cd $TARGET_DIR/tests
echo Running tests with $PYTHON
$PYTHON testall.py
echo "---------------------------------------------------------------------"

