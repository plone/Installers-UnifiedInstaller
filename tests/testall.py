#!/usr/bin/env python

import doctest

doctest.testfile("tests.txt", optionflags=doctest.ELLIPSIS or doctest.NORMALIZE_WHITESPACE)

print 'Done.'
