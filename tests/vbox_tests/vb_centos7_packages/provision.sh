#!/bin/sh -
sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
sudo yum update -y
sudo yum -y install gcc-c++ patch openssl-devel libjpeg-devel readline-devel libxml2-devel libxslt-devel make which \
    python36u python36u-libs python36u-devel python36u-pip