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
if os.getenv('OTS_DIR') is not None:
    # OTS folks have the OTS_DIR env var set too; use it if available.
    TEMPLATE_DIRS += [
                  os.path.join(os.getenv('OTS_DIR'), 'forms', 'jinja'),
                  os.path.join(os.getenv('OTS_DIR'), 'forms', 'latex')]

regex = {'sub':r'[^a-zA-Z0-9.,?!]'}
for r in regex:
    regex[r] = re.compile(regex[r])

def run_p(text, meta):
    return meta.get('legacy', '') != "legacy"

def after_p(text, meta):
    return True

def slurp_lines(fspec):
    with open(fspec) as fh:
        return fh.read().strip().split("\n")

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

class TodoManager():
    def __init__(self, fname="todo.txt"):
        self.fname = fname
        if os.path.exists(fname):
            self.lines = slurp_lines(fname)
        else:
            self.lines = []

        # We'll compare against this later to see if our lines changed
        self.new_lines = []

    def latex(self):
        if not self.lines:
            return ""
        ret = (r"\notocsection{{\color{red} TODOS}}"
               + "\\begin{itemize}\n\\item "
               + "\n\\item ".join(self.lines)
               + "\n\\end{itemize}")
        return ret

    def write(self):
        """Write our new todo lines, return True if they've changed"""
        if "\n".join(self.lines) != "\n".join(self.new_lines):
            self.lines = self.new_lines
            with open(self.fname, 'w') as fh:
                fh.write("\n".join(self.new_lines))
                fh.write("\n")
            return True
        return False

def latexify(text):
    """Transform text into something that won't break latex.

    This is a somewhat naive function."""

    text = text.replace("_", r"\_")
    return text

def url(text):
    return(r"\otsurl{" + latexify(text) + "}")

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

    tman = TodoManager()
    def todo(text):
        """Record a todo and return approprate latex to display the todo.

        Evoke with \VAR{todo()}"""

        tman.new_lines.append(text.replace("\n"," "))
        return f'\\textbf{{TODO}}: {text}'
    template.globals.update(todo=todo) # register jinja hook for todo func
    template.globals.update(url=url) # register jinja hook for todo func


    # Render repeatedly until we no longer need to rerender
    rejinjify = False
    while True:
        template.globals.update(todos = tman.latex())
        rendered = template.render(**meta)
        rejinjify = tman.write()
        if not rejinjify:
            break

    return rendered, meta

def after(pdf_fname, meta):
    tman = TodoManager()
    meta['todos'] = tman.lines
    meta['build_strings'] = meta.get('build_strings', [])
    meta['build_strings'].append('todos')
    return meta
