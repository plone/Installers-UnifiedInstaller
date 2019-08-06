#!/bin/bash

for vb in vb_*; do
    cd $vb
    vagrant box update
    cd ..
done
