############################################################################
# Unified Plone installer instance build script
# by Steve McMahon (steve at dcn.org)
#
# This script is meant to be invoked by another process
# that will choose the exec Python.
#

import argparse
import glob
import random
import os
import os.path
import subprocess
import shutil
import stat
import sys

import iniparse

BASE_ADDRESS = 8080
ADD_CLIENTS_MARKER = "# __ZEO_CLIENTS_HERE__\n"
CLIENT_TEMPLATE = """
[client%(client_num)d]
<= client_base
recipe = plone.recipe.zope2instance
zeo-address = ${zeoserver:zeo-address}
http-address = %(client_port)d
"""


def createPassword():
    pw_choices = ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                  "abcdefghijklmnopqrstuvwxyz"
                  "0123456789")
    pw = ''
    for i in range(12):
        pw = pw + random.choice(pw_choices)
    return pw


# find the full egg name for a module in the buildout-cache
def findEgg(basename, plone_home):
    return glob.glob(
        "%s*.egg" % os.path.join(
            plone_home,
            'buildout-cache',
            'eggs',
            basename)
        )[0]


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = po.communicate()
    sys.stderr.write(stdout)
    return po.returncode


# apply substitutions to a file
def inPlaceSub(fn, substitutions):
    fd = file(fn)
    contents = fd.read()
    fd.close()
    fd = file(fn, 'w')
    fd.write(contents % substitutions)
    fd.close()


##########################################################
# Get command line arguments
#
argparser = argparse.ArgumentParser(description="Plone instance creation utility")
argparser.add_argument('--uidir', required=True)
argparser.add_argument('--plone_home', required=True)
argparser.add_argument('--instance_home', default='zinstance')
argparser.add_argument('--instance_var', default=None)
argparser.add_argument('--backup_dir', default=None)
argparser.add_argument('--daemon_user', default='plone_daemon')
argparser.add_argument('--buildout_user', default='plone_buildout')
argparser.add_argument('--template', default='buildout')
argparser.add_argument('--password', required=False)
argparser.add_argument('--root_install', required=False, default='0', choices='01')
argparser.add_argument('--run_buildout', required=False, default='1', choices='01')
argparser.add_argument('--install_lxml', required=False, default='auto', choices=('yes', 'no', 'auto'))
argparser.add_argument('--itype', default='standalone', choices=('cluster', 'standalone'))
argparser.add_argument('--clients', required=False, default='2')
opt = argparser.parse_args()
if not opt.password:
    opt.password = createPassword()
opt.root_install = bool(int(opt.root_install))
opt.run_buildout = bool(int(opt.run_buildout))

substitutions = {
    "PLONE_HOME": opt.plone_home,
    "INSTANCE_HOME": opt.instance_home,
    "DAEMON_USER": opt.daemon_user,
    "BUILDOUT_USER": opt.buildout_user,
    "PASSWORD": opt.password,
    "PYTHON": sys.executable,
    "DISTRIBUTE_EGG": findEgg('distribute', opt.plone_home),
    "BUILDOUT_EGG": findEgg('zc.buildout', opt.plone_home),
}

##########################################################
# Copy the buildout skeleton into place, clean up a bit
#
print "Copying buildout skeleton"
shutil.copytree(os.path.join(opt.uidir, 'base_skeleton'), opt.instance_home)

# remove OS X and svn detritus (this is mainly helpful for installer development)
doCommand('find %s -name "._*" -exec rm {} \; > /dev/null' % opt.instance_home)
doCommand('find %s -name ".svn" | xargs rm -rf' % opt.instance_home)


##########################################################
# buildout.cfg customizations
#
CLIENTS = int(opt.clients)
template = opt.template
if not '.cfg' in template:
    template += ".cfg"

buildout = iniparse.RawConfigParser()
buildout.read(os.path.join(opt.uidir, 'buildout_templates', template))

# set the parts list
parts = buildout.get('buildout', 'parts').split('\n')
if opt.itype == 'standalone':
    parts.remove('client1')
    parts.remove('zeoserver')
else:
    parts.remove('instance')
    parts.remove('repozo')
    client_index = parts.index('client1')
    for client in range(1, CLIENTS):
        parts.insert(client_index + client, 'client%d' % (client + 1))
if not opt.root_install:
    parts.remove('setpermissions')
    parts.remove('precompiler')
buildout.set('buildout', 'parts', '\n'.join(parts))

# set password
buildout.set('buildout', 'user', "admin:%s" % opt.password)

# set effective users
buildout.set('buildout', 'effective-user', opt.daemon_user)
buildout.set('buildout', 'buildout-user', opt.buildout_user)
if not opt.root_install:
    buildout.set('buildout', 'need-sudo', "no")

if opt.instance_var:
    buildout.set('buildout', 'var-dir', opt.instance_var)
if opt.backup_dir:
    buildout.set('buildout', 'backups-dir', opt.backup_dir)

# remove unneeded sections
if opt.itype == 'standalone':
    buildout.remove_section('zeoserver')
else:
    buildout.remove_section('instance')

# Insert variable number of zeo client specs. This doesn't fit the iniparse
# model because the clients need to be inserted at particular
# points without fouling comments or section order.
iniparse.tidy(buildout)
buildout = str(buildout.data)
if opt.itype == 'standalone':
    # remove extra clients marker
    buildout = buildout.replace(ADD_CLIENTS_MARKER, '')
else:
    client_parts = ''
    client_addresses = ''
    for client in range(1, CLIENTS + 1):
        options = {
            'client_num': client,
            'client_port': BASE_ADDRESS + client - 1,
        }
        client_parts = "%s%s" % (client_parts, CLIENT_TEMPLATE % options)
    buildout = buildout.replace(ADD_CLIENTS_MARKER, client_parts)

# write out buildout.cfg
fn = os.path.join(opt.instance_home, 'buildout.cfg')
fd = file(fn, 'w')
fd.write(buildout)
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


# boostrapping is problematic when the python may not have the right
# components; so, let's fix up the bin/buildout ourselves.
print "Fixing up bin/buildout"
inPlaceSub(os.path.join(opt.instance_home, 'bin', 'buildout'), substitutions)


################
# Start the fun!
if opt.run_buildout:
    os.chdir(opt.instance_home)

    if opt.install_lxml == 'yes':
        print "Building lxml with static libxml2/libxslt; this requires Internet access,"
        print "and takes a while..."
        returncode = doCommand(
            os.path.join(opt.instance_home, 'bin', 'buildout') + \
            " -c lxml_static.cfg")
        if returncode:
            print "\nlxml build failed."
            print "See log file for details."
            print
            print "Try preinstalling up-to-date libxml2/libxslt system libraries, then run"
            print "the installer again."
        else:
            # test generated lxml via lxmlpy interpreter installed during build
            returncode = doCommand(
                os.path.join(opt.instance_home, 'bin', 'lxmlpy') + \
                  ' -c "from lxml import etree"')
            if returncode:
                print "Failed to build working lxml."
                print "lxml built with no errors, but does not have a working etree component."
                print "See log file for details."
                print
                print "Try preinstalling up-to-date libxml2/libxslt system libraries, then run"
                print "the installer again."
            else:
                # cleanup; if we leave around .installed.cfg, it will give
                # us a cascade of misleading messages and under some circumstances
                # fail during the next buildout.
                os.remove('.installed.cfg')
                # and we no longer need lxmlpy
                os.remove(os.path.join('bin', 'lxmlpy'))
                # we also don't need the part remnants
                shutil.rmtree('parts/lxml')
    else:
        returncode = 0

    if not returncode:
        print "Building Zope/Plone; this takes a while..."
        returncode = doCommand(
            os.path.join(opt.instance_home, 'bin', 'buildout') + \
            " -NU buildout:install-from-cache=true")

    if returncode:
        print "Buildout returned an error code: %s; Aborting." % returncode
        sys.exit(returncode)

    if opt.itype == 'standalone':
        if not (os.path.exists(os.path.join(opt.instance_home, 'bin', 'instance')) and
                 os.path.exists(os.path.join(opt.instance_home, 'parts', 'instance')) and
                 os.path.exists(os.path.join(opt.instance_home, 'var'))):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)
    else:
        if not (os.path.exists(os.path.join(opt.instance_home, 'bin', 'zeoserver')) and
                 os.path.exists(os.path.join(opt.instance_home, 'bin', 'client1')) and
                 os.path.exists(os.path.join(opt.instance_home, 'parts', 'client1')) and
                 os.path.exists(os.path.join(opt.instance_home, 'var'))):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)

    # sanity check PIL and lxml with our zopepy
    my_python = os.path.join(opt.instance_home, 'bin', 'zopepy')
    if doCommand(my_python + " -c 'from _imaging import jpeg_decoder'"):
        print "Failed: JPEG support is not available."
        print "If the installer did not built a static libjpeg, using"
        print "--libjpeg=yes option may cure this problem."
        sys.exit(1)
    if doCommand(my_python + " -c 'from lxml import etree'"):
        print "Failed: lxml does not have a working etree component."
        sys.exit(1)

else:
    print "Skipping bin/buildout at your request."
