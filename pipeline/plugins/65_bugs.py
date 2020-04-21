#!/usr/bin/env python3

"""This bug-hunting plugin identifies potential problems with the doc
and issues warnings or errors.  It puts those warnings/errors in the
build strings because otherwise they would get lost in the voluminous
pdflatex scroll.

If draft mode is on, we do warnings.  If draft mode is off, the
warnings turn into errors.  If you want to build despite errors, turn
the plugin off (e.g. bugs: False in the YAML).

Current warnings:

 * footnote instead of \footnote

This plugin has tests, which can be run via pytest.  Do `apt install
python3-pytest` and then run `pytest-3`.

"""

import pytest
import re
import sys

def run_p(text, meta):
    ## We don't run if user disabled with `bugs: False` in the doc's
    ## yaml block
    return meta.get('bugs', True) != False

pat = {
    "footnote" : r".*[^\\\s]footnote.*"
    }

pat = {k: re.compile(v) for k,v in pat.items()}

def run(text, meta):
    # Hijack meta['bugs']
    if not 'bugs' in meta or type(meta['bugs']) != type({}):
        meta['bugs'] = {}

    found = False
    for match in pat['footnote'].finditer(text):
        print("Found %s at position %s." % (match.group(), match.start()))
        found = True

    if found and not meta['draft']:
        sys.stderr.write("ERROR: Pipeline found errors in LaTeX.  Stopping build\n")
        sys.stderr.write("       because errors were found and this is not a draft.\n")
        sys.stderr.write("       To have the build continue despite the pipeline errors,\n")
        sys.stderr.write("       either set 'draft' to True or set 'bugs' to False.\n")
        sys.exit(-1)
        
    return text, meta

  
def test_run():

    # Make sure that running in non-draft mode throws errors.
    with pytest.raises(SystemExit) as pytest_wrapped_e:
        run(".footnote", {'draft':False})
    assert pytest_wrapped_e.type == SystemExit
    assert pytest_wrapped_e.value.code == -1

    # Make sure running in draft mode throws warnings, not errors
    run(".footnote", {'draft':True})
    
def test_footnotes():
    """Test that our footnote pattern matches as intended."""

    # We don't want to match these.  None of these are suspicious.
    assert not pat['footnote'].search(r"\footnote")
    assert not pat['footnote'].search(r"footnote")
    assert not pat['footnote'].search(r" footnote")
    assert not pat['footnote'].search(r"I really like footnotes")
    assert not pat['footnote'].search(r"I really like footnotes.\footnote{Really.}")

    # These merit warnings/errors
    assert pat['footnote'].search(r".footnote")
    assert pat['footnote'].search(r"}footnote")
    assert pat['footnote'].search(r"FOOfootnote")
    assert pat['footnote'].search(r"Oops, I messed up the footnote.footnote{I'm a dummy}")
    

if __name__ == "__main__":
    import os
    os.system("pytest-3 %s" % __file__)
