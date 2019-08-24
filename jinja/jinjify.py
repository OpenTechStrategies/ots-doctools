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
import re
import sys

regex = {'sub':r'[^a-zA-Z0-9.,?!]'}
for r in regex:
    regex[r] = re.compile(regex[r])

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

def redact(args, text):
    """Go through the list of strings in 'redacted' YAML field.  Treat
each one as a regex and replace each regex with a LaTeX function that
prints a censored black box.

    """
    if not 'redact' in args:
        return text
    
    ## Make a list of places we should censor, taking care to handle
    ## overlapping matches (we don't want a short match to prevent a
    ## long match that is a superset to not match)
    censor = []
    for pat in args['redacted']:
        pat = pat.replace(r'\ ', '\s*')
        pat = re.compile(pat, re.IGNORECASE)
        for m in pat.finditer(text):
            span = m.span()
            for i in range(len(censor)):
                c = censor[i]
                if (span and
                    span[0] < c[1] and
                    span[1] > c[0]):
                    censor[i] = (min(c[0], span[0]), max(c[1], span[1]))
                    span = None
            if span:
                censor.append(span)

    # Replace any matches with censored X boxes
    censor = sorted(censor)
    retext = ""
    last = 0
    for c in censor:
        retext += text[last:c[0]] + r"\censor{XXXX}"
        last = c[1]
    text = retext + text[last:]

    
    # Don't censor in the acronym definition section.  It breaks
    # LaTeX.  Just remove the line instead.
    state = None
    lines = text.split("\n")
    for l in range(len(lines)):
        line = lines[l].strip()
        if "Legacy" in line:
            print(line)
        if line.startswith("\\begin{acronym}"):
            state = "in acronyms"
        elif state == "in acronyms" and "\\censor{" in line:
                lines[l] = ""
        elif line.startswith("\end{acronym}"):
            state = "done"
    text = "\n".join(lines)
    
    return text

@click.command()
@click.argument('filename')
@click.option('--option', '-o', nargs=2, multiple=True, default='', help='Variables and their values.')
@click.option('--output')
#@click.option('--redact', 'redacted', flag_value=True, default=False)
def jinjify(filename, option, output):
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
    rendered = redact(args, rendered)

    if output:
        with open(output, 'w') as fh:
            fh.write(rendered)
    else:
        print(rendered)
if __name__ == '__main__':
    jinjify()
