#!/usr/bin/env python


import doctest

doctest.ELLIPSIS_MARKER = '-etc-'
doctest.testfile("tests.txt", optionflags=doctest.ELLIPSIS or doctest.NORMALIZE_WHITESPACE)

print 'Done.'
