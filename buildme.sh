#!/bin/sh
set -e

# Script to build a UnifiedInstaller tarball
# By default the target built against is the ~/nobackup/work directory.
# You can optionally give the target as the first argument.
# packages should already be updated; particularly the
# build-cache tarball.


# MODIFY THE VARIABLES BELOW TO REFLECT THE NEEDS OF THE NEW VERSION
BASE_VER="5.2.5"
INSTALLER_REVISION="1.0"

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
  TAR='gnutar --owner 0 --group 0 c-zf'
  UNTAR='gnutar xzf'
elif [ -n "`which gtar`" ]; then
  TAR='gtar --owner 0 --group 0 -czf'
  UNTAR='gtar xzf'
else
  if [ "`tar --help|grep GNU|head -n1|awk -F ' ' '{print $1}'`" = "GNU" ]; then
    TAR="tar --owner 0 --group 0 -czf"
    UNTAR='tar xzf'
  else
    echo "Using BSD tar, because neither gnutar nor gtar was not found"
    echo "Warning: Using BSD tar rather than gnutar or gtar may have unintended consequences."
    TAR='tar -czf'
    UNTAR="tar -xzf"
  fi
fi

TARGET=Plone-${BASE_VER}-UnifiedInstaller-${INSTALLER_REVISION}
TARGET_DIR=${WORK_DIR}/${TARGET}
TARGET_TGZ=${WORK_DIR}/${TARGET}.tgz
TARGET_ZIP=${WORK_DIR}/${TARGET}.zip

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
rm ${TARGET_DIR}/UPDATING_ME.rst
rm ${TARGET_DIR}/preflight.ac
rm -f ${TARGET_DIR}/install.log
rm -f {TARGET_DIR}/config.status
rm -f ${TARGET_DIR}/config.log
rm -f ${TARGET_DIR}/tests/testout.txt
rm -rf ${TARGET_DIR}/Plone-docs
rm -rf ${TARGET_DIR}/autom4te.cache
rm -r ${TARGET_DIR}/.github
rm -rf ${TARGET_DIR}/packages/Python*

echo "Getting docs"
curl -L https://github.com/plone/Plone/archive/${BASE_VER}.zip --output ${BASE_VER}.zip
if [ -f "${BASE_VER}.zip" ]; then
  unzip ${BASE_VER}.zip
  rm ${BASE_VER}.zip
  mv Plone-${BASE_VER}/docs ${TARGET_DIR}/Plone-docs
  rm -rf Plone-${BASE_VER}
fi

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

cd $WORK_DIR

echo "Making tarball"
echo "$TAR ${TARGET_TGZ} ${TARGET}"
$TAR ${TARGET_TGZ} ${TARGET}

echo "Making ZIP-file"
echo "zip -r ${TARGET_ZIP} ${TARGET}"
zip -r ${TARGET_ZIP} ${TARGET}

echo "Remove Build Dir"
rm -r ${TARGET}

echo "Test unpack of tarball"
$UNTAR ${TARGET_TGZ}
ls -la ${TARGET}
rm -r ${TARGET}

echo "Test unpack of zipfile"
unzip ${TARGET_ZIP}
ls -la ${TARGET}
rm -r ${TARGET}

cd $CURDIR
echo "Build Done"
echo "---------------------------------------------------------------------"
