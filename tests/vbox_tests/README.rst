vbox_tests
==========

VirtualBox (Vagrant) testing for Plone Unified Installer

This is an experimental framework for running Plone Unified
Installer tests in a set of Vagrant-provisioned VirtualBoxes.

Before use, copy or hard-link a Unified Installer .tgz into this directory.

    ./runvbs.sh

runs the suite.

    ./runvbs.sh vb_c*

runs tests on all the matching boxes.

Each vb_* directory is a vagrant kit that provisions an environment
adequate to run the installer.

In each vb_* directory, the `install` files contains a Unified Installer
command line suitable for that OS.

This kit is not directly useful if you don't have the matching vagrant
boxes. But, it may still be useful as a record of the configurations
that produced working copies on a platform.
