############################################################################
# Windows install setup.
#
# This is intended to be the functional Windows equivalent of
# main_install.sh.
#
# We're starting with the assumption of a working Python and the MS VCC
# for Python kit.


from i18n import _

import argparse
import glob
import os
import os.path
import shutil
import subprocess
import sys
import tarfile


def doCommand(command):
    po = subprocess.Popen(command,
                          shell=True,
                          universal_newlines=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = po.communicate()
    sys.stderr.write(stdout)
    return po.returncode


if os.name == 'nt':
    PLONE_HOME = os.path.join(os.environ['HOMEPATH'], 'Plone')
    SCRIPTS = 'Scripts'
    BIN_SUFFIX = '.exe'
else:
    PLONE_HOME = os.path.join(os.environ['HOME'], 'Plone')
    SCRIPTS = 'bin'
    BIN_SUFFIX = ''
INSTALLER_HOME = os.getcwd()
PACKAGES_HOME = os.path.join(INSTALLER_HOME, 'packages')

##########################################################
# Get command line arguments
#
argparser = argparse.ArgumentParser(description=_("Plone instance creation utility"))
argparser.add_argument(
    'itype',
    default='standalone',
    choices=('zeo', 'standalone'),
    help=_("Instance type to create."),
)
argparser.add_argument(
    '--password',
    required=False,
    help=_("Instance password; If not specified, a random password will be generated.")
)
argparser.add_argument(
    "--target",
    required=False,
    default=PLONE_HOME,
    help="Use to specify top-level path for installs. "
         "Plone instances will be built inside this directory. "
         "Default is {}.".format(PLONE_HOME),
)
argparser.add_argument(
    "--instance",
    required=False,
    help="Use to specify the name of the operating instance to be created. "
         "This will be created inside the target directory. "
         "Default is \"zinstance\" for standalone, \"zeocluster\" for ZEO.",
)
argparser.add_argument(
    "--clients",
    required=False,
    type=int,
    default=2,
    help='Use with the \"zeo\" install method to specify the number of Zope clients you wish to create. Default is 2.',
)


opt = argparser.parse_args()

if opt.instance is None:
    if opt.itype == 'standalone':
        opt.instance = 'zinstance'
        ITYPE = 'standalone'
    else:
        opt.instance = 'zeocluster'
        ITYPE = 'cluster'

# Establish plone home
if not os.path.exists(opt.target):
    print _("Creating target directory " + opt.target)
    os.mkdir(opt.target, 0700)

# buildout cache
if not os.path.exists(os.path.join(opt.target, 'buildout-cache')):
    print _("Extracting buildout cache to target")
    with tarfile.open(os.path.join(PACKAGES_HOME, 'buildout-cache.tar.bz2')) as tf:
        tf.extractall(opt.target)
    # Remove download dist contents. We want to fetch wheels rather than build from tarballs
    # that have binary components.
    print _("Removing cache source packages that need binary builds. We want to fetch wheels from PyPI.")
    dist_files = glob.glob(os.path.join(opt.target, 'buildout-cache', 'downloads', 'dist', '*'))
    for fn in dist_files:
        os.remove(fn)

# virtualenv
PY_HOME = os.path.join(opt.target, 'Python-2.7')
PY_SCRIPTS = os.path.join(PY_HOME, SCRIPTS)
if not os.path.exists(PY_HOME):
    print _("Preparing python virtualenv")
    with tarfile.open(glob.glob(os.path.join(PACKAGES_HOME, 'virtualenv*'))[0]) as tf:
        tf.extractall(opt.target)
    vepackagedir = glob.glob(os.path.join(opt.target, 'virtualenv*'))[0]
    doCommand([sys.executable, os.path.join(vepackagedir, 'virtualenv.py'), PY_HOME])
    shutil.rmtree(vepackagedir)
    PIP_BIN = os.path.join(PY_SCRIPTS, 'pip')
    setuptoolspackage = glob.glob(os.path.join(PACKAGES_HOME, 'setuptools*'))
    if setuptoolspackage:
        print _("Installing compatible setuptools in virtualenv")
        doCommand([PIP_BIN, 'install', setuptoolspackage[0]])
    print _("Installing compatible zc.buildout in virtualenv")
    doCommand([PIP_BIN, 'install', glob.glob(os.path.join(PACKAGES_HOME, 'zc.buildout*'))[0]])
    doCommand([PIP_BIN, 'install', 'pypiwin32'])

INSTANCE_HOME = os.path.join(PLONE_HOME, opt.instance)
if os.path.exists(INSTANCE_HOME):
    print _("Instance home ({}) already exists. Delete it if you wish to install a new instance.").format(INSTANCE_HOME)
    sys.exit(1)

print _("Creating instance home and buildout command.")
os.mkdir(INSTANCE_HOME)
INSTANCE_BIN = os.path.join(INSTANCE_HOME, 'bin')
os.mkdir(INSTANCE_BIN)
if os.name == 'nt':
    with open(os.path.join(INSTANCE_BIN, 'buildout.bat'), 'w') as f:
        f.write(os.path.join(PY_SCRIPTS, 'buildout' + BIN_SUFFIX) + ' %*')
else:
    os.symlink(os.path.join(PY_SCRIPTS, 'buildout' + BIN_SUFFIX), os.path.join(INSTANCE_BIN, 'buildout'))
PYTHON_BIN = os.path.join(PY_SCRIPTS, 'python' + BIN_SUFFIX)

options = []
if opt.password is not None:
    options.extend(['--password', opt.password])
if opt.itype == 'zeo':
    options.extend('--clients', str(opt.clients)])

print _("Running create_instance.py")
returncode = doCommand([
    PYTHON_BIN,
    os.path.join(INSTALLER_HOME, 'helper_scripts', 'create_instance.py'),
    '--uidir', INSTALLER_HOME,
    '--plone_home', PLONE_HOME,
    '--instance_home', INSTANCE_HOME,
    '--itype', + ITYPE,
    '--force_build_from_cache=no',
] + options)

if returncode:
    print _("Failed Windows build with error code: %s; Aborting.") % returncode
    sys.exit(returncode)

print _("Buildout succeeded.")
print _("Note: pep425tags runtime warnings may be ignored.")

print _('''
######################  Installation Complete  ######################

Plone successfully installed at {}
See {}
for startup instructions.
''').format(INSTANCE_HOME, os.path.join(INSTANCE_HOME, 'README.html'))

with open(os.path.join(INSTANCE_HOME, 'adminPassword.txt'), 'r') as f:
    print f.read()


os.chdir(INSTALLER_HOME)
