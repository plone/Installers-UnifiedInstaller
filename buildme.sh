#!/bin/sh

# Script to build a UnifiedInstaller tarball
# By default the target built against is the ~/nobackup/work directory.
# You can optionally give the target as the first argument.
# packages should already be updated; particularly the
# build-cache tarball.

WORK_DIR=~/nobackup/work
if [ -n "$1" ]; then
  WORK_DIR=$1
fi

# wget or curl?
if [ -n "`which wget`" ]; then
  WGET='wget'
else
  echo "Using curl, because wget was not found"
  WGET='curl -O'
fi

# gnutar or tar?
if [ -n "`which gnutar`" ]; then
  TAR='gnutar'
else
  echo "Using tar, because gnutar was not found"
  echo "Warning: Using tar rather than gnutar may have unintended consequences."
  TAR='tar'
fi

BASE_VER=5.0.8
NEWVER=${BASE_VER}
INSTALLER_REVISION="-r1"

SDIR=`pwd`

TARGET=Plone-${NEWVER}-UnifiedInstaller${INSTALLER_REVISION}

cd $WORK_DIR
rm -r ${TARGET} ${TARGET}.tgz

TARGET_DIR=${WORK_DIR}/${TARGET}

cd $SDIR
cp -R ${SDIR}/ ${TARGET_DIR}/
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
rm ${TARGET_DIR}/packages/Python*

mkdir ${TARGET_DIR}
cd ${TARGET_DIR}

echo "Getting docs"
$WGET --no-check-certificate https://github.com/plone/Plone/archive/${BASE_VER}.zip
unzip ${BASE_VER}.zip
rm ${BASE_VER}.zip
mv Plone-${BASE_VER}/docs Plone-docs
rm -r Plone-${BASE_VER}

find . -name "._*" -exec rm {} \;
find . -name ".DS_Store" -exec rm {} \;
find . -name "*.py[co]" -exec rm -f {} \;
find . -type f -exec chmod 644 {} \;
chmod 755 install.sh
find . -type d -exec chmod 755 {} \;

cd $WORK_DIR
echo Making tarball
$TAR --owner 0 --group 0 -zcf ${TARGET}.tgz ${TARGET}
rm -r ${TARGET}
echo Test unpack of tarball
$TAR zxf ${TARGET}.tgz
cd ${TARGET}
