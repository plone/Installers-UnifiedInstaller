#!/bin/sh

date > ~/results.log

cd ~
rm -rf Plone*
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
bin/instance stop
sleep 30
cp var/log/instance.log ~
cd ~
echo "Completed" >> ~/results.log

date >> ~/results.log
