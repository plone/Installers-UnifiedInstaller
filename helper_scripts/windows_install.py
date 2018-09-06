############################################################################
# Windows install setup.
#
# This is intended to be the functional Windows equivalent of
# main_install.sh.
#
# We're starting with the assumption of a working Python and the MS VCC
# for Python kit.

import argparse
from i18n import _


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

opt = argparser.parse_args()
