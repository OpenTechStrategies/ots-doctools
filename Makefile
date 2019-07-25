# LaTeX Makefile

# Find 'get_revision', used to get the current SVN (or Git) revision. 
# This script is required for 'make foo.draft.pdf' -- if get_revision
# is not found somewhere, that rule will fail.
REVBIN := $(OTS_DOCTOOLS_DIR)/get_revision
ifeq ("$(wildcard $(REVBIN))","")
REVBIN := $(shell find . -type f -name get_revision -print -quit)
endif
REVBIN := $(shell ${REVBIN})

LTX=$(wildcard *.ltx)

PDFLATEX="pdflatex"

# This is a script that takes yaml-fronted latex and feeds it to a
# jinja2 templating engine.  See the jinja directory for more.
JINJIFY=${OTS_DOCTOOLS_DIR}/jinja/jinjify.py

default: build-or-help

build-or-help:
	@if [ `ls -1 *.ltx | wc -l` = 1 ]; then                    \
          echo "Examining '`basename *.ltx .ltx`.pdf' for build."; \
          echo "No output means PDF is already up-to-date.";       \
          $(MAKE) `basename *.ltx .ltx`.pdf;                       \
        elif [ `ls -1 *.ltx | wc -l` -lt 5 ]; then                 \
          echo 'Build a specific PDF here by running "make DOCUMENT_NAME.pdf".';        \
          echo 'If you put ".draft" before the file extension, you get a version with'; \
          echo 'a "DRAFT" watermark diagonally across the background of each page.';    \
          echo 'You may be able to build all non-draft PDFs with "make all".';          \
	  echo "";                                             \
	  for name in *.ltx; do                                \
            echo "  make `basename $${name} .ltx`.pdf";        \
	  done;                                                \
	  echo "";                                             \
	  for name in *.ltx; do                                \
	    echo "  make `basename $${name} .ltx`.draft.pdf";  \
	  done;                                                \
        fi	

# The 'make all' and 'make all-drafts' functionality only works in
# directories where each .ltx file corresponds to an output .pdf.
# When there's a main .ltx file that includes lots of subsidiary
# .ltx files (which are also present in the dir), then making 'all'
# doesn't work because we don't know which doc is the real target.
#
# There are various possible solutions to this.  One is to autodetect
# the primary .ltx files, for example by looking for certain headers
# or by counting the number of times "\input" or "\include" appears.
# Another way would be to have a control file ('.ots-doctools-cfg'
# or something) that names the primary documents.
#
# But for now, we just punt on the whole issue.  In the 'help' rule
# instructions above, we weasel out by saying "You may be able to..."
all:
	@for name in *.ltx; do $(MAKE) `basename $${name} .ltx`.pdf; done

all-drafts:
	@for name in *.ltx; do $(MAKE) `basename $${name} .ltx`.draft.pdf; done

%.ltx: %.mdwn
	pandoc -s -f markdown -t latex -o $@ $<

# A LaTeX document may consist of multiple .ltx files all included
# (via \input or \include) into a single master .ltx file.  But
# tracing those dependencies here in the Makefile would be too much
# trouble, so instead we just rebuild the requested PDF if any LaTeX
# file in the directory changed.  That is guaranteed to be correct: it
# may do an unnecessary rebuild, but won't skip a necessary rebuild.
#
# (Also, it looks like some of the LaTeX tools do dependency tracking
# on their own anyway.  E.g. if a .ltx source file's timestamp changed
# but no content was changed, then 'latexmk' will run very quickly:
# it'll wake up, issue its cheery version-header greeting, realize
# that nothing actually needs to be done, and exit.)
LTX_SRCS := $(shell find . -name dd'*.ltx' ! -path './.\#*')
%.pdf: %.ltx Makefile venv #$(LTX_SRCS)
	venv/bin/python3 ${JINJIFY} -o draft True $< > $(<:.ltx=.intermediate_ltx)
	@latexmk -pdf -pdflatex=$(PDFLATEX) -halt-on-error $(<:.ltx=.intermediate_ltx)

# This builds the draft.  It can handle underscores in the jobname,
# but will produce spurious "type a command or say \end" notices.
%.draft.pdf: %.ltx Makefile venv
	@if [ -L $(shell basename $< .ltx).draft.pdf ]; then rm $(shell basename $< .ltx).draft.pdf; fi
	venv/bin/python3 ${JINJIFY} -o draft True $< > $(<:.ltx=.intermediate_ltx) 
	latexmk -pdf -pdflatex=$(PDFLATEX) -halt-on-error --shell-escape $(<:.ltx=.intermediate_ltx) 
	mv $(shell basename $< .ltx).pdf $(shell basename $< .ltx)-$(REVBIN).pdf
	ln -sf $(shell basename $< .ltx)-$(REVBIN).pdf $(shell basename $< .ltx).draft.pdf 

# OTS Doctools's Jinjify needs some python dependencies.  Not sure
# this is the best place to do this-- it wastes diskspace and clutters
# document dirs with a venv dir.  OTOH, it happens automatically, so
# it's one less thing for a user to think about.
venv:
	virtualenv -p python3 venv
	venv/bin/pip3 install python-frontmatter jinja2

# LaTeX litters a lot
clean_latex:
	@latexmk -c -f $(wildcard *.ltx) $(wildcard *.tex)
	@rm -f $(patsubst %.ltx,%.bbl,$(wildcard *.ltx)) 
	@rm -f $(patsubst %.ltx,%.run.xml,$(wildcard *.ltx)) 

# We don't remove .pdf files by default, even though they're generated
# files, because in practice one usually wants to keep them around.
# However, when a series of PDFs ordered by revision number (e.g.,
# "foo-r1729.pdf", etc) is present, remove all but the most recent.
clean: clean_latex
	@touch Makefile # force update of pdf on next make
	@(find . -maxdepth 1 -regex '.*-r[0-9]+\.pdf' -print                  \
            | sort > $$$$-rev-pdfs.tmp;                                       \
          cat $$$$-rev-pdfs.tmp | sort | tail -1 > $$$$-rev-pdf-to-save.tmp;  \
          if [ `wc -l $$$$-rev-pdf-to-save.tmp | cut -d " " -f 1` != "0" ];   \
          then                                                                \
            mv `cat $$$$-rev-pdf-to-save.tmp` $$$$-fish;                      \
          fi;                                                                 \
          rm -f `cat $$$$-rev-pdfs.tmp`;                                      \
          if [ `wc -l $$$$-rev-pdf-to-save.tmp | cut -d " " -f 1` != "0" ];   \
          then                                                                \
            mv $$$$-fish `cat $$$$-rev-pdf-to-save.tmp`;                      \
          fi;                                                                 \
          rm $$$$-rev-pdfs.tmp;                                               \
          rm $$$$-rev-pdf-to-save.tmp;                                        \
        )
	@if [ -s "latex2docx" ]; then rm -f latex2docx; fi
	@if [ -s "latex2odt" ]; then rm -f latex2odt; fi
	@rm -f $(patsubst %.ltx,%.intermediate_ltx,$(wildcard *.ltx)) 


# Don't delete intermediate files
.SECONDARY:

