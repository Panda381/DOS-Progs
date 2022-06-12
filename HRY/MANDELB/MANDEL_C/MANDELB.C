#include <graphics.h>
#include <stdio.h>
#include <conio.h>
#include <process.h>

main()
{
   double pomyx,zrpom,hranice,xsour,ysour,vel;
   double krokx,kroky,cr,ci,zr,zi,zr2,zi2;
   int i,j,pocet,maxx,maxy,maxcolor,limit,GraphDriver,GraphMode,color;

   pomyx=1;
   limit=100;
   hranice=4;
   xsour=ysour=vel=0;
   cr=ci=zr=zi=0;

   printf("\n\n\n\n\n\n\n\n         Mandelbrotova mno‘ina\n");
   printf("         =====================\n\n");
   printf("   Mandelbrotova mno‘ina je grafick‚ zobrazen¡\n");
   printf("     iterace z:=z*z + c v komplexn¡ rovinˆ.\n\n");
   printf("P©¡klady zad n¡ parametr–:\n\n");
   printf("X = - 3.0          Y = - 2.5         V = 15\n");
   printf("X = - 0.1354       Y = 0.9825        V = 0.0166\n");
   printf("X = - 0.7026       Y = 0.3451        V = 0.069\n");
   printf("X = - 0.762314     Y = 0.082855      V = 3.223 E-6\n");
   printf("X = - 0.7623125    Y = 0.08285587    V = 2.015 E-7\n");
   printf("X = - 0.762312634  Y = 0.082855815   V = 7.0   E-8\n\n\n");
   printf("Zadejte sou©adnici X: ");
   scanf("%lf",&xsour);
   printf("\nZadejte sou©adnici Y: ");
   scanf("%lf",&ysour);
   do
   {
      printf("\nZadejte velikost    : ");
      scanf("%lf",&vel);
   }
   while (vel<0);
   GraphDriver=DETECT;
   initgraph(&GraphDriver,&GraphMode,"");
   if (GraphDriver==CGA) setgraphmode(0);
   maxx=getmaxx()+1;
   maxy=getmaxy()+1;
   maxcolor=getmaxcolor();
   printf("\n\n     Cekejte-probiha kresleni !");
   printf("\n\n     Souradnice X = %g",xsour);
   printf("\n\n     Souradnice Y = %g",ysour);
   printf("\n\n     Velikost   V = %g",vel);
   if (vel<1.e-3) {if (vel<1.e-7) limit=300; else limit=200;} else limit=100;
   if (vel>.1) limit=20;
   krokx=vel/maxx;
   kroky=krokx/pomyx;
   for(i=0;i!=maxx-1;i++)
   {
      cr=xsour+i*krokx;
      for (j=0;j!=maxy-1;j++)
      {
	 ci=ysour+j*kroky;
	 zr=zi=zr2=zi2=pocet=0;
	 if (kbhit()){if (getch()==3) exit(0);};
         do
	 {
             zrpom=zr2-zi2+cr;
	     zi=2*zr*zi+ci;
	     zr=zrpom;
	     pocet++;
	     zr2=zr*zr;
	     zi2=zi*zi;
	 }
	 while (pocet != limit && zr2+zi2<hranice);


	 if (pocet>limit-10 ) color=maxcolor;
	 if (pocet<limit-9) color=(pocet % (maxcolor+1));
         putpixel(i,maxy-j-1,color);
      }
   }
   do {} while (!kbhit());
   return(0);
}


