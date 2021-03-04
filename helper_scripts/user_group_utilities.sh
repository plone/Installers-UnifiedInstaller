# Copyright (c) 2012-2021 Plone Foundation. Licensed under GPL v 2.
#
# This shell package provides functions for creating
# users and groups in common UNIX work-alikes:

# check_ug_ability
# Do we know how to create users and groups on this platform? If not, fail with
# a useful message.

# check_user TARGET_USER TARGET_GROUP
# Do we have expected user and group available? Fail if not.

# create_group TARGET_GROUP
# Create target group

# create_user TARGET_USER TARGET_GROUP
# Create a user with id TARGET_USER and TARGET_GROUP
# as the primary group.

# Currently supported:
#     useradd (Linux)
#     pw (BSD)

if [ -x /usr/sbin/useradd ]; then
    # Probably some flavor of Linux; cross fingers
    # and hope useradd has common options.

    check_ug_ability () {
        echo $USING_USERADD
    }

    create_group () {
        TARGET_GROUP="$1"
        egrep "^$TARGET_GROUP\:" /etc/group > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            eval "echo \"$GROUP_EXISTS\""
        else
            groupadd "$TARGET_GROUP" > /dev/null 2>&1
            if [ $? -gt 0 ]; then
                eval "echo \"$GROUP_FAILED\""
                exit 1
            fi
        fi
    }

    create_user () {
        TARGET_USER="$1"
        TARGET_GROUP="$2"

        NOLOGIN=`which nologin`
        NOHOME=`which false`
        USER_SETTINGS="-g $TARGET_GROUP --shell $NOLOGIN --home $NOHOME"

        id "$TARGET_USER" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            eval "echo \"$USER_EXISTS\""
            eval "echo \"$ADD_USER_TO_GROUP\""
            usermod $TARGET_USER -G $TARGET_GROUP
        else
            useradd $TARGET_USER $USER_SETTINGS
        fi
    }

elif [ -x /usr/sbin/pw ]; then
    # we're probably in the BSD world; compliments to the sysadmin.

    check_ug_ability () {
        echo $USING_PW
    }

    create_group () {
        TARGET_GROUP="$1"
        egrep "^$TARGET_GROUP\:" /etc/group > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            eval "echo \"$GROUP_EXISTS\""
        else
            pw groupadd "$TARGET_GROUP" > /dev/null 2>&1
            if [ $? -gt 0 ]; then
                eval "echo \"$GROUP_FAILED\""
                exit 1
            fi
        fi
    }

    create_user () {
        TARGET_USER="$1"
        TARGET_GROUP="$2"

        NOLOGIN=`which nologin`
        NOHOME=`which false`
        USER_SETTINGS="-g $TARGET_GROUP -s $NOLOGIN -d $NOHOME"

        id "$TARGET_USER" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            eval "echo \"$USER_EXISTS\""
            eval "echo \"$ADD_USER_TO_GROUP\""
            pw usermod $TARGET_USER -G $TARGET_GROUP
        else
            pw useradd $TARGET_USER $USER_SETTINGS
        fi
    }
else
    check_ug_ability () {
        echo $UNKNOWN_USER_ENV
    }

    # we don't know what we're doing -- so don't do anything.
    create_user () {
        return 0
    }
    create_group () {
        return 0
    }
fi

check_user () {
    TARGET_USER="$1"
    TARGET_GROUP="$2"

    id "$TARGET_USER" | egrep "uid=[0-9]+\(${TARGET_USER}\) .+[0-9]+\(${TARGET_GROUP}\)" > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        echo "id for $TARGET_USER returned"
        id "$TARGET_USER"
        eval "echo \"$UG_CREATE_FAILED\""
        exit 1
    fi
}