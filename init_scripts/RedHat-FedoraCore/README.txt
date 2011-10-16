Red Hat / Fedora Core style startup/shutdown scripts are located in 
/etc/rc.d/init.d and are started via symbolic links in the /etc/rc[0-9].d
run-level resource directories. You may use /sbin/chkconfig to create and
remove these links.

To install a startup script, use the commands:

sudo cp plone-cluster /etc/rc.d/init.d/plone
sudo chmod 755 /etc/rc.d/init.d/plone
sudo /sbin/chkconfig --add plone

Substitute "plone-standalone" for "plone-cluster" if you're using a
standalone instance.

To remove, use the command:

sudo /sbin/chkconfig --del plone

Thanks to Barry Page, Larry Pitcher, and Christian W. for their work
on this script.