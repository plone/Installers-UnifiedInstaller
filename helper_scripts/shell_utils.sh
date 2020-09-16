# Copyright (c) 2012-2013 Plone Foundation. Licensed under GPL v 2.
#
# Utilities meant to be sourced into a shell script


# untar ()
# unpack a tar archive, decompressing as necessary.
# this function is meant to isolate us from problems
# with versions of tar that don't support .gz or .bz2.
untar () {
    case "$1" in
        *.tar)
            tar -xf "$1" >> "$INSTALL_LOG"
            ;;
        *.tgz | *.tar.gz)
            gunzip -c "$1" | tar -xf - >> "$INSTALL_LOG"
            ;;
        *.tar.bz2)
            bunzip2 -c "$1" | tar -xf -  >> "$INSTALL_LOG"
            ;;
        *)
            echo "Unable to unpack $1; extension not recognized."
            exit 1
    esac
    if [ $? -gt 0 ]; then
        seelog
    fi
}

logged () {
    echo "### [ `date +'%T'` (in `pwd`) $* [" >> "$INSTALL_LOG"
    "$@" 2>&1 > "$INSTALL_TMP"
    LOCAL_RC=$?
    cat "$INSTALL_TMP" >> "$INSTALL_LOG"
    if [ -n "$LOCAL_RC" ]; then
        if [ "$LOCAL_RC" -gt 0 ]; then
            echo "### ]] --> $LOCAL_RC (ERROR)" >> "$INSTALL_LOG"
            error "Command failed [$LOCAL_RC]: $*"
        else
            echo "### ]] --> $LOCAL_RC" >> "$INSTALL_LOG"
        fi
    else
        echo "### ]] (no return code)" >> "$INSTALL_LOG"
    fi
    return $LOCAL_RC
}

# # download ()
# # Download using curl or wget.
# # Arguments should be URL, test filename, md5sum
download () {
    if [ -z "$3" ]; then
        echo "W: MD5 hash for $2 unknown!"
    fi
    if [ -f "$2" ]; then
        echo "Found in `pwd`:"
        ls -ld "$2"
        if [ -n "$3" ]; then
            if (which md5sum > /dev/null); then
                # check hash
                echo "$3  $2" | md5sum -c -
                [ $? -eq 0 ] && return
                # mismatch; repeating download
            else
                echo "W:Can't compute MD5 hash!"
                if [ $INTERACTIVE -eq 1 ]; then
                    if confirm "Use this file?"; then 
                        return
                    fi
                fi
                # non-interactive: download ... 
            fi
        else
            if (which md5sum > /dev/null); then
                md5sum "$2"
            else
                echo "W:Can't compute MD5 hash!"
            fi
            if [ $INTERACTIVE -eq 1 ]; then
                if confirm "Use this file?"; then 
                    return
                fi
            fi
            # non-interactive: download ... 
        fi
    fi
    eval "echo \"$DOWNLOADING_PYTHON\""
    if (which curl > /dev/null); then
        echo "Downloading $2 with curl"
        logged curl $1 --output $2 --location
    elif (which wget > /dev/null); then
        echo "Downloading $2 with wget"
        logged wget $1 -O $2
    else
        echo "We need either wget or curl in order to download $2."
        echo "Please use your package manager to install one of them."
        exit 1
    fi
    if [ $? -gt 0 ]; then
        echo "Download of $2 from $1 failed. Check for error messages"
        echo "on the console. Are you behind an HTTP proxy? If so, set"
        echo "the http_proxy environment variable."
        echo "(Download returned error.)"
        exit 1
    fi
    if [ ! -f $2 ]; then
        echo "Download of $2 from $1 failed. Check for error messages"
        echo "on the console. Are you behind an HTTP proxy? If so, set"
        echo "the http_proxy environment variable."
        echo "(File not found.)"
        exit 1
    fi
    if (which md5sum > /dev/null); then
        # check hash
        echo "$3  $2" | md5sum -c -
        if [ $? -gt 0 ]; then
            echo "MD5 checksum of downloaded file did not match expectations."
            echo "Download unusable. Failed!"
            exit 1
        fi
    fi
}

# ---------------------- [ little helpers for [23].x.y versions ... [
python_tb() {
    echo "Python-${1}.tgz"
}
python_dir() {
    echo "Python-$1"
}
python_url() {
    echo "https://www.python.org/ftp/python/$1/Python-${1}.tgz"
}

download_python () {
    download "`python_url "$1"`" "`python_tb "$1"`" "${PYTHON_MD5[$1]}"
}
# ---------------------- ] ... little helpers for [23].x.y versions ]

unchecked_download () {
    # e.g. for virtualenv.pyz; we don't maintain MD5 hash lists for this here
    if (which curl > /dev/null); then
        echo "Downloading $2 with curl"
        logged curl "$1" --output "$2" --location
    elif (which wget > /dev/null); then
        echo "Downloading $2 with wget"
        logged wget "$1" -O "$2"
    else
        echo "We need either wget or curl in order to download $2."
        echo "Please use your package manager to install one of them."
        exit 1
    fi
    if [ $? -gt 0 ]; then
        echo "Download of $2 from $1 failed. Check for error messages"
        echo "on the console. Are you behind an HTTP proxy? If so, set"
        echo "the http_proxy environment variable."
        echo "(Download returned error.)"
        exit 1
    fi
    if [ ! -f $2 ]; then
        echo "Download of $2 from $1 failed. Check for error messages"
        echo "on the console. Are you behind an HTTP proxy? If so, set"
        echo "the http_proxy environment variable."
        echo "(File not found.)"
        exit 1
    fi
}


# functions to check xslt or xml2 versions.
#
# config_version xml2/xslt 2.7.8
# returns 0 if good; 1 if not
#
# if config_version xml2 "2.7.8"; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# else
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# fi

config_version () {
    CONFIG="$1-config"

    REF_MAJOR=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    REF_MINOR=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    REF_MICRO=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`

    which $CONFIG > /dev/null
    if [ $? -gt 0 ]; then
        return 1
    fi

    VERSION=`$CONFIG --version`
    major_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    minor_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    micro_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`

    if [ $major_version -gt $REF_MAJOR ]; then
        return 0
    elif [ $major_version -eq $REF_MAJOR ]; then
        if [ $minor_version -gt $REF_MINOR ]; then
            return 0
        elif [ $minor_version -eq $REF_MINOR ]; then
            if [ $micro_version -ge $REF_MICRO ]; then
                return 0
            fi
        fi
    fi
    return 1
}

# for NEED_XML2 in 1.9.0 2.7.7 2.7.8 2.7.9 2.7.11 2.8.0; do
#     if config_version xml2 $NEED_XML2; then
#         echo "Yes, xml2-config exists, and version is >= $NEED_XML2"
#     else
#         echo "No, xml2-config doesn't exist, or version is < $NEED_XML2"
#     fi
# done

# for NEED_XSLT in 1.0.25 1.1.25 1.1.26 1.1.27 1.2.0 3.0.0; do
#     if config_version xslt $NEED_XSLT; then
#         echo "Yes, xslt-config exists, and version is >= $NEED_XSLT"
#     else
#         echo "No, xslt-config doesn't exist, or version is < $NEED_XSLT"
#     fi
# done

# download http://python.org/ftp/python/2.7.4/Python-2.7.4.tar.bz2 Python-2.7.4.tar.bz2 62704ea0f125923208d84ff0568f7d50

confirm() {
    read -n1 -p "$1
(<y>, <n>) "
    case "$REPLY" in
        '')
            echo "yes"
            return 0
            ;;
        'y' | 'Y')
            echo -e "\byes"
            return 0
            ;;
        *)  echo -e "\bno"
            return 1
            ;;
    esac
}
    
