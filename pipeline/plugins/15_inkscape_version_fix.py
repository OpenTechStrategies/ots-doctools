#!/usr/bin/env python3

"""As inkscape moves to version 1.0, they've changed the command line
options used to do conversions.  We use those to do svg -> pdf.  This
plugin checks the inkscape version number and if needed it adds a bit
of tex to the preamble that uses the correct options.

Note that the interface might change again, so check the
first-referenced link below for updates to the workaround.

References:

  * Latex SVG package bug report on this issue.  It contains the
    workaround.  https://github.com/mrpiggi/svg/issues/21

  * Inkscape issue on removing options breaking 3rd-party tools.
https://gitlab.com/inkscape/inkscape/-/issues/1315

  * Inkscape commit removing -z option. https://gitlab.com/inkscape/inkscape/-/commit/22b30cec074180e6532893443bbd9c6954b9e493

"""

import subprocess
import sys

def run_p(text, meta):
    try:
        version_str = subprocess.check_output(["inkscape", "--version"]).decode("utf-8") 
    except subprocess.CalledProcessError:
        # If we can't figure out the version, stand pat
        return False
    
    if version_str.startswith("Inkscape 1"):
        return True

    # If we aren't sure inkscape version is 1+, don't run.
    return False

def run(text, meta):
    workaround = r"""\usepackage{svg}
\makeatletter
\ifdefined\svg@ink@ver\else
  \def\svg@ink@ver{1}% change version to 0 if necessary
  \renewcommand*\svg@ink@cmd[2]{%
    \svg@ink@exe\space"#1.\svg@file@ext"\space%
    \svg@ink@area\space%
    \ifx\svg@ink@dpi\relax\else--export-dpi=\svg@ink@dpi\space\fi%
    \if@svg@ink@latex--export-latex\space\fi%
    \ifx\svg@ink@opt\@empty\else\svg@ink@opt\space\fi%
    \ifnum\svg@ink@ver<\@ne%
      --export-\svg@ink@format="#2.\svg@ink@format"\space%
    \else%
      --export-type=\svg@ink@format\space%
      --export-filename="#2.\svg@ink@format"\space%
    \fi%
  }%
\fi
\makeatother
"""
    try:
        meta['preambles'].append(workaround)   
    except KeyError:
        meta['preambles'] = [workaround]
    except AttributeError:
        meta['preambles'] = [meta['preambles'], workaround]
        
    return text, meta
