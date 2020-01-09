#!/usr/bin/env python3

import click
import frontmatter
import importlib
import os
import pkgutil
import re
import sys

"""
The 'stage' option is for running this pipeline either pre- or post- latex.
Ex: pipeline.py target.ltx -o stage post
Ex: pipeline.py target.ltx -o stage pre
"""

def err(msg):
    """Yeah, this is an obnoxious error message, but the user will have to
    pick it out of a long scroll of LaTeX and make output.

    """
    sys.stderr.write("BEGIN PIPELINE ERROR MSG\n")
    sys.stderr.write(msg)
    sys.stderr.write("\n")
    sys.stderr.write("END PIPELINE ERROR MSG\n")
    sys.exit(-1)
    
def get_plugins(plugin_dir=None):
    """Load plugins from PLUGIN_DIR and return a dict with the plugin name
    hashed to the imported plugin.

    PLUGIN_DIR is the name of the dir from which to load plugins.  If
    it is None, use the plugin dir in the dir that holds this func.

    We load plugins and run them in asciibetical order.  We ignore
    plugins that begin with a character other than a digit or a
    letter.

    PLUGIN API:

    run_p(text, meta, opt): predicate returns True if this
    plugin thinks it should run in the pipeline.

    run(text, meta, opt): runs the plugin, returns text, meta

    after_p(pdf_fname, meta, opt): predicate returns True if this plugin
    thinks it should run after the pdf is produced.

    after(pdf_fname, meta, opt): runs the plugin, returns meta.  May change the pdf

    """
    if not plugin_dir:
        plugin_dir = os.path.join(
            os.path.dirname(
                os.path.abspath(__file__)), "plugins")

    plugins = {}
    pat = {
        "enabled": r"^[0-9a-zA-Z]",
        "prefix": r"^[0-9]+_",
    }
    pat = {k: re.compile(v) for k,v in pat.items()}

    for fname in sorted(os.listdir(plugin_dir)):
        if (not fname.endswith(".py")
            or fname.startswith('.')
            or '#' in fname
            or not pat['enabled'].match(fname)):
            continue
        spec = importlib.util.spec_from_file_location(fname,
                                                      os.path.join(plugin_dir, fname))
        fname = pat["prefix"].sub("", fname)
        plugins[fname] = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(plugins[fname])
    return plugins

def tuple2dict(tup):
    """TUP is a tuple of 2-tuples.  Return a dict where the first element
    of each tuple hashes to the second.

    """
    ret = {}
    for t in tup:
        ret[t[0]] = t[1]
    return ret
            
@click.command()
@click.argument('filename')
@click.option('--output', help="output filename")
@click.option('--plugin', help="specify just one plugin to run (not implemented)")
@click.option('--option', '-o', nargs=2, multiple=True, default='', help='Variables and their values.')
def cli(filename, output, option, plugin):
    pdf_fname = os.path.splitext(filename)[0]+'.pdf'
    doc = frontmatter.load(filename)
    text = doc.content
    meta = doc.metadata
    if meta=={}:
        meta['legacy'] = "legacy"
    meta['input_filename'] = filename
    meta['output_filename'] = output
    
    # Grab the environment too
    meta['environment'] = dict(os.environ)

    # Pass to jinja any options submitted on the command line
    for o in option:
        meta[o[0]] = o[1]

    # Dict is easier to work with
    option = tuple2dict(option)
    option['stage'] = option.get('stage', 'pre')
    
    plugins = get_plugins()
    for p,m in plugins.items():
        if option['stage'] == 'pre':
            if hasattr(m, "run_p"):
                if m.run_p(text, meta):
                    text, meta = m.run(text, meta)
        elif option['stage'] == 'post':
            if hasattr(m, "after_p"):
                if m.after_p(pdf_fname, meta):
                    meta = m.after(pdf_fname, meta)
        else:
            err("Unknown stage: %s" % option['stage'])

    ## Print the output or write it to a file if we're pre-latex
    if option['stage'] == 'pre':
        if output:
            with open(output, 'w') as fh:
                fh.write(text)
        else:
            print(text)
        
if __name__ == '__main__':
    cli()
