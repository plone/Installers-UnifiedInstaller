#!/bin/sh

TARGETS="$1"
if [ "X${TARGETS}X" == "XX" ]; then
    TARGETS=vb_*
fi

CWD=`pwd`
for vb in $TARGETS; do
    echo "Testing $vb"
    cd $vb
    ln ../*.tgz .
    ln ../test_install.sh .
    rm install.log
    rm instance.log
    rm results.log
    echo $vb > results.log
    vagrant up
    if [ -x provision.sh ] && [ ! -e provisioned ]; then
	echo "Provisioning"
	vagrant ssh -c "sudo /vagrant/provision.sh" > provisioned
    fi
    vagrant ssh -c /vagrant/test_install.sh
    vagrant halt
    rm *.tgz
    rm test_install.sh
    cd $CWD
done
cat vb_*/results.log > results.log
