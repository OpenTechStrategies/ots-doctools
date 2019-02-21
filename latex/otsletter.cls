\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{otsletter}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{letter}}
\ProcessOptions
\LoadClass[letterpaper]{letter}

\longindentation=0pt 


\RequirePackage{ifthen}
\usepackage{setspace}
\usepackage{comment} 

%% For angle brackets in non-math text mode.  Use the shortcuts \la
%% and \ra (defined below) in this slightly non-intuitive way:
%% "\la jrandom@example.com\ra"
\usepackage{textcomp}
\newcommand\la{\textlangle}
\newcommand\ra{\textrangle}

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

% start everything near the top-left corner
\setlength{\parindent}{0pt}

%% Handle long tables (e.g., correctly break them across multiple pages).
%%
%% QUESTION: Why is this necessary when invoice.sty in this directory
%% already has "\RequirePackage{longtable}" (as of 2012-06-17)?  Are
%% we not actually using invoice.sty for anything?  Is it just there
%% as an example?  In any case, if we don't pull in 'longtable' here,
%% then generating an OTS invoice will fail with the rather clear
%% message "LaTeX Error: Environment longtable undefined", despite the
%% the \RequirePackage in invoice.sty.
\RequirePackage{longtable}

\address{Does it matter what I write here?  It appears not. But don't remove it or the sig block gets left justified?!}
\signature{\fromname}
\newcommand{\yrefname}{\textsl{Your ref.}}
\newcommand{\ymailname}{\textsl{Your letter from}}
\newcommand{\myrefname}{\textsl{Our Ref.}}
\newcommand{\subjectname}{\textsl{Subject}}
\newcommand{\telephonename}{Telephone}
\newcommand{\postcode}{11225-1512}

\newcommand{\@yref}{} 
\newcommand{\@ymail}{}
\newcommand{\@myref}{}
\newcommand{\@internet}{}
\newcommand{\@subject}{}

\newcommand{\yref}[1]{\renewcommand{\@yref}{\yrefname: #1}}
\newcommand{\ymail}[1]{\renewcommand{\@ymail}{\ymailname: #1}}
\newcommand{\myref}[1]{\renewcommand{\@myref}{\myrefname: #1}}
\newcommand{\subject}[1]{\renewcommand{\@subject}{\subjectname: #1}}
\newcommand{\internet}[1]{\renewcommand{\@internet}{#1}}

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

\newcommand{\circlesep}{\raisebox{1.7em}{\hspace{1.8em}\includegraphics[clip, trim=0cm 11cm 19.3cm 11cm, scale=0.05]{otslogo.pdf}\hspace{1.8em}}}

\newsavebox{\FIRM}
\newsavebox{\firmaddress}
\newsavebox{\firm}

\sbox{\FIRM}
  {\parbox[t]{\leftfield}
      % Uncomment next line for small logo, then do similar ~17 lines below
      {\xviisf   \begin{textblock}{3}(0.5,0.87)\includegraphics[scale=.3]{otslogo.pdf}\end{textblock} }}
      % Uncomment next line for big logo, then do similar ~17 lines below
      %{\xviisf   \begin{textblock}{3}(0,0)\includegraphics[scale=.7]{otslogo.pdf}\end{textblock} }}


\sbox{\firm}{\xsf Open Tech Strategies}


   \sbox{\firmaddress}
        {\parbox[t]{5.8in}
          % TBD: Switch the commenting on the next two lines to
          % generate an invoice with vs without our NY street address.
          % We still need to figure out a letterhead design that won't
          % confuse clients as to where to send payment.  Maybe we
          % could put something like:
          % 
          %    New York  *  Chicago  *  info@ots  *  phone number   ?
          % 
          % { \textcolor{dkergreen}{ {\viiisf 333 East 102nd Street, \#409, New York, NY 10029 \circlesep opentechstrategies.com \circlesep +1 (312) 857-6361} }}}
          { \textcolor{dkergreen}{ {\viiisf \null \hfill info@opentechstrategies.com \circlesep +1 (312) 857-6361} }}}

%            {\textcolor{dkergreen}{{\viiisf \null \hfill +1 (312) 857-6361\\333 East 102nd St, New York, NY 10029\hfill opentechstrategies.com}}}}}
          
%            {\xviisf   \begin{textblock}{3}(0.5,0.87)333 East 102nd St, \#409, New York, NY 10029\end{textblock}}
   %\textcolor{dkergreen}{333 East 102nd St, \#409, New York, NY 10029\hspace{5em}opentechstrategies.com\hspace{5em}+1 (312) 857-6361}
    %}
\newsavebox{\firmhead}
%\newsavebox{\firmfoot}

\sbox{\firmhead}
     {\parbox{\textwidth}{\usebox{\FIRM}\\\hspace*{1.4cm}\raisebox{-1.7cm}{\usebox{\firmaddress}}\\[3pt]\textcolor{dkgreen}{\rule{\textwidth}{1pt}}}}

\renewcommand{\ps@firstpage}
  {\setlength{\headheight}{71pt}\setlength{\headsep}{25pt}%
   \renewcommand{\@oddhead}{\usebox{\firmhead}}%
   %\renewcommand{\@oddfoot}{\raisebox{-20pt}[0pt]}
                           % {\usebox{\firmfoot}}}%
   %\renewcommand{\@evenhead}{}\renewcommand{\@evenfoot}{}
  }

\renewcommand{\ps@headings}{
  \setlength{\headheight}{41pt}%
  \renewcommand{\@oddhead}{
    \textcolor{dkgreen}{
      \parbox{\textwidth}{%\usebox{\firm}\\[5pt]
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
  
%\pagestyle{headings}

\renewcommand{\opening}[1]{
  \makeatletter
  \let\@texttop\relax
  \makeatother
  \vspace*{13mm} %%%% jlv
  \thispagestyle{firstpage}
  \parbox[t]{\leftfield}
    {
     \parbox[b][1.5cm][c]{\leftfield}{\toname\\\toaddress}
    }
  \parbox[t]{\rightfield}
    {\vspace*{-6em}
     \begin{spacing}{0.70}
       {\viiisf \fromname
        \ifthenelse{\equal{\telephonenum}{}}
            {}{\\ {\viiisf\baselineskip10pt \telephonenum}}
        \ifthenelse{\equal{\@internet}{}}
            {}{\\ {\viiisf\baselineskip10pt \@internet}}
       }
     \end{spacing}
     \vspace*{2.5em}\@date}
  \par
  \textcolor{dkgreen}{\rule{\textwidth}{01.6pt}}
  \makebox[\leftfield][l]
    {\ifthenelse{\equal{\@yref}{}}
      {\@ymail}{\@yref\hfill\@ymail\hfill}}
  \@myref\par
  \ifthenelse{\equal{\@subject}{}}{}{\vspace{-1.75em}\@subject\par}
  \vspace{2\parskip} #1 \par\nobreak}

\begin{comment}
\end{comment}
