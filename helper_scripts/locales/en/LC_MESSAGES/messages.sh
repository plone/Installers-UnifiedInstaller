# Installer messages. Note that these are typically single-quoted and
# sometimes contain variables for expansion via eval.
# So, all characters meaningful to the shell will need
# escaping if they're not meant to be interpreted.

USAGE_MESSAGE=\
'
Usage: [sudo] `basename $0` [options] standalone|zeo

Install methods available:
   standalone - install standalone zope instance
   zeo        - install zeo cluster

Use sudo (or run as root) for server-mode install.

Options (see top of install.sh for complete list):

--with-python=/full/path/to/python-${WANT_PYTHON}
  Path to the Python-${WANT_PYTHON} that you wish to use with Plone.
  virtualenv will be used to isolate the install.

--password=InstancePassword
  If not specified, a random password will be generated.

--target=pathname
  Use to specify top-level path for installs. Plone instances
  and Python will be built inside this directory
  (default is $PLONE_HOME)

--clients=client-count
  Use with the \"zeo\" install method to specify the number of Zope
  clients you wish to create. Default is 2.

--instance=instance-name
  Use to specify the name of the operating instance to be created.
  This will be created inside the target directory.
  Default is \"zinstance\" for standalone, \"zeocluster\" for ZEO.

--daemon-user=user-name
  In a server-mode install, sets the effective user for running the
  instance. Default is \"plone_daemon\". Ignored for non-server-mode installs.

--owner=owner-name
  In a server-mode install, sets the overall owner of the installation.
  Default is \"buildout_user\". This is the user id that should be employed
  to run buildout or make src or product changes.
  Ignored for non-server-mode installs.

--group=group-name
  In a server-mode install, sets the effective group for the daemon and
  buildout users. Default is \"plone_group\".
  Ignored for non-server-mode installs.

--template=template-name
  Specifies the buildout.cfg template filename. The template file must
  be in the ${TEMPLATE_DIR} subdirectory. Defaults to buildout.cfg.

--static-lxml
  Forces a static built of libxml2 and libxslt dependencies. Requires
  Internet access to download components.

Read the top of install.sh for more install options.
'

BAD_USER_OPTION=\
'Did you want "--daemon-user" instead of "--user"?'

BAD_TEMPLATE=\
'Unable to find $TEMPLATE or ${TEMPLATE}.cfg in $TEMPLATE_DIR'

NO_METHOD_SELECTED=\
'No method selected.
Will use standalone method for convenience, but not run bin/buildout.'

POLITE_GOODBYE=\
'
Goodbye for now'

WELCOME='Welcome'

DIALOG_WELCOME='
Welcome to the Plone Unified Installer.

This kit installs Plone from source in many Linux/BSD/OS X/Windows 10 environments.
You may use the installer via command-line arguments, or by having us
ask you questions about major options.

For command-line options, just re-run the installer with "--help".

Shall we continue?'

INSTALL_TYPE_TITLE='Install Type'
CHOOSE_CONFIG_MSG='Choose a basic configuration.'
# note that # is the choice separator
INSTALL_TYPE_CHOICES=\
"Standalone (best for testing/development)#ZEO Cluster (best for production; requires load-balancer setup.)"

CLIENT_CHOICES="1#2#3#4#5#6"
CHOOSE_CLIENTS_TITLE="ZEO Clients"
CHOOSE_CLIENTS_PROMPT=\
'How many ZEO clients would you like to create\?
This is easy to change later.
Clients are memory/CPU-intensive.'

INSTALL_DIR_TITLE="Install Directory"
INSTALL_DIR_PROMPT='Installation target directory? (Leave empty for ${PLONE_HOME}): '

PASSWORD_TITLE=Password
PASSWORD_PROMPT="Pick an administrative password. (Leave empty for random): "

Q_CONTINUE="Continue?"
CONTINUE_PROMPT=\
"
Continue with the command line:
"

NO_GCC_MSG="
Error: gcc is required for the install.
See README.txt for dependencies."

PREFLIGHT_FAILED_MSG="
Unable to run preflight check. Basic build tools are missing.
You may get more information about what went wrong by running
sh ./preflight
Aborting installation.
"

IGNORING_WITH_PYTHON="We already have a Python environment for this target; ignoring --with-python."

CHOOSE_PYTHON_TITLE="Pick a Python"
CHOOSE_PYTHON_EXPLANATION="
Choose the Python executable you wish to use for building and running Plone.
If you don't want one of these, cancel and use the --with-python command-line argument.
"

SUDO_REQUIRED_MSG="sudo utility is required to do a server-mode install."

MISSING_PARTS_MSG='
The install script directory must contain
$PACKAGES_DIR and $HSCRIPTS_DIR subdirectories.
'

NEED_INSTALL_PYTHON_MSG='
Please do one of the following:
1) Install python${WANT_PYTHON} or python3.6+ as a system "dev" package\;
2) Use --with-python=... option to point the installer to a useable python.\
'

NEED_INSTALL_LIBZ_MSG="

Unable to find libz library and headers. These are required to build Python.
Please use your system package or port manager to install libz dev.
(Debian/Ubuntu zlib1g-dev)
Exiting now.
"

NEED_INSTALL_LIBJPEG_MSG="

Unable to find libjpeg library and headers. These are required to build Plone.
Please use your system package or port manager to install libjpeg dev.
(Debian/Ubuntu libjpeg-dev)
Exiting now.
"

NEED_INSTALL_SSL_MSG="
Unable to find libssl or openssl/ssl.h.
libssl and its development headers are required for Plone.
Please install your platform's openssl-dev package
and try again.
(If your system is using an SSL other than openssl or is
putting the libraries/headers in an unconventional place,
you may need to set CFLAGS/CPPFLAGS/LDFLAGS environment variables
to specify the locations.)
If you want to install Plone without SSL support, specify
--without-ssl on the installer command line.
"

SORRY_OPENBSD='
***Aborting***
Sorry, but the Unified Installer cannot build a Python ${WANT_PYTHON} for OpenBSD.
There are too many platform-specific patches required.
Please consider installing the Python ${WANT_PYTHON} port and re-run installer.
'

PYTHON_NOT_FOUND='Unable to find python${WANT_PYTHON} on system exec path.'

WITH_PYTHON_IS_OK='$WITH_PYTHON looks OK. We will use it.'

WITH_PYTHON_IS_BAD='
$WITH_PYTHON does not meet the requirements for Zope/Plone.
'

WITH_PYTHON_NOT_EX='Error: $WITH_PYTHON is not an executable. It should be the filename of a Python binary.'

TESTING_WITH_PYTHON='Testing $WITH_PYTHON for Zope/Plone requirements....'

MISSING_GCC="Note: gcc is required for the install. Exiting now."

MISSING_GPP="Note: g++ is required for the install. Exiting now."

MISSING_MAKE="Note: make is required for the install. Exiting now."

MISSING_TAR="Note: gnu tar is required for the install. Exiting now."

MISSING_PATCH="Note: gnu patch program is required for the install. Exiting now."

MISSING_GUNZIP="Note: gunzip is required for the install. Exiting now."

MISSING_BUNZIP2="Note: bunzip2 is required for the install. Exiting now."

MISSING_MINIMUM_XSLT='
Plone installation requires the development versions of libxml2 and libxslt.
libxml2 must be version $NEED_XML2 or greater\; libxslt must be $NEED_XSLT or greater.
Ideally, you should install these as dev package libraries before running install.sh.
If -- and only if -- these packages are not available for your platform, you may
try adding --static-lxml=yes to your install.sh command line to force a
local, static build of these libraries. This will require Internet access for the
installer to download the extra source.
Installation aborted.'

MISSING_XSLT_DEV="Unable to find libxslt development libraries."

MISSING_XML2_DEV="Unable to find libxml2 development libraries."

BAD_XML2_VER='We need development version $NEED_XML2 of libxml2. Not found.'

BAD_XSLT_VER='We need development version $NEED_XSLT of libxslt. Not found.'

ROOT_INSTALL_CHOSEN='
Root install method chosen. Will install for use by users:
  ZEO & Client Daemons:      $DAEMON_USER
  Code Resources & buildout: $BUILDOUT_USER'

ROOTLESS_INSTALL_CHOSEN='Rootless install method chosen. Will install for use by system user $USER'

CANNOT_WRITE_LOG='Unable to write to ${INSTALL_LOG}\; detailed log will go to stdout.'

LOGGING_MSG='
Detailed installation log being written to $INSTALL_LOG'

SEE_LOG_EXIT_MSG='
Installation has failed.
See the detailed installation log at $INSTALL_LOG
to determine the cause.'

INSTALLING_NOW='Installing Plone ${FOR_PLONE} at $PLONE_HOME
'

CANNOT_CREATE_HOME='
Unable to create $PLONE_HOME
Please check rights and pathnames.

Installation has failed.
'

INSTANCE_HOME_EXISTS='Instance target $INSTANCE_HOME already exists; aborting install.'

CREATING_VIRTUALENV="Creating Python virtual environment."

VIRTUALENV_CREATION_FAILED='
Failed to create virtual environment for $WITH_PYTHON'

VIRTUALENV_BAD='
Python created with virtualenv no longer passes baseline tests.
'

DOWNLOADING_PYTHON='Downloading Python source from $PYTHON_URL'
DOWNLOADING_PYTHON3='Downloading Python source from $PYTHON3_URL'

PYTHON_BUILD_OK="Python build looks OK."

PYTHON_BUILD_BAD='
***Aborting***
The built Python does not meet the requirements for Zope/Plone.
Check messages and the install.log to find out what went wrong.

See the "Built Python does not meet requirements" section of
README.txt for more information about this error.'

INSTALLING_BUILDOUT='Installing zc.buildout in virtual environment.'

INSTALLING_BUILDOUT_FAILED='Unable to install zc.buildout in virtual environment.'

INSTALLING_SETUPTOOLS='Installing setuptools in virtual environment.'

INSTALLING_SETUPTOOLS_FAILED='Unable to install setuptools in virtual environment.'

INSTALLING_REQUIREMENTS='Installing Python requirements in virtual environment.'

INSTALLING_REQUIREMENTS_FAILED='Unable to install Python requirements in virtual environment.'

FOUND_BUILDOUT_CACHE='Found existing buildout cache at $BUILDOUT_CACHE\; skipping step.'

UNPACKING_BUILDOUT_CACHE='Unpacking buildout cache to $BUILDOUT_CACHE'

BUILDOUT_CACHE_UNPACK_FAILED="Buildout cache unpack failed. Unable to continue."

BUILDOUT_FAILED="Buildout failed. Unable to continue"

BUILDOUT_SUCCESS="Buildout completed"

INSTALL_COMPLETE='
######################  Installation Complete  ######################

Plone successfully installed at $PLONE_HOME
See $RMFILE
for startup instructions.
'

BUILDOUT_SKIPPED_OK='
Buildout was skipped at your request, but the installation is
otherwise complete and may be found at $PLONE_HOME
'

NEED_HELP_MSG='


- If you need help, ask in our forum https://community.plone.org
- Live chat channels also exists at http://plone.org/support/chat

- Submit feedback and report errors at https://github.com/plone/Products.CMFPlone/issues
(For install problems, https://github.com/plone/Installers-UnifiedInstaller/issues)
'

REPORT_ERRORS_MSG='
There were errors during the install.  Please read readme.txt and try again.
To report errors with the installer, visit https://github.com/plone/Installers-UnifiedInstaller/issues
'

# build_python.sh

INSTALLING_PYTHON='Installing ${PYTHON_DIR}. This takes a while...'
INSTALLING_PYTHON3='Installing ${PYTHON3_DIR}. This takes a while...'

UNABLE_TO_CONFIGURE_PY="Unable to configure Python build."

PY_BUILD_FAILED="Python build has failed."

INSTALL_PY_FAILED='Install of ${PYTHON_DIR} has failed.'
INSTALL_PY3_FAILED='Install of ${PYTHON3_DIR} has failed.'

# user_group_utilities.sh

USING_USERADD="Using useradd and groupadd to create users and groups."

GROUP_EXISTS='"$TARGET_GROUP" already exists; no need to create it.'

GROUP_FAILED='Creation of "$TARGET_GROUP" failed. Unable to continue.'

USER_EXISTS='User "$TARGET_USER" already exists. No need to create it.'

ADD_USER_TO_GROUP='Adding user $TARGET_USER to group $TARGET_GROUP.'

USING_PW="Using pw to create users and groups"

UNKNOWN_USER_ENV='We do not know how to add users and groups in this environment.
This is no problem if the required users and group already exist.
'

UG_CREATE_FAILED='Expected to find uid for $TARGET_USER and gid for $TARGET_GROUP but did not.
Please use your system tools to create/edit required users and group, then try again.'
