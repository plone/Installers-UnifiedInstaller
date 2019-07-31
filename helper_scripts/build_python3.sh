######################################
# Build Python (with readline and zlib support)
# note: Install readline and zlib before running this script
#

eval "echo \"$INSTALLING_PYTHON3\""
cd "$PKG"
untar "$PYTHON3_TB"
chmod -R 755 "$PYTHON3_DIR"
cd "$PYTHON3_DIR"

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

echo ./configure $EXFLAGS --prefix="$PY_HOME" ...
./configure $EXFLAGS --prefix="$PY_HOME" >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ]; then
    eval "echo \"$UNABLE_TO_CONFIGURE_PY\""
    seelog
    exit 1
fi

echo make install ...
make install >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ]; then
    echo $PY_BUILD_FAILED
    seelog
    exit 1
fi

cd "$PKG"
if [ -d "$PYTHON3_DIR" ]; then
    rm -rf "$PYTHON3_DIR"
fi
if [ ! -x "$PY_HOME/bin/python3" ]; then
	eval "echo \"$INSTALL_PY3_FAILED\""
	seelog
    exit 1
fi

cd "$CWD"
