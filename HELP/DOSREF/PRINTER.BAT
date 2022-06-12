ECHO OFF
ECHO      If you don't wish to use PRINT.COM or a spooler, this batch file
ECHO      will copy the DOSREF demo files to the printer.  It will take
ECHO      about a 1-1/2 to 2 inch stack of paper.
ECHOÿ
ECHO      Press a key to continue, or Control-C to abort
PAUSE
ECHOÿ
COPY   INTRO        > PRN
COPY   SUPPORT      > PRN
COPY   USAGE        > PRN
COPY   NEWSTUFF     > PRN
COPY   CONTENTS     > PRN
COPY   CHAPTER.001  > PRN
COPY   CHAPTER.002  > PRN
COPY   CHAPTER.003  > PRN
COPY   CHAPTER.004  > PRN
COPY   CHAPTER.005  > PRN
COPY   CHAPTER.006  > PRN
COPY   CHAPTER.007  > PRN
COPY   CHAPTER.008  > PRN
COPY   CHAPTER.009  > PRN
COPY   CREDITS      > PRN
COPY   BIBLIO       > PRN  
COPY   INVOICE.TRF  > PRN
COPY   MAILER       > PRN
ECHOÿ
ECHO     **** PRINT JOB COMPLETED ****
