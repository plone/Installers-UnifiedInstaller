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
from cStringIO import StringIO

import iniparse
from config_check import getVersion


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


argparser = argparse.ArgumentParser(description="Plone instance creation utility")
argparser.add_argument('--uidir', required=True)
argparser.add_argument('--plone_home', required=True)
argparser.add_argument('--instance_home', default='zinstance')
argparser.add_argument('--daemon_user', default='plone_daemon')
argparser.add_argument('--buildout_user', default='plone_buildout')
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

if opt.install_lxml == 'auto':
    if getVersion('xml2') >= 20708 and getVersion('xslt') >= 10126:
        print "Your platform's xml2/xslt are up-to-date. No need to build them."
        INSTALL_STATIC_LXML = 'no'
    else:
        print "Your platform's xml2/xslt are missing or out-of-date. We'll need to build them."
        INSTALL_STATIC_LXML = 'yes'
else:
    INSTALL_STATIC_LXML = opt.install_lxml


client_template = """

[clientCLIENT_NUM]
# a copy of client1, except adjusted address and var location
<= client1
http-address = ${buildout:clientCLIENT_NUM-address}
event-log = ${buildout:directory}/var/clientCLIENT_NUM/event.log
z2-log    = ${buildout:directory}/var/clientCLIENT_NUM/Z2.log
pid-file  = ${buildout:directory}/var/clientCLIENT_NUM/clientCLIENT_NUM.pid
lock-file = ${buildout:directory}/var/clientCLIENT_NUM/clientCLIENT_NUM.lock
"""

BASE_ADDRESS = 8080
CLIENTS = int(opt.clients)

if opt.root_install:
    sudo_command = "sudo -u %s " % opt.buildout_user
else:
    sudo_command = ""


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


print "Copying buildout skeleton"
shutil.copytree(os.path.join(opt.uidir, 'base_skeleton'), opt.instance_home)

# remove OS X and svn detritus (this is mainly helpful for installer development)
doCommand('find %s -name "._*" -exec rm {} \; > /dev/null' % opt.instance_home)
doCommand('find %s -name ".svn" | xargs rm -rf' % opt.instance_home)

# create a client list and client templates;
# we'll add them to the .cfg files later
client_list = 'client1'
client_parts = ''
client_addresses = '# Additional clients:\n'
for client in range(2, CLIENTS + 1):
    client_parts = "%s%s" % (client_parts,
        client_template.replace('CLIENT_NUM', str(client))
        )
    client_list = "%s client%s" % (client_list, client)
    client_addresses = '%sclient%d-address = %d\n' % (client_addresses, client, 8080 + client - 1)

#############################
# buildout.cfg customizations

# read appropriate buildout template
dest = os.path.join(opt.instance_home, 'buildout.cfg')
if opt.itype == 'standalone':
    template = 'standalone.cfg'
else:
    template = 'cluster.cfg'
fd = file(os.path.join(opt.uidir, 'buildout_templates', template))
buildout = fd.read()
fd.close()

buildout = buildout.replace('client1', client_list)
buildout = buildout.replace('# Additional clients:', client_addresses)


# set password
buildout = buildout.replace('__PASSWORD__', opt.password)

# set effective user
buildout = buildout.replace('__CLIENT_USER__', opt.daemon_user)

# if this python doesn't have PIL, add PIL to the eggs
try:
    from _imaging import jpeg_decoder
    jpeg_decoder  # avoid warning
except:
    buildout = buildout.replace('    Plone\n', '    Plone\n    Pillow\n')

fn = os.path.join(opt.instance_home, 'buildout.cfg')
fd = file(fn, 'w')
fd.write(buildout)
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


#############################
# base.cfg customizations

fd = file(os.path.join(opt.uidir, 'buildout_templates', 'base.cfg'))
base = fd.read()
fd.close()

base = "%s%s" % (base, client_parts)

fd = StringIO(base)
buildout = iniparse.INIConfig(fd)
fd.close()

mainClient = buildout.instance
client1 = buildout.client1
client2 = buildout.client2
zeoServer = buildout.zeoserver

if opt.root_install:
    buildout.unifiedinstaller['sudo-command'] = ' sudo -u %s' % opt.daemon_user
else:
    # remove chown commands
    for section in (buildout.chown, buildout['chown-zeo']):
        section.command = \
            '\n'.join([s for s in section.command.split('\n')
                          if len(s) and not s.count('chown')])

if opt.itype == 'standalone':
    del buildout['zeoserver']
    del buildout['client1']
    del buildout['chown-zeo']
else:
    del buildout['instance']
    del buildout['chown']

fn = os.path.join(opt.instance_home, 'base.cfg')
fd = file(fn, 'w')
fd.write(str(buildout))
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

    if INSTALL_STATIC_LXML == 'yes':
        print "Building lxml with static libxml2/libxslt; this takes a while..."
        returncode = doCommand(
            os.path.join(opt.instance_home, 'bin', 'buildout') + \
            " -c lxml_static.cfg -NU buildout:install-from-cache=true")
        if returncode:
            print "\nlxml build failed. You may wish to clean up and try again"
            print "without the lxml build by adding --without-lxml to the"
            print "command line."
        else:
            # cleanup; if we leave around .installed.cfg, it will give
            # us a cascade of misleading messages and under some circumstances
            # fail during the next buildout.
            os.remove('.installed.cfg')
            # we also don't need the part remnants
            shutil.rmtree('parts/lxml')
    else:
        print "Skipping static libxml2/libxslt build."
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

else:
    print "Skipping bin/buildout at your request."
