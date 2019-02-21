\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{contract}[2015/04/10 My custom contract class] 
\LoadClass{article}
            
\usepackage{graphicx} % for graphic sigs

\usepackage[en-GB]{datetime2}
\newcommand{\longtoday}{{\DTMlangsetup[en-GB]{abbr=false,ord=omit}\today}}

\usepackage{ifthen}
%\usepackage{eurofont}

\usepackage{fullpage}
\setlength{\textwidth}{7in}
\setlength{\oddsidemargin}{-.25in}
\setlength{\topmargin}{-0.35in}
\setlength{\headheight}{0pt}
\setlength{\headsep}{0in}
\setlength{\footskip}{0in}
\setlength{\textheight}{10in}

\setlength{\parindent}{0in}
\setlength{\parskip}{1em}

\newcounter{Lcount}
\newenvironment{paralist}[1]{\begin{list}{\hspace*{0em}(\alph{Lcount})}
  {\usecounter{Lcount}
   \setlength{\leftmargin}{3em}
   \setlength{\topsep}{0em}}
 #1}{\end{list}\vskip 1em}

%\def\para{\addtocounter{ParaCount}{1}\arabic{ParaCount}. }
\newcounter{ParaCount}
\newcommand*{\para}[1]{\addtocounter{ParaCount}{1}\textbf{\arabic{ParaCount}. #1.}}
\newcommand*{\bline}[1]{\rule{#1}{0.1pt}}

\usepackage{fancyhdr}
\fancyhead{}
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}

\usepackage{url}
%% Define a new 'leo' style for the package that will use a smaller font.
\makeatletter
\def\url@leostyle{%
  \@ifundefined{selectfont}{\def\UrlFont{\sf}}{\def\UrlFont{\small\ttfamily}}}
\makeatother
%% Now actually use the newly defined style.
\urlstyle{leo}

%\newcommand{\urlhref}[1]{\href{#1}{#1}}
%\newcommand{\mailhref}[1]{\href{mailto:#1}{#1}}
\pagestyle{fancyplain}

\usepackage{titlesec}
\titlespacing*{\section}{0cm}{0pt}{0pt}[0pt]
\titleformat{\section}{\normalfont\bf}{\thesection.}{5pt}{}

% Conventional wisdom says load hyperref last.  We need it or we get
% \textorpdf errors
\usepackage{hyperref}

%----------------------------------------------------------------------------------------
%	SIGNATURE BLOCK
%----------------------------------------------------------------------------------------
\newcommand{\signedblock}[5][5cm]{%
  \begin{minipage}[t]{7cm}
    \begin{tabular}{@{}p{#1}@{}}
      \includegraphics[height=1in,keepaspectratio]{#4}\vspace{-2em}
    \hrule \\[0pt]
    {\small \textit{#2}} \\ {\small \textit{#3}}
    \\[1\normalbaselineskip] #5 \\ \vskip -1em \hrule \\[0pt]
    \vskip -1.5em
    {\small \textit{Date}}
  \end{tabular}
  \end{minipage}
}

% Takes an optional date argument (#4).  Typically, the OTS signer
% includes a date, because we're sending someone a contract that
% we've signed, for them to countersign.  So the date is included
% ("{{{date}}}") on the OTS side, and blank ("{}") on their side.
\newcommand{\sigblock}[4][5cm]{%
  \begin{minipage}[t]{7cm}
  \begin{tabular}{@{}p{#1}@{}}
    \\[2\normalbaselineskip] \hrule \\[0pt]
    {\small \textit{#2}} \\ {\small \textit{#3}} \\[2\normalbaselineskip] \\ #4 \hrule \\[0pt]
    {\small \textit{Date}}
  \end{tabular}
  \end{minipage}
}

\newcommand{\sigblockaddress}[5][5cm]{%
  \begin{minipage}[t]{7cm}
  \begin{tabular}{@{}p{#1}@{}}
    \\{\small Signature:} \hrule \\[0pt]
    \\{\small #2} \hrule \\[0pt]
    \\{\small #3} \hrule \\[0pt]
    \\{\small #4} \hrule \\[0pt]
    \vskip 1em
    {\small Date:} #5 \hrule \\[0pt]
    
  \end{tabular}
  \end{minipage}
}

\newcommand{\sigblockOLD}[3][5cm]{%
  \begin{tabular}{@{}p{#1}@{}}
    \\[2\normalbaselineskip] \hrule \\[0pt]
    {\small \textit{#2}} \\ {\small \textit{#3}} \\[2\normalbaselineskip] \hrule \\[0pt]
    {\small \textit{Date}}
  \end{tabular}
}
