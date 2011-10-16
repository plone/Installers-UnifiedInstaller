#!/usr/bin/env python
# encoding: utf-8
"""
config_check.py

Easy access to version from xml2-config style programs

Created by Steve McMahon on 2011-10-01.
Copyright (c) 2011 Plone Foundation. Licensed under GPL v 2.
"""

import subprocess


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = po.communicate()
    if po.returncode == 0:
        return stdout.strip()
    else:
        return ''


def runConfig(name, option='--version'):
    return doCommand("%s-config %s" % (name, option))


def getVersion(name):
    parts = runConfig(name).split('.')
    if len(parts) < 3:
        major, minor, trivial = 0, 0, 0
    else:
        major, minor, trivial = parts
    return int(major) * 10000 + int(minor) * 100 + int(trivial)

if __name__ == '__main__':
    print '"%s"' % doCommand('xslt-config --version')
    print '"%s"' % runConfig('xslt')
    print getVersion('xslt')
    print getVersion('xml2')
    print getVersion('xml3')
