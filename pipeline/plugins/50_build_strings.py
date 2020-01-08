#!/usr/bin/env python3

"""This plugin is designed to be run at the post-processing stage.

If checks meta for a a list of vars to save under the key 'build_strings'.
It then assembles those vars and their values into a list, adds info
(e.g. SVN revision of the doc and git commit of the doctools repo),
renders it in YAML, appends '%' to each line, and sticks that in the
PDF
"""

import os
import pprint
pp = pprint.PrettyPrinter(indent=4)
import subprocess
from yaml import dump, load

def after_p(text, meta):
    """Even if there are no save_vars, we will add some standard info
    about the build, so user can turn it off with 'save_var: False'

    """
    return meta.get('build_strings', '[]') != False

def bslurp(fname):
    with open(fname, 'rb') as fh:
        return fh.read()

def after(pdf_fname, meta):
    pdf = bslurp(pdf_fname)
    saved = meta.get('build_stringss', [])

    ## Go through saved vars and default vars, saving some and munging
    ## as needed.
    out = {}
    get_rev = os.path.join(
        os.path.split(os.path.split(os.path.split(__file__)[0])[0])[0],
        "get_revision")
    out['ots_svn'] = subprocess.check_output(get_rev, shell=True).decode("utf-8").strip()
    out['doctools_git_id'] = subprocess.check_output(
        r"cd %s; git log -n 1 | head -n 1 | sed -re 's/(commit [0-9a-f]*) .*/\1/'" % os.path.split(__file__)[0],        
        shell=True).decode("utf-8").strip()
    out['doctools_git_branch'] = subprocess.check_output(
        r"cd %s; git branch | grep '\*'" % os.path.split(__file__)[0],
        shell=True).decode("utf-8")[1:].strip()

    ## grab the indicated vars
    for s in saved:
        out[s] = meta[s]

    ## munge vars, wherever they come from    
    out['client'] = meta.get('client', "")
    if out['client'].startswith(r"\ac{"):
        out['client'] = out['client'][4:-1]
    out['date'] = meta.get('date', "")
    out['title'] = meta.get('title', "").replace(r'\\', "\n")
    out['draft'] = meta.get('draft', False)
    out['input_filename'] = meta.get('input_filename', "")
    if os.path.exists(out['input_filename']):
        out['input_filename'] = os.path.abspath(out['input_filename'])

    ## Reformat as a commented-out YAML block
    out = (
        "%%% BEGIN OTS YAML BLOCK %%%\n" +
        "% " + "\n% ".join(dump(out).split("\n"))[:-2] +
        "%%% END OTS YAML BLOCK %%%\n"
    )

    # Append our block as a set of comments to the PDF.  The '%' at
    # the start of each line is PDF syntax for "comment" and should
    # mean that the lines get ignored.  I am a little uneasy that some
    # PDF renderers are unable to handle comments at the end of the
    # file, just because PDF renderers really range in quality.
    #
    # PDFs built by pdflatex have %%EOF at the end, and I have no
    # reason to think that's a magic comment, but who knows if some
    # reader out there will treat it as such and throw an error if you
    # add material beyond it.  I think we're ok, but...
    with open(pdf_fname, 'ab') as fh:
        fh.write(bytes(out.encode("utf-8")))

    # We do this because if it throws an error, we want to know now
    pp.pprint(extract_ots_yaml(pdf_fname))

    return meta
    
def extract_ots_yaml(pdf_fname):
    pdf = bslurp(pdf_fname)
    stoken = b"%%% BEGIN OTS YAML BLOCK %%%\n"
    etoken = b"%%% END OTS YAML BLOCK %%%\n"
    if not (stoken in pdf and etoken in pdf):
        return []

    # Throw away the PDF material, leaving just stuff at the end
    pdf = pdf.split(stoken)[-1]
    pdf = pdf.split(etoken)[0]

    # We cannot decode earlier because we have no idea what encodings
    # might be in in the actual PDF body.  Could be dragons, could be
    # the edge of the world.
    comment_block = pdf.decode("utf-8")[2:].replace("\n% ", "\n").strip()

    # Parse the decoded text as yaml and return
    return load(comment_block)
    
