
uses dos,crt,supervga;

const
  copyright='WHATVGA v. 1.50   18/jan/94    Copyright 1991-94  Finn Thoegersen';

  SWversion = 1500;    {1495 = 1.49e, 1500 = 1.50}

  menuchars:array[1..55] of char=
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&()[]{}-_=+/?';

var
  af_fil:file;
  af_buf:array[0..2048] of byte;
  af_pos:word;
  af_rec:_AT2;
  af_cmt:string;
  af_tst:_AT3;
  af_fail:boolean;
  af_filename:string[12];

procedure AddAFbuf(var b;bytes:word);
begin
  move(b,af_buf[af_pos],bytes);
  inc(af_pos,bytes);
end;

procedure WrAFbuf(typ:byte);
begin
  af_buf[0]:=typ;
  move(af_pos,af_buf[1],2);
  blockwrite(af_fil,af_buf,af_pos);
  close(af_fil);
  reset(af_fil,1);        {Flushes file output}
  seek(af_fil,filesize(af_fil));
  af_pos:=3;
end;

function getComment(tx:string):string;
var s,s1:string;
begin
  writeln('Please enter '+tx+' (max 3 lines):');
  s:='';s1:='';
  readln(s1);
  s1:=strip(s1);
  if s1<>'' then
  begin
    s:=s1;
    readln(s1);s1:=strip(s1);
    if s1<>'' then
    begin
      s:=s+' '+s1;
      readln(s1);s1:=strip(s1);
      if s1<>'' then
      begin
        s:=s+' '+s1;
        writeln;
      end;
    end;
  end;
  getComment:=s;
end;

function getYN:boolean;
const YN:array[0..1] of string[3]=('No','Yes');
var ret:integer;
begin
  ret:=-1;
  repeat
    case getkey of
      ord('y'),ord('Y'):ret:=1;
      ord('n'),ord('N'):ret:=0;
                 ch_esc:ret:=0;
    end;
  until ret>-1;
  getYn:=boolean(ret);
  writeln(YN[ret]);
  if ret=0 then af_fail:=true;
end;


procedure InitAFFile(cursel:word);
var x:word;
  hdr:_AT0;
  mm:mmods;
begin
  x:=0;
  repeat
    inc(x);     {Find first free file number}
    af_filename:='WHVGA'+istr(x)+'.TST';
    assign(af_fil,af_filename);
    {$i-}
    reset(af_fil,1);
    {$i+}
    if ioresult=0 then close(af_fil) else x:=0;
  until x=0;
  rewrite(af_fil,1);
  af_pos:=3;
  af_fail:=false;

  hdr.SWvers := SWversion;
  hdr.vid_sys:= Vids;
  hdr.cur_vid:= cursel;
  getFtime(af_fil,hdr.curtime);
  AddAFbuf(hdr,sizeof(hdr));

  af_cmt:=getComment('your Email address');
  AddAFbuf(af_cmt,length(af_cmt)+1);

  af_cmt:=getComment('your name & address');
  AddAFbuf(af_cmt,length(af_cmt)+1);
  af_cmt:=getComment('your video&monitor description');
  AddAFbuf(af_cmt,length(af_cmt)+1);
  af_cmt:=getComment('your system description');
  AddAFbuf(af_cmt,length(af_cmt)+1);

  af_cmt:='';
  for mm:=_text to _p32 do   {Build the Mode Name table}
    af_cmt:=af_cmt+copy(mmodenames[mm]+'    ',1,4);
  AddAFbuf(af_cmt,length(af_cmt)+1);

  WrAFbuf(0);
end;


function getmenkey:integer;
var x,c:word;
begin
  c:=getkey;
  if (c>=ord('a')) and (c<=ord('z')) then c:=c-32;
  getmenkey:=0;
  for x:=1 to 55 do
    if chr(c)=menuchars[x] then getmenkey:=x;
  if c=Ch_Esc then getmenkey:=-1;
end;


procedure clearmemory;
var x,y,maxbank:word;
begin
  case memmode of
    _text,_text2,_text4:
          begin
            {mov es,[vseg]  cld  xor di,di  mov ax,$720  mov cx,$4000  rep stosw}
            inline($8e/6/>vseg/$fc/$31/$ff/$B8/>$720/$B9/>$4000/$f3/$ab);
          end;
     _cga1,_cga2:
          fillchar(mem[$B800:0],$8000,0);
_pl2,_pl4:begin
            wrinx(GRC,0,0);
            wrinx(GRC,1,15);    (* planar modes *)
            wrinx(GRC,8,255);
            modinx(GRC,5,3,0);
            maxbank:=pred(mm div 256);
          end;
  else maxbank:=pred(mm div 64);
  end;
  if memmode>_cga2 then
    for x:=0 to maxbank do
    begin
      setbank(x);
      {mov es,[vseg]  cld  xor di,di  xor ax,ax  mov cx,$8000  rep stosw}
      inline($8e/6/>vseg/$fc/$31/$ff/$31/$C0/$B9/>$8000/$f3/$ab);
    end;
end;


procedure setpix(x,y:word;col:longint);
const
  msk:array[0..7] of byte=(128,64,32,16,8,4,2,1);
  plane :array[0..1] of byte=(5,10);
  plane4:array[0..3] of byte=(1,2,4,8);
  mscga4:array[0..3] of byte=($3f,$cf,$f3,$fc);
  shcga4:array[0..3] of byte=(6,4,2,0);
var l:longint;
    m,z:word;
begin
  case memmode of
   _cga1:begin
           z:=(y shr 1)*bytes+(x shr 3);
           if odd(y) then inc(z,8192);
           mem[$b800:z]:=(mem[$b800:z] and (255 xor msk[x and 7]))
                         or ((col and 1) shl (7-(x and 7)));
         end;
   _cga2:begin
           z:=(y shr 1)*bytes+(x shr 2);
           if odd(y) then inc(z,8192);
           mem[$b800:z]:=(mem[$b800:z] and mscga4[x and 3])
                         or (col and 3) shl shcga4[x and 3];
         end;
    _pl1:begin
           l:=y*bytes+(x shr 3);
           wrinx(GRC,3,0);
           wrinx(GRC,5,2);
           wrinx(SEQ,2,1);
           wrinx(GRC,8,msk[x and 7]);
           setbank(l shr 16);
           z:=mem[vseg:word(l)];
           mem[vseg:word(l)]:=col;
         end;
   _pl1e:begin
           l:=y*bytes+(x shr 3);
           modinx(GRC,5,3,0);
           wrinx(SEQ,2,15);
           wrinx(GRC,0,col*3);
           wrinx(GRC,1,3);
           wrinx(GRC,8,msk[x and 7]);
           z:=mem[vseg:word(l)];
           mem[vseg:word(l)]:=0;
         end;
    _pl2:begin
           l:=y*bytes+(x shr 4);
           wrinx(GRC,3,0);
           wrinx(GRC,5,2);
           wrinx(SEQ,2,plane[(x shr 3) and 1]);
           wrinx(GRC,8,msk[x and 7]);
           setbank(l shr 16);
           z:=mem[vseg:word(l)];
           mem[vseg:word(l)]:=col;
         end;
    _pk2:begin
           l:=y*bytes+(x shr 2);
           setbank(l shr 16);
           z:=mem[vseg:word(l)] and mscga4[x and 3];
           mem[vseg:word(l)]:=z or (col shl shcga4[x and 3]);
         end;
    _pl4:begin
           l:=y*bytes+(x shr 3);
           wrinx(GRC,3,0);
           wrinx(GRC,5,2);
           wrinx(GRC,8,msk[x and 7]);
           setbank(l shr 16);
           z:=mem[vseg:word(l)];
           mem[vseg:word(l)]:=col;
         end;
    _pk4:begin
           l:=y*bytes+(x shr 1);
           setbank(l shr 16);
           z:=mem[vseg:word(l)];
           if odd(x) then z:=z and $f+(col shl 4)
                     else z:=z and $f0+col;
           mem[vseg:word(l)]:=z;
         end;
     _p8:begin
           l:=y*bytes+x;
           setbank(l shr 16);
           mem[vseg:word(l)]:=col;
         end;
   _p15,_p16:
         begin
           l:=y*bytes+(x shl 1);
           setbank(l shr 16);
           memw[vseg:word(l)]:=col;
         end;
    _p24:begin
           l:=y*bytes+(x*3);
           z:=word(l);
           m:=l shr 16;
           setbank(m);
           if z<$fffe then move(col,mem[vseg:z],3)
           else begin
             mem[vseg:z]:=lo(col);
             if z=$ffff then setbank(m+1);
             mem[vseg:z+1]:=lo(col shr 8);
             if z=$fffe then setbank(m+1);
             mem[vseg:z+2]:=col shr 16;
           end;
         end;
    _p32:begin
           l:=y*bytes+(x shl 2);
           setbank(l shr 16);
           meml[vseg:word(l)]:=col;
         end;
    else ;
  end;
end;

function whitecol:longint;
var col:longint;
begin
  case memmode of
    _cga1,_pl1e,
     _pl1:col:=1;
    _cga2,_pk2
    ,_pl2:col:=3;
    _pk4,_pl4,
      _p8:col:=15;
     _p15:col:=$7fff;
     _p16:col:=$ffff;
_p24,_p32:col:=$ffffff;
  else
  end;
  whitecol:=col;
end;


procedure wrtext(x,y:word;txt:string);      {write TXT to pos (X,Y)}
type
  pchar=array[char] of array[0..15] of byte;
var
  p:^pchar;
  c:char;
  i,j,z,b:integer;
  ad,bk:word;
  l,v,col:longint;
begin
  rp.bh:=6;
  vio($1130);
  case memmode of
    _cga1,_pl1e,
     _pl1:col:=1;
    _cga2,_pk2
    ,_pl2:col:=3;
    _pk4,_pl4,
      _p8:col:=15;
     _p15:col:=$7fff;
     _p16:col:=$ffff;
_p24,_p32:col:=$ffffff;
  else
  end;
  p:=ptr(rp.es,rp.bp);
  for z:=1 to length(txt) do
  begin
    c:=txt[z];
    for j:=0 to 15 do
    begin
      b:=p^[c][j];
      for i:=0 to 7 do
      begin
        if (b and 128)<>0 then v:=col else v:=0;
        setpix(x+i,y+j,v);
        b:=b shl 1;
      end;
    end;
    inc(x,8);
  end;
end;


  function rgb(r,g,b:word):longint;
  begin
    r:=lo(r);g:=lo(g);b:=lo(b);
    case colbits[memmode] of
       1:rgb:=r and 1;
       2:rgb:=r and 3;
       4:rgb:=r and 15;
       8:rgb:=r;
      15:rgb:=((r shr 3) shl 5+(g shr 3)) shl 5+(b shr 3);
      16:rgb:=((r shr 3) shl 6+(g shr 2)) shl 5+(b shr 3);
      24:rgb:=(longint(r) shl 8+g) shl 8 +b;
    end;
  end;



procedure plotchar(x,y,ch:word);
begin
  mem[vseg:(y*pixels+x) shl 1]:=ch;
end;

procedure plotchat(x,y,ch,at:word);
begin
  memw[vseg:(y*pixels+x) shl 1]:=at shl 8+ch;
end;

procedure plotstr(x,y:word;s:string);
var z:word;
begin
  for z:=1 to length(s) do
    plotchar(x+z-1,y,ord(s[z]));
end;


procedure drawtestpattern(nam:string);
                       {Draw Test pattern.}
var s:string;
  l:longint;
  x,y,yst:word;
  white:longint;

  procedure wline(stx,sty,ex,ey:integer;col:longint);
  var x,y,d,mx,my:integer;
     l:longint;
  begin
    if sty>ey then
    begin
      x:=stx;stx:=ex;ex:=x;
      x:=sty;sty:=ey;ey:=x;
    end;
    y:=0;
    mx:=abs(ex-stx);
    my:=ey-sty;
    d:=0;
    repeat
      if col=0 then l:=rgb(y,y,y) else l:=col;
      y:=(y+1) and 255;
      setpix(stx,sty,l);
      if abs(d+mx)<abs(d-my) then
      begin
        inc(sty);
        d:=d+mx;
      end
      else begin
        d:=d-my;
        if ex>stx then inc(stx)
                  else dec(stx);
      end;
    until (stx=ex) and (sty=ey);

  end;

begin
  if memmode<=_TEXT4 then
  begin
    {Text modes}

  {  ClearMemory; }
    for x:=0 to pixels-1 do
    begin
      plotchar(x,0,(x mod 10)+ord('0'));
      if (x mod 10)=0 then
        plotchar(x,1,((x div 10) mod 10)+ord('0'));
      plotchar(x,lins-1,ord('.'));
    end;
    for x:=0 to lins-1 do
    begin
      plotchar(0,x,(x mod 10)+ord('0'));
      if (x mod 10)=0 then
        plotstr(0,x,istr(x));
      plotchar(pixels-1,x,ord('.'));
    end;
    plotstr(5,5,nam);
    for x:=0 to 255 do
      plotchat(x and 15+10,x shr 4+7,65,x);
    plotstr((pixels-30) div 2,lins,'This line shouldn''t be seen!!');
  end
  else begin

    white:=whitecol;

    wline(50,30,pixels-50,30 ,0);
    wline(50,lins-30,pixels-50,lins-30 ,0);

    wline(50,30,50,lins-30 ,0);
    wline(pixels-50,30,pixels-50,lins-30 ,0);
    wline(50,30,pixels-50,lins-30 ,0);

    wline(pixels-50,30,50,lins-30 ,0);

    if lins>200 then yst:=50 else yst:=18;
    wrtext(10,yst,name+' with '+istr(mm)+' Kb.');
    wrtext(10,yst+25,nam);

    for x:=1 to (pixels-10) div 100 do
    begin
      for y:=1 to 10 do
        setpix(x*100,y,white);
      wrtext(x*100+3,1,istr(x));
    end;

    for x:=1 to (lins-10) div 100 do
    begin
      for y:=1 to 10 do
        setpix(y,x*100,white);
      wrtext(1,x*100+2,istr(x));
    end;

    case memmode of
       _pk2,
       _pl2:for x:=0 to 63 do
              for y:=0 to 63 do
                setpix(30+x,yst+y+50,y shr 3);
      _pk4,
       _pl4:for x:=0 to 127 do
              if lins<250 then
                for y:=0 to 63 do
                  setpix(30+x,yst+y+50,y shr 2)
              else
                for y:=0 to 127 do
                  setpix(30+x,yst+y+50,y shr 3);
        _p8:for x:=0 to 127 do
              if lins<250 then
                for y:=0 to 63 do
                  setpix(30+x,yst+50+y,((y shl 2) and 240) +(x shr 3))
              else
                for y:=0 to 127 do
                  setpix(30+x,yst+50+y,((y shl 1) and 240)+(x shr 3));

      _p15,_p16,_p24,_p32:
            if pixels<600 then
            begin
              for x:=0 to 63 do
              begin
                for y:=0 to 63 do
                begin
                  setpix(30+x,100+y,rgb(x*4,y*4,0));
                  setpix(110+x,100+y,rgb(x*4,0,y*4));
                  setpix(190+x,100+y,rgb(0,x*4,y*4));
                end;
              end;
              for x:=0 to 255 do
                for y:=170 to 179 do
                begin
                  setpix(x,y   ,rgb(x,0,0));
                  setpix(x,y+10,rgb(0,x,0));
                  setpix(x,y+20,rgb(0,0,x));
                end;
            end
            else begin
              for x:=0 to 127 do
                for y:=0 to 127 do
                begin
                  setpix( 30+x,120+y,rgb(x*2,y*2,0));
                  setpix(200+x,120+y,rgb(x*2,0,y*2));
                  setpix(370+x,120+y,rgb(0,x*2,y*2));
                end;
              for x:=0 to 511 do
                for y:=260 to 269 do
                begin
                  setpix(x,y   ,rgb(x shr 1,0,0));
                  setpix(x,y+10,rgb(0,x shr 1,0));
                  setpix(x,y+20,rgb(0,0,x shr 1));
                end;
            end;

    end;
    wline(0,0,10, 0 ,whitecol);
    wline(0,0, 0,10 ,whitecol);
    wline(0,0,10,10 ,whitecol);

    wline(pixels-11, 0,pixels-1, 0 ,whitecol);
    wline(pixels-1 , 0,pixels-1,10 ,whitecol);
    wline(pixels-11,10,pixels-1, 0 ,whitecol);

    wline(0,lins-11, 0,lins-1  ,whitecol);
    wline(0,lins-1 ,10,lins-1  ,whitecol);
    wline(0,lins-1 ,10,lins-11 ,whitecol);

    wline(pixels-11,lins-1 ,pixels-1,lins-1 ,whitecol);
    wline(pixels-1 ,lins-11,pixels-1,lins-1 ,whitecol);
    wline(pixels-11,lins-11,pixels-1,lins-1 ,whitecol);
  end;
end;

           (* Writes the string s to 1. line of the mono. screen *)
procedure wrmono(s:string);
var x:word;
begin
  for x:=1 to length(s) do
    mem[$b000:x+x]:=ord(s[x]);
end;

           (* Ensures that xlow<=x<=xhigh *)
procedure chkrange(var x:integer;xlow,xhigh:integer);
begin
  if x<xlow then x:=xlow
  else if x>xhigh then x:=xhigh;
end;

function testvmode:boolean;
var
  s:string;
  r13,sclins,scpixs,scbytes:word;
  x0,y0,x:integer;
  ch:word;
  stop,scrollable,nxt:boolean;

begin
  testvmode:=true;
  s:='Mode: '+hex4(curmode)+'h: '+istr(pixels)+'x'+istr(lins)+' '+mmodenames[memmode];
  drawtestpattern(s);

  if auto_test then af_rec.flag:=1;    {Mode Supported}

  scrollable:=false;
  ch:=getkey;
  if (ch<>Ch_Esc) and not (chr(ch) in ['D','F','d','f']) then
  begin
    if memmode>=_pl4 then
    begin
      scrollable:=true;
      { Scroll test  }
      sclins:=lins;
      scpixs:=pixels;
      scbytes:=bytes;
      r13:=rdinx(crtc,$13);
      if (r13<128) and ((bytes*lins*planes*5 div 2)<mm*longint(1024))
        and (r13>0) and ((bytes div r13) in [1,2,4,8,16])
        and (memmode<>_cga1) and (memmode<>_cga2) then
      begin            {Can we double the screen?}
        wrinx(crtc,$13,r13*2);
        bytes:=bytes*2;
        pixels:=pixels*2;
      end;
      case memmode of
        _text,_text2,_text4:
                lins:=32768 div bytes;
        _cga1,_cga2:
                lins:=16384 div bytes;
           _pl1:lins:=mm*longint(256) div bytes;
      else lins:=mm*longint(1024) div (bytes*planes);
      end;
      case memmode of
   _cga1,_pl1,
         _pl4:pixels:=bytes*8;
        _cga2:pixels:=bytes*4;
         _pk4:pixels:=bytes*2;
          _p8:pixels:=bytes;
    _p15,_p16:pixels:=bytes shr 1;
         _p24:pixels:=bytes div 3;
         _p32:pixels:=bytes shr 2;
      end;

      Clearmemory;

      drawtestpattern(s);
      x0:=0;
      y0:=0;
      stop:=false;

      if auto_test then pushkey(ord('a'));
      repeat
        setvstart(x0,y0);
        case getkey of
            Ch_ArUp:y0:=y0-16;
          Ch_ArLeft:x0:=x0-16;
         Ch_ArRight:x0:=x0+16;
          Ch_ArDown:y0:=y0+16;
            Ch_PgUp:dec(y0);
            Ch_PgDn:inc(y0);
          ord('A'),ord('a'):begin
                              x0:=0;y0:=0;x:=0;
                              repeat
                                setvstart(x0,y0);
                                delay(100);
                                nxt:=false;
                                case x of
                                  0:if x0+16<=pixels-scpixs then inc(x0,16)
                                                           else nxt:=true;
                                  1:if y0+16<=lins-sclins then inc(y0,16)
                                                         else nxt:=true;
                                  2:if x0>=16 then dec(x0,16) else nxt:=true;
                                  3:if y0>=16 then dec(y0,16) else pushkey(ch_esc);
                                end;
                                if nxt then
                                begin
                                  inc(x);
                                  delay(500);
                                end;
                                if peekkey=Ch_Esc then stop:=true;
                              until stop;
                              delay(500);
                            end;
          ord('D'),ord('d'),ord('F'),ord('f'),Ch_Esc,Ch_Cr:stop:=true;
        end;
        chkrange(x0,0,pixels-scpixs);
        chkrange(y0,0,lins-sclins);

      until stop;
      setvstart(0,0);  {Reset start, some chipsets NEED this}
      pixels:=scpixs;
      lins:=sclins;
      bytes:=scbytes;
    end;
    dac2comm;     {Reset DAC}
    outp($3c6,0);
    dac2pel;
    textmode(3);

    writeln('Values for mode '+hex4(curmode)+':');
    writeln;
    write('Pixels per scan line:',pixels:5);
    if pixels<>calcpixels then write(' Calculated:',calcpixels:5);
    writeln;
    write('Lines in image:      ',lins:5);
    if lins<>calclines then write(' Calculated:',calclines:5);
    writeln;
    write('Bytes per scanline:  ',bytes:5);
    if bytes<>calcbytes then write(' Calculated:',calcbytes:5);
    writeln;
    write('Memory mode:         ',mmodenames[memmode]:5);
    if memmode<>calcmmode then write(' Calculated:',mmodenames[calcmmode]:5);
    writeln;
    if memmode<_herc then writeln('Character cell:      ',charwid,'x',charhigh);
    if vclk>0 then
    begin
      writeln;
      write('Clocks: Pixel: ',vclk:7:3,' MHz, Line: ',hclk:7:3
           ,' KHz, Frame: ',fclk:7:3,' Hz');
      if ilace then write(' (i)');
      writeln;
    end;
    if auto_test then
    begin
      pushkey(ch);
      writeln;
      write('Did the mode display properly (y/n): ');
      if getYN then inc(af_rec.flag,2);
      if scrollable then
      begin
        writeln;
        write('Did the mode scroll properly (y/n): ');
        if getYN then inc(af_rec.flag,8)
                 else inc(af_rec.flag,4);
      end;
      af_cmt:=GetComment('any comments to the test');

      af_rec.vseg    :=vseg;
      af_rec.Cpixels :=calcpixels;
      af_rec.Clins   :=calclines;
      af_rec.Cbytes  :=calcbytes;
      af_rec.CMmode  :=calcmmode;
      af_rec.ChWidth :=charwid;
      af_rec.ChHeight:=charhigh;
      af_rec.Cvseg   :=calcvseg;
      af_rec.ExtPixf :=Extpixfact;
      af_rec.Extlinf :=Extlinfact;
      af_rec.vclk    :=vclk;
      af_rec.hclk    :=hclk;
      af_rec.fclk    :=fclk;
      af_rec.ilace   :=ilace;




      pushkey(ch_cr);
    end;



    ch:=getkey;
  end;
  if (ch=ord('D')) or (ch=ord('d')) then ch:=dumpVGAregs;

  case ch of
     Ch_Esc:testvmode:=false;
    ord('f'),ord('F'):
            dumpVGAregfile;
  end;
end;





procedure testcursor;           {Test HardWare Cursor}
var m,x:word;
  md:integer;

procedure setXY(x0,y0:word);
begin
  SetHWcurpos(x0,y0);
  SetHWcurcol(((x0*longint(256) div pixels)*256
          +(y0*longint(256) div lins))*256+$ff,0);
end;

procedure tmode(m:word);
const
  CurMap:CursorType=
     ($00f81f00,$00800130,$00800130,$00800100
     ,$00f00f00,$008c3100,$00824100,$00818100
     ,$80800101,$40800102,$20800104,$21800184
     ,$11800188,$11800188,$11800188,$ffffffff
     ,$ffffffff,$11800188,$11800188,$11800188
     ,$21800184,$20800104,$40800102,$80800101
     ,$00818100,$00824100,$008C3100,$00f00f00
     ,$00800100,$00800100,$00800100,$00f81f00);

var x,x0,y0:integer;
  fgcol,bkcol:longint;
  stop:boolean;
begin
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    drawtestpattern('Mode: '+hex4(curmode)+'h: '+istr(pixels)+'x'
        +istr(lins)+' '+istr(modecols[memmode])+' colors');

    SetHWcurmap(CurMap);

    if auto_test then pushkey(ord('A'));
    stop:=false;
    x0:=100;y0:=150;  {Place it in the palette}
    repeat
      if x0<0 then x0:=0;
      if y0<0 then y0:=0;
      if x0+32>pixels then x0:=pixels-32;
      if y0+32>lins then y0:=lins-32;

      SetXY(x0,y0);
      case getkey of
          Ch_ArUp:dec(y0,17);
        Ch_ArLeft:dec(x0,17);
       Ch_ArRight:inc(x0,17);
        Ch_ArDown:inc(y0,17);
        ord('a'),ord('A'):
                  begin
                    x0:=0;
                    repeat
                      SetXY(x0,150);
                      delay(200);
                      inc(x0,17);
                    until x0>pixels-32;
                    x0:=0;
                    repeat
                      SetXY(200,x0);
                      delay(200);
                      inc(x0,17);
                    until x0>lins-32;
                    stop:=true;
                  end;
     Ch_Cr,Ch_Esc:stop:=true;
      end;
    until stop;
    HWcuronoff(false);
    if auto_test then
    begin
      repeat until keypressed;
      dac2comm;     {Reset DAC}
      outp($3c6,0);
      dac2pel;
      textmode(3);
      write('Did the Hardware Cursor work properly (y/n) ?');
      af_tst.Flag :=ord(getYN);
      af_cmt:=getComment('any comments to the test');

      af_tst.mode :=modetbl[m].md;
      af_tst.Mmode:=modetbl[m].memmode;
      AddAFbuf(af_tst,sizeof(af_tst));
      AddAFbuf(af_cmt,length(af_cmt)+1);
      WrAFbuf(3);
    end;
  end;
end;

begin
  textmode($103);   {43/50 line text mode}
  writeln('Hardware Cursor test.');
  writeln;

  if auto_test then
  begin
    delay(1000);
    pushkey(ord('*'));
  end
  else begin
    writeln('Modes:');
    writeln;
    for m:=1 to nomodes do
      if modetbl[m].memmode>=_pl4 then
      begin
        writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
             +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
      end;
    writeln;

    writeln('  *  All modes');
    writeln;
  end;

  x:=getmenkey;
  for m:=1 to nomodes do
    if ((x=0) or (x=m)) and (modetbl[m].memmode>=_pl4) then tmode(m);

end;



procedure testblit;           {Test BitBLT functions}
var m,x:word;
  md:integer;

procedure tmode(m:word);
var x,y,x0,y0:integer;
  stop:boolean;
begin
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    drawtestpattern('Mode: '+hex4(curmode)+'h: '+istr(pixels)+'x'
        +istr(lins)+' '+istr(modecols[memmode])+' colors');


    case memmode of
 _pl4,_pk4:for x:=0 to 15 do
             fillrect(200,100+x*8,128,8,x);
       _p8:for x:=0 to 255 do
             fillrect(200+(x and 15)*8,100+(x div 16)*8,8,8,x);
   _p15,_p16,_p24:
           for x:=0 to 63 do
           begin
             fillrect(200+(x and 15)*8,100+(x div 16)*8,8,8,rgb(x*4,0,0));
             fillrect(200+(x and 15)*8,132+(x div 16)*8,8,8,rgb(0,x*4,0));
             fillrect(200+(x and 15)*8,164+(x div 16)*8,8,8,rgb(0,0,x*4));
             fillrect(200+(x and 15)*8,196+(x div 16)*8,8,8,rgb(x*4,x*4,x*4));
           end;
    end;

    copyrect(30,50,500,45,128,200);
    copyrect(200,100,332,105,128,128);

    for y:=1 to 8 do
    begin
      y0:=y*10+250;
      fillrect(100,y0,y,8,y);
      x0:=101+y;
      for x:=1 to 15 do
      begin
        fillrect(x0,y0,x,8,y);
        x0:=x0+x+1;
      end;
      fillrect(x0,y0,9-y,8,y);
      y0:=y0+10;
    end;

    if memmode<=_pl4 then   {specaal 16c test pattern}
      for x:=0 to 19 do
      begin
        x0:=96+x*8;
        for y:=0 to 8 do
          setpix(x0,259+10*y,15);
      end;

    if auto_test then
    begin
      repeat until keypressed;
      dac2comm;     {Reset DAC}
      outp($3c6,0);
      dac2pel;
      textmode(3);
      write('Did the BitBLT test work properly (y/n) ?');
      af_tst.Flag :=ord(getYN);
      af_cmt:=getComment('any comments to the test');

      af_tst.mode :=modetbl[m].md;
      af_tst.Mmode:=modetbl[m].memmode;
      AddAFbuf(af_tst,sizeof(af_tst));
      AddAFbuf(af_cmt,length(af_cmt)+1);
      WrAFbuf(4);
    end
    else if getkey=0 then;
  end;
end;

begin
  textmode($103);
  writeln('Hardware BitBLT test.');
  writeln;

  if auto_test then
  begin
    delay(1000);
    pushkey(ord('*'));
  end
  else begin
    writeln('Modes:');
    writeln;
    for m:=1 to nomodes do
      if modetbl[m].memmode>=_pl4 then
      begin
        writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
               +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
      end;
    writeln;

    writeln('  *  All modes');
    writeln;
  end;
  x:=getmenkey;
  for m:=1 to nomodes do
    if ((x=0) or (x=m)) and (modetbl[m].memmode>=_pl4) then tmode(m);
end;


procedure testline;           {Test Line Draw functions}
var x,m:word;
  md:integer;

procedure tmode(m:word);
var x,x0,y0,w:integer;
  stop:boolean;
begin
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    drawtestpattern('Mode: '+hex4(curmode)+'h: '+istr(pixels)+'x'
        +istr(lins)+' '+istr(modecols[memmode])+' colors');

    x0:=pixels div 2;
    y0:=lins div 2;
    for x:=-10 to 9 do
    begin
      case memmode of
   _pl4,_pk4:w:=(x+11) and 15;
         _p8:w:=x+11;
        _p15:w:=$4210+x*$3FF;
        _p16:w:=$8410+x*$7FF;
      end;
      line(x0,y0,x0+x*15,y0-150 ,w);
      line(x0,y0,x0+150 ,y0+x*15,w);
      line(x0,y0,x0-x*15,y0+150 ,w);
      line(x0,y0,x0-150 ,y0-x*15,w);
    end;
    if auto_test then
    begin
      repeat until keypressed;
      dac2comm;     {Reset DAC}
      outp($3c6,0);
      dac2pel;
      textmode(3);
      write('Did the Line Draw test work properly (y/n): ?');
      af_tst.Flag :=ord(getYN);
      af_cmt:=getComment('any comments to the test');

      af_tst.mode :=modetbl[m].md;
      af_tst.Mmode:=modetbl[m].memmode;
      AddAFbuf(af_tst,sizeof(af_tst));
      AddAFbuf(af_cmt,length(af_cmt)+1);
      WrAFbuf(5);
    end
    else if getkey=0 then;
  end;
end;

begin
  textmode($103);
  writeln('Hardware Line Draw test.');
  writeln;

  if auto_test then
  begin
    delay(1000);
    pushkey(ord('*'));
  end
  else begin
    writeln('Modes:');
    writeln;
    for m:=1 to nomodes do
      if modetbl[m].memmode>=_pl4 then
      begin
        writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
               +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
      end;
    writeln;

    writeln('  *  All modes');
    writeln;
  end;

  x:=getmenkey;
  for m:=1 to nomodes do
    if ((x=0) or (x=m)) and (modetbl[m].memmode>=_pl4) then tmode(m);
end;


procedure testRWbank;           {Test R/W bank functions}
var x,m:word;
  md:integer;

procedure tmode(m:word);
var x,wid:integer;
  src,dst:longint;
begin
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    drawtestpattern('Mode: '+hex4(curmode)+'h: '+istr(pixels)+'x'
        +istr(lins)+' '+istr(modecols[memmode])+' colors');

    src:=50*bytes+10;
    dst:=300*bytes+10;
    if memmode=_pl4 then
    begin
      wid:=50;
      modinx(GRC,5,3,1);   {Use mode Write mode 1}
    end else wid:=300;
    for x:=1 to 200 do
    begin
      setbank(dst shr 16);
      setrbank(src shr 16);
      move(mem[$a000:src and $ffff],mem[$a000:dst and $ffff],wid);
      inc(src,bytes);
      inc(dst,bytes);
    end;
    if auto_test then
    begin
      repeat until keypressed;
      dac2comm;     {Reset DAC}
      outp($3c6,0);
      dac2pel;
      textmode(3);
      write('Did the Read/Write bank test work properly (y/n) ?');
      af_tst.Flag :=ord(getYN);
      af_cmt:=getComment('any comments to the test');

      af_tst.mode :=modetbl[m].md;
      af_tst.Mmode:=modetbl[m].memmode;
      AddAFbuf(af_tst,sizeof(af_tst));
      AddAFbuf(af_cmt,length(af_cmt)+1);
      WrAFbuf(6);
    end
    else if getkey=0 then;
  end;
end;

begin
  textmode($103);
  writeln('Seperate Read/Write bank test.');

  if auto_test then
  begin
    delay(1000);
    pushkey(ord('*'));
  end
  else begin
    writeln('Modes:');
    writeln;
    for m:=1 to nomodes do
      if modetbl[m].memmode>=_pl4 then
      begin
        writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
               +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
      end;
    writeln;

    writeln('  *  All modes');
    writeln;
  end;
  x:=getmenkey;
  for m:=1 to nomodes do
    if ((x=0) or (x=m)) and (modetbl[m].memmode>=_pl4) then tmode(m);
end;

procedure testbits;           {Test register bits}
var m,pt,ix,msk:word;
  md,x:integer;
  s:string;

function tmode(m:word):boolean;
const
  mask:array[0..7] of byte=(1,2,4,8,16,32,64,128);
var
  stop:boolean;
  x:word;
begin
  tmode:=true;
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    case memmode of
      _text,_text2,_text4:
              lins:=32768 div bytes;
      _cga1,_cga2:
              lins:=16384 div bytes;
         _pl1:lins:=mm*longint(256) div bytes;
    else lins:=mm*longint(1024) div (bytes*planes);
    end;

    Clearmemory;

    drawtestpattern(s);
    stop:=false;
    repeat
      wrtext(10,180,'Reg '+hex4(pt)+'h index '+hex2(ix)+'h bit '+chr(msk+48));
      x:=rdinx(pt,ix);
      wrinx(pt,ix,x xor mask[msk]);
      delay(500);
      wrinx(pt,ix,x);
      delay(500);

      if keypressed then
        case getkey of
           ord('-'):if msk>0 then dec(msk)
                    else begin
                      msk:=7;
                      dec(ix);
                    end;
           ord('+'):begin
                      inc(msk);
                      if msk>7 then
                      begin
                        msk:=0;
                        inc(ix);
                      end;
                    end;
           ord('*'):begin
                      inc(ix);
                      msk:=0;
                    end;
             Ch_Esc:stop:=true;
        end;
    until stop;
    dac2comm;     {Reset DAC}
    outp($3c6,0);
    dac2pel;
    textmode(3);
  end;
end;

begin
  textmode($103);
  writeln('Test register bits.');
  writeln;
  write('Base register (hex): ');
  readln(s);
  pt:=dehex(s);
  write('Start Index (hex 0-FFh): ');
  readln(s);
  ix:=dehex(s);
  write('Start Bit (0-7): ');
  readln(s);
  msk:=ord(s[1]) and 7;
  writeln;
  writeln('Testing register bits, starting with '+hex4(pt)+'h index '+hex2(ix)+'h bit '+chr(msk+48)+'.');
  writeln;
  writeln('  +  Steps up to the next bit (and possibly next index)');
  writeln('  -  Steps back to the last bit');
  writeln('  *  Steps to the next index, bit 0');
  writeln(' Esc Terminates the test');
  writeln;

  writeln('Modes:');
  writeln;
  for m:=1 to nomodes do
  begin
    writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
           +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
  end;
  writeln;

  writeln('  *  All modes');

  writeln;
  x:=getmenkey;
  for m:=1 to nomodes do
    if (x=0) or (x=m) then
      if not tmode(m) then x:=-1;  {stop}

end;


procedure testdac8;           {Test 8bit DAC mode}
var m,pt,ix,msk:word;
  md,x:integer;
  s:string;

procedure setpal(inx,red,grn,blu:word);
begin
  outp($3C8,inx);
  outp($3C9,red);
  outp($3C9,grn);
  outp($3C9,blu);
end;

function tmode(m:word):boolean;
var
  stop,dac8,olddac:boolean;
  x,y:word;
begin
  tmode:=true;
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;
  if setmode(modetbl[m].md) then
  begin
    drawtestpattern('Test 6/8 bit DAC');
    for y:=0 to 127 do
      for x:=0 to 255 do
        setpix(x+30,y+100,(x shr 2)+(y and $60)*2);

    stop:=false;
    dac8:=false;
    olddac:=not dac8;
    repeat
      if dac8<>olddac then
      begin
        if dac8 then setdac8 else setdac6;

        for x:=0 to 63 do setpal(x,x*4,0,0);
        for x:=0 to 63 do setpal(x+$40,0,x*4,0);
        for x:=0 to 63 do setpal(x+$80,0,0,x*4);
        for x:=0 to 63 do setpal(x+$C0,x*4,x*4,x*4);
        olddac:=dac8;
      end;
      if keypressed then
        case getkey of
           ord('6'):dac8:=false;
           ord('8'):dac8:=true;
       Ch_Esc,Ch_Cr:stop:=true;
        end;
    until stop;
    setdac6;
    dac2comm;     {Reset DAC}
    outp($3c6,0);
    dac2pel;
    textmode(3);
  end;
end;

begin
  textmode($103);
  writeln('Test 8bit DAC mode (256 of 16m colors).');
  writeln;
  writeln('Press 8 to switch to 8bit DAC, 6 to switch to 6bit DAC');
  writeln;

  writeln('Modes:');
  writeln;
  for m:=1 to nomodes do
    if modetbl[m].memmode=_p8 then
      writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
           +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
  writeln;

  writeln('  *  All modes');

  writeln;
  x:=getmenkey;
  for m:=1 to nomodes do
    if (x=0) or (x=m) then
      if not tmode(m) then x:=-1;  {stop}

end;


procedure testvgamodes;           {Test extended modes}
var m:word;
  md,x:integer;

function tmode(m:word):boolean;
begin
  tmode:=true;
  memmode:=modetbl[m].memmode;
  pixels :=modetbl[m].xres;
  lins   :=modetbl[m].yres;
  bytes  :=modetbl[m].bytes;

  if auto_test then
  begin
    fillchar(af_rec,sizeof(af_rec),0);
    af_rec.mode  :=modetbl[m].md;
    af_rec.Mmode :=memmode;
    af_rec.pixels:=pixels;
    af_rec.lins  :=lins;
    af_rec.bytes :=bytes;
  end;


  if setmode(modetbl[m].md) then tmode:=testvmode;

  if auto_test then
  begin
    af_rec.crtc  :=crtc;
    AddAFBuf(af_rec,sizeof(af_rec));
    AddAFbuf(af_cmt,length(af_cmt)+1);
    inc(af_pos,FormatRgs(af_buf[af_pos]));

    WrAFbuf(2);
  end;
end;

begin
  textmode($103);
  writeln('Test extended VGA modes.');
  writeln('Modes:');
  writeln;
  for m:=1 to nomodes do
  begin
    writeln('  '+menuchars[m]+' '+hex4(modetbl[m].md)+'h '+istr(modetbl[m].xres)
           +'x'+istr(modetbl[m].yres)+' '+mdtxt[modetbl[m].memmode]);
  end;
  writeln;

  writeln('  *  All modes');
  if auto_test then pushkey(ord('*'));
  writeln;
  x:=getmenkey;
  for m:=1 to nomodes do
    if (x=0) or (x=m) then
      if not tmode(m) then x:=-1;  {stop}

end;

procedure teststdvgamodes;          {Test standard VGA modes}
var m:word;
  md,x:integer;

function tmode(m:word):boolean;
begin
  memmode:=stdmodetbl[m].memmode;
  pixels :=stdmodetbl[m].xres;
  lins   :=stdmodetbl[m].yres;
  bytes  :=stdmodetbl[m].bytes;

  if auto_test then
  begin
    fillchar(af_rec,sizeof(af_rec),0);
    af_rec.mode  :=stdmodetbl[m].md;
    af_rec.Mmode :=memmode;
    af_rec.pixels:=pixels;
    af_rec.lins  :=lins;
    af_rec.bytes :=bytes;
  end;


  if setmode(stdmodetbl[m].md) then tmode:=testvmode;

  if auto_test then
  begin
    af_rec.crtc  :=crtc;
    AddAFBuf(af_rec,sizeof(af_rec));
    AddAFbuf(af_cmt,length(af_cmt)+1);
    inc(af_pos,FormatRgs(af_buf[af_pos]));
    WrAFbuf(2);
  end;
end;

begin
  textmode($103);
  writeln('Standard VGA mode test.');
  writeln;
  writeln('Modes:');
  writeln;
  for m:=1 to novgamodes do
  begin
    writeln('  '+menuchars[m]+' '+hex4(stdmodetbl[m].md)+'h '+istr(stdmodetbl[m].xres)
           +'x'+istr(stdmodetbl[m].yres)+' '+mdtxt[stdmodetbl[m].memmode]);
  end;
  writeln;
  writeln('  *  All modes');

  writeln;
  if auto_test then pushkey(ord('*'));
  x:=getmenkey;
  for m:=1 to novgamodes do
    if (x=0) or (x=m) then
      if not tmode(m) then x:=-1;

end;


procedure searchformodes;      {Run through all possible modes
                                and try to id any new ones}
type
  regblk=record
           base:word;
           nbr:word;
           x:array[0..255] of byte;
         end;
var
  md,m,hig,wid,x,y,oldbytes,wordadr:word;
  c:char;
  ofil:text;
  attregs:array[0..31] of byte;
  seqregs,grcregs,crtcregs,xxregs:regblk;
  stdregs:array[$3c0..$3df] of byte;
  l:longint;
  s:string;
  stop:boolean;


procedure dumprg(base:word;var rg:regblk);
var six,ix:word;
begin
  rg.base:=base;
  six:=inp(base);
  outp(base,0);
  ix:=inp(base) xor 255;
  outp(base,255);
  ix:=ix and inp(base);

  if ix>127 then rg.nbr:=255
  else if ix>63 then rg.nbr:=127
  else if ix>31 then rg.nbr:=63
  else if ix>15 then rg.nbr:=31
  else if ix>7 then rg.nbr:=15
  else rg.nbr:=7;
  for ix:=0 to rg.nbr do
    rg.x[ix]:=rdinx(base,ix);
  outp(base,six);
end;




begin
  md:=$14;
  stop:=false;
  while (md<$80) and not stop do
  begin
    textmode(3);
    gotoxy(10,10);
    write('Testing mode: '+hex2(md));
    delay(500);
    if setmode(md) then
    begin
      pixels :=calcpixels;
      lins   :=calclines;
      bytes  :=calcbytes;
      vseg   :=calcvseg;
      memmode:=calcmmode;
      repeat
        oldbytes:=bytes;

        if setmode(md) then
        begin
          drawtestpattern('Mode: '+hex2(md)+' ('+istr(pixels)+'x'+istr(lins)+' '
                   +mmodenames[memmode]+') '+istr(bytes)+' bytes.');
        end;

        case getkey of
          Ch_PgUp:bytes:=bytes shl 1;
          Ch_PgDn:bytes:=bytes shr 1;
          Ch_ArUp:inc(bytes);
        Ch_ArDown:dec(bytes);
      ord('d'),ord('D'):
                  begin
                    bytes:=oldbytes;
                    x:=dumpVGAregs;
                  end;
      ord('f'),ord('F'):
                  begin
                    bytes:=oldbytes;
                    dumpVGAregfile;
                  end;
           Ch_Esc:stop:=true;
        end;
      until bytes=oldbytes;
    end;
    inc(md);
  end;
  textmode(3);
end;



var
  stop:boolean;

function ljust(s:string;lnn:word):string;
begin
  ljust:=copy(s+'          ',1,lnn);
end;

function rjust(s:string;lnn:word):string;
begin
  if length(s)<lnn then s:=copy('          ',1,lnn-length(s))+s;
  rjust:=s;
end;

function chkptr(w:word):word;
begin
  if memw[0:w+2]=biosseg then chkptr:=memw[0:w]
                         else chkptr:=0;
end;

function fntadr(BH:word):word;
begin
  rp.bh:=BH;
  vio($1130);
  if rp.es=biosseg then fntadr:=rp.bp
  else fntadr:=0;
end;

procedure wrAFff;
var
  rhdr:_ATff;
  x,y,z,v:word;
begin
  if af_fail and (biosseg<>0) then
  begin
    fillchar(rhdr,sizeof(rhdr),0);
    rhdr.base :=biosseg;
    rhdr.size :=mem[biosseg:2];
    rhdr.int10:=chkptr($40);
    rhdr.int6D:=chkptr($1B4);
    rhdr.m4A8 :=chkptr($4A8);
    rhdr.fnt14  :=fntadr(2);
    rhdr.fnt8l  :=fntadr(3);
    rhdr.fnt8h  :=fntadr(4);
    rhdr.fnt14x9:=fntadr(5);
    rhdr.fnt16  :=fntadr(6);
    rhdr.fnt16x9:=fntadr(7);
    AddAFbuf(rhdr,sizeof(rhdr));
    WrAFbuf(255);
    y:=0;z:=0;
    for x:=0 to (rhdr.size*512-1) do
    begin
      v:=mem[biosseg:x];
      af_buf[z]:=v-y;
      y:=v;
      inc(z);
      if z>=2000 then
      begin
        blockwrite(af_fil,af_buf,z);
        z:=0;
      end;
    end;
    blockwrite(af_fil,af_buf,z);
  end;
end;



var
  chp,force_chip:chips;
  s,fea:string;
  iteration,err,x,sel:word;

  devs:array[1..10] of string[80];

begin
  {$ifdef ver70}
    test8086:=1;    {force 286}
  {$endif}
  fillchar(dotest,sizeof(dotest),ord(true));   {allow test for all chips}
  force_mm:=0;
  force_chip:=__none;
  for x:=1 to paramcount do
  begin
    s:=upstr(paramstr(x));
    case s[1] of
     '-':begin
           s:=upstr(strip(copy(s,2,255)));
           for chp:=chips(1) to __none do
             if upstr(header[chp])=s then
               dotest[chp]:=false;
         end;
     '+':begin
           s:=upstr(strip(copy(s,2,255)));
           fillchar(dotest,sizeof(dotest),ord(false));
           for chp:=chips(1) to __none do
             if upstr(header[chp])=s then
             begin
               dotest[chp]:=true;
               force_chip:=chp;
             end;
         end;
     '=':val(copy(s,2,255),force_mm,err);
     '/':if (s='/DEBUG') or (s='/D') then debug:=true
         else if (s='/A') or (s='/AUTO') then auto_test:=true;
    end;
  end;

  findvideo;

  if force_chip<>__none then chip:=force_chip;
  if force_mm<>0 then mm:=force_mm;


  for x:=1 to vids do
  begin
    SelectVideo(x);
    fea:='';
    if (features and ft_cursor)>0 then fea:=' C';
    if (features and ft_blit  )>0 then fea:=fea+' B';
    if (features and ft_line  )>0 then fea:=fea+' L';
    if (features and ft_rwbank)>0 then fea:=fea+' R';
    devs[x]:='  '+istr(x)+'  '+ljust(chipnam[chip],9)
               +rjust(istr(mm),8)+ljust(fea,8)+'  '+vid[x].name;
  end;


  iteration:=0;
  repeat
    stop:=false;
    if vids<>1 then
    begin
      textmode(3);
      writeln(copyright);
      writeln;
      writeln('Multiple Video Interfaces or Adapters found!!');
      writeln('Please select the one to test:');
      writeln('       Chip:    Memory:  Feat:  Name:');
      for x:=1 to vids do writeln(devs[x]);
      writeln;
      writeln(' 0  Stop');
      writeln;
      sel:=getkey-ord('0');
      if sel=0 then stop:=true;
    end
    else sel:=1;
    if (sel>0) and (sel<=vids) then SelectVideo(sel);

    while not stop do
    begin
      dac2comm;     {Reset DAC}
      outp($3c6,0);
      dac2pel;
      textmode(3);
      writeln(copyright);
      writeln;

      write('Video system: ',chipnam[chip],' with '+istr(mm)+' Kbytes');
      if SubVers<>0 then write(' Version: '+hex4(SubVers));
      writeln;
      if name<>'' then writeln('Name: '+name);
      writeln('Dac: '+dacname);

      if features<>0 then
      begin
        write('Special features:');
        if (features and ft_cursor)<>0 then write(' Cursor');
        if (features and ft_blit)<>0 then write(' BitBlt');
        if (features and ft_line)<>0 then write(' Line');
        if (features and ft_rwbank)<>0 then write(' RW-bank');
        writeln;
      end;

      writeln;
      if (chip<>__vesa) and (chip<>__XBE) then
        writeln('     1  Test Standard VGA modes');
      writeln('     2  Test Extended modes');
      if (chip<>__vesa) and (chip<>__XBE) then
        writeln('     3  Search for video modes');
      if (features and ft_cursor)<>0 then
        writeln('     5  HardWare Cursor test');
      if (features and ft_blit)<>0 then
        writeln('     6  HardWare BitBLT test');
      if (features and ft_line)<>0 then
        writeln('     7  Line Draw test');
      if (features and ft_rwbank)<>0 then
        writeln('     8  R/W bank test');
      writeln;
      writeln('     0  Stop');
      writeln;

      if auto_test then
      begin
        inc(iteration);
        pushkey(Ch_Cr);  {No Operation, just step on}
        case iteration of
          1:begin
              InitAFfile(sel);
              for x:=1 to vids do
              begin
                AddAFbuf(vid[x],sizeof(vid[1]));
                WrAFbuf(1);
              end;
              if (chip<>__vesa) and (chip<>__XBE) then pushkey(ord('1'));
            end;
          2:pushkey(ord('2'));
          3:if (features and ft_cursor)<>0 then pushkey(ord('5'));
          4:if (features and ft_blit)<>0 then pushkey(ord('6'));
          5:if (features and ft_line)<>0 then pushkey(ord('7'));
          6:if (features and ft_rwbank)<>0 then pushkey(ord('8'));
          7:pushkey(ch_esc);

        end;
      end;




      case getkey of
             ord('1'):teststdvgamodes;
             ord('2'):testvgamodes;
             ord('3'):searchformodes;
             ord('5'):testcursor;
             ord('6'):testblit;
             ord('7'):testline;
             ord('8'):testrwbank;
    ord('a'),ord('A'):auto_test:=true;
    ord('b'),ord('B'):testbits;
    ord('d'),ord('D'):testdac8;
             ord('0'):stop:=true;
      Ch_Esc:begin
               stop:=true;
               sel:=0;
             end;
      end;
    end;
    if vids<=1 then sel:=0;
  until sel=0;

  dac2comm;     {Reset DAC}
  outp($3c6,0);
  dac2pel;
  vio(3);

  if auto_test then
  begin
    wrAFff;
    close(af_fil);
    writeln;
    writeln('The test results are in the file: ',af_filename);
    writeln;
    writeln('For e-mail, modem etc the test file should be compressed');
    writeln('(ZIP, ARJ...) savings of >40% are not uncommon.');
    writeln;
    writeln('For Email transport, remember that the test file is BINARY.');

  end;
end.
