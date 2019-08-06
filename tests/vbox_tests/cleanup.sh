#!/bin/bash

find vb* -name *.tgz -delete
find vb* -name "*.log" -delete
find vb* -name test_install.sh -delete
find . -name "._*" -delete
for vb in vb_*; do
    cd $vb
    vagrant destroy -f
    cd ..
done
