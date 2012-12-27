# functions to check xslt or xml2 versions.
#
# version_str2num converts a string like 2.7.8 to a number like 20708
#
# config_version xml2/xslt 2.7.8
# returns 1 if good; 0 if not
#
# if config_version xml2 "2.7.8"; then
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# else
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# fi

version_str2num () {
    # convert a string like 2.7.8 to a number like 20708
    major_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    minor_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    micro_version=`echo $1 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`
    return $(($major_version * 10000 + $minor_version*100 + $micro_version))
}

config_version () {
    CONFIG="$1-config"
    version_str2num $2;
    REF_VERSION=$?

    which $CONFIG > /dev/null
    if [ $? -gt 0 ]; then
        return 0
    fi

    version_str2num `$CONFIG --version`
    return $(($? >= $REF_VERSION))
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
