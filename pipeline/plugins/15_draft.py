#!/usr/bin/env python3

"""If we're making a file with 'draft' in the name, enable draft mode"""

def run_p(text, meta):
    return 'draft' in meta['output_filename']

def run(text, meta):
    meta['draft']=True
    return text, meta
