#!/usr/bin/env python3

""" If we're making a file with 'redacted' in the filename, do redactions."""

import re

def redact(text, meta):
    """Go through the list of strings in 'redacted' YAML field of dict
META.  Treat each one as a regex and replace each regex in string TEXT
with a LaTeX function that prints a censored black box.

    """
    
    if not 'redacted' in meta:
        return text, meta
    
    ## Make a list of places we should censor, taking care to handle
    ## overlapping matches (we don't want a short match to prevent a
    ## long match that is a superset to not match)
    censor = []
    for pat in meta['redacted']:
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
    
    return text, meta

def run_p(text, meta):
    return 'redacted' in meta['output_filename']

def run(text, meta):
    text, meta = redact(text, meta)
    return text, meta
