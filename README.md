# Open Tech Strategies's Document Infrastructure

This is Open Tech Strategies' infrastructure for building our
published documents from their source files.  Most of the documents
are written in LaTeX, though we sometimes use other formats too.

The expected audience is people who want to work with the source text
of our published reports.  If you have the source repository for a given
report, and you have this infrastructure, you should be able to re-create the
published report (usually a PDF).  Please
[let us know](https://github.com/OpenTechStrategies/ots-doctools/issues/new) 
if you have difficulty doing so.  We always welcome suggestions for 
improving this infrastructure.

## Installation

* Install the system software prerequisites.

  Make sure `pdflatex` and `latexmk` are installed on your system
  already.

* Set up the **`OTS_DOCTOOLS_DIR`** environment variable.

  Set the environment variable OTS_DOCTOOLS_DIR to point to the
  directory where you have this source tree checked out.  For example,
  put something like this in your `~/.bashrc`:

        OTS_DOCTOOLS_DIR=${HOME}/src/ots-doctools
        export OTS_DOCTOOLS_DIR

* Set up the **`TEXMFHOME`** environment variable.

  Set the TEXMFHOME variable so that that kpathsea can find `latex/*`
  in this directory.  For example, put

        TEXMFHOME=${HOME}/texmf
        export TEXMFHOME

  in your `~/.bashrc`, and make sure that `~/texmf/tex/latex/ots` is a
  symlink to `${OTS_DOCTOOLS_DIR}/latex`.  (Because kpathsea sometimes
  behaves oddly, we also recommend `mkdir ~/texmf/tex/latex/dummy` so
  that kpathsea will follow the symlink properly.)

## Usage

The top-level `Makefile` in your document's source tree -- remember,
that's a different tree from this one -- should be a copy of the file
`ext-Makefile` here.  If you got the document tree from us, that will
already be the case.  Just run

      $ make foo.pdf

to build `foo.pdf` from `foo.ltx`.  For draft PDFs, use `make foo.draft.pdf`.

## Pipeline and Plugins

We have enabled the use of jinja templates.  The Makefile runs
pipeline.py, which applies a series of plugins to the document and its
metadata.  Each plugin can implement run(document, metadata) that
returns doucment, metadata.  Optionally, a plugin might implement
run_p(document, metadata) that returns true iff the plugin should run.

Plugins might also implement after and after_p, which get run after
the doc is built.  These plugins might operate on the pdf or do
post-build cleanup tasks.

A well-behaved plugin should have some way to disable itself in the
doc.  One easy method is to honor flags: if the user sets
"PlUGIN_NAME: False" in the doc's YAML preamble, then run_p can return
`meta.get('PLUGIN_NAME', True) != False`

We load and run plugins in asciibetical order and skip ones whose
names start with something other than a digit or a number.  This
allows users to disable a plugin by prefixing its name with an
underscore.

See the plugins in ./pipeline/plugins for documentation on specific
plugins.

## Windows

Linux and OS X should generally do the right thing with these
materials.  We have not documented how to set this up on Windows
because we haven't tried that setup.  If you're on Windows, please let
us know how it goes and how we can improve these materials.
