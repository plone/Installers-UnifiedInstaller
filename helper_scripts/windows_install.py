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
import os
import os.path


PLONE_HOME = os.path.join(os.environ['HOMEPATH'], 'Plone')

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
    default=PLONE_HOME,
    help="Use to specify top-level path for installs."
         "Plone instances will be built inside this directory."
         "(default is {}).".format(PLONE_HOME),
)


opt = argparser.parse_args()
