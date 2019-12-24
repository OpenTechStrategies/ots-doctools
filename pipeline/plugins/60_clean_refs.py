#!/usr/bin/env python3

"""This plugin removes refs from the output so we can ref and deref
without it showing in the final doc.

By default, we remove ref:[0-9a-f]+ with surrounding parentheses and
brackets.  You can set ref_regex in the YAML head of the doc to
override.

"""
import os
import re

def run_p(text, meta):
    return meta.get('cleanrefs', True) != False

def run(text, meta):
    """Remove refs from the text.

    Returns text with a regex substitution and unchanged META."""

    pat = re.compile(meta.get("ref_regex", "[[(]*ref:[0-9a-f]+[])]*"))
    text = pat.sub("", text)
    
    return text, meta
