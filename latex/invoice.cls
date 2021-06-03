\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{invoice}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{otsletter}}
\ProcessOptions
\LoadClass[letterpaper]{otsletter}

\renewcommand{\myrefname}{\textsl{Invoice \#}}

% For hourly-rate entries, use \timeentry.  The four arguments are: 
%
%   Date      (e.g., "2012-06-30")
%   Who/What  (e.g., "{\em James Vasile}\\ Advice on open source mixology.")
%   Hours     (e.g., "3")
%   Dollars   (e.g., "900")
%
% The "\ifthenelse" command is so that our invoices use singular
% "hour" in the case of "1 hour" and plural "hours" otherwise.
% 
% Note that if you wanted singular "hour" even for the values "1.0"
% and "1.00", you could get that by replacing the "{s}" (that is, the
% 'else' portion of the command) with a nested conditional:
% 
%   \ifthenelse{\equal{\detokenize{#3}}{\detokenize{1.0}}}{}{\ifthenelse{\equal{\detokenize{#3}}{\detokenize{1.00}}}{}{s}}
%
% However, I tried it, and it turns out that "1.0 hour" looks silly.
% Oddly enough, what we actually say in English is "1.0 hours" and
% "1.00 hours", etc.  Turns out our singular/plural grammar is not
% strictly based on the math.  Who knew?  (Linguists, that's who.)
\newcommand{\timeentry}[4]{#1 & \parbox[t]{20em}{#2\vspace*{0.2em}} & #3 \ifthenelse{\equal{\detokenize{#3}}{1}}{\hphantom{s}hour}{hours} & \$#4\\}

% For flat-rate entries in a timereport, just use \flatentry.  The three arguments are: 
%
%   Date      (e.g., "2012-06-30")
%   Who/What  (e.g., "{\em James Vasile}\\ Advice on open source mixology.")
%   Dollars   (e.g., "900")
%
% It will automatically put italicized "flat rate" in the hours column.
% 
\newcommand{\flatentry}[3]{#1&\parbox[t]{20em}{#2\vspace*{0.2em}}&\em{flat\ rate}&\$#3\\}

% Use timereport if you have any time-based entries at all
% (even if you also have some flat-rate entries among them).
\newsavebox{\timereporttimetotal}
\newsavebox{\timereportdollartotal}
\newenvironment{timereport}[2]
  {\sbox{\timereporttimetotal}{#1}
   \sbox{\timereportdollartotal}{#2}
   \renewcommand{\arraystretch}{1.75}%
   \setlength{\tabcolsep}{1em}
   \begin{longtable}[t]{llrr}\underline{Date} & \underline{Description} & \underline{Time} & \underline{Charge}\\}
  {\hline\multicolumn{3}{r}{\rule[-3mm]{0mm}{8mm}\textbf{Total}: \textbf{\usebox{\timereporttimetotal} hours}}&\textbf{\$\usebox{\timereportdollartotal}}\\\end{longtable}}

% Use flatreport if you have *only* flat-rate entries
% (i.e., no time entries at all).
\newsavebox{\flatreporttimetotal}
\newsavebox{\flatreportdollartotal}
\newenvironment{flatreport}[1]
  {\sbox{\flatreportdollartotal}{#1}
   \renewcommand{\arraystretch}{1.75}%
   \setlength{\tabcolsep}{0.5em}
   \begin{longtable}[t]{llrr}\underline{Date} & \underline{Description} & \underline{Time} & \underline{Charge}\\}
  {\hline\multicolumn{3}{r}{\rule[-3mm]{0mm}{6mm}\textbf{Total}: } \hspace{5em} &\textbf{\$\usebox{\flatreportdollartotal}}\\\end{longtable}}

% For expense entries, use \expenseentry.  The three arguments are: 
%
%   Date      (e.g., "2012-06-30")
%   Who/What  (e.g., "{\em James Vasile}\\ Supplies for mixology demo.")
%   Dollars   (e.g., "900")
%
% It will automatically put italicized "expense" in the hours column.
% 
\newcommand{\expenseentry}[3]{#1&\parbox[t]{20em}{#2\vspace*{0.2em}}&\$#3\\}

\newsavebox{\expensereportdollartotal}
\newenvironment{expensereport}[1]
  {\sbox{\expensereportdollartotal}{#1}
   \renewcommand{\arraystretch}{1.75}%
   \setlength{\tabcolsep}{1em}
   \begin{longtable}[t]{llrl}\underline{Date} & \underline{Description} & \underline{Charge}\\}
  {\hline\multicolumn{3}{r}{\rule[-3mm]{0mm}{8mm}\textbf{Total}:} \textbf{\$\usebox{\expensereportdollartotal}}\\\end{longtable}}
