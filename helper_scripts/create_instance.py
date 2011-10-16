############################################################################
# Unified Plone installer instance build script
# by Steve McMahon (steve at dcn.org)
#
# This script is meant to be invoked by another process
# that will choose the exec Python.
#
# $LastChangedDate: 2009-09-14 15:28:32 -0700 (Mon, 14 Sep 2009) $ $LastChangedRevision: 29710 $

import sys, os, os.path, stat, subprocess, shutil, re, iniparse, platform

# pick up globals from command line
(UIDIR,
PLONE_HOME,
INSTANCE_HOME,
CLIENT_USER,
ZEO_USER,
PASSWORD,
ROOT_INSTALL,
MYZOPE,
RUN_BUILDOUT,
OFFLINE,
ITYPE) = sys.argv[1:]


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True)
    po.communicate()
    return po.returncode


if ITYPE == 'standalone':
    print "Copying buildout skeleton"
shutil.copytree(os.path.join(UIDIR, 'base_skeleton'), INSTANCE_HOME)


# remove OS X and svn detritus (this is mainly helpful for installer development)
doCommand('find %s -name "._*" -exec rm {} \; > /dev/null' % INSTANCE_HOME)
doCommand('find %s -name ".svn" | xargs rm -rf' % INSTANCE_HOME)


#############################
# buildout.cfg customizations

# read appropriate buildout
fd = file(os.path.join(UIDIR, 'buildout_templates', '%s.cfg' % ITYPE))
buildout = iniparse.INIConfig(fd)
fd.close()

if ITYPE == 'standalone':
    mainClient = buildout.instance
    zeoServer = None
else:
    mainClient = buildout.client1
    zeoServer = buildout.zeoserver

# set password
mainClient.user = 'admin:%s' % PASSWORD

# set buildout location
buildout.buildout['eggs-directory'] = '%s/buildout-cache/eggs' % PLONE_HOME
buildout.buildout['download-cache'] = '%s/buildout-cache/downloads' % PLONE_HOME

# set shared Zope directory
buildout.buildout['zope-directory'] = PLONE_HOME

if ROOT_INSTALL == '1':
    # Set effective-user
    mainClient['effective-user'] = CLIENT_USER
    if zeoServer:
        zeoServer['effective-user'] = ZEO_USER
    buildout.unifiedinstaller['sudo-command'] = 'sudo'
else:
    # remove effective-user options
    del mainClient['effective-user']
    if zeoServer:
        del zeoServer['effective-user']
    # remove chown commands
    buildout.chown.command = \
        '\n'.join( [s for s in buildout.chown.command.split('\n') 
                      if len(s) and not s.count('chown')] )

if MYZOPE != '0':
    # set buildout.cfg to use the separate zope
    zope2 = buildout.zope2
    zope2['location'] = MYZOPE
    del zope2.url
    # set location
    mainClient['zope2-location'] = MYZOPE
    if zeoServer:
        zeoServer['zope2-location'] = MYZOPE
    # no shared directory
    del buildout.buildout['zope-directory']    


# if standalone, non-root & OS X Leopard or later, install controller
if (ITYPE == 'standalone') and \
   (ROOT_INSTALL != '1') and \
   (platform.system() == 'Darwin') and \
   (int(platform.platform().split('-')[1].split('.')[0]) >= 9):
    # add to parts
    parts = buildout.buildout.parts.split()
    parts.append('osxcontroller')
    buildout.buildout.parts = '\n'.join(parts)
    # add part
    buildout.osxcontroller.recipe = 'plone.recipe.osxcontroller'


fn = os.path.join(INSTANCE_HOME, 'buildout.cfg')
fd = file(fn, 'w')
fd.write(str(buildout))
fd.close()
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)


##########################
# set bin/buildout paths
fn = os.path.join(INSTANCE_HOME, 'bin', 'buildout')
fd = open(fn)
bbin = fd.read()
fd.close
bbin = bbin.replace('__TARGET__', PLONE_HOME)
fd = open(fn, 'w')
fd.write(bbin)
fd.close()
os.chmod(fn, stat.S_IRWXU)


################
# Start the fun!
if RUN_BUILDOUT == '1':
    print "Running buildout"
    
    os.chdir(INSTANCE_HOME)
    
    if OFFLINE == '1':
        returncode = doCommand(os.path.join(INSTANCE_HOME, 'bin', 'buildout') + " -NoU")
    else:
        returncode = doCommand(os.path.join(INSTANCE_HOME, 'bin', 'buildout') + " -NU")
    
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
    

    if ITYPE == 'standalone':
        ###############################
        # Create a Plone instance at /Plone in the ZODB.
        # We don't do this for ZEO installs because we don't
        # want to connect to a server port without giving the user
        # an opportunity to change it.
        print "Creating Plone site..."
        if doCommand("./bin/plonectl init"):
            print "Attempt to create a Plone site in the Zope instance failed."
            print "You will need to do this manually."
        else:
            # successful. cleanup.
            try:
                os.remove(os.path.join(INSTANCE_HOME, 'var', 'filestorage', 'Data.fs.index'))
                os.remove(os.path.join(INSTANCE_HOME, 'var', 'filestorage', 'Data.fs.tmp'))
                os.remove(os.path.join(INSTANCE_HOME, 'var', 'filestorage', 'Data.fs.lock'))
            except OSError:
                pass
else:
    print "Skipping bin/buildout at your request."
