# 
# You'll need at least the 'pdflatex' tool installed.

# Note that 'make VIEW=true all' will build the pdf and then try to
# open a pdf viewer.  This is a convenience target and if it doesn't
# work on your system, you can just do make and then run the pdf
# viewer manually.

# This Makefile assumes OTSDIR is an environment variable set to the
# root of the OTS repository directory.  In my .bashrc, I set this
# with 'export OTSDIR=~/OTS'

# It also might depend on kpathsea being able to find forms/latex/*.
# I'm assuming your TEXMFHOME is set properly.  I have "export
# TEXMFHOME=~/texmf" in my .bashrc.  Then, ~/texmf/tex/latex/ots is a
# symlink to ${OTSDIR}/forms/latex.  Because kpathsea is broken, I
# also did `mkdir ~/texmf/tex/latex/dummy` so kpathsea would follow
# the symlink properly.

# To use it, run e.g. "make 20121220-1.pdf" in an your document
# directory where you have the appropriate symlinks set up, which will
# be some hopefully obvious subset of (or just all of) something like
# these:
#
#   Makefile      ->  ../../../forms/latex/Makefile
#   otsletter.cls ->  ../../../forms/latex/otsletter.cls
#   otsreport.cls ->  ../../../forms/latex/otsreport.cls
#   otslogo.pdf   ->  ../../../forms/latex/otslogo.pdf
#
# And maybe you'll want this too:
#   invoice.cls   ->  ../../../forms/latex/invoice.cls
#
# For draft PDFs: OTS maintains a script called 'get_revision', which
# returns a string describing the current svn revision of the tree.
# This Makefile tries to find that file by looking for
# $OTSDIR/utils/get_revision.  If that doesn't exist (perhaps because
# OTSDIR is not defined in the environment), it takes the first file
# returned by GNU find.  If it cannot find this file, don't worry.  It
# will just omit the SVN revision number from the generated pdf.

# Find 'get_revision', used to get the current SVN (or Git) revision. 
# This script is required for 'make foo.draft.pdf' -- if get_revision
# is not found somewhere, that rule will fail.
REVBIN := $(OTSDIR)/utils/get_revision
ifeq ("$(wildcard $(REVBIN))","")
REVBIN := $(shell find . -type f -name get_revision -print -quit)
endif

default: help

help:
	@echo 'You can build PDF for any document here by running "make DOCUMENT.pdf".'
	@echo 'Adding "VIEW=true" to the command line opens or refreshes the PDF in your'
	@echo 'default viewer (as determined by OTSDIR/utils/mailcap-open).'
	@echo 'If you put ".draft" before the file extension, you get a version with a'
	@echo 'a "DRAFT" watermark diagonally across the background of each page.'
	@echo 'You can build all non-draft PDFs with "make all".'
	@echo ''
	@for name in *.ltx; do echo "  make `basename $${name} .ltx`.pdf"; done
	@for name in *.ltx; do echo "  make `basename $${name} .ltx`.draft.pdf"; done
	@for name in *.ltx; do echo "  make VIEW=true `basename $${name} .ltx`.draft.pdf"; done

all:
	@for name in *.ltx; do $(MAKE) `basename $${name} .ltx`.pdf; done

all-drafts:
	@for name in *.ltx; do $(MAKE) `basename $${name} .ltx`.draft.pdf; done

%.ltx: %.mdwn
	pandoc -s -f markdown -t latex -o $@ $<

%.pdf: %.ltx
	@latexmk -pdf -halt-on-error $<

%.xml: %.ltx
	@latexmk -pdflatex=lualatex --jobname="$(shell basename $< .ltx).xml" -pdf -halt-on-error $<
	@pdftotext -layout -nopgbrk "$(shell basename $< .ltx).xml.pdf" "$(shell basename $< .ltx).xml"
	@sed -i 's/”/"/' "$(shell basename $< .ltx).xml"
	@sed -i 's/”/"/' "$(shell basename $< .ltx).xml"

ifeq ("$(VIEW)","true")
	$(OTSDIR)/utils/mailcap-open $@
endif

# This builds the draft.  It can handle underscores in the jobname,
# but will produce spurious "type a command or say \end" notices.
%.draft.pdf: %.ltx Makefile
	@if [ -L $(shell basename $< .ltx).draft.pdf ]; then rm $(shell basename $< .ltx).draft.pdf; fi
	@if test $(findstring _, $<); then \
           export SVNREVISION="$(shell $(REVBIN) $<)" ; \
           export DRAFT=yes ; \
           sed  "s/\\\getenv\\[\\\JOBNAME.*/\\\newcommand{\\\JOBNAME}{$(subst _,\\\_,$<)}/" $< | \
	   latexmk -pdf -halt-on-error --shell-escape -jobname=$(addsuffix , $(basename $@)); \
        else \
	  export SVNREVISION="$(shell $(REVBIN) $<)" ; \
	  export DRAFT=yes ; \
	  export JOBNAME="$<" ; \
	  latexmk -pdf -halt-on-error --shell-escape -jobname=$(addsuffix , $(basename $@)) $< ; \
	fi;
	mv $(shell basename $< .ltx).draft.pdf $(shell basename $< .ltx)-$(shell $(REVBIN) $<).pdf
	ln -sf $(shell basename $< .ltx)-$(shell $(REVBIN) $<).pdf $(shell basename $< .ltx).draft.pdf 
ifeq ("$(VIEW)","true")
	$(OTSDIR)/utils/mailcap-open $@
endif

# LaTeX litters a lot
clean_latex:
	@rm -f *.fdb_latexmk *.aux *.fls *.lof *.lot *.log *.out *.toc

# We don't remove .pdf files by default, even though they're generated
# files, because in practice one usually wants to keep them around.
# However, when a series of PDFs ordered by revision number (e.g.,
# "foo-r1729.pdf", etc) is present, remove all but the most recent.
clean: clean_latex
	@(find . -maxdepth 1 -regex '.*-r[0-9]+\.pdf' -print | sort > $$-rev-pdfs.tmp; \
	  cat $$-rev-pdfs.tmp | sort | tail -1 > $$-rev-pdf-to-save.tmp;               \
          mv `cat $$-rev-pdf-to-save.tmp` fish;                                        \
	  rm -f `cat $$-rev-pdfs.tmp`;                                                 \
          mv fish `cat $$-rev-pdf-to-save.tmp`;                                        \
          rm $$-rev-pdfs.tmp;                                                          \
          rm $$-rev-pdf-to-save.tmp;)

	@if [ -s "latex2docx" ]; then rm -f latex2docx; fi
	@if [ -s "latex2odt" ]; then rm -f latex2odt; fi


# Don't delete intermediate files
.SECONDARY:
