PROGRAM Pakovani;

{volnˆ podle programu "LZSS.C - A Data Compression Program 4/6/1989"
 autora Haruhiko Okumura (Japonsko)}

USES Dos, Crt;

CONST
      BufferSize            = 4096;              {delka cyklick‚ho bufferu}
      Null                  = BufferSize;
      MatchLimit            = 18;                {max. d‚lka shody}
      Threshold             = 2;                 {min. d‚lka shody, pro kterou
                                                  stoj¡ za to prov‚st k¢dov n¡}
CONST
      TextSize       : word = 0;                 {d‚lka vstup. posloupnosti}
      CodeSize       : word = 0;                 {zak¢dovan  d‚lka}
      PrintCount     : word = 0;                 {‡¡ta‡ pro tisk "zivaka"}
VAR
      TextBuf        : ARRAY [0..BufferSize+MatchLimit-1] OF byte;
                                                 {kruhov˜ buffer}
      MatchPosit     : word;                     {poloha shody}
      MatchLen       : word;                     {d‚lka shody}
      LSon           : ARRAY [0..BufferSize] of word;
      RSon           : ARRAY [0..BufferSize+256] OF word;
      Dad            : ARRAY [0..BufferSize] of word;

      InFile,OutFile : FILE OF byte;

PROCEDURE InitTree;                              {inicializace hledac¡ho stromu}
VAR i                : word;
BEGIN
  {Pro i:=0..BufferSize-1 jsou RSon[i] a LSon[i] prav˜ a lev˜ syn uzlu i
   a Dad[i] je jeho otec. Inicializuji se na Null.
   Pro j:=0..255 je RSon[j+BufferSize+1] ko©enem stromu pro
   stringy za‡¡naj¡c¡ znakem "j". Inicializuji se na Null.
   Strom– tedy je 256.}
FOR i:=BufferSize+1 TO BufferSize+256 DO
    RSon[i] := Null;
FOR i:=0 TO BufferSize-1 DO
    Dad[i] := Null;
END;

PROCEDURE InsertNode(R:word);
LABEL NalezenRozdil, VelmiDlouhaShoda;
VAR i                : word;
    p                : word;                     {ukazatel do stromu}
    Cmp              : integer;
    Key              : byte;
BEGIN
  {Vkl d  string d‚lky MatchLimit, le‘¡c¡ v TextBuf[R..R+MatchLimit-1],
   do TextBuf[R]-t‚ho stromu a vrac¡ pozici a d‚lku nejdel¨¡ shody.
   Je-li d‚lka shody rovna MatchLimit, odstran¡ star˜ uzel ve prospˆch
   nov‚ho, proto‘e star˜ by byl vypu¨tˆn d©¡ve. V¨imnˆte si, ‘e R hraje
   dvoj¡ roli - jako ko©en stromu a jako pozice v bufferu.}
Cmp := 1;
Key := TextBuf[R];
p   := BufferSize+Key+1;
RSon[R] := Null;
LSon[R] := Null;
MatchLen := 0;

REPEAT
     IF Cmp>=0 THEN
          IF RSon[p]<>Null THEN
               p := RSon[p]
          ELSE
               BEGIN
               RSon[p] := R;
               Dad[R]  := p;
               Exit;
               END
     ELSE
          IF LSon[p]<>Null THEN
               p := LSon[p]
          ELSE
               BEGIN
               LSon[p] := R;
               Dad[R]  := p;
               Exit;
               END;
     i := 1;
     WHILE i<MatchLimit DO
          BEGIN
          Cmp := TextBuf[R+i]-TextBuf[p+i];
          IF Cmp<>0 THEN GoTo NalezenRozdil;
          i := i+1;
          END;

NalezenRozdil:
     IF i>MatchLen THEN
          BEGIN
          MatchPosit := p;
          MatchLen := i;
          IF MatchLen >= MatchLimit THEN
               GoTo VelmiDlouhaShoda;
          END;
UNTIL FALSE;

VelmiDlouhaShoda:
Dad[R] := Dad[p];
LSon[R] := LSon[p];
RSon[R] := RSon[p];
Dad[ LSon[p] ] := R;
Dad[ RSon[p] ] := R;
IF RSon[ Dad[p] ]=p THEN
     RSon[ Dad[p] ] := R
ELSE
     LSon[ Dad[p] ] := R;
Dad[p] := Null;                                  {odstranit p}
END;

PROCEDURE DeleteNode(P:word);                    {odstranit uzel P ze stromu}
VAR q                : word;
BEGIN
IF Dad[P]=Null THEN Exit;                        {nen¡ uvnit© stromu}
IF RSon[P]=Null THEN
     q := LSon[p]
ELSE IF LSon[P]=Null THEN
     q := RSon[P]
ELSE
     BEGIN
     q := LSon[p];
     IF RSon[q]<>Null THEN
          BEGIN
          REPEAT
               q := RSon[q];
          UNTIL RSon[q]=Null;
          RSon[ Dad[q] ] := LSon[q];
          Dad[ LSon[q] ] := Dad[q];
          LSon[q] := LSon[p];
          Dad[ LSon[p] ] := q;
          END;
     RSon[q] := RSon[p];
     Dad[ RSon[p] ] := q;
     END;
Dad[q] := Dad[p];
IF RSon[ Dad[p] ]=p THEN
     RSon[ Dad[p] ] := q
ELSE
     LSon[ Dad[p] ] := q;
Dad[p] := Null;
END;

PROCEDURE Encode;
VAR  i               : word;
     C               : byte;
     Len             : word;
     r               : word;
     s               : word;
     LastMatchLen    : byte;
     CodeBufPtr      : byte;

     CodeBuf         : ARRAY [0..16] OF byte;
     Mask            : byte;

BEGIN
InitTree;                                        {inicializace stromu}
CodeBuf[0] := 0;                                 {CodeBuf[1..16] obsahuje 8 slov
                                                  k¢du a CodeBuf[0] funguje jako
                                                  8 bit–, v nich‘ "1" znamen 
                                                  nek¢dovan˜ znak a "0" znamen 
                                                  dvojici <pozice;d‚lka>(= 2 B)}
Mask := 1;
CodeBufPtr := 1;
s := 0;
r := BufferSize-MatchLimit;
FOR i := s TO r-1 DO
     TextBuf[i] := $20;                          {buffer naplnit jak˜mkoliv
                                                  ‡asto se vyskytuj¡c¡m znakem}
Len := 0;
WHILE (Len<MatchLimit)AND(not Eof(InFile)) DO
     BEGIN
     read(InFile,TextBuf[r+Len]);                {do posledn¡ch MatchLimit znak–
                                                  TextBuf na‡¡st MaxLimit bajt–}
     Len := Len+1;
     END;
TextSize := Len;
IF Len=0 THEN Exit;                              {soubor nulov‚ d‚lky}
FOR i := 1 TO MatchLimit DO
     InsertNode(r-i);                            {vlo‘it MatchLimit string–,
                                                  z nich‘ ka‘d˜ za‡¡n  jednou ‡i
                                                  v¡ce mezerami. Po©ad¡ jejich
                                                  generov n¡ je takov‚, ‘e je
                                                  m‚nˆ pravdˆpodobn‚ vytvo©en¡
                                                  degenerovan˜ch strom–}
InsertNode(r);                                   {nakonec se vlo‘¡ cel˜ pr vˆ
                                                  na‡ten˜ string a nastav¡ se
                                                  glob ln¡ promˆnn‚ MatchLen
                                                  a MatchPosition}
REPEAT
     IF MatchLen>Len THEN                        {na konci InFile m–‘e MatchLen}
          MatchLen := Len;                       {obsahovat fale¨n˜ £daj}
     IF MatchLen<=Threshold THEN                 {shoda p©¡li¨ kr tk }
          BEGIN
          MatchLen := 1;                         {vy¨le se 1 bajt}
          CodeBuf[0] := CodeBuf[0] OR Mask;      {v CodeBuf je 1 bajt}
          CodeBuf[CodeBufPtr] := TextBuf[r];
          CodeBufPtr := CodeBufPtr+1;            {vyslat nek¢dovan˜ znak}
          END
     ELSE
          BEGIN                                  {shoda dostate‡n }
          CodeBuf[CodeBufPtr] := Lo(MatchPosit);
          CodeBufPtr := CodeBufPtr+1;
          CodeBuf[CodeBufPtr] := ( Hi(MatchPosit) SHL 4)
                                   OR (MatchLen-Threshold-1);
          CodeBufPtr := CodeBufPtr+1;
          END;
     Mask := (Mask SHL 1) AND $FF;               {masku p©esunout o bit vlevo}
     IF Mask=0 THEN
          BEGIN
          FOR i := 0 TO CodeBufPtr-1 DO
               write(OutFile,CodeBuf[i]);        {zapsat max. CodeBufPtr bajt–}
          CodeSize := CodeSize+CodeBufPtr;
          CodeBuf[0] := 0;
          Mask := 1;
          CodeBufPtr := 1;
          END;
     LastMatchLen := MatchLen;
     i := 0;
     WHILE (i<LastMatchLen) AND (not Eof(InFile)) DO
          BEGIN
          read(InFile,C);
          DeleteNode(s);                         {zru¨it star‚ stringy}
          TextBuf[s] := C;                       {na‡¡st dal¨¡ bajty}
          IF s<MatchLimit-1 THEN
               TextBuf[s+BufferSize] := C;       {na konci bufferu pro
                                                  jednodu¨¨¡ test}
          s := (s+1) AND (BufferSize-1);
          r := (r+1) AND (BufferSize-1);         {proto‘e to je kruhov˜ buffer,
                                                  p©i‡¡t m s MODULO BufferSize}
          InsertNode(r);                         {zav‚st string do
                                                  TextBuf[r..r+MatchLimit]-1}
          i := i+1;
          END;
     TextSize := TextSize+i;
     IF TextSize>PrintCount THEN
          BEGIN
          write('.');                            {indikuje funkci programu}
          PrintCount := PrintCount+1024;
          END;

     WHILE i<LastMatchLen DO                     {za koncem textu se nic ne‡te}
          BEGIN                                  {ale buff.nesm¡ z–stat pr zdn˜}
          i := i+1;
          DeleteNode(s);
          s := (s+1) AND (BufferSize-1);
          r := (r+1) AND (BufferSize-1);         {proto‘e to je kruhov˜ buffer,
                                                  p©i‡¡t m s MODULO BufferSize}
          Len := Len-1;
          IF Len<>0 THEN
               InsertNode(r);
          END;
UNTIL Len<=0;                                    {dokud d‚lka stringu nen¡ = 0}

IF CodeBufPtr>1 THEN
     BEGIN                                       {vyslat zb˜vaj¡c¡ k¢d}
     FOR i := 0 TO CodeBufPtr-1 DO
          write(Outfile, CodeBuf[i]);
     CodeSize := CodeSize+CodeBufPtr;
     END;
writeln;
writeln ('Vstup:  ',TextSize,' Bajt–,');
writeln ('V˜stup: ',CodeSize,' Bajt–.');
writeln ('Kompresn¡ pomˆr: ',CodeSize/TextSize:5:2);
writeln;
END;

PROCEDURE Decode;                                {obr cen˜ postup ke k¢dov n¡}
VAR  i               : byte;
     k               : word;
     Delka           : byte;
     Pozice          : word;
     r               : word;
     c               : byte;
     Flags           : word;
BEGIN
FOR k := 0 TO BufferSize-MatchLimit-1 DO
     TextBuf[k] := $20;
r := BufferSize-MatchLimit;
Flags := 0;
REPEAT
     Flags := Flags SHR 1;
     IF (Flags AND $100)=0 THEN
          BEGIN
          IF Eof(InFile) THEN
               Exit;
          read(InFile,C);
          Flags := c OR $FF00;                   {vy¨¨¡ bajt Flags je ‡¡t. do 8}
          END;
     IF (Flags AND 1)=0 THEN
          BEGIN                                  {dvojice poloha/d‚lka}
          IF Eof(InFile) THEN
               Exit;
          read(InFile,i,Delka);
          Pozice := i OR ((Delka AND $F0) SHL 4);
          Delka := (Delka AND $0f)+Threshold;
          FOR k := 0 TO Delka DO
               BEGIN
               c := TextBuf[(Pozice+k)And(BufferSize-1)];
               write(OutFile,c);
               TextBuf[r] := c;
               r := (r+1) AND (BufferSize-1);
               END;
          END
     ELSE
          BEGIN                                  {samostatn˜ bajt}
          IF Eof(InFile) THEN
               Exit;
          read(InFile,C);
          write(OutFile,c);
          TextBuf[r] := c;
          r := (r+1) AND (BufferSize-1);
          END;
UNTIL FALSE;
END;

{**************************** hlavn¡ program *********************************}

VAR c : string;

BEGIN
IF ParamCount<>3 THEN
     BEGIN
     writeln('"KOMPRESS K Vstup V˜stup" zak¢duje Vstup do V˜stup');
     writeln('"KOMPRESS D Vstup V˜stup" dek¢duje Vstup do V˜stup');
     writeln;
     Halt;
     END
ELSE
     BEGIN
     assign ( InFile,ParamStr(2)); reset  (InFile);
     assign (OutFile,ParamStr(3)); rewrite(OutFile);
     c := ParamStr(1);
     IF UpCase(c[1])='K' THEN
          EnCode;
     IF UpCase(c[1])='D' THEN
          Decode;
     Close (OutFile);
     Close (InFile);
     END;
END.
