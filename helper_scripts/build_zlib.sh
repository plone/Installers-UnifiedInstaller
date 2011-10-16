##################
# build zlib
# Note that, even though we're building static libraries, python
# is going to try to build a shared library for it's own use.
# The "-fPIC" flag is thus required for some platforms.
#
# $LastChangedDate: 2010-09-16 12:54:42 -0700 (Thu, 16 Sep 2010) $ $LastChangedRevision: 39955 $


if [ "X$INSTALL_ZLIB" = "Xyes" ] && [ ! -f "$LOCAL_HOME/lib/libz.a" ]
then
	echo "Compiling and installing local zlib ..."
	cd "$PKG"
	untar "$ZLIB_TB"
	chmod -R 755 "$ZLIB_DIR"
	cd "$ZLIB_DIR"
    ./configure --prefix="$LOCAL_HOME" >> "$INSTALL_LOG" 2>&1
	make >> "$INSTALL_LOG" 2>&1
	make test >> "$INSTALL_LOG" 2>&1
	make install >> "$INSTALL_LOG" 2>&1
	cd "$PKG"
	if [ -d "$ZLIB_DIR" ]
	then
	    rm -rf "$ZLIB_DIR"
	fi
	if [ ! -f "$LOCAL_HOME/lib/libz.a" ]
	then
		echo "Install of local libz failed"
		seelog
		exit 1
	fi
else
	echo "Skipping zlib build"
fi

cd "$CWD"