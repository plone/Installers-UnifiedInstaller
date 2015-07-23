====================
Upgrade Instructions
====================

.. contents:: :local:

For general instructions on upgrading a Plone installation,
see `Plone Upgrade Guide
<http://docs.plone.org/manage/upgrading/index.html>`_ .

Major Version Upgrades
======================

Upgrading from Plone 2.x to Plone 4
-----------------------------------

You will nearly always want to upgrade your Plone 2.x installation first to a
working Plone 3.3.x installation, then attempt the Plone 5 upgrade.
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

1) Independently install Plone 5

2) Get all of your add-on products working on your new Plone 5 install

   This will usually involve adding new product version specifications
   to the "eggs" list of the Plone 5 install. If you're upgrading a
   custom product, see TODO: add Plone 5 add-on ugrade doc reference

3) Copy the file and blob storage directories to
   your new install. Restart Zope and run the portal migration to update
   database entries to new formats.
