#!/bin/sh

sudo rm ~/*.log
date > ~/results.log

cd ~
if [ -f /vagrant/use_sudo ]; then
    sudo rm -rf /opt/plone*
    tar xf /vagrant/*.tgz
    cd Plone*Unified*
    . /vagrant/install
    if [ $? -gt 0 ]; then
        echo "Install failed." >> ~/results.log
        cp ~/Plone*Unified*/install.log ~/install.log
        exit 0
    fi
    cp ~/Plone*Unified*/install.log ~/install.log
    cd /opt/plone/z*
    sudo -u plone_daemon bin/plonectl start
    if [ $? -gt 0 ]; then
        echo "Start failed." >> ~/results.log
        cp var/log/*.log ~
        exit 0
    fi
    sudo -u plone_daemon bin/plonectl stop
    sleep 30
    sudo cp var/log/*.log ~
else
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
fi

cd ~
echo "Completed" >> ~/results.log
date >> ~/results.log
