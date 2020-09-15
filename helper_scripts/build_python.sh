######################################
# Build Python (with readline and zlib support)
# note: Install readline and zlib before running this script
#

PYTHON_TB="`python_tb "$BUILD_PYTHON"`"
PYTHON_DIR="`python_dir "$BUILD_PYTHON"`"

eval "echo \"$INSTALLING_PYTHON\""
logged cd "$PKG"

logged untar "$PYTHON_TB"
logged chmod -R 755 "$PYTHON_DIR"
logged cd "$PYTHON_DIR"

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

echo ./configure $EXFLAGS --prefix="$PY_HOME" ...
logged ./configure $EXFLAGS --prefix="$PY_HOME"
if [ $? -gt 0 ]; then
    eval "echo \"$UNABLE_TO_CONFIGURE_PY\""
    seelog
    exit 1
fi

echo make install ...
logged make install >> "$INSTALL_LOG" 2>&1
if [ $? -gt 0 ]; then
    echo $PY_BUILD_FAILED
    seelog
    exit 1
fi

logged cd "$PKG"
if [ -d "$PYTHON_DIR" ]; then
    logged rm -rf "$PYTHON_DIR"
fi
if [ ! -x "$PY_HOME/bin/python" ]; then
	eval "echo \"$INSTALL_PY_FAILED\""
	seelog
    exit 1
fi

logged cd "$CWD"
