#!/usr/bin/env python



import doctest


doctest.testfile("tests.txt", optionflags=doctest.ELLIPSIS or NORMALIZE_WHITESPACE)

print 'Done.'