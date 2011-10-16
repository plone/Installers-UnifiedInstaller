Ubuntu startup/shutdown scripts are located in /etc/init.d and are
started via symbolic links in the /etc/rc[0-9].d run-level resource
directories. Ubuntu supplies a utility, update-rc.d, to create and
remove the symbolic links.

To install a startup script for Ubuntu 7, use the commands:

sudo cp plone-cluster /etc/init.d/plone
sudo chmod 755 /etc/init.d/plone
sudo update-rc.d plone defaults

Substitute "plone-standalone" for "plone-cluster" if you're using a
standalone instance.

To remove, use the command:

sudo update-rc.d -f plone remove

Thanks to Barry Page, Larry Pitcher, and Christian W. for their work
on this script.