#!/bin/sh

case "$1" in
start)
        echo -n " Starting Zope"
        /opt/plone/zinstance/bin/plonectl start
        ;;
stop)
        echo -n " Stopping Zope"
        /opt/plone/zinstance/bin/plonectl stop
        ;;
restart)
        echo -n " Restarting Zope"
        /opt/plone/zinstance/bin/plonectl restart
        ;;
status)
        echo -n " Zope Status"
        /opt/plone/zinstance/bin/plonectl status
        ;;
*)
        echo "Usage: `basename $0` {start|stop|restart|status}" >&2
        ;;
esac

exit 0
