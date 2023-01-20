#!/usr/bin/env python3

"""Remove refs (see below) from the output if YAML vars say to do so.
This is so we can ref and deref without it showing in the final doc.

In the YAML head of the doc, you must set 'remove-refs' to TRUE to
have refs removed.  By default, we remove "ref:[0-9a-f]+" and any
surrounding parentheses and brackets.  However, if you also set
'ref-regex' to some regular expression string, that regex is used
instead of the default.

The reference system this plugin works with is 'oref', available here:
https://code.librehq.com/ots/ots-tools/-/blob/main/emacs-tools/oref.el

"""

import os
import re

def run_p(text, meta):
    return meta.get('cleanrefs', True) != False

def run(text, meta):
    """Remove refs from the text if META["remove-refs"] is True.
    If META["ref-regex"] is also present, use that regular expression
    to match refs instead of the default regular expression.
    Returns text with a regex substitution and unchanged META."""

    if meta.get("remove-refs", None) is True:
        custom_re = meta.get("ref-regex", None)
        if custom_re is not None:
            pat = re.compile(custom_re)
        else:
            pat = re.compile("[[(]*ref:[0-9a-f]+[])]*")
        text = pat.sub("", text)
    
    return text, meta
