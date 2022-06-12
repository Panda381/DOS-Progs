
type
  mmods=(_text,
         _text2,
         _text4,
         _pl2 ,   {plain mono, 8 pixels per byte}
         _pl2e,   {mono odd/even, 8 pixels per byte, two planes}
         _herc,   {Hercules mono, 4 "banks" of 8kbytes}
         _cga2,   {CGA 2 color, 2 "banks" of 16kbytes}
         _cga4,   {CGA 4 color, 2 "banks" of 16kbytes}
         _pl4 ,   {4 color odd/even planes}
         _pk4 ,   {4 color "packed" pixels 4 pixels per byte}
         _pl16,   {std EGA/VGA 16 color: 4 planes, 8 pixels per byte}
         _pk16,   {ATI mode 65h two 16 color pixels per byte}
         _p256,   {one 256 color pixel per byte}
         _p32k,   {Sierra 15 bit}
         _p64k,   {Sierra 16bit/XGA}
         _p16m);  {RGB 3bytes per pixel}

  modetype=record
             md,xres,yres,bytes:word;
             memmode:mmods;
           end;

  CHIPS=(__EGA,__VGA,__chips451,__chips452,__chips453,__paradise,__video7
        ,__tseng3,__tseng4,__tridBR,__tridCS,__trid89,__everex,__ati1,__ati2
        ,__genoa,__oak,__cirrus,__aheadA,__aheadB,__ncr,__yamaha,__poach
        ,__s3,__al2101,__acumos,__mxic,__vesa,__realtek,__p2000,__cirrus54
        ,__xga,__none);


const
  colbits:array[mmods] of integer=
               (0,0,0,1,1,1,1,2,2,2,4,4,8,15,16,24);
  modecols:array[mmods] of longint=
               (0,0,0,2,2,2,2,4,4,4,16,16,256,32768,65536,16777216);


  coltxt:array[mmods] of string[3]=('1','1','1','2','2','2','2'
             ,'4','4','4','16','16','256','32k','64k','16m');


  mdtxt:array[mmods] of string[210]=('Text','2 color Text','4 color Text'
                ,'Monochrome','2 colors planar','Hercules','CGA 2 color','CGA 4 color'
                ,'4 colors planar','4 colors packed','16 colors planar','16 colors packed'
                ,'256 colors packed','32768 colors','65536 colors'
                ,'16777216 colors');

  mmodenames:array[mmods] of string[4]=('TXT ','TXT2','TXT4','PL2 ','PL2E','HERC'
              ,'CGA2','CGA4','PL4 ','PK4 ','PL16','PK16','P256','P32K','P64K','P16M');


  header:array[CHIPS] of string[14]=
         ('EGA','VGA','Chips&Tech','Chips&Tech','Chips&Tech'
         ,'Paradise','Video7','ET3000','ET4000'
         ,'Trident','Trident','Trident','Everex','ATI','ATI'
         ,'Genoa','Oak','Cirrus','Ahead','Ahead','NCR'
         ,'Yamaha','Poach','S3','AL2101','Acumos','MXIC'
         ,'VESA','Realtek','PRIMUS','Cirrus54','XGA','');




type
  regblk=record
           base:word;
           nbr:word;
           x:array[0..255] of byte;
         end;


  regtype=record
            chip:chips;
            mmode:mmods;
            mode,pixels,lins,bytes,tridold0d,tridold0e:word;
            attregs:array[0..31] of byte;
            seqregs,grcregs,crtcregs,xxregs:regblk;
            stdregs:array[$3c0..$3df] of byte;
            xgaregs:array[0..15] of byte;
          end;


var
  f:file of regtype;
  fo:text;
  s:string;

  xxs,ix,off:word;
  mxcrtc,mxseq,mxattr,mxgrf,mxxtra,xtraix:word;
  xx:array[1..50] of regtype;

const hx:array[0..15] of char='0123456789ABCDEF';

function hex2(w:word):string;
begin
  hex2:=hx[(w shr 4) and 15]+hx[w and 15];
end;

function hex4(w:word):string;
begin
  hex4:=hx[w shr 12]+hx[hi(w) and 15]+hx[(w shr 4) and 15]+hx[w and 15];
end;

function gtbyte(var s:string):word;
var i,j:word;
begin
  while copy(s,1,1)=' ' do delete(s,1,1);
  i:=(ord(s[1])-48) and 31;if i>9 then dec(i,7);
  j:=(ord(s[2])-48) and 31;if j>9 then dec(j,7);
  delete(s,1,2);
  gtbyte:=i*16+j;
end;

function gtword(var s:string):word;
var i,j:word;
begin
  i:=gtbyte(s);
  j:=gtbyte(s);
  gtword:=i*256+j;
end;

function gtval(var s:string):longint;
var x,z:word;
  y:longint;
begin
  x:=pos(': ',s);
  delete(s,1,x+1);
  x:=pos(' ',s);if x=0 then x:=length(s)+1;
  val(copy(s,1,x-1),y,z);
  delete(s,1,x);
  gtval:=y;
end;


var
  parms:word;
  parm:array[1..256] of word;
  parmsame:boolean;
  parmstr:string;

procedure setstr(s:string);
begin
  parms:=0;
  parmstr:=s;
  parmsame:=true;
end;

procedure adds(w:word);
begin
  inc(parms);
  parm[parms]:=w;
  if parm[1]<>w then parmsame:=false;
end;

function getstr:string;
var x:word;
begin
  if parmsame then parms:=1;
  for x:=1 to parms do
    parmstr:=parmstr+' '+hex4(parm[x]);
  getstr:=parmstr;
end;


var x,y:word;
    l:longint;

begin
  assign(f,'register.vga');
  reset(f);
  xxs:=0;ix:=0;off:=0;xtraix:=0;
  mxcrtc:=0;mxattr:=31;mxseq:=0;mxgrf:=0;mxxtra:=0;
  fillchar(xx,sizeof(xx),0);
  while not eof(f) do
  begin
    inc(xxs);
    read(f,xx[xxs]);
    if xx[xxs].seqregs.nbr>mxseq then mxseq:=xx[xxs].seqregs.nbr;
    if xx[xxs].grcregs.nbr>mxgrf then mxgrf:=xx[xxs].grcregs.nbr;
    if xx[xxs].crtcregs.nbr>mxcrtc then mxcrtc:=xx[xxs].crtcregs.nbr;
    if xx[xxs].xxregs.base<>0 then
    begin
      xtraix:=xx[xxs].xxregs.base;
      if xx[xxs].xxregs.nbr>mxxtra then mxxtra:=xx[xxs].xxregs.nbr;
    end;
  end;
  close(f);

  assign(fo,'register.tbl');
  rewrite(fo);
  write(fo,'Mode:   ');
  for y:=1 to xxs do write(fo,hex4(xx[y].mode):5);
  writeln(fo);
  write(fo,'Pixels: ');
  for y:=1 to xxs do write(fo,xx[y].pixels:5);
  writeln(fo);
  write(fo,'Lines:  ');
  for y:=1 to xxs do write(fo,xx[y].lins:5);
  writeln(fo);
  write(fo,'Bytes:  ');
  for y:=1 to xxs do write(fo,xx[y].bytes:5);
  writeln(fo);
  write(fo,'Colors: ');
  for y:=1 to xxs do write(fo,coltxt[xx[y].mmode]:5);
  writeln(fo);
  if xx[1].chip in [__tridBR,__tridCS,__trid89,__poach] then
  begin
    setstr('OLD 0D: ');
    for y:=1 to xxs do adds(xx[y].tridold0d);
    writeln(fo,getstr);
    setstr('OLD 0E: ');
    for y:=1 to xxs do adds(xx[y].tridold0E);
    writeln(fo,getstr);
  end;

  setstr('03CC   :');
  for y:=1 to xxs do adds(xx[y].stdregs[$3CC]);
  writeln(fo,getstr);
  setstr('03DA   :');
  for y:=1 to xxs do adds(xx[y].stdregs[$3DA]);
  writeln(fo,getstr);


  for x:=0 to mxattr do
  begin
    setstr('ATTR '+hex2(x)+':');
    for y:=1 to xxs do adds(xx[y].attregs[x]);
    writeln(fo,getstr);
  end;
  for x:=0 to mxSEQ do
  begin
    setstr('SEQ '+hex2(x)+': ');
    for y:=1 to xxs do adds(xx[y].seqregs.x[x]);
    writeln(fo,getstr);
  end;
  for x:=0 to mxgrf do
  begin
    setstr('GRF '+hex2(x)+': ');
    for y:=1 to xxs do adds(xx[y].grcregs.x[x]);
    writeln(fo,getstr);
  end;
  for x:=0 to mxcrtc do
  begin
    setstr('CRTC '+hex2(x)+':');
    for y:=1 to xxs do adds(xx[y].crtcregs.x[x]);
    writeln(fo,getstr);
  end;
  if xtraix<>0 then
    for x:=0 to mxxtra do
    begin
      setstr(hex4(xtraix)+' '+hex2(x)+':');
      for y:=1 to xxs do adds(xx[y].xxregs.x[x]);
      writeln(fo,getstr);
    end;
  close(fo);
end.

