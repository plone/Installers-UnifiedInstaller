# Copyright (c) 2012 Plone Foundation. Licensed under GPL v 2.
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


# version_str2num converts a string like 2.7.8 to a number like 20708
#
version_str2num () {
    # convert a string like 2.7.8 to a number like 20708
    major_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    minor_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    micro_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`
    echo $(($major_version * 10000 + $minor_version*100 + $micro_version))
}


# A_VERSION=`version_str2num 1.2.3`
# echo $A_VERSION
# exit 0


# functions to check xslt or xml2 versions.
#
# config_version xml2/xslt 2.7.8
# returns 1 if good; 0 if not
#
# if config_version xml2 "2.7.8"; then
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# else
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# fi
config_version () {
    CONFIG="$1-config"
    REF_VERSION=`version_str2num $2`

    which $CONFIG > /dev/null
    if [ $? -gt 0 ]; then
        return 0
    fi
    CONFIG_VERSION=`$CONFIG --version`

    FOUND_VERSION=`version_str2num $CONFIG_VERSION`
    return $(($FOUND_VERSION >= $REF_VERSION))
}

# if config_version xml2 "2.7.8"; then
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# else
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# fi
# if config_version xml2 "2.7.11"; then
#     echo "No, xml2-config doesn't exist, or version is < 2.7.11"
# else
#     echo "Yes, xml2-config exists, and version is >= 2.7.11"
# fi
# if config_version xml20 "2.7.8"; then
#     echo "No, xml20-config doesn't exist, or version is < 2.7.8"
# else
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# fi
