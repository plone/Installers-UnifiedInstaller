#!/usr/bin/env python
# encoding: utf-8
"""
update_eggs.py

rebuilds the buildout-cache tarball from a working install.

Strategy:

  * copy the buildout-cache directory from the working install

  * remove eggs

  * eliminate older versions from download/dist

  * delete all the binary and one-python wheels from the dist
    directory, replace them with tarballs

  * bundle it all up.

Created by Steve McMahon on 2008-11-06.
Copyright (c) 2008-19, Plone Foundation. Licensed under GPL v 2.
"""

from __future__ import print_function

import os.path
import re
import pkg_resources
import shutil
import subprocess
import sys


BINARY_SIG_RE = re.compile(r'-py[23]\.\d-.+(?=.egg)')
PY_SIG = re.compile(r'-\.py[23]\.\d')

if len(sys.argv) != 2:
    print('usage: update_packages.py path/to/work/target')
    exit(1)

# source directory for packages
target = sys.argv[1]


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True)
    po.communicate()


class PackageList:

    pkgpat = re.compile(r'(.+)-(\d.+?)\.(?:zip|egg|tar|tar.gz|tgz)$')

    def __init__(self, pathnames):
        self.packages = {}

        for pathname in pathnames:
            for fn in os.listdir(pathname):
                basename = BINARY_SIG_RE.sub('', fn)
                basename = PY_SIG.sub('', basename)
                mo = self.pkgpat.match(basename)
                if mo:
                    name, version = mo.groups()[0:2]
                    self.packages.setdefault(name, []).append((
                        pkg_resources.parse_version(version),
                        os.path.join(pathname, fn)))

    def olderVersions(self):
        for eggk in self.packages.keys():
            eggv = self.packages[eggk]
            if len(eggv) > 1:
                eggv.sort()
                for i in range(0, len(eggv) - 1):
                    yield eggv[i][1]

    def cleanOlder(self):
        for fn in self.olderVersions():
            if os.path.isdir(fn):
                shutil.rmtree(fn)
            else:
                os.unlink(fn)


workDir = "./packages/buildout-cache"
desttar = "./packages/buildout-cache.tar.bz2"

if os.path.exists(workDir):
    print("remove existing work dir")
    shutil.rmtree(workDir)

print("Copying to work directory")
shutil.copytree(os.path.join(target, 'buildout-cache'), workDir)

# removing eggs
eggs = os.path.join(workDir, 'eggs')
shutil.rmtree(eggs)
os.mkdir(eggs)

downloads = os.path.join(workDir, 'downloads')
dist = os.path.join(downloads, 'dist')

print("clean older packages")
packages = PackageList((dist, ))
packages.cleanOlder()
# packages = PackageList((eggs, ))
# packages.cleanOlder()

# deal with binary wheels
cwd = os.getcwd()
for fn in os.listdir(dist):
    if fn.endswith('whl') and not fn.endswith('-py2.py3-none-any.whl'):
        # presumably a binary wheel
        spec = '=='.join(re.search(r'^(.+?)-(.+?)-', fn).groups())
        print("Replacing binary wheel for {}".format(spec))
        os.unlink(os.path.join(dist, fn))
        os.chdir(dist)
        doCommand("pip download --no-binary :all: --no-deps {}".format(spec))
        os.chdir(cwd)

# clean mac crapola
doCommand('find %s -name ".DS_Store" -exec rm {} \;' % workDir)

print("permission fixups")
doCommand("find %s -type d -exec chmod 755 {} \;" % workDir)
doCommand("find %s -type f -exec chmod 644 {} \;" % workDir)

if os.path.exists(desttar):
    print("remove existing buildout cache archive")
    os.unlink(desttar)

# GNU tar is required for this task...
# BSD tar does not have the same set of options that we require.
# Does the system have 'tar' set or symlinked to gnutar?
p = subprocess.Popen(['tar', '--version'], stdout=subprocess.PIPE)
stdout = p.communicate()[0]
has_gnutar = False
if stdout.find(b'GNU') >= 0:
    has_gnutar = True
    tar_command = 'tar'
else:
    # Check for the existance of the 'gnutar' command.
    rcode = subprocess.call(['which', 'gnutar'])
    if rcode == 0:
        has_gnutar = True
        tar_command = 'gnutar'
if not has_gnutar:
    raise RuntimeError("GNU tar is required to complete this packaging.")

# print("generate new archive")
doCommand("%s --owner 0 --group 0 --exclude=.DS_Store -jcf %s -C packages buildout-cache" % (tar_command, desttar))

# cleanup
shutil.rmtree(workDir)
