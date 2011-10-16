################################################
# Add user account via platform-specific methods
# if necessary.
#
# $LastChangedDate: 2008-09-01 16:03:50 -0700 (Mon, 01 Sep 2008) $ $LastChangedRevision: 22465 $

createUser () {

TARGET_USER=$1

id $TARGET_USER
if [ "$?" = "0" ]; then
	echo "User '$TARGET_USER' already exists. No need to create it."
else
	echo "Adding user account '$TARGET_USER' to system ..."
	# Add unprivileged user account via 'useradd', if exists (Linux)
	if [ -e /usr/sbin/useradd ]; then
		/usr/sbin/useradd -s /bin/false $TARGET_USER

	# Add unprivileged user account via 'adduser', if exists (*BSD)
	elif [ -e /usr/sbin/adduser ]; then
		/usr/sbin/adduser -f helper_scripts/adduser.txt

	# try dscl for Mac OS X
	elif [ -e /usr/bin/dscl ]; then
		UNAME=$TARGET_USER
	        # find or create a $UNAME group
	        dscl . search /groups RecordName $UNAME | grep "($UNAME)" > /dev/null
	        if [ "$?" = "0" ]; then
	                gid=$(dscl . read /groups/$UNAME PrimaryGroupID | cut -d" " -f2 -)
	        else
	                gid="50"
	                dscl . search /groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
	                while [ "$?" = "0" ]; do
	                        if [ "$gid" = "500" ]; then
	                                echo Failed to find available gid below 500.  Exiting.
	                                exit 1
	                        else
	                                gid=$(($gid + 1))
	                                dscl . search /groups PrimaryGroupID $gid | grep -E "^[( ]+${gid}\)?$" > /dev/null
	                        fi
	                done
	                echo Creating group $UNAME with gid $gid via dscl...
	                dscl . -create /groups/$UNAME
	                dscl . -create /groups/$UNAME gid $gid
	        fi

	        # find or create a $UNAME user
	        dscl . search /users RecordName $UNAME | grep "($UNAME)" > /dev/null
	        if [ "$?" != "0" ]; then
	                # Add $TARGET_USER user via dscl, with a uid below 500
	                echo Creating $TARGET_USER user
	                uiddef=$gid
	                dscl . search /users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
	                while [ "$?" = "0" ]; do
	                        if [ "$uiddef" = "500" ]; then
	                                echo Failed to find available uid below 500.  Exiting.
	                                exit 1
	                        else
	                                uiddef=$(($uiddef + 1))
	                                dscl . search /users UniqueID $uiddef | grep -E "^[( ]+${uiddef}\)?$" > /dev/null
	                        fi
	                done
	                #
	                echo Creating user $UNAME with uid $uiddef via dscl...
	                dscl . -create /users/$UNAME
	                if [ "$?" = "0" ]; then
	                        dscl . -create /users/$UNAME UniqueID $uiddef
	                        dscl . -create /users/$UNAME RealName "Plone Administration"
	                        dscl . -create /users/$UNAME PrimaryGroupID $gid
	                        dscl . -create /users/$UNAME NFSHomeDirectory $PLONE_HOME
	                        dscl . -create /users/$UNAME Password '*'
	                        dscl . -create /users/$UNAME UserShell /usr/bin/false
	                else
	                        echo "Creating user $TARGET_USER failed"
	                        exit 1
	                fi
	        else
	                oldgid=$(dscl . read /users/$UNAME PrimaryGroupID | cut -f2 -d" " -)
	                if [ $oldgid != $gid ]; then
	                        dscl . -create /users/$UNAME PrimaryGroupID $gid
	                fi
	        fi

	# Try NetInfo niutil
elif [ -e /usr/bin/niutil ]; then
		niutil -readprop -t localhost/local /users/$TARGET_USER uid
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
			niutil -create  -t localhost/local /users/$TARGET_USER
			if [ "$?" = "0" ]; then
				niutil -createprop -t localhost/local /users/$TARGET_USER realname "Plone Administration"
				niutil -createprop -t localhost/local /users/$TARGET_USER uid $uiddef
				niutil -createprop -t localhost/local /users/$TARGET_USER gid 20
				niutil -createprop -t localhost/local /users/$TARGET_USER home "$PLONE_HOME"
				niutil -createprop -t localhost/local /users/$TARGET_USER name $TARGET_USER
				niutil -createprop -t localhost/local /users/$TARGET_USER passwd '*'
				niutil -createprop -t localhost/local /users/$TARGET_USER shell /usr/bin/false
				niutil -createprop -t localhost/local /users/$TARGET_USER _writers_passwd $TARGET_USER
			else
				echo "Creating user $TARGET_USER failed"
				exit 1
			fi
		fi
	fi
fi

}


