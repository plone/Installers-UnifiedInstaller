The scripts in this directory are trivial variations on the excellent
startup scripts provided with the FreeBSD Zope 2.9 port. Only the version
numbers are changed.

They are licensed under the FreeBSD license.

To enable for zeocluster use, copy both scripts to /usr/local/etc/rc.d
(create /usr/local/etc/rc.d if it doesn't exist):

cp zeo2_10 /usr/local/etc/rc.d
chmod 555 /usr/local/etc/rc.d/zeo2_10
cp zope2_10 /usr/local/etc/rc.d
chmod 555 /usr/local/etc/rc.d/zope2_10

Then, add the following to your /etc/rc.conf or rc.conf.local:

zeo2_10_enable="YES"
zeo2_10_instances="/opt/Plone-3.0/zeocluster/server"
zope2_10_enable="YES"
zope2_10_instances="/opt/Plone-3.0/zeocluster/client1 /opt/Plone-3.0/zeocluster/client2"

----------------

To enable for standalone use, copy the zope script to /usr/local/etc/rc.d
(create /usr/local/etc/rc.d if it doesn't exist):

cp zope2_10 /usr/local/etc/rc.d
chmod 555 /usr/local/etc/rc.d/zope2_10

Then, add the following to your /etc/rc.conf or rc.conf.local:

zope2_10_enable="YES"
zope2_10_instances="/opt/Plone-3.0/zinstance"
