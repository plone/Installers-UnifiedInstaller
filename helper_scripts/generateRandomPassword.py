##############################################################################
#
# Copyright (c) 2001,2002 Zope Corporation and Contributors.
# All Rights Reserved.
#
# This software is subject to the provisions of the Zope Public License,
# Version 2.0 (ZPL).  A copy of the ZPL should accompany this distribution.
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY AND ALL EXPRESS OR IMPLIED
# WARRANTIES ARE DISCLAIMED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF TITLE, MERCHANTABILITY, AGAINST INFRINGEMENT, AND FITNESS
# FOR A PARTICULAR PURPOSE
#
##############################################################################

# This code is based on zpasswd.py in Zope 2.6.2.
#
# It creates a random cleartext password that can be fed into
# mkzopeinstance.py in Zope 2.7
#
# $LastChangedDate: 2008-08-03 10:21:34 -0700 (Sun, 03 Aug 2008) $ $LastChangedRevision: 21978 $


import random

pw_choices = ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"
              "abcdefghijklmnopqrstuvwxyz"
              "0123456789")
pw = ''
for i in range(8):
    pw = pw + random.choice(pw_choices)

print pw
