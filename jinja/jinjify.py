#!/usr/bin/env python3

"""This plugin provides a RUN function.  It takes two parameters.  The
first is the latex source and the second is the metadata from the yaml
frontmatter.  We pass the yaml frontmatter to that jinja2 template and
print the results and the unchanged metadata.

TODO: get the commit ID and timestamp of the current revision.  Then,
insert it into the pdf as a comment somewhere that can be extracted.
It would be good if PDFs were internally identified with svn revision
and ots-doctools commit id.  One could then in theory reconstruct the
state of the world for any doc.  Maybe we could even test buildability
for anything in the sent dir.

"""
import os
import jinja2
import subprocess
import re
import sys

# Search path for Jinja templates, in order of preference
TEMPLATE_DIRS = [ os.path.abspath(os.getcwd()),
                  os.path.join(os.getenv('OTS_DOCTOOLS_DIR'), 'jinja'),
                  os.path.join(os.getenv('OTS_DOCTOOLS_DIR'), 'latex')]
if os.getenv('OTSDIR') is not None:
    # OTS folks have the OTSDIR env var set too; use it if available.
    TEMPLATE_DIRS += [
                  os.path.join(os.getenv('OTSDIR'), 'forms', 'jinja'),
                  os.path.join(os.getenv('OTSDIR'), 'forms', 'latex')]

regex = {'sub':r'[^a-zA-Z0-9.,?!]'}
for r in regex:
    regex[r] = re.compile(regex[r])

def run_p(text, meta):
    return meta.get('legacy', '') != "legacy"


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

def run(text, meta):
    """Apply jinja templates to TEXT, using metadata from dict META.
    Returns rendered text and unchanged META."""
    
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
                jinja2.DictLoader({'jinjify_me.ltx':text,
                                'proposal.ltx':'test'}),
            ])
        )
    
    template = latex_jinja_env.get_template('jinjify_me.ltx')
    
    # Quick example of calling a python func from our template. Evoke with
    # \VAR{testfunc()}
    #def testfunc():
    #    return u'TEST'
    #template.globals.update(testfunc=testfunc)

    return template.render(**meta), meta
