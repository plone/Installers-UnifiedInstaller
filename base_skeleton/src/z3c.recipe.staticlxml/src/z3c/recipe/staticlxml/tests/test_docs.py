# -*- coding: utf-8 -*-
"""
Doctest runner for 'z3c.recipe.staticlxml'.
"""
__docformat__ = 'restructuredtext'

from zope.testing import renormalizing
import doctest
import os
import unittest
import zc.buildout.testing
import zc.buildout.tests
import zc.recipe.cmmi.tests


optionflags =  (doctest.ELLIPSIS |
                doctest.NORMALIZE_WHITESPACE |
                doctest.REPORT_NDIFF |
                doctest.REPORT_ONLY_FIRST_FAILURE)

test_dir = os.path.dirname(os.path.abspath(__file__))


def setUp(test):
    zc.recipe.cmmi.tests.setUp(test)

    # Install the recipe in develop mode
    zc.buildout.testing.install_develop('z3c.recipe.staticlxml', test)

    # Install any other recipes that should be available in the tests
    zc.buildout.testing.install('zc.recipe.egg', test)
    zc.buildout.testing.install('zc.recipe.cmmi', test)

def test_suite():
    suite = unittest.TestSuite((
            doctest.DocFileSuite(
                '../README.txt',
                setUp=setUp,
                tearDown=zc.buildout.testing.buildoutTearDown,
                optionflags=optionflags,
                globs=dict(test_dir=test_dir),
                checker=renormalizing.RENormalizing([
                        # If want to clean up the doctest output you
                        # can register additional regexp normalizers
                        # here. The format is a two-tuple with the RE
                        # as the first item and the replacement as the
                        # second item, e.g.
                        # (re.compile('my-[rR]eg[eE]ps'), 'my-regexps')
                        zc.buildout.testing.normalize_path,
                        ]),
                ),
            ))
    return suite

if __name__ == '__main__':
    unittest.main(defaultTest='test_suite')
