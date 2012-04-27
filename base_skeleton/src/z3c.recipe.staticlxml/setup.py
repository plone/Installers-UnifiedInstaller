# -*- coding: utf-8 -*-
"""
This module contains the tool of z3c.recipe.staticlxml
"""
import os
from setuptools import setup, find_packages

def read(*rnames):
    return open(os.path.join(os.path.dirname(__file__), *rnames)).read()

version = '0.9dev'

long_description = (
    read('README.rst')
    + '\n' +
    'Detailed Documentation\n'
    '**********************\n'
    + '\n' +
    read('src', 'z3c', 'recipe', 'staticlxml', 'README.txt')
    + '\n' +
    'Contributors\n' 
    '************\n'
    + '\n' +
    read('CONTRIBUTORS.txt')
    + '\n' +
    'Change history\n'
    '**************\n'
    + '\n' + 
    read('CHANGES.txt')
    + '\n' +
    'Download\n'
    '********\n'
    )
entry_point = 'z3c.recipe.staticlxml:Recipe'
entry_points = {"zc.buildout": ["default = %s" % entry_point]}

tests_require=['zope.testing', 'zc.buildout', 'zc.recipe.egg', 'zc.recipe.cmmi']

setup(name='z3c.recipe.staticlxml',
      version=version,
      description="A recipe to build lxml",
      long_description=long_description,
      classifiers=[
        'Framework :: Buildout',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'License :: OSI Approved :: Zope Public License',
        ],
      keywords='buildout recipe lxml static',
      author='Stefan Eletzhofer',
      author_email='se@nexiles.de',
      url='http://svn.zope.org/z3c.recipe.staticlxml/trunk',
      license='ZPL',
      packages=find_packages('src', exclude=['ez_setup']),
      package_dir = {'': 'src'},
      namespace_packages=['z3c', 'z3c.recipe'],
      include_package_data=True,
      zip_safe=False,
      install_requires=['setuptools',
                        'zc.buildout',
                        'zc.recipe.egg',
                        'zc.recipe.cmmi'
                        # -*- Extra requirements: -*-
                        ],
      tests_require=tests_require,
      extras_require=dict(tests=tests_require),
      test_suite = 'z3c.recipe.staticlxml.tests.test_docs.test_suite',
      entry_points=entry_points,
      )
