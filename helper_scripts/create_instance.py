############################################################################
# Unified Plone installer instance build script
# by Steve McMahon (steve at dcn.org)
#
# This script is meant to be invoked by another process
# that will choose the exec Python.
#

import sys
import os
import os.path
import stat
import subprocess
import shutil
import iniparse
import platform
import glob
from cStringIO import StringIO

from config_check import getVersion


log = ''

# pick up globals from command line
(UIDIR,
PLONE_HOME,
INSTANCE_HOME,
CLIENT_USER,
ZEO_USER,
PASSWORD,
ROOT_INSTALL,
RUN_BUILDOUT,
INSTALL_STATIC_LXML,
OFFLINE,
ITYPE,
LOG_FILE,
CLIENTS) = sys.argv[1:]

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
CLIENTS = int(CLIENTS)


# find the full egg name for a module in the buildout-cache
def findEgg(basename):
    return glob.glob(
        "%s*.egg" % os.path.join(
            PLONE_HOME,
            'buildout-cache',
            'eggs',
            basename)
        )[0]

substitutions = {
    "PLONE_HOME": PLONE_HOME,
    "INSTANCE_HOME": INSTANCE_HOME,
    "CLIENT_USER": CLIENT_USER,
    "ZEO_USER": ZEO_USER,
    "PASSWORD": PASSWORD,
    "PYTHON": sys.executable,
    "DISTRIBUTE_EGG": findEgg('distribute'),
    "BUILDOUT_EGG": findEgg('zc.buildout'),
}


# apply substitutions to a file
def inPlaceSub(fn):
    fd = file(fn)
    contents = fd.read()
    fd.close()
    fd = file(fn, 'w')
    fd.write(contents % substitutions)
    fd.close()


def doCommand(command):
    global log

    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = po.communicate()
    log += stdout
    return po.returncode


print "Copying buildout skeleton"
shutil.copytree(os.path.join(UIDIR, 'base_skeleton'), INSTANCE_HOME)

# remove OS X and svn detritus (this is mainly helpful for installer development)
doCommand('find %s -name "._*" -exec rm {} \; > /dev/null' % INSTANCE_HOME)
doCommand('find %s -name ".svn" | xargs rm -rf' % INSTANCE_HOME)

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
dest = os.path.join(INSTANCE_HOME, 'buildout.cfg')
if ITYPE == 'standalone':
    template = 'standalone.cfg'
else:
    template = 'cluster.cfg'
fd = file(os.path.join(UIDIR, 'buildout_templates', template))
buildout = fd.read()
fd.close()

buildout = buildout.replace('client1', client_list)
buildout = buildout.replace('# Additional clients:', client_addresses)


# set password
buildout = buildout.replace('__PASSWORD__', PASSWORD)

# set effective user
buildout = buildout.replace('__CLIENT_USER__', CLIENT_USER)

fn = os.path.join(INSTANCE_HOME, 'buildout.cfg')
fd = file(fn, 'w')
fd.write(buildout)
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


#############################
# base.cfg customizations

fd = file(os.path.join(UIDIR, 'buildout_templates', 'base.cfg'))
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

# set buildout location
# buildout.buildout['eggs-directory'] = '%s/buildout-cache/eggs' % PLONE_HOME
# buildout.buildout['download-cache'] = '%s/buildout-cache/downloads' % PLONE_HOME
# buildout.buildout['extends-cache'] = '%s/buildout-cache/downloads/extends' % PLONE_HOME


if ROOT_INSTALL == '1':
    buildout.unifiedinstaller['sudo-command'] = ' sudo -u %s' % CLIENT_USER
else:
    # remove chown commands
    for section in (buildout.chown, buildout['chown-zeo']):
        section.command = \
            '\n'.join([s for s in section.command.split('\n')
                          if len(s) and not s.count('chown')])

if ITYPE == 'standalone':
    del buildout['zeoserver']
    del buildout['client1']
    del buildout['chown-zeo']
else:
    del buildout['instance']
    del buildout['chown']

fn = os.path.join(INSTANCE_HOME, 'base.cfg')
fd = file(fn, 'w')
fd.write(str(buildout))
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


# boostrapping is problematic when the python may not have the right
# components; so, let's fix up the bin/buildout ourselves.
print "Fixing up bin/buildout"
inPlaceSub(os.path.join(INSTANCE_HOME, 'bin', 'buildout'))


################
# Start the fun!
if RUN_BUILDOUT == '1':
    os.chdir(INSTANCE_HOME)

    logfile = file(LOG_FILE, 'a')
    logfile.write(log)
    logfile.close()
    log = ''

    if INSTALL_STATIC_LXML == 'yes':
        print "Building lxml with static libxml2/libxslt; this takes a while..."
        returncode = doCommand(
            os.path.join(INSTANCE_HOME, 'bin', 'buildout') + \
            " -c lxml_static.cfg -NU")
        if returncode:
            print "\nlxml build failed."
            print "See log file for details."
            print
            print "Try preinstalling up-to-date libxml2/libxslt system libraries, then run"
            print "the installer again."
        else:
            # test generated lxml via lxmlpy interpreter installed during build
            returncode = doCommand(
                os.path.join(INSTANCE_HOME, 'bin', 'lxmlpy') + \
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
            os.path.join(INSTANCE_HOME, 'bin', 'buildout') + \
            " -NU buildout:install-from-cache=true")

    logfile = file(LOG_FILE, 'a')
    logfile.write(log)
    logfile.close()
    log = ''

    if returncode:
        print "Buildout returned an error code: %s; Aborting." % returncode
        sys.exit(returncode)

    if ITYPE == 'standalone':
        if not (os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'instance')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'parts', 'instance')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'var'))):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)
    else:
        if not (os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'zeoserver')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'client1')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'parts', 'client1')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'var'))):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)

else:
    print "Skipping bin/buildout at your request."
