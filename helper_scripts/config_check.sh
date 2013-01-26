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

# if config_version xml2 2.7.7; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.7"
# else
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# fi
# if config_version xml2 2.7.8; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# else
#     echo "No, xml2-config doesn't exist, or version is < 2.7.11"
# fi
# if config_version xml2 2.7.11; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.11"
# else
#     echo "No, xml2-config doesn't exist, or version is < 2.7.11"
# fi
# if config_version xml20 2.7.8; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# else
#     echo "No, xml20-config doesn't exist, or version is < 2.7.8"
# fi

# NEED_XML2="2.7.8"
# if ! config_version xml2 $NEED_XML2; then
#     echo "We need development version $NEED_XML2 of libxml. Not found."
# fi
