#!/usr/bin/env python3

"""This script takes two parameters.  The first is a latex file with
yaml frontmatter.  The body after the frontmatter is latex use as a
jinja2 template.  We pass the yaml frontmatter to that jinja2 template
and print the results.

"""
import os

# Search path for Jinja templates, in order of preference
TEMPLATE_DIRS = [ os.path.abspath(os.getcwd()),
                  os.path.join(os.getenv('OTSDIR'), 'forms', 'jinja'),
                  os.path.join(os.getenv('OTSDIR'), 'forms', 'latex'),
                  os.path.join(os.getenv('OTS_DOCTOOLS_DIR'), 'jinja'),
                  os.path.join(os.getenv('OTS_DOCTOOLS_DIR'), 'latex')]

import click
import frontmatter
import jinja2
import subprocess
import sys

# We're not using this func right now, but I do want to add markdown
# support back in later, once I've figure out how to fit it in
# appropriately.
def md2tex(string):
    """Pass markdown STRING through pandoc and return the resulting latex"""
    p = subprocess.Popen("pandoc -f markdown -t latex",
                         shell=True,
                         stdout=subprocess.PIPE,
                         stdin=subprocess.PIPE,
                         stderr=subprocess.PIPE
    )
    return p.communicate(input=string.encode('UTF-8'))[0].decode('UTF-8') 

@click.command()
@click.argument('filename')
@click.option('--option', '-o', nargs=2, multiple=True, default='', help='Variables and their values.')
def jinjify(filename, option):
    """Read and parse yaml+latex file."""
    doc = frontmatter.load(filename)
    template = doc.content # treat latex as a jinja2 template
    args = doc.metadata    # treat yaml frontmatter as jinja2 arguments

    # Pass the environment in as a var
    args['environment'] = os.environ

    # Pass to jinja any options submitted on the command line
    for o in option:
        args[o[0]] = o[1]
        
    # Make a version of a Jinja2 parser that plays nice with LaTeX
    latex_jinja_env = jinja2.Environment(
            block_start_string = '\BLOCK{',
            block_end_string = '}',
            variable_start_string = '\VAR{',
            variable_end_string = '}',
            comment_start_string = '\#{',
            comment_end_string = '}',
            line_statement_prefix = '%%',
            line_comment_prefix = '%#',
            trim_blocks = True,
            autoescape = False,
            loader = jinja2.ChoiceLoader([
                jinja2.FileSystemLoader(TEMPLATE_DIRS),
                jinja2.DictLoader({'jinjify_me.ltx':template,
                                'proposal.ltx':'test'}),
            ])
        )

    template = latex_jinja_env.get_template('jinjify_me.ltx')

    # Quick example of calling a python func from our template. Evoke with
    # \VAR{testfunc()}
    #def testfunc():
    #    return u'TEST'
    #template.globals.update(testfunc=testfunc)

    rendered = template.render(**args)
    print(rendered)
if __name__ == '__main__':
    jinjify()
