program KonVen;
uses Crt;

{P©evod textu v k¢du Kamenick˜ch z textov‚ho editoru Kontext do
 Ventura Publishing.
 
 Transformace textu prob¡haj¡ podle schematu:

 Kontext - V˜znam               Ventura Publishing
 ____________________________________________________________________
  0        nadsazen¡ on/off          <^>    akce ©e¨eny p©¡kazem case
  1        podsazen¡ on/off          <v>    pro k¢dy 0-6
  2        kursiva on/off            <I>
  3        podtr‘en¡ on/off          <U>
  4        zv˜raznˆn˜ tisk on/off    <B>
  5        inversn¡ p¡smo (int.)     ign. ''
  6x6      rozdˆlen¡ x-              x<->
  6-       pohyb. rozdˆlovac¡ znak   <->
  7        p©ech. rozdˆlen¡ pro - jako zadan˜ znak na konci © dku.
           Tento znak se kop¡ruje na v˜stup. Mezery na dal¨¡m © dku
           se ignoruj¡.
  8,9      bez v˜znamu               ign. ''
  10       LF, ve skupinˆ CR LF      ign. v˜znam VP: konec paragrafu
  11,12    bez v˜znamu               ign. ''
  13       CR, ve skupinˆ CR LF      ign. v˜znam VP: konec paragrafu
  14,15    bez v˜znamu               ign. ''
  16       za‡ tek odstavce          ign. ''
  17       konec odstavce            ign. ''
  18,19,20 bez v˜znamu               ign. ''
  21,173   znak paragraf             VP ©etˆz <185>
  26       EOF konec souboru         chr(26)
  27..30   bez v˜znamu               ign. ''
  31       za‡. neform. odstavce     ign. '' mezery se neru¨¡ do <17>
  60       <                         <<
  62       >                         >>
  250      pevn  mezera              <N> non-breaking space
  255      n sl. znak s dvoj. ¨¡©kou ign. ''
  158                               <158>
  169      ©                         <169>
  250      pevn  mezera              <N>

 Jin‚ znaky se p©ev dˆj¡ na v˜stup beze zmˆny. Ukon‡en¡ ur‡it‚
 funkce se pro VP vyzna‡¡ <D> (v¨echny funkce) nebo funkci ukon-
 ‡¡ jin  volba. Volby se mohou v <...> sdru‘ovat.

 Program d le p©ev d¡ v tabulk ch (mezi znaky za‡ tku a konce ta-
 bulky) grafick‚ znaky º, ³, Â atd. na tabel tory a © dky tabulky
 kon‡¡ jako odstavce VP (CRLFCRLF). Z toho lze ve VP tabulku zre-
 konstruovat po vhodn‚m nastaven¡ tabel tor–, proto‘e tabulky jsou
 ozna‡eny (voliteln˜mi) jm‚ny. V textu m–‘e b˜t na ur‡it˜ch © dc¡ch
 jen jedna tabulka a p©ed n¡ zleva ani za n¡ vpravo nesm¡ b˜t u‘
 dal¨¡ text, jak to ukazuje schema:

           ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      bez  ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ bez
    textu  ³  jen jedna³ tabulka na © dku            ³ textu
           ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
           ³           ³                             ³
           ³           ³                             ³
           ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 To nen¡ omezen¡m obecnosti: Je-li v £seku v¡ce tabulek nebo text,
 uprav¡ se tento obsah prostˆ na jednu tabulku a podle vlo‘en˜ch 
 tabel tor– se z¡sk  ve VP pot©ebn‚ uspo© d n¡. Rozum¡ se, ‘e for-
 m t v¨ech © dk– v tabulce mus¡ b˜t stejn˜; p©i zmˆnˆ form tu je 
 t©eba definovat novou tabulku.
 
 V s t u p e m  pro program je jen specifikace vstupn¡ho (p©ev -
 dˆn‚ho) souboru a specifikace v˜stupn¡ho souboru. Tyto parametry
 lze zadat jako extern¡; nejsou-li zad ny jako extern¡, budou vy-
 ‘ d ny v pr–bˆhu programu.

 Autor: S. Dvo© k, OVS Tesla Ro‘nov
 Datum: 9/90, zpracov n¡ tabulky doplnˆno 10/7/91.
 Jazyk: Turbo Pascal 5.5                                }

var
  Fin,Fout: file;
  inspec,outspec: string[80];
  inbuf: array [1..8192] of byte;
  outbuf: array[0..16384] of byte;
  inblk,outblk,rest,i,j,k: word;
  S: string;
  Str4: string[4];
  errpos: integer;
  cc,c,dc,len: byte;
  ch: char;
  IgnSpc,Expnt,Index,Ital,UndLn,Bold: boolean; {p©ep¡na‡e typu p¡sma}
  Use: array[0..255] of byte;
  InTab: boolean;                     {p©ep¡na‡ vnˆ - uvnit© tabulky}
  TrS,TabStr: string[10];
  TabInd: word;
  TabindC: string[4];
  TabLen: byte;

label NewCh;

const
  igsize=20;
  IgnVal: array[1..igsize] of byte =
    (8,9,11,12,13,14,15,16,18,19,20,22,23,24,25,27,28,29,30,255);
  VertCh: array[1..30] of byte=
        (179,180,181,182,183, 184,185,186,187,191,
         192,193,194,195,197, 198,199,200,202,203,
         204,206,207,208,209, 210,211,212,215,216);
  TabBg:  array[1..4] of byte=(201,213,214,218);
  TabEnd: array[1..4] of byte=(188,189,190,217);
  LF=10;
  Space=32;
  SoftBreak: string[3]='<->';
  Less: string[2]='<<';
  Greater: string[2]='>>';
  BigR: string[5]='<158>';              { v ‡e¨tinˆ Kamenick˜ch}
  DelSym: string[3]='<D>';
  ParSym: string[4]=chr(13)+chr(10)+chr(13)+chr(10);
  FxSpace: string[3]='<N>';
  Parag: string[5]='<185>';             {znak paragrafu pro 21 a 173}

{ ------------------------------------------------------------------- }
procedure GetChar;
{Procedura ‡te dal¨¡ znak do c jako byte.}
begin
  if i<inblk then begin Inc(i); c:=inbuf[i] end
  else Blockread(Fin,c,1,rest)
end;

procedure GetSym;
begin
 while inbuf[k]=Space do Inc(k);
 S:=''; while inbuf[k]<>Space do begin S:=S+chr(inbuf[k]); Inc(k) end
end;

{$V- R- A+}
procedure UpCon(var S: string);
var sx: byte;
begin
 for sx:=1 to length(S) do S[sx]:=UpCase(S[sx])
end;

procedure Vent;
{Procedura vytv ©¡ znakov˜ ©etˆz pro ©¡zen¡ VP. U‘¡vaj¡ se
 indik tory  zapnut˜ch funkc¡. Nen¡-li ‘ dn  funkce Ital, Bold,...
 aktivn¡, vytvo©¡ se ©etˆz <D>. Ten vznikne i po LF, je-li
 nˆkter  funkce aktivn¡.}

begin
 S:='<';
 if Expnt then S:=S+'^';
 if Index then S:=S+'V';
 if Ital then S:=S+'I';
 if UndLn then S:=S+'U';
 if Bold then S:=S+'B';
 if length(S)=1 then S:=S+'D';
 S:=S+'>';
 Move(S[1],outbuf[j],length(S)); Inc(j,ord(S[0]));
end;

procedure AppOff;      {Vypnut¡ Appearance p©¡znak–}
begin
 if Expnt or Index or Ital or UndLn or Bold then
   begin
     Move(DelSym[1],outbuf[j],3); Inc(j,3);
     Expnt:=false; Index:=false; Ital:=false; UndLn:=false; Bold:=false
   end
end;

begin
  TabInd:=0; IgnSpc:=true;
  for i:=0 to 255 do Use[i]:=1;
  for i:=1 to igsize do begin c:=IgnVal[i]; Use[c]:=0 end;
  for i:=1 to 30     do begin c:=VertCh[i]; Use[c]:=2 end;
  for i:=1 to 4      do begin c:=TabBg[i];  Use[c]:=3 end;
  for i:=1 to 4      do begin c:=TabEnd[i]; Use[c]:=4 end;

  TextColor(LightGreen); TextBackGround(Black);
  writeln; writeln;
  writeln('P  E V O D   K O N T E X T --> V E N T U R A');
  writeln('_____________________________________________');
  TextColor(LightGray);
  if ParamCount>0 then
  begin
    inspec:=ParamStr(1); outspec:=ParamStr(2)
  end
  else
  begin
    writeln;
    writeln('Program nyn¡ vy‘ d  £plnou  specifikaci vstupn¡ho a v˜stup-');
    writeln('n¡ho (p©eveden‚ho) souboru. Pokud se v p©ev dˆn‚m textu na-');
    writeln('jde znak za‡ tku tabulky, zad te jej¡ jm‚no. Zadejte p©esnˆ');
    writeln('jm‚no, kter‚ odpov¡d  form tu tabulky (nap©. jsou-li v tex-');
    writeln('tu ‡ty©i tabulky 1, 2, 2, 1 dvou form t– 1,2, zadejte nap©.');
    writeln('jm‚na T1,T2,T2,T1, jak o nˆ program po‘ d . P©edpokl d  se,');
    writeln('‘e grafick‚ znaky  (kter‚ Ventura v k¢du Kam. ignoruje) ne-');
    writeln('jsou v p©ev dˆn‚m textu pou‘ity mimo tabulky. Pokud se zad ');
    writeln('p©i  po‘adavku na  jm‚no jen <Enter>, pou‘ije se jako jm‚no');
    writeln('tabulky TBp, kde p je po©ad¡ tabulky v textu. Jm‚na se p©e-');
    writeln('vedou do velk˜ch p¡smen, tj. mal  a velk  p¡smena se v nich');
    writeln('nerozli¨uj¡. Jm‚no za‡¡n  p¡smenem angl. abecedy, v dal¨¡ch');
    writeln('m¡stech mohou b˜t p¡smena nebo ‡¡slice. Jm‚na u‘ijte kr tk .');
    writeln;
    write('Specifikace vstupn¡ho souboru:  ');
    TextAttr:=$0A; Readln(inspec); TextAttr:=7;
    write('Specifikace v˜stupn¡ho souboru: ');
    TextAttr:=$0A; Readln(outspec);
  end;
  TextAttr:=7;

 {$I-}
   Assign(Fin,inspec); Reset(Fin,1);
   while IOResult<>0 do
   begin
     TextAttr:=12; writeln('Soubor ',inspec,' nelze otev©¡t.');
     TextAttr:=7;
     writeln('Zadejte specifikaci znovu nebo <Enter> pro ukon‡en¡.');
     write('Specifikace vstup. souboru: ');
     TextAttr:=$0A; Readln(inspec); TextAttr:=7;
     if inspec='' then Halt(1);
     Assign(Fin,inspec); Reset(Fin,1);
   end;
 {$I+}

 {Vstupn¡ soubor p©ipraven ke zpracov n¡.}

 {$I-}
   Assign(Fout,outspec); Rewrite(Fout,1);
   while IOResult<>0 do
   begin
     TextAttr:=12; writeln('Soubor ',outspec,' nelze otev©¡t.');
     TextAttr:=7;
     writeln('Zadejte specifikaci znovu nebo <Enter> pro ukon‡en¡.');
     write('Specifikace v˜st. souboru: ');
     TextAttr:=$0A; Readln(outspec); TextAttr:=7;
     if outspec='' then Halt(1);
     Assign(Fout,outspec); Rewrite(Fout,1);
   end;
 {$I+}

 {V˜stupn¡ soubor p©ipraven ke zpracov n¡. €te se z hlav¡
  CONTEXT left_mg right_mg heading footing pgsize}

  {$R+} BlockRead(Fin,inbuf[1],8192,inblk); {$R-}
  k:=1; Getsym;
  if S='CONTEXT' then
  begin
    GetSym; GetSym; GetSym; Val(S,i,errpos);
    GetSym; Val(S,j,errpos);
    Inc(i,j+1);     {tolik LF naj¡t na likvidaci pat a z hlav¡}
    for j:=1 to i do
    begin while inbuf[k]<>10 do Inc(k); Inc(k) end
  end
  else k:=1;  {k ukazuje na prvn¡ znak, co se m  ‡¡st}

 {Transformace souboru za‡¡n ....}

 Expnt:=false; Index:=false; Ital:=false;
 UndLn:=false; Bold:=false;  Intab:=false;
 i:=k-1; outbuf[0]:=0;   {i..ukazatel na posledn¡ ‡ten˜ znak}

 repeat
   j:=1;
   {j..voln  pozice ve v˜stupu, i..posl. ‡ten  pozice vstupu}
   while i<inblk do   {i..posledn¡ ‡ten˜ znak z Inbuf}
   begin
     Inc(i); c:=inbuf[i];
NewCh:
     case c of
      32: if IgnSpc then
	  begin
	    if outbuf[j-1]<>Space then
	    begin outbuf[j]:=c; Inc(j) end
	  end
	  else begin outbuf[j]:=c; Inc(j) end;
       0..4: begin
         repeat
           case c of
             0: Expnt:=not Expnt;     {nadsazen¡}
             1: Index:=not Index;     {podsazen¡}
             2: Ital:=not Ital;       {kursiva}
             3: UndLn:=not UndLn;     {podtr‘en¡}
             4: Bold:=not Bold;       {tu‡n‚ p¡smo}
           end;
           GetChar;
         until c>4;
         Vent; goto NewCh
         end;
       6:begin
	   GetChar;
	   if c=ord('-') then  {rozdˆlen¡ na konci © dku}
           begin
             GetChar; GetChar; {pro 6 ignor. CR LF za - na konci © dku}
             repeat GetChar until c<>Space; {ignorov n¡ p©¡p. mezer}
             Move(SoftBreak[1],outbuf[j],3); Inc(j,3); AppOff;
             goto NewCh
           end;
	   outbuf[j]:=c; Inc(j); GetChar; {vnit©n¡ dˆlen¡ se sledem 6X6}
	   Move(SoftBreak[1],outbuf[j],3); Inc(j,3)
	 end;
      7: begin  {zadan‚ - uvnit© slova na konci © dku}
           GetChar; Outbuf[j]:=c; Inc(j);    {- na v˜stup}
           GetChar; GetChar; {pro 6 ignor. CR LF za - na konci © dku}
           repeat GetChar until c<>Space; {ignorov n¡ p©¡p. mezer}
           goto NewCh
         end;
     10: begin
           AppOff;  {p©i LF vypneme v¨echny atributy textu}
           if InTab then   {Line Feed - konec © dku a jsme v tabulce}
	   begin
             Move(ParSym[1],outbuf[j],4); Inc(j,4); {konec odstavce}
             Move(TabStr[1],outbuf[j],TabLen); Inc(j,TabLen) {nov˜ © dek tab.}
           end
           else  {mus¡me nahradit LF mezerou, aby byla slova oddˆlena}
           begin
             cc:=outbuf[j-1];
             if (cc<>Space) and (cc<>LF) then
	     begin
               outbuf[j]:=Space; Inc(j)
             end
           end
         end;
     17: begin                    {konec odstavce}
	   AppOff; Move(ParSym[1],outbuf[j],4); Inc(j,4);
	   IgnSpc:=true;
	 end;
    158: begin Move(BigR[1],outbuf[j],5); Inc(j,5) end;
    169..172:
      begin
        Str(c:3,TrS); TrS:='<'+TrS+'>';
        Move(TrS[1],outbuf[j],5); Inc(j,5)
      end;
    250: begin Move(FxSpace[1],outbuf[j],3); Inc(j,3) end;
    21,173: begin Move(Parag[1],outbuf[j],5); Inc(j,5) end;
     26: begin outbuf[j]:=26; Inc(j) end;
     31: begin IgnSpc:=false; end;     {neform. odstavec}
     60: begin Move(Less[1],outbuf[j],2); Inc(j,2) end;
     62: begin Move(Greater[1],outbuf[j],2); Inc(j,2) end
    else
    case Use[c] of
     {0: ignorov n¡ znaku}
     1: begin outbuf[j]:=c; Inc(j) end; {kop¡rov n¡ znaku na v˜stup}
     2: if InTab then                   {v¨echny svisl‚ tabulkov‚ znaky}
        begin
          outbuf[j]:=9; Inc(j)          {se zmˆn¡ na tabel tory}
	end;
     3: begin
          InTab:=true;                  {po‡ te‡n¡ znak tabulky}
          Inc(TabInd);
          write('Jm‚no ',TabInd,'. tabulky v textu: ');
          TextAttr:=$0A; readln(TabStr); TextAttr:=7;
          if TabStr='' then
          begin
            Str(TabInd,TabIndC);
            TabStr:='@TB'+TabIndC+' = '
          end
          else TabStr:='@'+TabStr+' = ';
          TabLen:=Length(TabStr); UpCon(TabStr);
          
          if (j>4) then
          begin
            Move(outbuf[j-4],Str4,4);
            if Str4<>ParSym then
            begin
              AppOff; Move(ParSym[1],outbuf[j],4); Inc(j,4);
            end          {dopln¡me konec odstavce, kdy‘ nep©edch z¡}
          end
          else AppOff;
          Move(TabStr[1],outbuf[j],TabLen);
          Inc(j,TabLen);                      {nov˜ © dek tabulky}
          outbuf[j]:=9; Inc(j)   {po‡. znak se zmˆn¡ na tabel tor}
        end;
     4: begin
          InTab:=false;                 {koncov˜ znak tabulky}
          outbuf[j]:=9; Inc(j);         {se zmˆn¡ na tabel tor}
          Move(ParSym[1],outbuf[j],4); Inc(j,4);
        end
      end                               {of inner case}
    end;                                {of outer case}
  end;                                  {of while loop}
  Dec(j); outbuf[0]:=outbuf[j];
  BlockWrite(Fout,outbuf[1],j,outblk);
  if not eof(Fin) then
  begin
   {$R+} BlockRead(Fin,inbuf[1],8192,Inblk); {$R-} i:=0
  end
  else Inblk:=0;
 until Inblk=0;
 Close(Fin);
 Close(Fout);
 writeln('KonVen: P©evod dokon‡en. <Enter>.'); readln
end.
