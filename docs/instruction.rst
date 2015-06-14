=========================
Installation Instructions
=========================

The installer will compile Python, Zope, and key required libraries from
source on an as-needed basis. (Basic build tools and common libraries are
required. See `Utility Dependencies <http://docs.plone.org/installing/unified-unix-installer/dependencies>`_.

For different install options, please read our docs about all the different `install options <http://docs.plone.org/installing/unified-unix-installer/options>`_.  

.. note: You have the option to run the installation as root or a
  normal user. There are serious security implications to this choice.

The non-root method produces an install that will run the Zope server with the
same privileges as the installing user. This is probably not an acceptable
security profile for a production server, but is much easier for testing and
development purposes or if you take care to set  users and privileges
yourself.

The 'root' method produces an install that runs the Zope server as a
distinct user identity with minimal privileges (unless you add them).
Providing adequate security for a production server requires many more
steps, but this is a better starting point.

.. note: You have the option to install Plone as a standalone
  (single-instance) setup or as a clustered (ZEO) setup.

The `clustered (ZEO) setup <http://docs.plone.org/installing/unified-unix-installer/zeo>`_ will take advantage of multi-core CPUs and is
recommended for a production deployment, while the `standalone method <http://docs.installing/unified-unix-installer/standalone>`_ is
easier for development or testing.
