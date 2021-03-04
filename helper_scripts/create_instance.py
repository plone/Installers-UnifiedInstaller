############################################################################
# Unified Plone installer instance build script
# by Steve McMahon (steve at dcn.org)
#
# This script is meant to be invoked by another process
# that will choose the exec Python.
#

from distutils.dir_util import copy_tree
from i18n import _
from i18n import _print

import argparse
import os
import os.path
import random
import re
import subprocess
import shutil
import stat
import sys


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
    pw_choices = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz" "0123456789"
    pw = ""
    for i in range(12):
        pw = pw + random.choice(pw_choices)
    return pw


def doCommand(command):
    po = subprocess.Popen(
        command,
        shell=True,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    stdout, stderr = po.communicate()
    sys.stderr.write(stdout)
    return po.returncode


##########################################################
# Get command line arguments
#
argparser = argparse.ArgumentParser(description=_("Plone instance creation utility"))
argparser.add_argument("--uidir", required=True)
argparser.add_argument("--plone_home", required=True)
argparser.add_argument("--instance_home", default="zinstance")
argparser.add_argument("--instance_var", default=None)
argparser.add_argument("--backup_dir", default=None)
argparser.add_argument("--daemon_user", default="plone_daemon")
argparser.add_argument("--buildout_user", default="plone_buildout")
argparser.add_argument("--template", default="buildout")
argparser.add_argument("--password", required=False)
argparser.add_argument("--root_install", required=False, default="0", choices="01")
argparser.add_argument("--run_buildout", required=False, default="1", choices="01")
argparser.add_argument(
    "--install_lxml", required=False, default="auto", choices=("yes", "no", "auto")
)
argparser.add_argument(
    "--itype", default="standalone", choices=("cluster", "standalone")
)
argparser.add_argument("--clients", required=False, default="2")
argparser.add_argument("--force_build_from_cache", required=False, default="yes")
opt = argparser.parse_args()
if not opt.password:
    opt.password = createPassword()
opt.root_install = bool(int(opt.root_install))
opt.run_buildout = bool(int(opt.run_buildout))

##########################################################
# Copy the buildout skeleton into place, clean up a bit
#
_print("Copying buildout skeleton to {}".format(opt.instance_home))
copy_tree(os.path.join(opt.uidir, "base_skeleton"), opt.instance_home, update=1)

if os.name != "nt":
    # remove OS X and svn detritus (this is mainly helpful for installer development)
    doCommand('find %s -name "._*" -exec rm {} \; > /dev/null' % opt.instance_home)
    doCommand('find %s -name ".svn" | xargs rm -rf' % opt.instance_home)

##########################################################
# create adminPassword.txt
#
if os.name == "nt":
    with open(os.path.join(opt.instance_home, 'adminPassword.txt'), "w") as fd:
        fd.write(opt.password + "\n")
    with open(os.path.join(opt.instance_home, 'README.html'), "w") as fd:
        fd.write("<html><body>")
        fd.write("<h1>Welcome to your Plone</h1>")
        if opt.itype == "standalone":        
            fd.write("<p>Start your instance with <i>bin\\runwsgi.exe -dv part/instance/wsgi.ini</i></p>")
        else:
            fd.write("<p>Start your cluster with>:<br/>")
            fd.write("<i>START bin\\zeoserver_runzeo.bat</i><br />")
            fd.write("<i>START runwsgi.exe -dv part/client1/wsgi.ini</i><br />")
            fd.write("<i>bin\\runwsgi.exe -dv part/client2/wsgi.ini</i></p>")
        fd.write("<p><a href='https://docs.plone.org'>Read the Plone documentation</a> for more information or ")
        fd.write("consult the <a href='https://community.plone.org'>Plone Community Forum</a></p>")
        fd.write("</html></body>")

##########################################################
# buildout.cfg customizations
#
CLIENTS = int(opt.clients)
template = opt.template
if ".cfg" not in template:
    template += ".cfg"

with open(os.path.join(opt.uidir, "buildout_templates", template), "r") as fd:
    buildout = fd.read()

# get the list of parts
parts = re.search(r"^parts =\n(.+?)\n\n", buildout, re.MULTILINE + re.DOTALL).group(1)
parts = re.split(r"\W+", parts)[1:]

if opt.itype == "standalone":
    parts.remove("client1")
    parts.remove("zeoserver")
else:
    parts.remove("instance")
    parts.remove("repozo")
    client_index = parts.index("client1")
    for client in range(1, CLIENTS):
        parts.insert(client_index + client, "client%d" % (client + 1))

if os.name == "nt":
    parts.remove("setpermissions")
    parts.remove("unifiedinstaller")
    parts.remove("precompiler")
    # no hard links and rsync, no backup
    parts.remove("backup")
elif not opt.root_install:
    parts.remove("setpermissions")
    parts.remove("precompiler")

parts = "parts =\n    {0}\n".format("\n    ".join(parts))
buildout = re.sub(r"^parts =\n.+?\n\n", parts, buildout, flags=re.MULTILINE + re.DOTALL)

# set password
buildout = buildout.replace("__PASSWORD__", opt.password)

# set effective users
if sys.version_info[0] == 2:
    buildout = buildout.replace("plone_daemon", opt.daemon_user)
else:
    buildout = buildout.replace("plone_daemon", "")
buildout = buildout.replace("plone_buildout", opt.buildout_user)
if not opt.root_install:
    buildout = buildout.replace("need-sudo = yes", "need-sudo = no")

if opt.instance_var:
    buildout = buildout.replace(
        "var-dir=${buildout:directory}/var", "var-dir={0}".format(opt.instance_var)
    )
if opt.backup_dir:
    buildout = buildout.replace(
        "backups-dir=${buildout:var-dir}", "backups-dir={0}".format(opt.backup_dir)
    )

# remove unneeded sections
if opt.itype == "standalone":
    buildout = re.sub(r"\[zeoserver\].+?\n\n", "\n\n", buildout, flags=re.DOTALL)
else:
    buildout = re.sub(r"\[instance\].+?\n\n", "\n\n", buildout, flags=re.DOTALL)

# Windows cleanup
if os.name == "nt":
    buildout = re.sub(r"extensions =.+?\n\n", "\n\n", buildout, flags=re.DOTALL)
    buildout = buildout.replace("eggs =", "eggs =\n    pywin32\n    nt_svcutils\n")

# Insert variable number of zeo client specs. This doesn't fit the iniparse
# model because the clients need to be inserted at particular
# points without fouling comments or section order.
# iniparse.tidy(buildout)
if opt.itype == "standalone":
    # remove extra clients marker
    buildout = buildout.replace(ADD_CLIENTS_MARKER, "")
else:
    client_parts = ""
    client_addresses = ""
    for client in range(1, CLIENTS + 1):
        c_options = {
            "client_num": client,
            "client_port": BASE_ADDRESS + client - 1,
        }
        client_parts = "%s%s" % (client_parts, CLIENT_TEMPLATE % c_options)
    buildout = buildout.replace(ADD_CLIENTS_MARKER, client_parts)

# write out buildout.cfg
fn = os.path.join(opt.instance_home, "buildout.cfg")
with open(fn, "w") as fd:
    fd.write(buildout)
os.chmod(fn, stat.S_IRUSR | stat.S_IWUSR)

#################################
# To buildout or not to buildout!
if not opt.run_buildout:
    _print("Skipping bin/buildout at your request.")
    sys.exit(0)

################
# Start the fun!
os.chdir(opt.instance_home)

if opt.install_lxml == "yes":
    _print("Building lxml with static libxml2/libxslt; this requires Internet access,")
    _print("and takes a while...")
    returncode = doCommand(
        os.path.join(opt.instance_home, "bin", "buildout") + " -c lxml_static.cfg"
    )
    if returncode:
        _print("\nlxml build failed.")
        _print("See log file for details.")
        _print(
            "Try preinstalling up-to-date libxml2/libxslt development libraries, then run"
        )
        _print("the installer again.")
        sys.exit(returncode)
    # test generated lxml via lxmlpy interpreter installed during build
    returncode = doCommand(
        os.path.join(opt.instance_home, "bin", "lxmlpy")
        + ' -c "from lxml import etree"'
    )
    if returncode:
        _print("Failed to build working lxml.")
        _print(
            "lxml built with no errors, but does not have a working etree component."
        )
        _print("See log file for details.")
        _print(
            "Try preinstalling up-to-date libxml2/libxslt development libraries, then run"
        )
        _print("the installer again.")
        sys.exit(returncode)
    # cleanup; if we leave around .installed.cfg, it will give
    # us a cascade of misleading messages and under some circumstances
    # fail during the next buildout.
    os.remove(".installed.cfg")
    # and we no longer need lxmlpy
    os.remove(os.path.join("bin", "lxmlpy"))
    # we also don't need the part remnants
    shutil.rmtree("parts/lxml")

_print("Building Zope/Plone; this takes a while...")
options = ""
if opt.force_build_from_cache == "yes":
    options += " -NU buildout:install-from-cache=true"
returncode = doCommand(os.path.join(opt.instance_home, "bin", "buildout") + options)
if returncode:
    _print("Buildout returned an error code: {0}; Aborting.".format(returncode))
    sys.exit(returncode)

if os.name == "nt":
    ext = ".exe"
else:
    ext = ""

paths_to_check = [
    os.path.join(opt.instance_home, "var"),
    os.path.join(opt.instance_home, "bin", "runwsgi" + ext),
]
if opt.itype == "standalone":
    paths_to_check += [
        os.path.join(opt.instance_home, "parts", "instance"),
    ]
else:
    paths_to_check += [
        os.path.join(opt.instance_home, "bin", "zeoserver" + ext),
        os.path.join(opt.instance_home, "parts", "zeoserver"),
        os.path.join(opt.instance_home, "parts", "client1"),
        os.path.join(opt.instance_home, "parts", "client2"),
    ]
for path_to_check in paths_to_check:
    if not os.path.exists(path_to_check):
        _print(
            "Parts of the install are missing: path '{}'. Buildout must have failed. Aborting.".format(
                path_to_check
            )
        )
        _print("-" * 80)
        _print(
            "Instance directory {} contains:\n- {}".format(
                opt.instance_home, "\n- ".join(os.listdir(opt.instance_home))
            )
        )
        _print(
            "Instance bin directory {} contains:\n- {}".format(
                os.path.join(opt.instance_home, "bin"),
                "\n- ".join(os.listdir(os.path.join(opt.instance_home, "bin"))),
            )
        )
        _print(
            "Instance parts directory contains:\n- {}".format(
                "\n- ".join(os.listdir(os.path.join(opt.instance_home, "parts")))
            )
        )
        _print("-" * 80)
        sys.exit(1)

# sanity check PIL and lxml with our zopepy
zopepy = os.path.join(opt.instance_home, "bin", "zopepy" + ext)
# Note that the nt shell is finicky about quoting; it doesn't like
# single quotes.
if doCommand(zopepy + ' -c "from PIL._imaging import jpeg_decoder"'):
    _print("Failed: JPEG support is not available.")
    _print(
        "Try preinstalling up-to-date libjpeg development libraries, then run the installer again."
    )
    sys.exit(1)
if doCommand(zopepy + ' -c "from PIL._imaging import zip_decoder"'):
    _print("Failed: ZIP support in PIL is not available.")
    _print(
        "Try preinstalling up-to-date zip development libraries, then run the installer again."
    )
    sys.exit(1)
if doCommand(zopepy + ' -c "from lxml import etree"'):
    _print("Failed: lxml does not have a working etree component.")
    _print(
        "Try preinstalling up-to-date libxml2 and libxslt development libraries, then run the installer again."
    )
    sys.exit(1)

sys.exit(0)
