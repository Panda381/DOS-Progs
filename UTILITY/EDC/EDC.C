/*
                 Kontroln¡ sou‡et zadan˜ch soubor– EDC
     Soubory se zad vaj¡ p©i vyvol n¡ programu jako seznam soubor– 
                    s ud n¡m jejich pln‚ specifikace
*/

#include <stdio.h> 	/* standardn¡ vstup/v˜stup */
#include <process.h>
#include <io.h>

#define BUF 128         /* vstupnˆ/v˜stupn¡ buffer */

main (argc, argv)       /* vstup do hlavn¡ funkce */
   int argc;		/* po‡et soubor– v povelov‚m © dku */
   char *argv[];	/* vstupn¡ povelov˜ © dek */
{
   long int delka,cit;	    /* d‚lka souboru, ‡¡ta‡ bajt– */
   unsigned char d,e,a,f;   /* registry kontroln¡ho sou‡tu */
   FILE *fp, *fopen();
   if(argc < 2)
   {
      printf ("Zadejte jm‚no souboru !\n");
      exit(1);
   }
   while(--argc > 0)
   {
      if((fp=fopen(*++argv,"rb")) == NULL)
      {
         printf("Chyba otev©en¡ souboru %s !\n",*argv);
	 exit(1);
      }
      delka=filelength(fileno(fp));
      cit=0;
      e=d=0xff;
      while (cit++<delka)
      {
         a = fgetc(fp);
         d = a ^= d;
	 a >>= 4;
         d = a ^= d;
	 a = (a >> 3) | (a << 5);
	 f = a;
	 a &= 0x1f;
	 e = a ^= e;
         a = f;
	 a = (a >> 1) | (a << 7);
	 a &= 0xf0;
	 e = a ^= e;
	 a = f & 0xe0;
	 a ^= d;
	 d = e;
	 e = a;
      }
      printf("Kontroln¡ sou‡et EDC souboru %s \t= %.2X%.2XH.\n",*argv,d,e);
      fclose(fp);
   }
   return (0);
}



