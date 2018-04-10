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

To use the OTS specific commands, include `\usepackage{ots}` in the
header of your document and make sure that your LaTeX doc can find
`ots.sty`.

TODO: We recommend adding `otsltxsetup` to your PATH.  This will
symlink the `Makefile` and `ots.sty` from the specified location of this
repository to the directory in which you ran `otsltxsetup`.

Probable OTS-specific things:

- OTSDIR: This reference to our home Subversion directory is only
  necessary to find the relevant revision for drafts.  Not having an
  OTSDIR will not break anything, but you won't see the revision number
  in the name of your drafts.

  Possible improvement: rename OTSDIR to REPOROOT and make the revision
  work for either git or svn repos.

- VIEW option: A possible improvement here would be to replace the
  reference to `utils/mailcap-open` with a variable that the user could
  set to their preferred pdf viewer, like `$PDFVIEWER = /usr/bin/evince`


