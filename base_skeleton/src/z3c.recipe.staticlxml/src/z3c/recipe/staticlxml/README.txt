Supported options
=================

The recipe supports the following options:

**egg**
    Set to the desired lxml egg, e.g. ``lxml`` or ``lxml==2.1.2``

**libxslt-url, libxml2-url**
    The URL to download the source tarball of these libraries from.
    If unset, the [versions] section of the buildout is searched,
    if nothing is found there, either, these default values are used::

      http://dist.repoze.org/lemonade/dev/cmmi/libxslt-1.1.24.tar.gz
      http://dist.repoze.org/lemonade/dev/cmmi/libxml2-2.6.32.tar.gz

**build-libxslt, build-libxml2**
    Set to ``true`` (default) if these should be build, ``false`` otherwise.
    Needes to be ``true`` for a static build.

**static-build**
    ``true`` or ``false``.  On OS X this defaults to ``true``.

**xml2-location**
    Needed if ``libxml2`` is not built.

**xslt-location**
    Needed if ``libxslt`` is not built.

**xslt-config**
    Path to the ``xslt-config`` binary.  Not needed if ``build-libxslt`` is
    set to true.

**xml2-config**
    Path to the ``xml2-config`` binary.  Not needed if ``build-libxml2`` is
    set to true.

**force**
    Set to ``true`` to force rebuilding libraries every time.


Example usage
=============

This is an example buildout::

    [buildout]
    parts =
       lxml
       pylxml
    develop = .

    log-level = DEBUG

    download-directory = downloads
    download-cache = downloads

    versions=versions

    [versions]
    lxml = 2.1.3


    [pylxml]
    recipe=zc.recipe.egg
    interpreter=pylxml
    eggs=
        lxml

    [lxml]
    recipe = z3c.recipe.staticlxml
    egg = lxml

This will build a ``static`` version of the ``lxml`` egg, that is, it won't have
any dependencies on ``libxml2`` and ``libxslt``.

The egg is installed in your buildout's egg directory (it is *not* installed
as a development egg).  If you have a global ``eggs-directory`` configured in
your ``~/.buildout/default.cfg``, the static lxml egg is thus placed in that
global egg directory.

If you specified a specific version for the lxml egg, the egg directory is
checked for an existing lxml egg. If found, it is used as-is. Specifying
``force = true`` of course means that this check isn't performed.

Sanity check
============

This is not a complete exercise of all the ways the recipe can be configured,
rather it's a sanity check that all parts (especially, recipes we depend on)
work as expected:

>>> write('buildout.cfg',
... """
... [buildout]
... parts = lxml
... newest = false
...
... [lxml]
... recipe = z3c.recipe.staticlxml
... libxml2-url = file://%s/foo.tgz
... libxslt-url = file://%s/foo.tgz
... xml2-config = none
... xslt-config = none
... egg = lxml
... static-build = false
... """ % (distros, distros))

>>> print system('bin/buildout')
Installing lxml.
lxml: CMMI libxml2 ...
lxml: Using libxml2 download url /distros/foo.tgz...
libxml2: Unpacking and configuring
configuring foo...
echo building foo
building foo
echo installing foo
installing foo
lxml: CMMI libxslt ...
lxml: Using libxslt download url /distros/foo.tgz...
libxslt: Unpacking and configuring
configuring foo...
echo building foo
building foo
echo installing foo
installing foo...
lxml: Building lxml ...
