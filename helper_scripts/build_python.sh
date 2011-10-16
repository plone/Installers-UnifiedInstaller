######################################
# Build Python (with readline and zlib support)
# note: Install readline and zlib before running this script
#
# $LastChangedDate: 2011-08-16 10:04:48 -0700 (Tue, 16 Aug 2011) $ $LastChangedRevision: 51626 $

echo "Installing Python 2.4.6. This takes a while..."
cd "$PKG"
untar "$PYTHON_TB"
chmod -R 775 "$PYTHON_DIR"
cd "$PYTHON_DIR"

# Look for Darwin
if [ `uname` = 'Darwin' ]; then
	# if /opt/local is available, make sure it's included in the component
	# build so that we can get fixed readline lib -- unless we're building our own
    if [ "X$INSTALL_RL" = "Xno" ] && [ -d /opt/local/include ] && [ -d /opt/local/lib ]; then
        sed -E -e "s|#(add_dir_to_list\(self\.compiler\..+_dirs, '/opt/local/)|\\1|" -i.bak setup.py
    fi
    # Look for Leopard (9.x)
    if uname -r | grep -q '^9\.'
    then
        # we're on Leopard
        if [ "X$MACOSX_DEPLOYMENT_TARGET" != "X10.4" ]; then
            # we're not compiling for tiger compatibility
        	# so, patch for Leopard setpgrp
        	sed -E -e "s|(CPPFLAGS=.+)|\\1 -D__DARWIN_UNIX03|" -i.bak Makefile.pre.in
        fi
    fi
    # Look for Snow Leopard (10.x)
    if uname -r | grep -q '^1[01]\.'
    then
        # we're on Snow Leopard; time to patch
        # Thanks, Florian!
        patch -p0 < ../../patches/python-2.4-darwin-10.6.patch >> "$INSTALL_LOG" 2>&1
        EXFLAGS="--disable-toolbox-glue --disable-ipv6 --disable-framework"
    fi
fi

if [ "x$UNIVERSALSDK" != "x" ];	then
    EXFLAGS="--enable-universalsdk=$UNIVERSALSDK"
fi

if [ $NEED_LOCAL -eq 1 ]; then
	./configure $EXFLAGS \
		--prefix="$PY_HOME" \
		--with-readline \
		--with-zlib \
		--disable-tk \
		--with-gcc="$GCC -I\"$LOCAL_HOME\"/include" \
		--with-cxx="$GPP -I\"$LOCAL_HOME\"/include" \
		LDFLAGS="-L\"$LOCAL_HOME\"/lib" \
		>> "$INSTALL_LOG" 2>&1
else
    ./configure $EXFLAGS \
		--prefix="$PY_HOME" \
		--with-readline \
		--with-zlib \
		--disable-tk \
		--with-gcc="$GCC" \
		--with-cxx="$GPP" \
		>> $INSTALL_LOG 2>&1
fi
"$GNU_MAKE" >> $INSTALL_LOG 2>&1
"$GNU_MAKE" install >> $INSTALL_LOG 2>&1
cd "$PKG"
if [ -d "$PYTHON_DIR" ]
then
    rm -rf "$PYTHON_DIR"
fi
if [ ! -x "$PY_HOME/bin/python" ]
then
	echo "Install of Python 2.4.6 has failed."
	seelog
    exit 1
fi
"$PY_HOME/bin/python" -c "'test'.encode('zip')"
if [ $? -gt 0 ]
then
	echo "Python zlib support is missing; something went wrong in the zlib or python build."
	seelog
	exit 1
fi

cd "$CWD"
