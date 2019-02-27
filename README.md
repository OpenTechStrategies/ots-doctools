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

      $ make

to see a list of possible document-building commands.  Generally,
`make foo.pdf` will build `foo.pdf` using `foo.ltx` as input.  For
draft PDFs, use `make foo.draft.pdf`.

## Windows

Linux and OS X should generally do the right thing with these
materials.  We have not documented how to set this up on Windows
because we haven't tried that setup.  If you're on Windows, please let
us know how it goes and how we can improve these materials.
