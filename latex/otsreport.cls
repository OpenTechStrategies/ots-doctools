%%% OTS Reports (e.g. business reports to clients).
%%%
%%% Do \date{7 June 2017}\reportstart{Title of your report} and this
%%% should make a nice start to your doc.
%%%
%%%
%%% Note that OTS Report is *not* based on the LaTeX "report" style!
%%% Rather, it is based on the LaTeX "article" style, because that
%%% gets us a lot closer to what we want our business reports to look
%%% like than LaTeX's native "report" style does (it was meant more
%%% for academic reports I guess).

%%% TODO: having our mini-logo in the corner of each non-first page
%%% isn't working yet (it works with invoices/letters, just not here).
%%% Ideally, we'd have the mini-logo and the title of the report,
%%% repeated on each page.  But let not the perfect be the enemy of
%%% the cliché.  Or something like that.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{otsreport}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions
\LoadClass[letterpaper]{article}

\RequirePackage{ifthen}
\usepackage{setspace}
\usepackage{comment} 

%% Stuff for colored rules
\usepackage[table]{xcolor}
\definecolor{ltgreen}{RGB}{66, 147, 90}
\definecolor{dkgreen}{RGB}{50, 109, 72}
\definecolor{dkergreen}{RGB}{0, 100, 0}

%% Stuff for logo insertion
\usepackage{graphicx}
\usepackage[absolute]{textpos}
\setlength{\TPHorizModule}{30mm}
\setlength{\TPVertModule}{\TPHorizModule}
\textblockorigin{10mm}{10mm}

% Vertical space between paragraphs.
\setlength{\parskip}{0.8em}

% Don't indent paragraphs; start them at their top-left corners.
\setlength{\parindent}{0pt}

%% Handle long tables (e.g., correctly break them across multiple pages).
%%
%% QUESTION: Why is this necessary when otsreport.sty in this directory
%% already has "\RequirePackage{longtable}" (as of 2013-01-13)?  Are
%% we not actually using otsreport.sty for anything?  Is it just there
%% as an example?  In any case, if we don't pull in 'longtable' here,
%% then generating an OTS report will fail with the rather clear
%% message "LaTeX Error: Environment longtable undefined", despite the
%% the \RequirePackage in otsreport.sty.
\RequirePackage{longtable}

\setlength{\textheight}{215mm}
\setlength{\textwidth}{160mm}
\setlength{\oddsidemargin}{0pt}
\setlength{\evensidemargin}{0pt}
\setlength{\topmargin}{-20pt}
\setlength{\headheight}{12pt}
\setlength{\headsep}{35pt}

\DeclareFixedFont{\xviisf}{OT1}{cmss}{m}{n}{17}
\DeclareFixedFont{\xsf}{OT1}{cmss}{m}{n}{10}
\DeclareFixedFont{\viiisf}{OT1}{cmss}{m}{n}{8}

\newlength{\leftfield}
\setlength{\leftfield}{117mm}
\newlength{\rightfield}
\setlength{\rightfield}{43mm}

\newsavebox{\FIRM}
\newsavebox{\firmaddress}
\newsavebox{\firm}
\newsavebox{\firmreturn}

%\sbox{\FIRM}
%  {\parbox[t]{\leftfield}
%      {\xviisf   \begin{textblock}{3}(0,0)\includegraphics[scale=.26]{otslogo.pdf}\end{textblock} }}
%
%\sbox{\firm}{\xsf Open Tech Strategies}

\sbox{\firmreturn}
   {}
   %{\viiisf\underline{Return address goes here, New York, NY}}

% We do postcode as a command because otsletter.cls does it that way.
% Why does otsletter.cls do it that way?  Not sure.  Cargo cult LaTeX.
\newcommand{\postcode}{10029}

\sbox{\firmaddress}
%  {\parbox[t]{\rightfield}{\viiisf\baselineskip5pt
  {\parbox[t]{\textwidth}{\viiisf
   \vspace{1cm}
   \textcolor{dkergreen}{
   \centerline{\hfill @OpenTechStrat \hspace{2em} info@opentechstrategies.com \hspace{2em} +1 (312) 857-6361}}}
    }
\newsavebox{\firmhead}
%\newsavebox{\firmfoot}

\sbox{\firmhead}
     {\parbox{\textwidth}{\vspace{-1cm}\usebox{\FIRM}\raisebox{6pt}{\usebox{\firmaddress}}\\[3pt]\textcolor{dkgreen}{\rule{\textwidth}{1pt}}}}

\renewcommand{\ps@headings}{
  \setlength{\headheight}{41pt}%
  \renewcommand{\@oddhead}{
    \textcolor{dkgreen}{
      \parbox{\textwidth}{
        \includegraphics[scale=.15]{otslogo.pdf}\\[1pt]
        \slshape \headtoname{} \toname\hfill\@date\hfill
        \pagename{} \thepage\\
        \rule[3pt]{\textwidth}{1pt}}}}
  \renewcommand{\@oddfoot}{}
  \renewcommand{\@evenhead}{\@oddhead}
  \renewcommand{\@evenfoot}{\@oddfoot}
}

\providecommand{\@evenhead}{}
\providecommand{\@oddhead}{}
\providecommand{\@evenfoot}{}
\providecommand{\@oddfoot}{}
  
\newcommand{\ps@otsreportfirstpage}
  {\setlength{\headheight}{10pt}\setlength{\headsep}{30pt}
    \renewcommand{\@oddhead}{\usebox{\firmhead}}
  }
 
%% For reference, the 10 default LaTeX font sizes are:
%%
%%    \tiny
%%    \scriptsize
%%    \footnotesize
%%    \small
%%    \normalsize
%%    \large
%%    \Large
%%    \LARGE
%%    \huge
%%    \Huge 
%%
%% I find it amazing that they are case-sensitive, but apparently that
%% is the case (hah hah, get it?  thud).

\newcommand{\otsheader}{%
  \vspace{1em}

  \begin{minipage}[c]{0.5\textwidth}
    \begin{figure}[H]
      \includegraphics[scale=0.20]{otslogo.pdf}
    \end{figure}
  \end{minipage} \hfill
  \begin{minipage}[c]{0.45\textwidth}
    \vspace*{0.25cm}
    \textcolor{dkergreen}{{\viiisf \hfill info@opentechstrategies.com \circlesep +1 (312) 857-6361}}
  \end{minipage}

  \vspace*{-0.71cm}\hspace*{0.95cm}\textcolor{dkgreen}{\rule{0.942\textwidth}{1pt}}

  \vspace{2em}
}

% We don't use this, but you might want to set the date as
% \date{\today} and this will format it as "d Monthname yyyy"
\usepackage{datetime2-calc}
\DTMnewdatestyle{otsdate}{%
  \renewcommand*{\DTMdisplaydate}[4]{\number##3~\DTMmonthname{##2} ##1}%
  \renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}
\DTMsetdatestyle{otsdate}

\newcommand{\reportstart}[1]{
  \makeatletter
  \let\@texttop\relax
  \makeatother
  \thispagestyle{otsreportfirstpage}
  \begin{center} 
  {\Large\bf #1}\\
  {\normalsize
    \@date}
  \end{center}
  \par\nobreak}

\begin{comment}
\end{comment}

%% Stuff for hyperlinks
\usepackage[unicode=true]{hyperref}

