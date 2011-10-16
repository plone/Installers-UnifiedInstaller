# Install readline if required
#
# $LastChangedDate: 2010-09-16 12:54:42 -0700 (Thu, 16 Sep 2010) $ $LastChangedRevision: 39955 $

if [ "X$INSTALL_READLINE" = "Xyes" ] && [ ! -f "$LOCAL_HOME/lib/libreadline.a" ]
then
	echo "Compiling and installing readline local libraries ..."

	mkdir "$LOCAL_HOME/lib" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/bin" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/include" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/man" >> "$INSTALL_LOG" 2>&1
	mkdir "$LOCAL_HOME/man/man1" >> "$INSTALL_LOG" 2>&1
	
	cd "$PKG"
	untar $READLINE_TB
	chmod -R 755 "$READLINE_DIR"
	cd "$READLINE_DIR"
	READLINE_DIR=`pwd`
  	./configure \
  	  --prefix="$LOCAL_HOME" >> "$INSTALL_LOG" 2>&1
	make >> "$INSTALL_LOG" 2>&1
	make install >> "$INSTALL_LOG" 2>&1

	if [ ! -f "$LOCAL_HOME/lib/libreadline.a" ]
	then
		echo "Local install of readline has failed"
		seelog
		exit 1
	fi

	cd "$PKG"
	if [ -d "$READLINE_DIR" ]
	then
	        rm -rf "$READLINE_DIR"
	fi
else
	echo "Skipping readline build"
fi

cd "$CWD"
