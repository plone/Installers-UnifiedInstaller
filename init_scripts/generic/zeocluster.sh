#!/bin/sh

case "$1" in
start)
        echo -n " Starting ZEO Cluster"
        /usr/local/plone/zeocluster/bin/plonectl start
        ;;
stop)
        echo -n " Stopping ZEO Cluster"
        /usr/local/Plone/zeocluster/bin/plonectl stop
        ;;
restart)
        echo -n " Restarting ZEO Cluster"
        /usr/local/Plone/zeocluster/bin/plonectl restart
        ;;
*)
        echo "Usage: `basename $0` {start|stop|restart}" >&2
        ;;
esac

exit 0
