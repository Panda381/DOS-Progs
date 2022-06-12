TexGen v1.19 - generátor textur
(c) 2015 Miroslav Nìmeèek

projekt: www.breatharian.eu/TexiGen
www: panda38.sweb.cz
email: Panda38@seznam.cz
portfolio: www.shutterstock.com/g/PandaWild


Licenèní podmínky použití aplikace TexiGen
-----------------------------------------

Aplikace TexiGen je volnì k dispozici jako FREEWARE a lze ji volnì šíøit a používat pro soukromé i komerèní úèely. Textury vytvoøené pomocí aplikace TexiGen a generátorù v aplikaci obsažených je možné bez omezení prodávat, s jednou výjimkou - nesmí být prodávány textury vygenerované z cizích variant a z implicitních variant nastavení generátorù, protože varianty jsou duševním vlastnictvím jejich autorù. Pro úèely prodeje textur je nutné vygenerovat vlastní varianty nastavení generátorù. Uvedené nemusí platit automaticky pro generátory od jiných autorù, kteøí si stanovují své licenèní podmínky.

K programu TexiGen jsou volnì k dispozici jeho zdrojové kódy a mohou být využívány v jiných soukromých i komerèních projektech. V pøípadì vytvoøení modifikace programu je nutné viditelnì odlišit modifikovanou verzi od pùvodní verze, aby bylo zøejmé, že se jedná o modifikovanou verzi, a také uvést ze kterého projektu modifikace vycházela.

Aplikace TexiGen je poskytována v takové formì v jaké je, se známými i neznámými chybami. Autor nenese žádnou zodpovìdnost za pøípadné následky vzniklé použitím aplikace, ani za následky vzniklé chybnou funkcí aplikace.


Známé chyby a nedostatky
------------------------

- chybí undo/redo
- chybí podpora clipboard
- po nìjaké dobì editace se pøestanou zobrazovat táhla (a i prvky v oknì výbìru barev), program se musí spustit znovu
- nedostateèné ošetøení chyby pøi naèítání generátoru
- v Blur je obraz špatnì posunutý (proti Image jakoby uskakoval doleva dolù)
- nedostateènì funkèní Emboss filtr, odlesky a stíny nevypadají realisticky
- možná nemá Image pøesné souøadnice, výstup se liší od originálu
- obsluha scrolování myši
- pravým tlaèítkem lokální menu
- možnost minimalizovat program bìhem renderování (=dialog souèástí okna)
- zobrazení èísla varianty (vedle titulku Variace)
- relativní cesty RelToAbsPath, AbsToRelPath, aby cesty nebyly souèástí generátoru (generátor se pak nedá pøenést jinam)
- Includes filtry - ve složce _Includes (zobrazí se v nabídce také jako filtry - mìly by mít v názvu verzi)
- smyèka - opravit havarování (teï je ošetøeno s Level < 100) pøi položení výstupu LoopEnd na Source LoobBeg.
- bloky - filtr bloku má v sobì graf filtrù, v _Blocks jsou knihovny blokù (jsou to normální filtry), v bloku mùže být vnoøený další blok
- integrovaný obrázek se zachováním komprimovaných formátù
- cache filtr (pøedrenderuje obrázek v nastaveném rozlišení - absolutní rozlišení nebo relativnì k výstupnímu rozlišení)


Vývoj verzí
-----------

14.10.2014 v1.0 - Lite verze omezená na textury 1024x1024

16.10.2014 v1.01 - Mutování variant, práce s renderovací frontou (rušení, priorita, odhad èasu).

17.10.2014 v1.02 - Priorita náhledù.

18.10.2014 v1.03 - Oprava filtru Particle (posun obrazu), filtry souøadnice a náhody Particle, filtr náhody.

20.10.2014 v1.10 - Uvolnìní plné verze programu do Freeware.

22.10.2014 v1.11 - Filtr snìhové vloèky.

28.10.2014 v1.12 - Filtry Percentile a Lookup.

 4.11.2014 v1.13 - Generování videa, oprava hranic Bevel Profile.

 9.11.2014 v1.14 - Vylepšení funkce filtrù Blur, HighPass a Percentile.

14. 1.2015 v1.15 - Zrychlena obsluha vstupních obrázkù (naètou se do pamìti - vyšší nároky na pamì). Sdílení obrázkù mezi renderovacími vlákny (snížení nárokù na pamì). Ošetøení nenaèteného obrázku (obrázek lze i vypnout). Podpora vstupu z obrázkù TGA, BMP, PNG a JPG, pouze 24bitové RGB formáty, u TGA a PNG navíc 32bitový RGBA, TGA i komprimovaný formát. Možnost automatické konverze renderovaného obrázku na JPG. Inverze zámkù vlastností generátoru. F9 vybírá náhodnì i vstupní obrázky v zadané složce. 

 5. 2.2015 v1.16 - Filtr Tussock, filtr Cut, pøepínaè AlphaMod u Blend.

12. 2.2015 v1.17 - Èeská nápovìda a tutoriály.

 3. 3.2015 v1.18 - Filtry Deform a Enform. Možnost naèítat a zpracovávat video filtrem Video.

 8. 3.2015 v1.19 - Filtr Fractal.
