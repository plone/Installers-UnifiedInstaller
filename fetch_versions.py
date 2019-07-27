#!/usr/bin/env python
# encoding: utf-8

# Download Plone version files, following extends as necessary.
# e.g.,
# fetch_versions.py 5.2.0

import re
import sys

from six.moves import urllib

try:
    version = sys.argv[1]
except IndexError:
    print("Usage: fetch_versions version_#")
    sys.exit(1)

extends_pattern = re.compile(r"^extends\s*?=\W*(.+?)\s*$", re.MULTILINE + re.DOTALL)


def getURL(url, munge=True):

    def fn_fix(s):
        return u'-'.join(s.split(u'/')[1:])

    def ereplace(mo):
        found = mo.group(1)
        new_url = urllib.parse.urljoin(url, found)
        getURL(new_url)
        path = urllib.parse.urlparse(new_url).path
        return u'\nextends = {}\n'.format(fn_fix(path))

    # https only
    url = re.sub(r"^http:", u"https:", url)

    fh = urllib.request.urlopen(url)
    content = fh.read().decode('utf-8')
    fh.close()

    if munge:
        content = extends_pattern.sub(ereplace, content)
        fn = fn_fix(urllib.parse.urlparse(url).path)
    else:
        fn = urllib.parse.urlparse(url).path.split(u'/')[-1]
    with open(fn, 'w') as file:
        file.write(content)
    print(fn)


getURL(u'https://dist.plone.org/release/{0}/requirements.txt'.format(version), False)
getURL(u'https://dist.plone.org/release/{0}/versions.cfg'.format(version))
