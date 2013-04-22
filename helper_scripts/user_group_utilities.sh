# Copyright (c) 2012 Plone Foundation. Licensed under GPL v 2.
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
#     dscl (OS X)

if [ -x /usr/sbin/useradd ]; then
    # Probably some flavor of Linux; cross fingers
    # and hope useradd has common options.

    check_ug_ability () {
        echo "Using useradd and groupadd to create users and groups."
    }

    create_group () {
        TARGET_GROUP="$1"
        egrep "^$TARGET_GROUP\:" /etc/group > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "'$TARGET_GROUP' already exists; no need to create it."
        else
            groupadd "$TARGET_GROUP" > /dev/null 2>&1
            if [ $? -gt 0 ]; then
                echo "Creation of '$TARGET_GROUP' failed. Unable to continue."
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
            echo "User '$TARGET_USER' already exists. No need to create it."
            echo "Adding user $TARGET_USER to group $TARGET_GROUP."
            usermod $TARGET_USER -G $TARGET_GROUP
        else
            useradd $TARGET_USER $USER_SETTINGS
        fi
    }

elif [ -x /usr/sbin/pw ]; then
    # we're probably in the BSD world; compliments to the sysadmin.

    check_ug_ability () {
        echo "Using pw to create users and groups"
    }

    create_group () {
        TARGET_GROUP="$1"
        egrep "^$TARGET_GROUP\:" /etc/group > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$TARGET_GROUP already exists; no need to create it."
        else
            pw groupadd "$TARGET_GROUP" > /dev/null 2>&1
            if [ $? -gt 0 ]; then
                echo "Creation of $TARGET_GROUP failed. Unable to continue."
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
            echo "User '$TARGET_USER' already exists. No need to create it."
            echo "Adding $TARGET_USERto $TARGET_GROUP."
            pw usermod $TARGET_USER -G $TARGET_GROUP
        else
            pw useradd $TARGET_USER $USER_SETTINGS
        fi
    }

elif [ -x /usr/bin/dscl ]; then
    # probably OS X

    check_ug_ability () {
        LDAP127=$(dscl -q localonly -list /LDAPv3 | grep "127.0.0.1")
        # If /LDAPv3/127.0.0.1 is listed: assume Mac OS X Server or a custom environment,
        # steer the user to Workgroup Manager, and exit.
        if [ "$LDAP127" = "127.0.0.1" ]; then
            echo "Mac OS X Directory Service finds /LDAPv3/127.0.0.1 in its search policy. "
            echo "In a custom environment such as this, scripted creation of users and groups "
            echo "for a root installation of Plone may be inappropriate. Installation of Plone is "
            echo "not complete. See README.txt for instructions on how to proceed."
            echo ""
            return 1
        fi
        echo "Using dscl to create users and groups"
    }

    create_group () {
        TARGET_GROUP="$1"

        dscl . search /Groups RecordName "$TARGET_GROUP" | grep "($TARGET_GROUP)" > /dev/null
        if [ $? -gt 0 ]; then
            gid="50"
            dscl . search /Groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
            while [ $? -eq 0 ]; do
                if [ "$gid" = "500" ]; then
                    echo "Amongst local groups, a gid below 500 is not available. Unable to continue. "
                    exit 1
                else
                    gid=$(($gid + 1))
                    dscl . search /Groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
                fi
            done
            echo "Using dscl (Directory Service command line utility) to create group "
            echo  $TARGET_GROUP with gid $gid in directory /Local/Default ...
            dscl . -create "/Groups/$TARGET_GROUP"
            dscl . -create "/Groups/$TARGET_GROUP" gid $gid
        fi
    }

    create_user () {
        UNAME="$1"
        GNAME="$2"

        # first, determine gid for our group
        gid=$(dscl . read "/Groups/$GNAME" PrimaryGroupID | cut -d" " -f2 -)

        # find or create a $UNAME user
        dscl . search /Users RecordName "$UNAME" | grep "($UNAME)" > /dev/null
        if [ $? -gt 0 ]; then
            # Add $TARGET_USER user via dscl, with a uid below 500
            echo Creating $TARGET_USER user ...

            # first, find an available uid. Oh my, this would be easier
            # in Python.
            uiddef=50
            dscl . search /Users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
            while [ $? -eq 0 ]; do
                if [ "$uiddef" = "500" ]; then
                    echo "Amongst local users, a uid below 500 is not available. Installation of Plone is "
                    echo "not complete, this script is stopping. "
                    exit 1
                else
                    uiddef=$(($uiddef + 1))
                    dscl . search /Users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
                fi
            done

            echo "Using dscl (Directory Service command line utility) to create user "
            echo $UNAME with uid $uiddef in directory /Local/Default ...
            dscl . -create "/Users/$UNAME"
            if [ $? -eq 0 ]; then
                dscl . -create "/Users/$UNAME" UniqueID $uiddef
                dscl . -create "/Users/$UNAME" RealName "Plone administration"
                dscl . -create "/Users/$UNAME" PrimaryGroupID $gid
                dscl . -create "/Users/$UNAME" Password '*'
                dscl . -create "/Users/$UNAME" UserShell /usr/bin/false
                dscl . -create "/Users/$UNAME" NFSHomeDirectory /var/empty
            else
                echo "Creating user $TARGET_USER failed"
                exit 1
            fi
        else
            oldgid=$(dscl . read "/Users/$UNAME" PrimaryGroupID | cut -f2 -d" " -)
            if [ "$oldgid" != "$gid" ]; then
                dscl . -create "/Users/$UNAME" PrimaryGroupID $gid
            fi
        fi
    }

else
    # we don't know what we're doing -- so don't do it.
    check_ug_ability () {
            echo "We don't know how to add users and groups in this environment. "
            echo "Please add users and group manually, then try again."
            echo "See README.txt for instructions on how to proceed."
            echo ""
        exit 1
    }
fi

check_user () {
    TARGET_USER="$1"
    TARGET_GROUP="$2"

    id "$TARGET_USER" | egrep "uid=[0-9]+\(${TARGET_USER}\) .+[0-9]+\(${TARGET_GROUP}\)" > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        echo "id for $TARGET_USER returned"
        id "$TARGET_USER"
        echo "Expected to find uid for $TARGET_USER and gid for $TARGET_GROUP but did not."
        echo "Please use your system tools to create/edit users and groups, then try again."
        exit 1
    fi
}