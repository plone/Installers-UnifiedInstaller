Options
=======

--target=pathname
  Use to specify top-level path for installs. Plone instances
  and Python will be built inside this directory.
  Default is ``/usr/local/Plone`` for root install,
  ``$HOME/Plone`` for non-root.

  PLEASE NOTE: Your pathname should not include spaces.

--instance=instance-name
  Use to specify the name of the operating instance to be created.
  This will be created inside the target directory.
  Default is 'zinstance' for standalone, 'zeocluster' for ZEO.

--clients=client-count
  Use with the "zeo" install method to specify the number of Zope
  clients you wish to create. Default is 2.

--daemon-user=user-name
  In a root install, sets the effective system user for running the
  instance. Default is 'plone_daemon'.
  Ignored for non-root installs.

--owner=owner-name
  In a server-mode install, sets the overall system owner of the installation.
  Default is 'plone_buildout'. This is the user id that should be employed
  to run buildout or make src or product changes.
  Ignored for non-root installs.

--group=group-name
  In a server-mode install, sets the effective system group for the daemon and
  buildout users. Default is 'plone_group'.
  Ignored for non-server-mode installs.

--with-python=</full/path/to/python2.7 or /full/path/to/python3.5+>
  If you have an already built Python that's adequate to run
  Zope / Plone, you may specify it here.
  virtualenv will be used to isolate the copy used for the install.
  The specified Python will need to have been built with support
  for libz and libjpeg and include the Python Imaging Library.

--password=InstancePassword
  If not specified, a random password will be generated.

--without-ssl
  Optional. Allows the build to proceed without ssl dependency tests.

--static-lxml
  Forces a static build of lxml's libxml2 and libxslt dependencies. Requires
  Internet access to download components.

Note that you may run install.sh repeatedly for the same target so long
as you either use a different installation method or specify different
instance names. Installations to the same target will share the same Python
and egg/download cache.
