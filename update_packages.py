#!/usr/bin/env python
# encoding: utf-8
"""
update_eggs.py

Created by Steve McMahon on 2008-11-06.
Copyright (c) 2008, Plone Foundation. All rights reserved.
"""

# source directory for packages
target = '/Volumes/kingston/work/p33'


import sys, os, os.path, re, pkg_resources, shutil, subprocess


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True)
    po.communicate()
    # if po.returncode:
    #     print "Error in command: %s" % command
    #     sys.exit(1)
    

class PackageList:
    
    def __init__(self, pathnames):
        self.packages = {}

        pkgpat = re.compile(r'(.+)-(.+?)(?:-py2\.4)?\.(?:egg|tar|tar.gz|tgz)$')
        for pathname in pathnames:
            for fn in os.listdir(pathname):
                mo = pkgpat.match(fn.replace('-py2.4', ''))
                if mo:
                    name, version = mo.groups()[0:2]
                    self.packages.setdefault(name, []).append((
                        pkg_resources.parse_version(version),
                        os.path.join(pathname,fn)
                        ))

    def olderVersions(self):
        for eggk in self.packages.keys():
            eggv = self.packages[eggk]
            if len(eggv) > 1:
                eggv.sort()
                for i in range(0, len(eggv)-1):
                    yield eggv[i][1]

    def cleanOlder(self):
        for fn in self.olderVersions():
            if os.path.isdir(fn):
                shutil.rmtree(fn)
            else:
                os.unlink(fn)


workDir = "./packages/buildout-cache"
desttar = "./packages/buildout-cache.tar.bz2"


boc = os.path.join(target, 'buildout-cache')
eggs = os.path.join(boc, 'eggs')
downloads = os.path.join(boc, 'downloads')
dist = os.path.join(downloads, 'dist')

print "clean older packages"
packages = PackageList( (eggs,downloads) )
packages.cleanOlder()
if os.path.exists(dist):
    print "remove dist dir" 
    shutil.rmtree(dist)

if os.path.exists(workDir):
    print "remove existing work dir"
    shutil.rmtree(workDir)

print "Copying to work directory"
shutil.copytree(boc, workDir)

print "zap *.pyc and binary eggs"
doCommand( "find %s -name '*.py[co]' -exec rm {} \\;" % workDir )
doCommand("find %s -name '.DS_Store' -exec rm {} \\;" % workDir )
doCommand("find %s -name '._*' -exec rm {} \\;" % workDir )
doCommand('find %s -name "*-py2.4-*.egg" -exec rm -rf {} \\;' % workDir )

print "permission fixups"
doCommand(  "find %s -type d -exec chmod 755 {} \;" % workDir)
doCommand(  "find %s -type f -exec chmod 644 {} \;" % workDir)

if os.path.exists(desttar):
    print "remove existing buildout cache archive"
    os.unlink(desttar)

print "generate new archive"
doCommand(  "gnutar --owner 0 --group 0 -jcf %s -C packages buildout-cache" % (desttar))

# cleanup
shutil.rmtree(workDir)
