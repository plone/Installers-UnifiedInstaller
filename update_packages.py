#!/usr/bin/env python
# encoding: utf-8
"""
update_eggs.py

rebuilds the buildout-cache tarball from a working install.

Strategy:

  * copy the buildout-cache directory from the working install

  * eliminate older versions from both eggs and download/dist

  * delete all the eggs with binary signatures from the eggs
    directory, keeping a list of what we've done

  * delete all the .py[c|o] files from the installed eggs
    directory. those will be recompiled on install.

  * Delete all but the packages which have binary build
    components from download/dist

  * bundle it all up.

Created by Steve McMahon on 2008-11-06.
Copyright (c) 2008-12, Plone Foundation. Licensed under GPL v 2.
"""

import os.path
import re
import pkg_resources
import shutil
import subprocess
import sys


BINARY_SIG_RE = re.compile(r'-py2.[7]-.+(?=.egg)')
PY_SIG = '-.py2.7'

if len(sys.argv) != 2:
    print 'usage: update_packages.py path/to/work/target'
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
                basename = BINARY_SIG_RE.sub('', fn).replace(PY_SIG, '')
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
    print "remove existing work dir"
    shutil.rmtree(workDir)

print "Copying to work directory"
shutil.copytree(os.path.join(target, 'buildout-cache'), workDir)

eggs = os.path.join(workDir, 'eggs')
downloads = os.path.join(workDir, 'downloads')
dist = os.path.join(downloads, 'dist')

print "clean older packages"
packages = PackageList((dist, ))
packages.cleanOlder()
packages = PackageList((eggs, ))
packages.cleanOlder()

binaries = {}

print "Removing installed eggs with binary components:"
for fn in os.listdir(eggs):
    if BINARY_SIG_RE.search(fn) is not None:
        basename = BINARY_SIG_RE.sub('', fn).replace('.egg', '')
        binaries[basename] = 1
        shutil.rmtree(os.path.join(eggs, fn))
        print basename,
print

print "Removing dist packages without binary components. Remaining:"
for fn in os.listdir(dist):
    basename = BINARY_SIG_RE.sub('', fn).replace('.tar.gz', '').replace('.zip', '')
    if basename in binaries:
        del binaries[basename]
        print basename,
    else:
        os.unlink(os.path.join(dist, fn))
print
if binaries:
    print "Ooops: %s" % binaries.keys()


print "zap *.py[c|o] files from installed eggs"
doCommand("find %s -name '*.py[co]' -exec rm {} \\;" % eggs)
print "zap *.mo files from installed eggs"
doCommand("find %s -name '*.mo' -exec rm {} \\;" % eggs)

print "Removing .registration.cache files"
doCommand("find %s -name '.registration.cache' -exec rm {} \\;" % eggs)

# clean mac crapola
doCommand('find %s -name ".DS_Store" -exec rm {} \;' % workDir)

print "permission fixups"
doCommand("find %s -type d -exec chmod 755 {} \;" % workDir)
doCommand("find %s -type f -exec chmod 644 {} \;" % workDir)

if os.path.exists(desttar):
    print "remove existing buildout cache archive"
    os.unlink(desttar)

# GNU tar is required for this task...
# BSD tar does not have the same set of options that we require.
# Does the system have 'tar' set or symlinked to gnutar?
p = subprocess.Popen(['tar', '--version'], stdout=subprocess.PIPE)
stdout = p.communicate()[0]
has_gnutar = False
if stdout.find('GNU') >= 0:
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

#print "generate new archive"
doCommand("%s --owner 0 --group 0 --exclude=.DS_Store -jcf %s -C packages buildout-cache" % (tar_command, desttar))

# cleanup
shutil.rmtree(workDir)
