#!/usr/bin/env python
# encoding: utf-8

import os.path
import re
import sys
import urllib2
import urlparse

try:
    version = sys.argv[1]
except IndexError:
    print "Usage: fetch_versions version_#"
    sys.exit(1)

extends_pattern = re.compile(r"(^extends\s*?=\s*http.+?^\S)", re.MULTILINE + re.DOTALL)
url_pattern = re.compile(r"(http\S+)")


def getURL(url):

    def ureplace(mo):
        found = mo.group(0)
        getURL(found)
        path = urlparse.urlparse(found).path
        return os.path.basename(path)

    def ereplace(mo):
        found = mo.group(0)
        return url_pattern.sub(ureplace, found)

    # https only
    url = re.sub(r"^http:", "https:", url)

    fh = urllib2.urlopen(url)
    content = fh.read()
    fh.close()

    content = extends_pattern.sub(ereplace, content)
    fn = os.path.basename(urlparse.urlparse(url).path)
    with open(fn, 'w') as file:
        file.write(content)
    print fn


starting_url = 'https://dist.plone.org/release/{0}/versions.cfg'.format(version)
getURL(starting_url)
