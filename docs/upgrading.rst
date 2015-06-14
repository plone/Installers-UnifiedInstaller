====================
Upgrade Instructions
====================

.. contents:: :local:

For general instructions on upgrading a Plone installation,
see `Plone Upgrade Guide
<http://plone.org/documentation/manual/upgrade-guide/>`_ .

Major Version Upgrades
======================

Upgrading from Plone 2.x to Plone 4
-----------------------------------

You will nearly always want to upgrade your Plone 2.x installation first to a
working Plone 3.3.x installation, then attempt the Plone 4 upgrade.
Upgrades of very old installations will nearly always require add-on-product
problem solving.

Upgrading from Plone 3.0 or 3.1
-------------------------------

Plone installations before 3.2 generally did not use the zc.buildout
configuration management system. See
`General advice on updating from a non-buildout to buildout-based installation
<http://plone.org/documentation/manual/upgrade-guide/general-advice-on-updating-from-a-non-buildout-to-buildout-based-installation>`_
for an orientation to buildout and advice on the update pattern.

Upgrading from Plone 3.2 or later
---------------------------------

The general strategy for this upgrade path is to:

1) Independently install Plone 4

2) Get all of your add-on products working on your new Plone 4 install

   This will usually involve adding new product version specifications
   to the "eggs" list of the Plone 4 install. If you're upgrading a
   custom product, see  `Updating add-on products for Plone 4
   <http://plone.org/documentation/manual/upgrade-guide/version/upgrading-plone-3-x-to-4.0/updating-add-on-products-for-plone-4.0>`_
   
3) Copy the ``Data.fs`` database file from your old to ``var/filestorage`` in
   your new install. Restart Zope and run the portal migration to update
   database entries to new formats.
   
Upgrading from an earlier Plone 4
---------------------------------

You probably do not need a new installation. Instead, follow the 
instructions in your ``buildout.cfg`` file for switching your version
configuration file to use the latest available.

Make sure you back up your complete installation before running
any in-place update! 
