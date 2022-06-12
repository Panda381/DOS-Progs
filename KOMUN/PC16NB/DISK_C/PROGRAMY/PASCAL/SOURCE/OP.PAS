unit Starwind;

interface
uses crt;

CONST single='ÚÄ¿³ÙÄÀ³';
      double='ÉÍ»º¼ÍÈº';
      up=true;
      down=false;
TYPE  Style=string[8];
      str80=string[80];

PROCEDURE WritAT(x,y,ink,paper:byte;s:str80);
PROCEDURE CheckKey(zn:char);
PROCEDURE NoCurs;
PROCEDURE Curs(x,y:byte);
PROCEDURE PushWindow;
PROCEDURE PopWindow(dispse:boolean);
PROCEDURE MWindow(num,x1,y1,x2,y2:byte;st:style);
PROCEDURE Remove;
PROCEDURE Select(NUM:byte);
PROCEDURE Title(tx:str80;where:boolean);

implementation

CONST vidram=$b800;
      actwind:byte=0;
      actrange:array[1..4] of byte=(2,2,17,12);
      actattr:byte=0;
      maxbuf=150;
      numwind:byte=0;

TYPE  stri=string[maxbuf];
      Point=^Brfr;
          Brfr=record
                 str:stri;
                 next:point
               end;
      Point1=^W1;
        W1=record
             no:byte;
             kde,obsah:point;
             range:array[1..4] of byte;
             attr:byte;
             next:point1
           end;
      Stack=^P2;
        p2=record
             obs:byte;
             next:stack
           end;
VAR   buf:point;
      windows,windowse:point1;
      stac:stack;

FUNCTION AddrXY(x,y:byte):word;
begin
  AddrXY:=x*2+y*160
end;

FUNCTION Attrib(ink,paper:byte):byte;
begin
  ink:=ink and $0f;
  paper:=paper and $0f;
  Attrib:=ink or (paper shl 4)
end;

PROCEDURE WritAT(x,y,ink,paper:byte;s:str80);
var i,atr:byte; a:word;
begin
  atr:=attrib(ink,paper);
  a:=addrXY(x,y);
  for i:=1 to ord(s[0]) do begin
                              mem[vidram:a]:=ord(s[i]);
                              mem[vidram:a+1]:=atr;
                              a:=a+2
                            end;
end;

PROCEDURE CheckKey(zn:char);
var key:char;
begin
  zn:=UpCase(zn);
  repeat key:=UpCase(ReadKey) until key=zn
end;

PROCEDURE Pushs(a:byte);
var q:stack;
begin
  if actwind=0 then stac:=nil;
  q:=stac; new(stac);stac^.next:=q;
  stac^.obs:=a
end;

PROCEDURE Pops(var a:byte);
var q:stack;
begin
  if stac=nil then exit;
  q:=stac^.next;
  a:=stac^.obs;
  dispose(stac);stac:=q;
end;

FUNCTION NajdiPol(n:byte):Point1;
var p:point1;
begin
  p:=windowse;
  while(p<>nil) and (p^.no<>n) do p:=p^.next;
  NajdiPol:=p
end;

PROCEDURE NoCurs;
begin
  inline($55/$b4/$01/$b5/$10/$30/$c9/$cd/$10/$5d);
end;

PROCEDURE Curs(x,y:byte);
begin
inline($55/$89/$e5/$8a/$4e/$06/$8a/$6e/$08/$80/
       $e5/$07/$80/$e1/$07/$b4/$01/$cd/$10/$5d);
end;


PROCEDURE DrawBorder(color:byte;st:style);
var a:word;  i,j,x1,y1,x2,y2:byte;
begin
  x1:=actrange[1];y1:=actrange[2];x2:=actrange[3];y2:=actrange[4];
  a:=AddrXY(x1,y1);
  mem[vidram:a]:=ord(st[1]);
  mem[vidram:a+1]:=color; a:=a+2;
  for i:=x1+1 to x2-1 do
  begin
    mem[vidram:a]:=ord(st[2]);
    mem[vidram:a+1]:=color;
    a:=a+2
  end;
  mem[vidram:a]:=ord(st[3]);
  mem[vidram:a+1]:=color;a:=a+160;
  for j:=y1+1 to y2-1 do
  begin
    mem[vidram:a]:=ord(st[4]);
    mem[vidram:a+1]:=color;
    a:=a+160
  end;
  mem[vidram:a]:=ord(st[5]); mem[vidram:a+1]:=color;
  a:=a-2;
  for i:=x2-1 downto x1+1 do
  begin
    mem[vidram:a]:=ord(st[6]);mem[vidram:a+1]:=color;
    a:=a-2
  end;
  mem[vidram:a]:=ord(st[7]); mem[vidram:a+1]:=color;
  a:=a-160;
  for j:=y2-1 downto y1+1 do
  begin
    mem[vidram:a]:=ord(st[8]); mem[vidram:a+1]:=color;
    a:=a-160
  end
end;

PROCEDURE PushWindow;
var a:word;
    c,col,row:byte;
    pozn:point;
BEGIN
  a:=AddrXY(actrange[1],actrange[2]);
  c:=1;
  new(buf);
  buf^.next:=nil; pozn:=buf;
  for row:=0 to actrange[4]-actrange[2] do
  begin
    for col:=0 to 2*(actrange[3]-actrange[1])+1 do
    begin
      buf^.str[c]:=chr(mem[vidram:a]);
      a:=a+1;
      if c=maxbuf then
      begin
        new(buf);
        buf^.next:=pozn;
        pozn:=buf;c:=1;
      end
      else c:=c+1;
    end;
    a:=a-col+160-1;
  end;
  buf^.str[0]:=chr(c-1)
end;

PROCEDURE PopWindow(dispse:boolean);
var a:word;
    c,col,row:byte;
    pozn:point;
BEGIN
  inline($fa);
  a:=AddrXY(actrange[3],actrange[4])+1;
  c:=ord(buf^.str[0]); pozn:=buf;
  for row:=0 to actrange[4]-actrange[2] do
  begin
    for col:=0 to 2*(actrange[3]-actrange[1])+1 do
    begin
      mem[vidram:a]:=ord(buf^.str[c]);
      a:=a-1;
      if c=1 then
      begin
        buf:=buf^.next;
        if dispse=true then dispose(pozn);
        pozn:=buf; c:=maxbuf
      end
      else c:=c-1
    end;
    a:=a+col-160+1
  end;
  inline($fb);
end;

PROCEDURE MWindow(num,x1,y1,x2,y2:byte;st:style);
var color:byte; a:word;
BEGIN
  color:=TextAttr;
  if numwind=0 then windowse:=nil;
  new(windows); windows^.next:=windowse;windowse:=windows;
  with windows^ do  begin
                     no:=num;
                     range[1]:=x1;range[2]:=y1;range[3]:=x2;range[4]:=y2;
                     obsah:=nil
                   end;
  numwind:=succ(numwind);
  pushs(num);
  actrange[1]:=x1; actrange[2]:=y1; actrange[3]:=x2; actrange[4]:=y2;
  PushWindow;
  actwind:=num;
  windows^.kde:=buf;
  Window(x1+2,y1+2,x2,y2);
  TextColor(color and $0f); TextBackGround((color and $70)shr 4);
  ClrScr;
  DrawBorder(color,st)
end;

PROCEDURE Remove;
var p:Point;
begin
  if actwind=0 then begin writat(10,10,yellow,red,'*ERROR no actived window*');exit
                    end;
  windows:=NajdiPol(actwind);
  if windows^.obsah=nil then
  begin
    PushWindow;
    Windows^.obsah:=buf;
  end;
  buf:=windows^.kde;
  Pops(actwind);
  Pops(actwind);
  if actwind=0 then begin PopWindow(true); Window(0,0,79,24); Exit end;
  Pushs(actwind);
  PopWindow(true);
  windows:=NajdiPol(actwind);
  buf:=windows^.kde;
  with windows^ do
  begin
    window(range[1]+2,range[2]+2,range[3],range[4]);
    actrange[1]:=range[1];actrange[2]:=range[2];
    actrange[3]:=range[3];actrange[4]:=range[4]
  end;
end;

PROCEDURE Select(NUM:byte);
var pb1,pb2:point1;
begin
  Pushs(num);
  windows:=Najdipol(num);
  with windows^ do
  begin
    actwind:=num;
    actrange[1]:=range[1];actrange[2]:=range[2];
    actrange[3]:=range[3];actrange[4]:=range[4];
    window(range[1]+2,range[2]+2,range[3],range[4])
  end;
  pushwindow;
  windows^.kde:=buf;
  buf:=windows^.obsah;
  PopWindow(false);
  GotoXY(0,0);
end;

PROCEDURE Title(tx:str80;where:boolean);
var a:word; x,y,i:byte;
begin
  x:=1+(actrange[3]-actrange[1]-ord(tx[0]))div 2+actrange[1];
  if where then y:=actrange[2]
           else y:=actrange[4];
  a:=addrxy(x,y);
  mem[vidram:a-2]:=ord(' ');mem[vidram:a-1]:=TextAttr;
  for i:=1 to ord(tx[0]) do begin
                              mem[vidram:a]:=ord(tx[i]);
                              mem[vidram:a+1]:=TextAttr;
                              a:=a+2
                            end;
  mem[vidram:a]:=ord(' ');mem[vidram:a+1]:=TextAttr;
end;
end.


