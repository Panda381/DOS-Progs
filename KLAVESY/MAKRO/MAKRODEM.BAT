@echo off
makro !                             ; odinstalovani stare verze z pameti > nul
makro b 1600                        ; instalace do pameti, buffer 1600 B > nul
makro r makrodem.mac m ALT-$1234    ; nacteni ukazkoveho souboru maker   > nul
echo.
echo Makroklavesy:  ALT-kurzory ......... posun o 6 kroku
echo                CTRL-{TAB} .......... vlozeni 8 mezer do textu
echo                SHIFT-CTRL-{TAB} .... posun o 8 pozic vlevo
echo                {F12} ............... ukazkovy text
echo                CTRL-{F11} .......... spusteni DOS Manazeru
echo                CTRL-{F12} .......... odinstalovani programu MAKRO
echo Klavesnice je nyni predefinovana jako cesky psaci stroj. K vygenerovani
echo carky nad pismenem stisknete klavesu {=+} a potom pismeno, k vygenerovani
echo hacku a krouzku stisknete SHIFT-{=+} a pismeno. Stiskem klavesy {1!}, 
echo {2@} nebo {3#} po klavese {=+} lze prepnout typ klavesnice:
echo      {1!}=normalni,  {2@}=programatorska,  {3#}=pisarska.
echo.
