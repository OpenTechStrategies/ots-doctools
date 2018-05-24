# README

This is the source repository for Open Tech Strategies' LaTeX
infrastructure.  We use this to create headers for and add specific
commands to our LaTeX documents.  We know that our LaTeX infrastructure
is set up imperfectly and welcome input on ways to improve it.

The expected audience for this repository are people who would like to
view or use the source for our published reports.  Given the `.ltx` file
for a given report and these infrastructure files, you should be able to
re-create the published report.  Please file an issue if you have
difficulty doing so.

## Usage

If you are building a document from an OTS repository, the Makefile
that came with that document should either find your installation of
ots-doctools or do a hyperlocal install in a subdir of that document's
directory.  The doc should build smoothly from there based on the
doc-specific makefile in the document's repository.

If you are starting your own document and want to rely on OTS
materials to do that (e.g. if you are an OTS staffer), copy the
Makefile.docspecific in this directory to your document directory (or
link to it) and rename it to Makefile.  `make` should do a hyperlocal
install if needed.  You can edit that copy of the Makefile to suit
your document's needs.

If you want to install these materials widely so your user can access
them and you don't have to manage this as a submodule (highly
recommended if, for example, you're on subversion and not git), you
will need to do the kpathsea and texmfhome fiddling specified in the
comments in Makefile.  TODO: document that install process here.

## Windows

Linux and OS X should generally do the right thing with these
materials.  We have not yet documented how to set this up on Windows
because we haven't tried to do that setup.  If you're on Windows,
please let us know how it goes and hjow we can improve these
materials.

## OTS-specific matters

- OTSDIR: This reference to our home Subversion directory is only
  necessary to find the relevant revision for drafts.  Not having an
  OTSDIR will not break anything, but you won't see the revision number
  in the name of your drafts.

  Possible improvement: rename OTSDIR to REPOROOT and make the revision
  work for either git or svn repos.

- VIEW option: A possible improvement here would be to replace the
  reference to `utils/mailcap-open` with a variable that the user could
  set to their preferred pdf viewer, like `$PDFVIEWER = /usr/bin/evince`


