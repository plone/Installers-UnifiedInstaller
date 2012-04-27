# -*- coding: utf-8 -*-
"""Recipe staticlxml"""

import os
import sys
import logging
import tempfile
import platform
import pkg_resources

from fnmatch import fnmatch

from distutils import sysconfig

from zc.buildout import UserError

from zc.recipe.egg.custom import Custom

import zc.recipe.cmmi


# http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2011-3919
# http://people.canonical.com/~ubuntu-security/cve/2011/CVE-2011-3919.html
# http://git.gnome.org/browse/libxml2/commit/?id=5bd3c061823a8499b27422aee04ea20aae24f03e
patch_cve_2011_3919 = """diff --git a/parser.c b/parser.c
index 4e5dcb9..c55e41d 100644
--- a/parser.c
+++ b/parser.c
@@ -2709,7 +2709,7 @@ xmlStringLenDecodeEntities(xmlParserCtxtPtr ctxt, const xmlChar *str, int len,
 
 		buffer[nbchars++] = '&';
 		if (nbchars > buffer_size - i - XML_PARSER_BUFFER_SIZE) {
-		    growBuffer(buffer, XML_PARSER_BUFFER_SIZE);
+		    growBuffer(buffer, i + XML_PARSER_BUFFER_SIZE);
 		}
 		for (;i > 0;i--)
 		    buffer[nbchars++] = *cur++;
"""


def which(fname, path=None):
    """Return first matching binary in path or os.environ["PATH"]
    """
    if path is None:
        path = os.environ.get("PATH")
    fullpath = filter(os.path.isdir,path.split(os.pathsep))

    if '.' not in fullpath:
        fullpath = ['.'] + fullpath
    fn = fname
    for p in fullpath:
        for f in os.listdir(p):
            head, ext = os.path.splitext(f)
            if f == fn or fnmatch(head, fn):
                return os.path.join(p,f)
    return None


class Recipe(object):
    """zc.buildout recipe"""

    def __init__(self, buildout, name, options):
        self.buildout, self.name, self.options = buildout, name, options
        self.logger = logging.getLogger(name)

        # force build option
        force = options.get("force")
        self.force = force in ("true", "True")
        options["force"] = force and "true" or "false"

        # XLST build or location option
        build_xslt = options.get("build-libxslt", "true")
        self.build_xslt = build_xslt in ("true", "True")
        options["build-libxslt"] = build_xslt and "true" or "false"

        if not self.build_xslt:
            self.xslt_location = options.get("xslt-location")
            if not self.xslt_location:
                raise UserError("You must either configure ``xslt-location`` or set"
                        " ``build-libxslt`` to ``true``")

        # XML2 build or location option
        build_xml2 = options.get("build-libxml2", "true")
        self.build_xml2 = build_xml2 in ("true", "True")
        options["build-libxml2"] = build_xml2 and "true" or "false"

        if not self.build_xml2:
            self.xml2_location = options.get("xml2-location")
            if not self.xml2_location:
                raise UserError("You must either configure ``xml2-location`` or set"
                        " ``build-libxml2`` to ``true``")

        # static build option
        static_build = options.get("static-build", "darwin" in sys.platform and "true" or None)
        self.static_build = static_build in ("true", "True")
        if self.static_build and not (self.build_xml2 and self.build_xslt):
            raise UserError("Static build is only possible if both "
                    "``build-libxml2`` and ``build-libxslt`` are ``true``.")
        if self.static_build:
            self.logger.info("Static build requested.")
        options["static-build"] = self.static_build and "true" or "false"

        # our location
        location = options.get(
            'location', buildout['buildout']['parts-directory'])
        options['location'] = os.path.join(location, name)

    def build_libxslt(self):
        self.logger.info("CMMI libxslt ...")
        versions = self.buildout.get(self.buildout['buildout'].get('versions', '__invalid__'), {})
        self.options["libxslt-url"] = self.xslt_url = self.options.get("libxslt-url",
                versions.get("libxslt-url", "http://xmlsoft.org/sources/libxslt-1.1.26.tar.gz"))
        self.logger.info("Using libxslt download url %s" % self.xslt_url)

        options = self.options.copy()
        options["url"] = self.xslt_url
        options["extra_options"] = "--with-libxml-prefix=%s --without-python --without-crypto" % self.xml2_location
        # ^^^ crypto is off as libgcrypt can lead to problems on especially osx and also on some linux machines.
        if platform.machine() == 'x86_64':
            options["extra_options"] += ' --with-pic'
        self.xslt_cmmi = zc.recipe.cmmi.Recipe(self.buildout, "libxslt", options)

        if os.path.exists(os.path.join(self.xslt_cmmi.options["location"], "bin", "xslt-config")):
            self.logger.info("Skipping build of libxslt: already there")
            loc = self.xslt_cmmi.options.get("location")
        else:
            loc = self.xslt_cmmi.install()

        self.options["xslt-location"] = self.xslt_location = loc

    def make_cve_2011_3919_patch(self):
        """make_cve_2011_3919_patch() -> path to patch file
        
        Write patch file, return path.
        """
        fd, path = tempfile.mkstemp(suffix=".patch")
        f = os.fdopen(fd, "w")
        f.write(patch_cve_2011_3919)
        f.close()
        return path
        

    def build_libxml2(self):
        self.logger.info("CMMI libxml2 ...")
        versions = self.buildout.get(self.buildout['buildout'].get('versions', '__invalid__'), {})
        self.options["libxml2-url"] = self.xml2_url = self.options.get("libxml2-url",
                versions.get("libxml2-url", "http://xmlsoft.org/sources/libxml2-2.7.8.tar.gz"))
        self.logger.info("Using libxml2 download url %s" % self.xml2_url)

        options = self.options.copy()
        options["url"] = self.xml2_url
        options["patch"] = self.make_cve_2011_3919_patch()
        options["patch_options"] = "-p1"
        options["extra_options"] = "--without-python"
        if platform.machine() == 'x86_64':
            options["extra_options"] += ' --with-pic'
        self.xml2_cmmi = zc.recipe.cmmi.Recipe(self.buildout, "libxml2", options)

        if not self.force and os.path.exists(os.path.join(self.xml2_cmmi.options["location"], "bin", "xml2-config")):
            self.logger.info("Skipping build of libxml2: already there")
            loc = self.xml2_cmmi.options["location"]
        else:
            loc = self.xml2_cmmi.install()
        self.options["xml2-location"] = self.xml2_location = loc

    def update(self):
        pass

    def install(self):
        options = self.options
        install_location = self.buildout['buildout']['eggs-directory']

        if not os.path.exists(options['location']):
            os.mkdir(options['location'])

        # Only do expensive download/compilation when there's no existing egg.
        path = [install_location]
        req_string = self.options['egg'] # 'lxml' or 'lxml == 2.0.9'
        version_part = self.buildout['buildout'].get('versions')
        if version_part:
            version_req = self.buildout[version_part].get('lxml')
            if version_req:
                # [versions] wins and is often the place where it is specified.
                req_string = 'lxml == %s' % version_req
        req = pkg_resources.Requirement.parse(req_string)
        matching_dists = [d for d in pkg_resources.Environment(path)['lxml']
                          if d in req]
        if matching_dists and not self.force:
            # We have found existing lxml eggs that match our requirements.
            # If we specified an exact version, we'll trust that the matched
            # egg is good. We don't currently accept matches for not-pinned
            # versions as that would mean lots of code duplication with
            # easy_install (handling newest=t/f and so).
            specs = req.specs
            if len(specs) == 1 and specs[0][0] == '==':
                self.logger.info("Using existing %s. Delete it if that one "
                                 "isn't statically compiled.",
                                 matching_dists[0].location)
                return ()

        # build dependent libs if requested
        if self.build_xml2:
            self.build_libxml2()
        else:
            self.logger.warn("Using configured libxml2 at %s" % self.xml2_location)

        if self.build_xslt:
            self.build_libxslt()
        else:
            self.logger.warn("Using configured libxslt at %s" % self.xslt_location)

        # get the config executables
        self.get_configs( os.path.join(self.xml2_location, "bin"), os.path.join(self.xslt_location, "bin"))

        if self.static_build:
            self.remove_dynamic_libs(self.xslt_location)
            self.remove_dynamic_libs(self.xml2_location)

        # build LXML
        dest = options.get("location")
        if not os.path.exists(dest):
            os.mkdir(dest)

        options["include-dirs"] = '\n'.join([
            os.path.join(self.xml2_location, "include", "libxml2"),
            os.path.join(self.xslt_location, "include")])
        options["library-dirs"] = '\n'.join([
                os.path.join(self.xml2_location, "lib"),
                os.path.join(self.xslt_location, "lib")])
        options["rpath"] = '\n'.join([
                os.path.join(self.xml2_location, "lib"),
                os.path.join(self.xslt_location, "lib")])

        if "darwin" in sys.platform:
            self.logger.warn("Adding ``iconv`` to libs due to a lxml setup bug.")
            options["libraries"] = "iconv"

        self.lxml_custom = Custom(self.buildout, self.name, self.options)
        self.lxml_custom.environment = self.lxml_build_env()
        self.lxml_custom.options["_d"] = install_location

        self.logger.info("Building lxml ...")
        self.lxml_dest = self.lxml_custom.install()

        return ()

    def get_ldshared(self):
        LDSHARED = sysconfig.get_config_vars().get("LDSHARED")
        self.logger.debug("LDSHARED=%s" % LDSHARED)
        if "darwin" in sys.platform:
            self.logger.warn("OS X detected.")
            # remove macports "-L/opt/local/lib"
            if "-L/opt/local/lib" in LDSHARED:
                self.logger.warn("*** Removing '-L/opt/local/lib' from 'LDSHARED'")
                LDSHARED = LDSHARED.replace("-L/opt/local/lib", "")
            if self.static_build:
                self.logger.info("Static build -- adding '-Wl,-search_paths_first'")
                LDSHARED = LDSHARED + " -Wl,-search_paths_first "
        self.logger.debug("LDSHARED'=%s" % LDSHARED)
        return LDSHARED

    def remove_dynamic_libs(self, path):
        self.logger.info("Removing dynamic libs from path %s ..." % path)
        soext = "so"

        if "darwin" in sys.platform:
            soext = "dylib"

        path = os.path.join(path, "lib")

        for fname in os.listdir(path):
            if fname.endswith(soext):
                os.unlink(os.path.join(path, fname))
                self.logger.debug("removing %s" % fname)

    def get_configs(self, xml2_location=None, xslt_location=None):
        """Get the executables for libxml2 and libxslt configuration

        If not configured, then try to get them from a built location.
        If the location is not given, then search os.environ["PATH"] and
        warn the user about that.
        """
        self.xslt_config = self.options.get("xslt-config")
        if not self.xslt_config:
            self.xslt_config = which("xslt-config", xslt_location)
            if not self.xslt_config:
                raise UserError("No ``xslt-config`` binary configured and none found in path.")
            self.logger.warn("Using xslt-config found in %s." % self.xslt_config)

        self.xml2_config = self.options.get("xml2-config")
        if not self.xml2_config:
            self.xml2_config = which("xml2-config", xml2_location)
            if not self.xml2_config:
                raise UserError("No ``xml2-config`` binary configured and none found in path.")
            self.logger.warn("Using xml2-config found in %s." % self.xml2_config)

        self.logger.debug("xslt-config: %s" % self.xslt_config)
        self.logger.debug("xml2-config: %s" % self.xml2_config)

    update = install

    def lxml_build_env(self):
        return dict(
                XSLT_CONFIG=self.xslt_config,
                XML_CONFIG=self.xml2_config,
                LDSHARED=self.get_ldshared())

# vim: set ft=python ts=4 sw=4 expandtab :
