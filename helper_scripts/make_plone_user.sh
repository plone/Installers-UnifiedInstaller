################################################
# Add user account via platform-specific methods
# if necessary.
#
# $LastChangedDate: 2010-09-16 12:54:42 -0700 (Thu, 16 Sep 2010) $ $LastChangedRevision: 39955 $

createUser () {

TARGET_USER="$1"

id "$TARGET_USER" > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "User '$TARGET_USER' already exists. No need to create it."
else
    echo "Adding user account '$TARGET_USER' to system ..."
    # Add unprivileged user account via 'useradd', if exists (Linux)
    if [ -x /usr/sbin/useradd ]; then
        /usr/sbin/useradd -s /bin/false "$TARGET_USER"

    # Add unprivileged user account via 'adduser', if exists (*BSD)
    elif [ -x /usr/sbin/adduser ]; then
        /usr/sbin/adduser -f helper_scripts/adduser.txt

    # try dscl for Mac OS X
    elif [ -x /usr/bin/dscl ]; then
        UNAME="$TARGET_USER"
        
        # If the environment is one in which scripted addition of users and groups 
        # can not proceed with 100% confidence, such as when ldap is the datasource,
        # then exit early.
        
        LDAP127=$(dscl -q localonly -list /LDAPv3 | grep "127.0.0.1")
        # If /LDAPv3/127.0.0.1 is listed: assume Mac OS X Server or a custom environment, 
        # steer the user to Workgroup Manager, and exit.
        if [ "$LDAP127" = "127.0.0.1" ]; then
            echo "Mac OS X Directory Service finds /LDAPv3/127.0.0.1 in its search policy. "
            echo "In a custom environment such as this, scripted creation of users and groups "
            echo "for a root installation of Plone may be inappropriate. Installation of Plone is "
            echo "not complete. See README.txt for instructions on how to proceed."
            echo ""
            exit 1
        fi

        # If the required group already exists in /Local/Default
        # then set gid to the PrimaryGroupID of that group.
        dscl . search /Groups RecordName "$UNAME" | grep "($UNAME)" > /dev/null
        if [ "$?" = "0" ]; then
            gid=$(dscl . read "/Groups/$UNAME" PrimaryGroupID | cut -d" " -f2 -)
        else
            gid="50"
            dscl . search /Groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
            while [ "$?" = "0" ]; do
                if [ "$gid" = "500" ]; then
                    echo "Amongst local groups, a gid below 500 is not available. Unable to continue. "
                    exit 1
                else
                    gid=$(($gid + 1))
                    dscl . search /Groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
                fi
            done
            echo "Using dscl (Directory Service command line utility) to create group " 
            echo  $UNAME with gid $gid in directory /Local/Default ...
            dscl . -create "/Groups/$UNAME"
            dscl . -create "/Groups/$UNAME" gid $gid
        fi


        # find or create a $UNAME user
        dscl . search /Users RecordName "$UNAME" | grep "($UNAME)" > /dev/null
        if [ "$?" != "0" ]; then
            # Add $TARGET_USER user via dscl, with a uid below 500
            echo Creating $TARGET_USER user ...
            uiddef=$gid

            dscl . search /Users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
            while [ "$?" = "0" ]; do
                if [ "$uiddef" = "500" ]; then
                    echo "Amongst local users, a uid below 500 is not available. Installation of Plone is "
                    echo "not complete, this script is stopping. "
                    exit 1
                else
                    uiddef=$(($uiddef + 1))
                    dscl . search /Users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
                fi
            done
            #
            echo "Using dscl (Directory Service command line utility) to create user " 
            echo $UNAME with uid $uiddef in directory /Local/Default ...
            dscl . -create "/Users/$UNAME"
            if [ "$?" = "0" ]; then
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
            if [ $oldgid != $gid ]; then
                dscl . -create "/Users/$UNAME" PrimaryGroupID $gid
            fi
        fi

    # Try NetInfo niutil
elif [ -x /usr/bin/niutil ]; then
        niutil -readprop -t localhost/local "/users/$TARGET_USER" uid
        if [ "$?" != "0" ]; then
            # Add $TARGET_USER user to NetInfo, with a uid below 500
            echo Creating $TARGET_USER user
            uiddef="50"
            niutil -readprop -t localhost/local /users/uid=$uiddef name
            while [ "$?" = "0" ]; do
                if [ "$uiddef" = "500" ]
                then
                    echo Failed to find available uid below 500.  Exiting.
                    exit 1
                else
                    uiddef=`echo $uiddef + 1 | bc`
                    niutil -readprop -t localhost/local /users/uid=$uiddef name
                fi
            done
            #
            echo Creating user $TARGET_USER with uid $uiddef...
            niutil -create  -t localhost/local "/users/$TARGET_USER"
            if [ "$?" = "0" ]; then
                niutil -createprop -t localhost/local "/users/$TARGET_USER" realname "Plone Administration"
                niutil -createprop -t localhost/local "/users/$TARGET_USER" uid $uiddef
                niutil -createprop -t localhost/local "/users/$TARGET_USER" gid 20
                niutil -createprop -t localhost/local "/users/$TARGET_USER" home "$PLONE_HOME"
                niutil -createprop -t localhost/local "/users/$TARGET_USER" name "$TARGET_USER"
                niutil -createprop -t localhost/local "/users/$TARGET_USER" passwd '*'
                niutil -createprop -t localhost/local "/users/$TARGET_USER" shell /usr/bin/false
                niutil -createprop -t localhost/local "/users/$TARGET_USER" _writers_passwd "$TARGET_USER"
            else
                echo "Creating user $TARGET_USER failed"
                exit 1
            fi
        fi
    fi
fi

}


