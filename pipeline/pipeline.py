#!/usr/bin/env python3

import click
import frontmatter
import importlib
import os
import pkgutil
import sys


def get_plugins(plugin_dir=None):
    """Load plugins from PLUGIN_DIR and return a dict with the plugin name
    hashed to the imported plugin.

    PLUGIN_DIR is the name of the dir from which to load plugins.  If
    it is None, use the plugin dir in the dir that holds this func.

    Plugins are loaded and run in asciibetical order.

    PLUGIN API:

    run_p(text, meta): (required) predicate returns True if this
    plugin thinks it should run in the pipeline.

    run(text, meta): (required) runs the plugin, returns text, meta

    """
    if not plugin_dir:
        plugin_dir = os.path.join(
            os.path.dirname(
                os.path.abspath(__file__)), "plugins")

    plugins = {}
    for fname in sorted(os.listdir(plugin_dir)):
        if (not fname.endswith(".py")
            or fname.startswith('.')
            or '#' in fname):
            continue
        spec = importlib.util.spec_from_file_location(fname,
                                                      os.path.join(plugin_dir, fname)
                                                      )
        plugins[fname] = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(plugins[fname])
    return plugins

@click.command()
@click.argument('filename')
@click.option('--output', help="output filename")
@click.option('--plugin', help="specify just one plugin to run (not implemented)")
@click.option('--option', '-o', nargs=2, multiple=True, default='', help='Variables and their values.')
def cli(filename, output, option, plugin):
    doc = frontmatter.load(filename)
    text = doc.content
    meta = doc.metadata
    if meta=={}:
        meta['legacy'] = "legacy"
    meta['input_filename'] = filename
    meta['output_filename'] = output
    
    # Grab the environment too
    meta['environment'] = os.environ

    # Pass to jinja any options submitted on the command line
    for o in option:
        meta[o[0]] = o[1]

    plugins = get_plugins()
    for p,m in plugins.items():
        if hasattr(m, "run_p"):
            if m.run_p(text, meta):
                text, meta = m.run(text, meta)
           
    if output:
        with open(output, 'w') as fh:
            fh.write(text)
    else:
        print(text)
        
if __name__ == '__main__':
    cli()
