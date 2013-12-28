#!/bin/sh

rm -rf Plone*
date >> /vagrant/results.log
tar xf /vagrant/*.tgz
cd Plone*Unified*
. /vagrant/install > install
if [ $? -gt 0 ]; then
    echo "Install failed." >> /vagrant/results.log
    cp install.log /vagrant
    exit 0
fi
cd ../Plone/zinstance
bin/instance start
if [ $? -gt 0 ]; then
    echo "Start failed." >> /vagrant/results.log
    cp var/log/instance.log /vagrant
    exit 0
fi
sleep 10
bin/instance stop
cd ~
echo "Completed" >> /vagrant/results.log
date >> /vagrant/results.log
