#!/usr/bin/env python3

"""This plugin removes \S*ref:[0-9a-f]\S* from the output in an
attempt to remove oref tags from the text.
"""
import os
import re

def run_p(text, meta):
    return meta.get('cleanrefs', True) != False

def run(text, meta):
    """Remove refs from the text.

    Returns text with a regex substitution and unchanged META."""

    pat = re.compile("\S*ref:[0-9a-f]+\S*")
    text = pat.sub("", text)
    
    return text, meta
