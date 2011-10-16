###################
# build libjpeg
# $LastChangedDate: 2009-11-08 13:03:15 -0800 (Sun, 08 Nov 2009) $ $LastChangedRevision: 31217 $
#

if [ "X$INSTALL_JPEG" = "Xglobal" ]
then
	echo "Compiling and installing jpeg system libraries ..."

	# It's not impossible that the /usr/local hierarchy doesn't
	# exist. The libjpeg install will not create it itself.
	# (The zlib install will, but we can't count on it having
	# run, since we've made it an option.)
	if [ ! -e /usr/local ]
	then
		mkdir /usr/local
	fi
	if [ ! -e /usr/local/bin ]
	then
		mkdir /usr/local/bin
	fi
	if [ ! -e /usr/local/include ]
	then
		mkdir /usr/local/include
	fi
	if [ ! -e /usr/local/lib ]
	then
		mkdir /usr/local/lib
	fi
	if [ ! -e /usr/local/man ]
	then
		mkdir /usr/local/man
	fi
	if [ ! -e /usr/local/man/man1 ]
	then
		mkdir /usr/local/man/man1
	fi

	cd "$PKG"
	untar "$JPEG_TB"
	chmod -R 775 "$JPEG_DIR"
	cd "$JPEG_DIR"
	# Oddities to workaround: on Mac OS X, using the "--enable-static"
	# flag will cause the make to fail. So, we need to manually
	# create and place the static library.
    ./configure CFLAGS="$CFLAGS" >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" install >> $INSTALL_LOG 2>&1
	ranlib libjpeg.a
	cp libjpeg.a /usr/local/lib
	cp *.h /usr/local/include
	cd "$PKG"
	if [ -d "$JPEG_DIR" ]
	then
	        rm -rf "$JPEG_DIR"
	fi

	if [ ! -e "/usr/local/lib/libjpeg.a" ]
	then
		echo "Install of libjpeg has failed"
		seelog
		exit 1
	fi
elif [ "X$INSTALL_JPEG" = "Xlocal" ] && [ ! -e "$LOCAL_HOME/lib/libjpeg.a" ]
then
	echo "Compiling and installing jpeg local libraries ..."

	mkdir "$LOCAL_HOME/lib" >> $INSTALL_LOG 2>&1
	mkdir "$LOCAL_HOME/bin" >> $INSTALL_LOG 2>&1
	mkdir "$LOCAL_HOME/include" >> $INSTALL_LOG 2>&1
	mkdir "$LOCAL_HOME/man" >> $INSTALL_LOG 2>&1
	mkdir "$LOCAL_HOME/man/man1" >> $INSTALL_LOG 2>&1
	
	cd "$PKG"
	untar "$JPEG_TB"
	chmod -R 775 "$JPEG_DIR"
	cd "$JPEG_DIR"
	# Oddities to workaround: on Mac OS X, using the "--enable-static"
	# flag will cause the make to fail. So, we need to manually
	# create and place the static library.
	./configure CFLAGS="$CFLAGS" --prefix="$LOCAL_HOME" >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" >> $INSTALL_LOG 2>&1
	"$GNU_MAKE" install >> $INSTALL_LOG 2>&1
	# --enable-static flag doesn't work on OS X, make sure
	# we get an install anyway
	if [ ! -e "$LOCAL_HOME/lib/libjpeg.a" ]
	then
		ranlib libjpeg.a
		cp libjpeg.a "$LOCAL_HOME/lib"
		cp *.h "$LOCAL_HOME/include"
	fi

	if [ ! -e "$LOCAL_HOME/lib/libjpeg.a" ]
	then
		echo "Local install of libjpeg has failed"
		seelog
		exit 1
	fi

	cd $PKG
	if [ -d "$JPEG_DIR" ]
	then
	        rm -rf "$JPEG_DIR"
	fi
else
	echo "Skipping libjpeg compile/install"
fi

cd "$CWD"