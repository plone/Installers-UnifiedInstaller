#!/bin/sh

cd ~
rm -rf Plone*
date > ~/results.log
tar xf /vagrant/*.tgz
cd Plone*Unified*
. /vagrant/install >> ~/results.log
if [ $? -gt 0 ]; then
    echo "Install failed." >> ~/results.log
    cp ~/Plone*Unified*/install.log ~/install.log
    exit 0
fi
cp ~/Plone*Unified*/install.log ~/install.log
cd ~/Plone/zinstance
bin/instance start
if [ $? -gt 0 ]; then
    echo "Start failed." >> ~/results.log
    cp var/log/instance.log ~
    exit 0
fi
cp var/log/instance.log ~
sleep 10
bin/instance stop
cd ~
echo "Completed" >> ~/results.log
date >> ~/results.log
