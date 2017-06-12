#!/bin/sh

VERSION=5.0.8
scp -oHostKeyAlgorithms=+ssh-dss packages/buildout-cache.tar.bz2 stevem@74.203.223.202:/srv/dist.plone.org/http/root/release/${VERSION}/
