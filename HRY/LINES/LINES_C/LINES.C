/*                                                                    */
/*              LINES - demonstra‡n¡ grafick˜ program                 */
/*                 programovac¡ jazyk - Turbo C                       */
/*                                                                    */

#include <graphics.h>                  /* grafick  knihovna           */
#include <stdlib.h>

int GraphDriver;                       /* ‡¡slo grafick‚ho driveru    */
int GraphMode;                         /* grafick˜ m¢d                */
int MaxX,MaxY;                         /* maxim ln¡ sou©adnice X a Y  */
int MaxColor;                          /* maxim ln¡ cislo barvy       */
int X1, X2, Y1, Y2;                    /* sou©adnice £se‡ky           */
int dx1,dx2,dy1,dy2;                   /* p©¡rustky sou©adnic £se‡ky  */
int Color;                             /* aktivn¡ barva £se‡ky        */
int i,j;                               /* ‡¡ta‡e cykl–                */
int Bufx1 [120];                       /* z znamn¡k sou©adnic X1      */
int Bufy1 [120];                       /* z znamn¡k sou©adnic Y1      */
int Bufx2 [120];                       /* z znamn¡k sou©adnic X2      */
int Bufy2 [120];                       /* z znamn¡k sou©adnic Y2      */

int main ()
{
   GraphDriver = DETECT;              /* auto-detekce displeje        */
   randomize();                       /* nastaven¡ gener toru n hody  */
   initgraph( &GraphDriver,&GraphMode, ""); /* init.displeje         */
   if( graphresult() != grOk)
   {  printf("Chyba grafick‚ho syst‚mu !\n");
      exit(1);
   }                                  /* chybov˜ n vrat               */
   MaxColor = getmaxcolor();          /* max. cislo barvy             */
   MaxX = getmaxx();                  /* max. sou©adnice X            */
   MaxY = getmaxy();                  /* max. sou©adnice Y            */
   for( j=0 ; j<120 ; ++j)            /* vymaz n¡ z znamn¡k–          */
   {
      Bufx1[j] = 0;
      Bufy1[j] = 0;
      Bufx2[j] = 0;
      Bufy2[j] = 0;
   }
   X1  = random (MaxX-20);             /* po‡ te‡n¡ nastaven¡ X1      */
   Y1  = random (MaxY-20);             /* po‡ te‡n¡ nastaven¡ Y1      */
   X2  = random (MaxX-20);             /* po‡ te‡n¡ nastaven¡ X2      */
   Y2  = random (MaxY-20);             /* po‡ te‡n¡ nastaven¡ Y1      */
   dx1 = random (5)+1;                 /* po‡ te‡n¡ nastaven¡ dx1     */
   dx2 = random (5)+1;                 /* po‡ te‡n¡ nastaven¡ dx2     */
   dy1 = random (5)+1;                 /* po‡ te‡n¡ nastaven¡ dyt     */
   dy2 = random (5)+1;                 /* po‡ te‡n¡ nastaven¡ dy2     */
   i = 0;                              /* ukazatel sou©adnic v z znam.*/
   while (1==1)                        /* nekone‡n˜ cyklus            */
   {
      Color = random (MaxColor)+1;     /* n hodn  barva               */
      for (j=0 ; j<random(130)+100;++j)/* cyklus jedn‚ barvy          */
      {
         setcolor (0);                 /* nastaven¡ ‡ern‚ barvy       */
         line (Bufx1[i],Bufy1[i],Bufx2[i],Bufy2[i]); /* vymaz.‡ar     */
	 line (Bufx1[i],MaxY-Bufy1[i],Bufx2[i],MaxY-Bufy2[i]);
	 if ((X1+dx1) < 0   ) dx1= random(4)+1; /* p©esah ?        */
	 if ((X1+dx1) > MaxX) dx1=-random(4)-1;
	 if ((Y1+dy1) < 0   ) dy1= random(4)+1;
	 if ((Y1+dy1) > MaxY) dy1=-random(4)-1;
	 if ((X2+dx2) < 0   ) dx2= random(4)+1;
	 if ((X2+dx2) > MaxX) dx2=-random(4)-1;
	 if ((Y2+dy2) < 0   ) dy2= random(4)+1;
	 if ((Y2+dy2) > MaxY) dy2=-random(4)-1;
         X1=X1+dx1;                    /* nov‚ sou©adnice             */
         X2=X2+dx2;
         Y1=Y1+dy1;
         Y2=Y2+dy2;
         setcolor(Color);
         line (X1,Y1,X2,Y2);           /* nakreslen¡ ‡ ry             */
	 line (X1,MaxY-Y1,X2,MaxY-Y2); /* zrcadlov  ‡ ra              */
         Bufx1[i]=X1;
         Bufx2[i]=X2;
         Bufy1[i]=Y1;
         Bufy2[i]=Y2;
         if (++i >69) i=0;
         if (kbhit()) {getch();exit(0);} /* konec p©i kl vese         */
        }
   }
}
