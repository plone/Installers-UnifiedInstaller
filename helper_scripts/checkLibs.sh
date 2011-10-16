###############################################
# library need determination for jpeg and zlib
#
# $LastChangedDate: 2010-01-25 15:48:09 -0800 (Mon, 25 Jan 2010) $ $LastChangedRevision: 33440 $

if [ $INSTALL_ZLIB = "auto" ]; then
	# check for zconf.h, zlib.h, libz.[so|a]
	if [ -e /usr/include/zconf.h ] || [ -e /usr/local/include/zconf.h ]
	then
		HAVE_ZCONF=1
		#echo have zconf
	else
		HAVE_ZCONF=0
		#echo no zconf
	fi
        if [ -e /usr/include/zlib.h ] || [ -e /usr/local/include/zlib.h ]; then
                HAVE_ZLIB=1
                #echo have zlib
        else
                HAVE_ZLIB=0
                #echo no zlib
        fi
        if [ -e /usr/lib/libz.so ] || [ -e /usr/local/lib/libz.so ] || \
           [ -e /usr/lib64/libz.so ] || [ -e /usr/local/lib64/libz.so ] || \
	   [ -e /usr/lib/libz.dylib ] || [ -e /usr/local/lib/libz.dylib ] || \
	   [ -e /usr/lib/libz.a ] || [ -e /usr/local/lib/libz.a ]; then
                HAVE_LIBZ=1
                #echo have libz
        else
                HAVE_LIBZ=0
                #echo no libz
        fi
	if [ $HAVE_ZCONF -eq 1 ] && [ $HAVE_ZLIB -eq 1 ] && [ $HAVE_LIBZ -eq 1 ]
	then
		INSTALL_ZLIB=no
		#echo do not install zlib
	fi
    # if [ $INSTALL_ZLIB = "auto" ] && [ $ROOT_INSTALL -eq 1 ]
    # then
    #   INSTALL_ZLIB="global"
    # fi
	if [ $INSTALL_ZLIB = "auto" ]
	then
		INSTALL_ZLIB="local"
	fi
	echo "zlib installation: $INSTALL_ZLIB"
fi

if [ $INSTALL_JPEG = "auto" ]; then
	# check for jpeglib.h and libjpeg.[so|a]
	if [ -e /usr/include/jpeglib.h ] || [ -e /usr/local/include/jpeglib.h ]
	then
		HAVE_JPEGH=1
	else
		HAVE_JPEGH=0
	fi
	if [ -e /usr/lib/libjpeg.so ] || [ -e /usr/local/lib/libjpeg.so ] || \
	   [ -e /usr/lib64/libjpeg.so ] || [ -e /usr/local/lib64/libjpeg.so ] || \
	   [ -e /usr/lib/libjpeg.dylib ] || [ -e /usr/local/lib/libjpeg.dylib ] || \
	   [ -e /usr/lib/libjpeg.a ] || [ -e /usr/local/lib/libjpeg.a ]
	then
		HAVE_LIBJPEG=1
	else
		HAVE_LIBJPEG=0
	fi
	if [ $HAVE_JPEGH -eq 1 ] && [ $HAVE_LIBJPEG -eq 1 ]
	then
		INSTALL_JPEG="no"
	fi
	if [ $INSTALL_JPEG = "auto" ]
	then
		INSTALL_JPEG="local"
	fi
	echo "libjpeg installation: $INSTALL_JPEG"
fi
