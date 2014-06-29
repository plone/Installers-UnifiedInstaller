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

--build-python
  If you do not have a suitable Python available, the installer will
  build one for you if you set this option. Requires Internet access
  to download Python source.

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

BAD_BUILD_PYTHON=\
'Bad argument for --build-python'

BAD_USER_OPTION=\
'Did you want "--daemon-user" instead of "--user"?'

BAD_TEMPLATE=\
'Unable to find $TEMPLATE or ${TEMPLATE}.cfg in $TEMPLATE_DIR'

NO_METHOD_SELECTED=\
'No method selected.
Will use standalone method for convenience, but not run bin/buildout.'

CONTRADICTORY_PYTHON_COMMANDS=\
'--with-python and --build-python may not be employed at the same time.'

POLITE_GOODBYE=\
'
Goodbye for now'

WELCOME='Welcome'

DIALOG_WELCOME='
Welcome to the Plone Unified Installer.

This kit installs Plone from source in many Linux/BSD/Unix environments.
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
IGNORING_BUILD_PYTHON="We already have a Python environment for this target; ignoring --build-python."

SUDO_REQUIRED_MSG="sudo utility is required to do a server-mode install."

MISSING_PARTS_MSG='
The install script directory must contain
$PACKAGES_DIR and $HSCRIPTS_DIR subdirectories.
' 
