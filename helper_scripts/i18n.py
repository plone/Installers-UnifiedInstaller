# -*- coding: utf-8 -*-

import gettext
import os

APP_NAME = "installer"
DEFAULT_LANGUAGE = "en"

APP_DIR = os.path.dirname(__file__)
LOCALE_DIR = os.path.join(APP_DIR, "locales")

languages = os.environ.get("LANG", "").split(":") + [DEFAULT_LANGUAGE]

language = gettext.translation(
    APP_NAME, LOCALE_DIR, languages=languages, fallback=True, codeset="UTF-8"
)

_ = language.gettext


def _print(s):
    print(_(s))
