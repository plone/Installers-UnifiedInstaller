#!/bin/bash

rm vb*/*.tgz
rm vb*/*.log
rm vb*/test_install.sh
rm -rf vb*/.vagrant
find . -name "._*" -delete
for vb in vb_*; do
    cd $vb
    vagrant destroy -f
    cd ..
done
