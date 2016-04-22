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

BASE_VER=4.3.9
NEWVER=${BASE_VER}-r1

SDIR=`pwd`

cd $WORK_DIR
rm -r Plone-${NEWVER}-UnifiedInstaller Plone-${NEWVER}-UnifiedInstaller.tgz

cd $SDIR
cp -R ${SDIR}/ $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/
rm -rf $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/.git
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/.gitignore
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/buildme.sh
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/preflight.ac
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/update_packages.py
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/to-do.txt
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/install.log
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/config.status
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/config.log
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/buildenv.sh
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/tests/testout.txt
rm -r $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/Plone-docs
rm -r $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/autom4te.cache
rm $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller/packages/Python*

mkdir $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller
cd $WORK_DIR/Plone-${NEWVER}-UnifiedInstaller

echo "Getting docs"
$WGET --no-check-certificate https://pypi.python.org/packages/source/P/Plone/Plone-${BASE_VER}.tar.gz
tar xf Plone-${BASE_VER}.tar.gz
rm Plone-${BASE_VER}.tar.gz
mv Plone-${BASE_VER}/docs Plone-docs
rm -r Plone-${BASE_VER}

find . -name "._*" -exec rm {} \;
find . -name ".DS_Store" -exec rm {} \;
find . -name "*.py[co]" -exec rm -f {} \;
find . -type f -exec chmod 644 {} \;
chmod 755 install.sh base_skeleton/bin/*
find . -type d -exec chmod 755 {} \;

cd $WORK_DIR
echo Making tarball
$TAR --owner 0 --group 0 -zcf Plone-${NEWVER}-UnifiedInstaller.tgz Plone-${NEWVER}-UnifiedInstaller
rm -r Plone-${NEWVER}-UnifiedInstaller
echo Test unpack of tarball
$TAR zxf Plone-${NEWVER}-UnifiedInstaller.tgz
cd Plone-${NEWVER}-UnifiedInstaller
