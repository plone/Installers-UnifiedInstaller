Plone Unified Installer
=======================


.. admonition:: Description

	The Unified Installer is an installation kit that includes nearly everything necessary to build Plone on Linux, OS X, BSD and most Unix workalikes.
	It will also build Plone on Windows 10.

The Unified Installer is an installation kit for installing Python, Zope, Plone and their dependencies on Unix-like platforms. It has two major components:

- An installation script that downloads the packages to create a ready-to-run, relatively self-contained, Python/Zope/Plone install that meets the Plone community's best-practices standards.

- The new Zope/Plone install will use its own virtualenv copy of Python, and the Python installed by the Unified Installer will not replace your system's copy of Python. You may optionally use your system (or some other) Python, and the Unified Installer will use it without modifying it or your site libraries.

.. warning::

	Previous versions of the Unified Installer included a cache of all the required Python libraries not included with Python itself.
	This allowed the installer to build Plone offline.
	This is no longer the case.
	The installer now requires Internet access adequate to download Python packages from the Python Package Index, PyPI.

.. warning::

	We strongly advise against installing Plone via OS packages or ports. There is no .rpm, .deb, or BSD port that is supported by the Plone community. Plone dependencies can and should be installed via package or port -- but not Plone itself.


Root or User Install?
---------------------

The "root" vs "user" installation options only apply to Linux and Unix-like systems; there is no such option for Windows.

Why Choose root or normal?
~~~~~~~~~~~~~~~~~~~~~~~~~~

Installing as root (or with root privileges via sudo) may be the best choice for a production installation of Plone. Since this install runs under the user id of a user created specifically for this purpose, it should have a more controllable level of access to resources. It is a generally accepted "best practice" to run persistent processes (like Zope) as unique users with limited rights.

Installing as a normal user (perhaps with your own user identity) may be a better choice for a test or development instance. It makes it very easy to install and edit custom products without worrying about user rights or identities.

To ZEO or Not to Zeo?
---------------------

.. admonition:: Description

	The Unified Installer will install Zope to either run in a Client/Server or stand-alone configuration. Here are the merits of each.

The Unified Installer offers two different strategies for your Zope configuration:

- A ZEO Client/Server configuration. ZEO (Zope Enterprise Objects) allows you to have several Zope clients processes (or separate servers) that share a common object database server process.

- A stand-alone Zope instance.

The stand-alone Zope instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Is simpler to understand, integrate and control, and is probably the best choice for a simple or test environment.
It's also nearly certainly the best choice if you're installing on Windows, as a Windows installation is unlikely to be used for live, production purposes.

The ZEO Client/Server configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Has several advantages for production or development use:

- Better load balancing options. Even without a load-balancing proxy, running independent client and server processes can spread the load better on modern multi-core servers. With a load-balancing proxy, even better results are possible.

- The ability to run scripts against a live site. You may use "zopectl run" to run scripts on one of the clients while others serve the site to the Internet.

- Better debugging. You may run one client in debug mode while the rest run in production mode. You may then have improved diagnostics for the debug instance. You'll also be able to use introspection tools like Clouseau and "zopectl debug" against a live site.

- You may reserve a client for administrative access (it'll have its own port). Then, if you're slashdotted before you're ready, you'll be able to make changes via the administrative client even when your public client slows down.

Installing Plone
----------------

`Windows installation instructions <./windows.rst>`_ are in a separate document.
The remainder of this page applies only to Linux and Unix-like systems.

Preparations
~~~~~~~~~~~~

Please make sure that you have all :doc:`dependencies` installed.

Download the latest Plone unified installer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now it is time to download the installer. Go to `Plone Installer download Page on Launchpad <https://launchpad.net/plone/+download>`_ and COPY the URL of the latest release.

.. code-block:: bash

	wget --no-check-certificate PASTE-URL-HERE

Extract the downloaded file (change filename to actual :

.. code-block:: bash

	tar -xf Plone-5.2.12-UnifiedInstaller-1.0.tgz

Go the folder containing installer script:

.. code-block:: bash

	cd Plone-5.2.12-UnifiedInstaller-1.0

Run the installer:

.. note::

	We will run the installer without any extra options, like setting passwords, the install path and any more, for a full overview please read :doc:`options` or execute `` install.sh --help``.

.. code-block:: bash

	./install.sh

Please follow the instructions on the screen

.. image:: images/install_gui_1.png
   :alt: Shows installer welcome message

We choose here for the ``standalone`` mode

.. image:: images/install_gui_2.png
   :alt: Shows menu to choose between standalone and zeo

Accept the default installation target or change the path

.. image:: images/install_gui_3.png
   :alt: Shows menu to set installation target

Choose a password option

.. image:: images/install_gui_4.png
   :alt: Shows password menu

Controll the settings to make sure everything is as you want it

.. image:: images/install_gui_5.png
   :alt: Show overview about password and target dir

Wait till the installer is done

.. image:: images/install_gui_6.png
   :alt: Shows installer in progess


.. image:: images/install_gui_7.png
   :alt: Show that installer is finished

Starting Plone
---------------

Switch to the directory which you defined as installation target:

.. code-block:: bash

	cd /Users/svx/Projects/Sprint/Installer/zinstance

Start the instance:

.. code-block:: bash

	bin/plonectl start

Now you can point your browser to ``localhost:8080`` and explore your site.
