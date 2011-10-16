##################
# build zlib
# Note that, even though we're building static libraries, python
# is going to try to build a shared library for it's own use.
# The "-fPIC" flag is thus required for some platforms.
#
# $LastChangedDate: 2009-11-08 13:03:15 -0800 (Sun, 08 Nov 2009) $ $LastChangedRevision: 31217 $


if [ "X$INSTALL_ZLIB" = "Xglobal" ]
then
	echo "Compiling and installing zlib ..."
	cd "$PKG"
	untar "$ZLIB_TB"
	chmod -R 775 "$ZLIB_DIR"
	cd $ZLIB_DIR
	./configure >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" test >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" install >> $INSTALL_LOG 2>&1
	cd "$PKG"
	if [ -d "$ZLIB_DIR" ]
	then
	    rm -rf "$ZLIB_DIR"
	fi
	if [ ! -e "$/usr/local/lib/libz.a" ]
	then
		echo "Install of local libz failed"
		seelog
		exit 1
	fi
elif [ "X$INSTALL_ZLIB" = "Xlocal" ] && [ ! -e "$LOCAL_HOME/lib/libz.a" ]
then
	echo "Compiling and installing local zlib ..."
	cd "$PKG"
	untar "$ZLIB_TB"
	chmod -R 775 "$ZLIB_DIR"
	cd "$ZLIB_DIR"
    ./configure --prefix="$LOCAL_HOME" >> $INSTALL_LOG 2>&1
	$GNU_MAKE >> $INSTALL_LOG 2>&1
	$GNU_MAKE test >> $INSTALL_LOG 2>&1
	$GNU_MAKE install >> $INSTALL_LOG 2>&1
	cd "$PKG"
	if [ -d "$ZLIB_DIR" ]
	then
	    rm -rf "$ZLIB_DIR"
	fi
	if [ ! -e "$LOCAL_HOME/lib/libz.a" ]
	then
		echo "Install of local libz failed"
		seelog
		exit 1
	fi
else
	echo "Skipping zlib compile and install"
fi

cd "$CWD"