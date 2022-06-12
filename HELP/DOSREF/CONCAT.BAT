ECHO OFF
ECHO      This batch file will concatenate all the Tech Ref files into
ECHO      one large file for easier printing or viewing.  It will require
ECHO      approximately 700k of free disk space.
ECHOÿ
ECHO      Press a key to continue, or Control-C to abort
PAUSE
ECHOÿ
RENAME  INTRO    DOSREF30
COPY  DOSREF30 + SUPPORT     
COPY  DOSREF30 + USAGE       
COPY  DOSREF30 + NEWSTUFF    
COPY  DOSREF30 + CONTENTS    
COPY  DOSREF30 + CHAPTER.001 
COPY  DOSREF30 + CHAPTER.002 
COPY  DOSREF30 + CHAPTER.003 
COPY  DOSREF30 + CHAPTER.004 
COPY  DOSREF30 + CHAPTER.005 
COPY  DOSREF30 + CHAPTER.006 
COPY  DOSREF30 + CHAPTER.007 
COPY  DOSREF30 + CHAPTER.008 
COPY  DOSREF30 + CHAPTER.009 
COPY  DOSREF30 + CREDITS     
COPY  DOSREF30 + BIBLIO      
COPY  DOSREF30 + INVOICE.TRF 
COPY  DOSREF30 + MAILER      
ECHOÿ
ECHO     **** COPIES COMPLETED ****

