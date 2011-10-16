############################################################################
# Unified Plone installer instance build script
# by Steve McMahon (steve at dcn.org)
#
# This script is meant to be invoked by another process
# that will choose the exec Python.
#
# $LastChangedDate: 2011-06-06 16:22:56 -0700 (Mon, 06 Jun 2011) $ $LastChangedRevision: 50300 $

import sys, os, os.path, stat, subprocess, shutil, iniparse, platform, glob, pwd

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
OFFLINE,
ITYPE,
LOG_FILE) = sys.argv[1:]

# find the full egg name for a module in the buildout-cache
def findEgg(basename):
    try:
        return glob.glob(
            "%s*.egg" % os.path.join(
                PLONE_HOME, 
                'buildout-cache', 
                'eggs', 
                basename)
            )[0]
    except:
        return "%s_MISSING" % basename

substitutions = {
    "PLONE_HOME" : PLONE_HOME,
    "INSTANCE_HOME" : INSTANCE_HOME,
    "CLIENT_USER" : CLIENT_USER,
    "ZEO_USER" : ZEO_USER,
    "PASSWORD" : PASSWORD,
    "PYTHON" : sys.executable,
    "DISTRIBUTE_EGG" : findEgg('distribute'),
    "BUILDOUT_EGG" : findEgg('zc.buildout'),
}

# apply substitutions to a file
def inPlaceSub(fn):
    fd = file(fn);
    contents = fd.read()
    fd.close()
    fd = file(fn, 'w');
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

# if standalone, non-root & OS X Leopard or later, install controller
if (ITYPE == 'standalone') and \
   (ROOT_INSTALL != '1') and \
   (platform.system() == 'Darwin') and \
   (int(platform.platform().split('-')[1].split('.')[0]) >= 9):
    # add to parts
    buildout = buildout.replace('parts =\n', 'parts =\n    osxcontroller')

# set password
buildout = buildout.replace('__PASSWORD__', PASSWORD)

# set effective user
buildout = buildout.replace('__CLIENT_USER__', CLIENT_USER)

# if this python doesn't have PIL, add it to the eggs
try:
    from _imaging import jpeg_decoder
except:
    buildout = buildout.replace('    Plone\n', '    Plone\n    Pillow\n')

fn = os.path.join(INSTANCE_HOME, 'buildout.cfg')
fd = file(fn, 'w')
fd.write(buildout)
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


#############################
# base.cfg customizations

fd = file(os.path.join(UIDIR, 'buildout_templates', 'base.cfg'))
buildout = iniparse.INIConfig(fd)
fd.close()

mainClient = buildout.instance
client1 = buildout.client1
client2 = buildout.client2
zeoServer = buildout.zeoserver

# set buildout location
buildout.buildout['eggs-directory'] = '%s/buildout-cache/eggs' % PLONE_HOME
buildout.buildout['download-cache'] = '%s/buildout-cache/downloads' % PLONE_HOME
buildout.buildout['extends-cache'] = '%s/buildout-cache/downloads/extends' % PLONE_HOME


if ROOT_INSTALL == '1':
    buildout.unifiedinstaller['sudo-command'] = ' sudo -u %s' % CLIENT_USER
else:
    # remove chown commands
    for section in (buildout.chown, buildout['chown-zeo']):
        section.command = \
            '\n'.join( [s for s in section.command.split('\n') 
                          if len(s) and not s.count('chown')] )

if ITYPE == 'standalone':
    del buildout['zeoserver']
    del buildout['client1']
    del buildout['client2']
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

    # CLIENT_USER should own everything we create
    if ROOT_INSTALL == '1':
        doCommand('chown -R "%s" "%s"' % (CLIENT_USER, INSTANCE_HOME))
        # switch effective user so that we don't run buildout as root, 
        print "Switching user to %s" % CLIENT_USER
        uid, gid = pwd.getpwnam(CLIENT_USER)[2:4]
        os.seteuid(uid)

    print "Running buildout; this takes a while..."

    if OFFLINE == '1':
        returncode = doCommand(os.path.join(INSTANCE_HOME, 'bin', 'buildout') + " -NU buildout:install-from-cache=true")
    else:
        returncode = doCommand(os.path.join(INSTANCE_HOME, 'bin', 'buildout') + " -NU")
    
    if ROOT_INSTALL == '1':
        # return to root
        os.seteuid(os.getuid())

    logfile = file(LOG_FILE, 'a')
    logfile.write(log)
    logfile.close()
    log = ''

    if returncode:
        print "Buildout returned an error code: %s; Aborting." % returncode
        sys.exit(returncode)

    if ITYPE == 'standalone':
        if not ( os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'instance')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'parts', 'instance')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'var')) ):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)
    else:
        if not ( os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'zeoserver')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'bin', 'client1')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'parts', 'client1')) and
                 os.path.exists(os.path.join(INSTANCE_HOME, 'var')) ):
            print "Parts of the install are missing. Buildout must have failed. Aborting."
            sys.exit(1)

else:
    print "Skipping bin/buildout at your request."

