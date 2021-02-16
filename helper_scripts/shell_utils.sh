# Copyright (c) 2012-2021 Plone Foundation. Licensed under GPL v 2.
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


# # download ()
# # Download using curl or wget.
# # Arguments should be URL, test filename, md5sum
download () {
    if (which curl > /dev/null); then
        echo Downloading $2 with curl
        curl $1 --output $2 --location
    elif (which wget > /dev/null); then
        echo Downloading $2 with wget
        wget $1 -O $2
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
