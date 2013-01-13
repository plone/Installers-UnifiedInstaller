######################################
# Build Python (with readline and zlib support)
# note: Install readline and zlib before running this script
#

echo "Installing ${PYTHON_DIR}. This takes a while..."
cd "$PKG"
untar "$PYTHON_TB"
chmod -R 755 "$PYTHON_DIR"
cd "$PYTHON_DIR"

# XXX: See if we still need this.
# echo "Patching for thread size"
# patch -p0 < ../issue9670-v2.txt >> "$INSTALL_LOG" 2>&1
# if [ $? -gt 0 ]; then
# 	echo "Failed to patch for thread size."
# 	seelog
# 	exit 1
# fi

# Look for Darwin
if [ `uname` = 'Darwin' ]; then
	# if /opt/local is available, make sure it's included in the component
	# build so that we can get port libraries, which historically have been
    # better maintained than what Apple includes.
    if [ -d /opt/local/include ] && [ -d /opt/local/lib ]; then
        sed -E -e "s|#(add_dir_to_list\(self\.compiler\..+_dirs, '/opt/local/)|\\1|" -i.bak setup.py
    fi
    EXFLAGS="--disable-toolbox-glue --disable-ipv6 --disable-framework"

    if [ "x$UNIVERSALSDK" != "x" ]; then
        EXFLAGS="--enable-universalsdk=$UNIVERSALSDK"
    fi
fi


./configure $EXFLAGS --prefix="$PY_HOME" >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ]; then
    echo "Unable to configure Python build."
    seelog
    exit 1
fi

make install >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ]; then
    echo "Python build has failed."
    seelog
    exit 1
fi

cd "$PKG"
if [ -d "$PYTHON_DIR" ]; then
    rm -rf "$PYTHON_DIR"
fi
if [ ! -x "$PY_HOME/bin/python" ]; then
	echo "Install of ${PYTHON_DIR} has failed."
	seelog
    exit 1
fi

cd "$CWD"
