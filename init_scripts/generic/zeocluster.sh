#!/bin/sh

case "$1" in
start)
        echo -n " Starting ZEO Cluster"
        /opt/plone/zeocluster/bin/plonectl start
        ;;
stop)
        echo -n " Stopping ZEO Cluster"
        /opt/plone/zeocluster/bin/plonectl stop
        ;;
restart)
        echo -n " Restarting ZEO Cluster"
        /opt/plone/zeocluster/bin/plonectl restart
        ;;
*)
        echo "Usage: `basename $0` {start|stop|restart}" >&2
        ;;
esac

exit 0
