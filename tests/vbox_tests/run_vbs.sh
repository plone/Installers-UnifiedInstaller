#!/bin/sh

CWD=`pwd`
for vb in whe*; do
    echo $vb
    cd $vb
    ln ../*.tgz .
    ln ../test_install.sh .
    rm install.log
    rm instance.log
    rm results.log
    echo $vb > results.log
    vagrant up
    vagrant ssh -c /vagrant/test_install.sh
    vagrant halt
    rm *.tgz
    rm test_install.sh
    cd $CWD
done
cat vb_*/results.log > results.log
