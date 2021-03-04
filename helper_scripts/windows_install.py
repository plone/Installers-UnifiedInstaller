############################################################################
# Windows install setup.
#
# This is intended to be the functional Windows equivalent of
# main_install.sh.
#
# We're starting with the assumption of a working Python and the MS VCC
# for Python kit.


from i18n import _
from i18n import _print

import argparse
import glob
import os
import os.path
import shutil
import subprocess
import sys
import tarfile


def doCommand(command, check=False):
    po = subprocess.Popen(
        command,
        shell=True,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    stdout, stderr = po.communicate()
    sys.stderr.write(stdout)
    sys.stdout.write(stdout)
    if check and po.returncode != 0:
        raise AssertionError(
            '"{}" Failed with error code: {}'.format(command, po.returncode)
        )
    return po.returncode


if os.name == "nt":
    DEFAULT_PLONE_HOME = os.path.join(os.environ["HOMEPATH"], "Plone")
    SCRIPTS = "Scripts"
    BIN_SUFFIX = ".exe"
else:
    DEFAULT_PLONE_HOME = os.path.join(os.environ["HOME"], "Plone")
    SCRIPTS = "bin"
    BIN_SUFFIX = ""

INSTALLER_HOME = os.getcwd()
PACKAGES_HOME = os.path.join(INSTALLER_HOME, "packages")

##########################################################
# Get command line arguments
#
argparser = argparse.ArgumentParser(description=_("Plone instance creation utility"))
argparser.add_argument(
    "itype",
    default="standalone",
    choices=("zeo", "standalone"),
    help=_("Instance type to create."),
)
argparser.add_argument(
    "--password",
    required=False,
    help=_("Instance password; If not specified, a random password will be generated."),
)
argparser.add_argument(
    "--target",
    required=False,
    default=DEFAULT_PLONE_HOME,
    help="Use to specify top-level path for installs. "
    "Plone instances will be built inside this directory. "
    "Default is {}.".format(DEFAULT_PLONE_HOME),
)
argparser.add_argument(
    "--instance",
    required=False,
    help="Use to specify the name of the operating instance to be created. "
    "This will be created inside the target directory. "
    'Default is "zinstance" for standalone, "zeocluster" for ZEO.',
)
argparser.add_argument(
    "--clients",
    required=False,
    type=int,
    default=2,
    help='Use with the "zeo" install method to specify the number of Zope clients you wish to create. Default is 2.',
)


opt = argparser.parse_args()

if opt.itype == "standalone":
    ITYPE = "standalone"
else:
    ITYPE = "cluster"
if opt.instance is None:
    if opt.itype == "standalone":
        opt.instance = "zinstance"
    else:
        opt.instance = "zeocluster"

# Establish plone home
if not os.path.exists(opt.target):
    _print("Creating target directory " + opt.target)
    os.mkdir(opt.target, 0o700)
else:
    _print("Using target directory " + opt.target)

# virtualenv
PY_HOME = os.path.join(opt.target, "py-" + ".".join([str(x) for x in sys.version_info]))
PY_SCRIPTS = os.path.join(PY_HOME, SCRIPTS)
if not os.path.exists(PY_HOME):
    _print("Preparing python virtualenv")
    if sys.version_info[0] < 3:
        with tarfile.open(
            glob.glob(os.path.join(PACKAGES_HOME, "virtualenv*"))[0]
        ) as tf:
            tf.extractall(opt.target)
        vepackagedir = glob.glob(os.path.join(opt.target, "virtualenv*"))[0]
        doCommand(
            sys.executable
            + " "
            + os.path.join(vepackagedir, "virtualenv.py")
            + " "
            + PY_HOME,
            check=True,
        )
        shutil.rmtree(vepackagedir)
    else:
        import venv

        builder = venv.EnvBuilder(with_pip=True)
        builder.create(PY_HOME)
PIP_BIN = os.path.join(PY_SCRIPTS, "pip" + BIN_SUFFIX)
_print("Updating pip")
doCommand(PIP_BIN + " install -U pip")
_print("Installing requirements in virtualenv")
doCommand(
    PIP_BIN
    + " install -r "
    + os.path.join(INSTALLER_HOME, "base_skeleton", "requirements.txt")
    + " --no-warn-script-location",
    check=True,
)
doCommand(PIP_BIN + " install pypiwin32", check=True)

INSTANCE_HOME = os.path.join(opt.target, opt.instance)
if os.path.exists(INSTANCE_HOME):
    _print(
        "Instance home ({}) already exists. Delete it if you wish to install a new instance.".format(
            INSTANCE_HOME
        )
    )
    sys.exit(1)

_print("Creating instance home and buildout command.")
INSTANCE_BIN = os.path.join(INSTANCE_HOME, "bin")
os.makedirs(INSTANCE_BIN)
if os.name == "nt":
    with open(os.path.join(INSTANCE_BIN, "buildout.bat"), "w") as f:
        f.write(os.path.join(PY_SCRIPTS, "buildout" + BIN_SUFFIX) + " %*")
else:
    os.symlink(
        os.path.join(PY_SCRIPTS, "buildout" + BIN_SUFFIX),
        os.path.join(INSTANCE_BIN, "buildout"),
    )
PYTHON_BIN = os.path.join(PY_SCRIPTS, "python" + BIN_SUFFIX)

options = ""
if opt.password is not None:
    options += ' --password="' + opt.password + '"'
if opt.itype == "zeo":
    options += " --clients=" + str(opt.clients)

_print("Running create_instance.py; this takes a while.")
command = (
    PYTHON_BIN
    + " "
    + os.path.join(INSTALLER_HOME, "helper_scripts", "create_instance.py")
    + " --uidir="
    + INSTALLER_HOME
    + " --plone_home="
    + opt.target
    + " --instance_home="
    + INSTANCE_HOME
    + " --itype="
    + ITYPE
    + " --force_build_from_cache=no"
    + options
)
_print("> " + command)
returncode = doCommand(command)

if returncode:
    _print("Failed Windows build with error code: {0}; Aborting.".format(returncode))
    sys.exit(returncode)

_print("Buildout succeeded.")
_print("Note: pep425tags runtime warnings may be ignored.")
_print(
    """
######################  Installation Complete  ######################

Plone successfully installed at {}
See {}
for startup instructions.
""".format(
        INSTANCE_HOME, os.path.join(INSTANCE_HOME, "README.html")
    )
)

with open(os.path.join(INSTANCE_HOME, "adminPassword.txt"), "r") as f:
    print(f.read())


os.chdir(INSTALLER_HOME)
