###################
# build libjpeg
#

if [ "X$INSTALL_JPEG" = "Xyes" ] && [ ! -f "$LOCAL_HOME/lib/libjpeg.a" ]
then
	echo "Compiling and installing jpeg local libraries ..."

	mkdir "$LOCAL_HOME/lib" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/bin" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/include" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/man" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/man/man1" >> "$INSTALL_LOG" 2>&1
	
	cd "$PKG"
	untar "$JPEG_TB"
	chmod -R 755 "$JPEG_DIR"
	cd "$JPEG_DIR"
	./configure CFLAGS="$CFLAGS" --prefix="$LOCAL_HOME" --enable-shared=no >> "$INSTALL_LOG" 2>&1
	make >> "$INSTALL_LOG" 2>&1
	make install >> "$INSTALL_LOG" 2>&1

	if [ ! -f "$LOCAL_HOME/lib/libjpeg.a" ]
	then
		echo "Local install of libjpeg has failed"
		seelog
		exit 1
	fi

	cd "$PKG"
	if [ -d "$JPEG_DIR" ]
	then
	        rm -rf "$JPEG_DIR"
	fi
else
	echo "Skipping libjpeg build"
fi

cd "$CWD"
