==========================
Building Development Tools
==========================

Once you have installed Plone with the Unified Installer, you may activate the development tools by running buildout via:

    bin/buildout -c develop.cfg

This specifies develop.cfg as buildout's configuration file. This configuration file extends buildout.cfg, so that all the options from that file are automatically included.

Included in the development configuration
-----------------------------------------

Common development tools:

 * mr.bob, a Python package-skeleton generator. With bobtemplates.plone it has support for common Plone development packages like content-type and theme packages. See the `PyPI page for bobtemplates.plone <https://pypi.python.org/pypi/bobtemplates.plone>`_ for details on using the templates.

 * mr.developer, a tool that automatically checks out source for add ons from a versioning system, then adds them to your development package list. See https://pypi.python.org/pypi/mr.developer/ or read the comments in develop.cfg.

 * testrunner, which provides a command-line test tool to run test suites. https://pypi.python.org/pypi/zope.testrunner and https://pypi.python.org/pypi/collective.xmltestreport

 * Diazo command-line tools: diazocompile and diazorun. Useful for debugging and understanding Diazo and plone.app.theming. See http://docs.diazo.org/en/latest/compiler.html

 * zest.releaser, a kit for managing the release cycle for Python packages. See https://pypi.python.org/pypi/zest.releaser.

 * pocompile, a tool to compile message translation files. https://pypi.python.org/pypi/zest.pocompile

 * collective.checkdocs adds new distutils commands checkdocs and showdocs to validate restructured text in long_description field of Python eggs. This package aims to make Python egg help page publishing and editing easier.