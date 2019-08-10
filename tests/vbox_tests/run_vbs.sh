#!/bin/sh

TARGETS="$1"
if [ "X${TARGETS}X" = "XX" ]; then
    TARGETS=vb_*
fi

CWD=`pwd`
for vb in $TARGETS; do
    cd $vb
    echo > results.log
    echo >> results.log
    echo "*************** Testing box: $vb ***************" >> results.log
    echo >> results.log
    ln ../*.tgz .
    cp ../test_install.sh .
    vagrant up
    if [ -x provision.sh ]; then
    	echo "Provisioning"
    	vagrant ssh -c "sudo /vagrant/provision.sh"
    fi
    vagrant ssh -c /vagrant/test_install.sh
    vagrant ssh -c "cat ~/results.log" >> results.log
    vagrant ssh -c "cat ~/install.log" > install.log
    vagrant ssh -c "cat ~/instance.log" > instance.log
    vagrant halt
    cd $CWD
done
cat vb_*/results.log > results.log
