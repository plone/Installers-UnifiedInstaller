#!/usr/bin/env python

# $LastChangedDate: 2009-02-12 09:26:46 -0800 (Thu, 12 Feb 2009) $ $LastChangedRevision: 25050 $


import doctest


doctest.testfile("tests.txt", optionflags=doctest.ELLIPSIS or NORMALIZE_WHITESPACE)

print 'Done.'