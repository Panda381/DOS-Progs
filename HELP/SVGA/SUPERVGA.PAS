
unit supervga;

interface
uses dos;



  {$i defvga.pas}   {Definitions}

{$i idvga.pas}



  (*  Set memory bank  *)

procedure setbank(bank:word);
var x:word;
begin
  if bank=curbank then exit;   {Only set bank if diff. from current value}
  vseg:=$a000;
  curbank:=bank;
  case chip of
    __aheadA:begin
           wrinx(GRC,13,bank shr 1);
           x:=inp($3cc) and $df;
           if odd(bank) then inc(x,32);
           outp($3c2,x);
         end;
    __aheadB:wrinx(GRC,13,bank*17);
    __al2101:begin
           outp($3d7,bank);
           outp($3D6,bank);
         end;
      __ati1:modinx(IOadr,$b2,$1e,bank shl 1);
      __ati2:begin
           x:=bank*$22;      {Roll bank nbr into bit 0}
           modinx(IOadr,$b2,$ff,hi(x) or lo(x));
         end;
    __atiGUP:begin
           x:=(bank and 15)*$22;          {Roll bank nbr into bit 0}
           modinx(IOadr,$b2,$ff,hi(x) or lo(x));
           modinx(IOadr,$AE,3,bank shr 4);
         end;
  __chips451:wrinx(IOadr,$B,bank);
  __chips452:begin
           if memmode<=_pl4 then bank:=bank shl 2;
           wrinx(IOadr,$10,bank shl 2);
         end;
  __chips453:begin
           if memmode<=_pl4 then bank:=bank shl 2;
           wrinx(IOadr,$10,bank shl 4);
         end;
     __cir54:begin
           if (rdinx(GRC,$B) and 32)=0 then bank:=bank shl 2;
           wrinx(GRC,9,bank shl 2);
         end;
     __cir64:begin
           bank:=bank shl 4;
           wrinx(GRC,$E,bank);
           wrinx(GRC,$F,bank);
         end;
    __compaq:begin
           wrinx(GRC,$f,5);
           bank:=bank shl 4;
           wrinx(GRC,$45,bank);
           if (rdinx(GRC,$40) and 1)>0 then inc(bank,8);
           wrinx(GRC,$46,bank);
         end;
    __ET3000:outp($3cd,bank*9+64);
    __Weitek,
    __ET4000:outp($3cd,bank*17);
    __ET4w32:begin
           outp($3cd,(bank and 15)*17);
           outp($3cb,(bank shr 4)*17);
         end;
    __everex:begin
           x:=inp($3cc) and $df;
           if (bank and 2)>0 then inc(x,32);
           outp($3c2,x);
           modinx(SEQ,8,$80,bank shl 7);
         end;
     __genoa:wrinx(SEQ,6,bank*9+64);
       __HMC:begin
           if memmode=_p8 then modinx(SEQ,$EE,$70,bank shl 4)
           else if bank=0 then vseg:=$A000 else vseg:=$B000;
         end;
    __iitagx:if (inp(IOadr) and 4)>0 then outp(IOadr+8,bank)
         else begin
           wrinx(SEQ,$B,0);
           if rdinx(SEQ,$B)=0 then;
           modinx(SEQ,$E,$f,bank xor 2);
         end;
      __mxic:wrinx(SEQ,$c5,bank*17);
       __ncr:begin
           if memmode<=_pl4 then bank:=bank shl 2;
           wrinx(SEQ,$18,bank shl 2);
           wrinx(SEQ,$1C,bank shl 2);
         end;
       __oak:wrinx($3de,$11,bank*17);
     __oak87:begin
           wrinx($3DE,$23,bank);
           wrinx($3DE,$24,bank);
         end;
  __paradise:begin
           wrinx(GRC,9,bank shl 4);
           wrinx(GRC,$A,bank shl 4);
         end;

     __p2000,
   __realtek:begin
           outp($3d6,bank);
           outp($3d7,bank);
         end;
    __s3:begin
           wrinx(crtc,$38,$48);
           wrinx(crtc,$39,$A5);
           setinx(crtc,$31,9);
           if memmode<=_pl4 then bank:=bank*4;
           modinx(crtc,$35,$f,bank);
           modinx(crtc,$51,$C,bank shr 2);
           wrinx(crtc,$39,$5A);
           wrinx(crtc,$38,0);
         end;
    __tridBR:begin
           modinx(SEQ,$E,6,bank);
           if (bank and 1)>0 then vseg:=$B000 else vseg:=$A000;
         end;
    __tridCS,__poach,__trid89
        :if version=TR_8900CL then outp($3D8,bank)
         else begin
    (*   wrinx(SEQ,$B,0);
           if rdinx(SEQ,$B)=0 then;  {New mode}
           modinx(SEQ,$E,$f,bank xor 2);  *)
           wrinx(SEQ,$B,0);
           if rdinx(SEQ,$B)=0 then;  {New mode}
           if (memmode<=_pl4) and (bank>1) then inc(bank,2);
           modinx(SEQ,$E,$f,bank xor 2);
         end;
    __video7:if Version<V7_208A then
         begin
           x:=inp($3cc) and $df;
           if (bank and 2)>0 then inc(x,32);
           outp($3c2,x);
           modinx(SEQ,$f9,1,bank);
           modinx(SEQ,$f6,$80,(bank shr 2)*5);
         end
         else begin
           wrinx(SEQ,$E8,bank);
           wrinx(SEQ,$E9,bank);
         end;
       __UMC:wrinx(SEQ,6,bank*17);
      __vesa:begin
           rp.bx:=0;
           bank:=bank*longint(64) div vgran;
           rp.dx:=bank;
           vio($4f05);
           rp.bx:=1;
           rp.dx:=bank;
           vio($4f05);
         end;
 __xbe,__xga:outp(IOadr+8,bank);
  __WeitekP9:outp($3CD,bank or $20);
  end;
end;

procedure setRbank(bank:word);
var x:word;
begin
  curbank:=$FFFF;    {always flush}
  case chip of
   __aheadB:modinx(GRC,$D,$F,bank);
   __al2101:outp($3D6,bank);
     __ati2:begin
          x:=bank shl 5;          {Roll bank nbr into bit 0}
          modinx(IOadr,$b2,$e1,hi(x) or lo(x));
        end;
   __atiGUP:begin
          x:=(bank and 15) shl 5;          {Roll bank nbr into bit 0}
          modinx(IOAdr,$b2,$e1,hi(x) or lo(x));
          modinx(IOadr,$AE,$C,bank shr 2);
        end;
    __cir64:wrinx(GRC,$E,bank shl 4);
   __ET3000:modreg($3CD,$38,bank shl 3);
   __Weitek,
   __ET4000:modreg($3CD,$F0,bank shl 4);
   __ET4w32:begin
          modreg($3cd,$F0,bank shl 4);
          modreg($3cb,$F0,bank);
        end;
     __mxic:modinx(SEQ,$C5,$f0,bank shl 4);
      __ncr:begin
           if memmode<=_pl4 then bank:=bank shl 2;
           wrinx(SEQ,$1C,bank shl 2);
        end;
      __oak:modinx($3de,$11,$f,bank);
    __oak87:wrinx($3DE,$23,bank);
 __paradise:wrinx(GRC,9,bank shl 4);
    __p2000:outp($3D7,bank);
  __realtek:outp($3D6,bank);
   __Video7:wrinx(SEQ,$E9,bank);
      __UMC:modinx(SEQ,6,$F,bank);
  end;
end;



procedure vesamodeinfo(md:word;vbe1:_vbe1p);
const
  width :array[$100..$11b] of word=
      (640,640,800,800,1024,1024,1280,1280,80,132,132,132,132
      ,320,320,320,640,640,640,800,800,800,1024,1024,1024,1280,1280,1280);
  height:array[$100..$11b] of word=
      (400,480,600,600, 768, 768,1024,1024,60, 25, 43, 50, 60
      ,200,200,200,480,480,480,600,600,600, 768, 768, 768,1024,1024,1024);
  bits  :array[$100..$11b] of byte=
      (  8,  8,  4,  8,   4,   8,   4,   8, 0,  0,  0,  0,  0
      , 15, 16, 24, 15, 16, 24, 15, 16, 24,  15,  16,  24,  15,  16,  24);


var
  vbxx:_vbe1;
begin
  if vbe1=NIL then vbe1:=@vbxx;
  fillchar(vbe1^,sizeof(_vbe1),0);
  viop($4f01,0,md,0,vbe1);
  if ((vbe1^.attr and 2)=0) and (md>=$100) and (md<=$11b)
   then  (* optional info missing *)
  begin
    vbe1^.width :=width[md];
    vbe1^.height:=height[md];
    vbe1^.bits  :=bits[md];
  end;


  vgran :=vbe1^.gran;
  bytes :=vbe1^.bytes;
  pixels:=vbe1^.width;
  lins  :=vbe1^.height;
end;


procedure initxga;
var xbe1:_xbe1;
  phadr:longint;
  x:word;
begin
  outp(IOAdr+1,1);
  modreg(IOadr+9,$8,0);

  mem [xgaseg:$12]:=1;
  meml[xgaseg:$14]:=phadr;
  memw[xgaseg:$18]:=pixels;
  memw[xgaseg:$1A]:=lins;
  case memmode of
   _pk4:x:=2;
    _p8:x:=3;
   _p16:x:=4;
  end;
  mem [xgaseg:$1C]:=x;

end;

function safemode(md:word):boolean;
var x,y:word;
begin             {Checks if we entered a Graph. mode}
  safemode:=false;
  wrinx(crtc,$11,0);
  wrinx(crtc,1,0);
  vio(lo(md));
  if (rdinx(crtc,1)<>0) or (rdinx(crtc,$11)<>0) then
  begin
    if (md<=$13) or (mem[0:$449]<>3) then safemode:=true;
  end;
end;

function tsvio(ax,bx:word):boolean;   {Tseng 4000 Hicolor mode set}
begin
  rp.bx:=bx;
  vio(ax);
  tsvio:=rp.ax=16;
end;

function setATImode(md:word):boolean;
begin
  rp.bx:=$5506;
  rp.bp:=$ffff;
  rp.si:=0;
  vio($1200+md);
  if rp.bp=$ffff then setATImode:=false
  else begin
    vio(md);
    setATImode:=true;
  end;
end;

function setmode(md:word):boolean;
var x,y,prt:word;
begin
  setmode:=true;
  curmode:=md;
  case chip of
__ati1,__ati2:setmode:=setATImode(md);
     __atiGUP:if md<$100 then setmode:=setATImode(md)
          else begin
        case memmode of
         _p15:x:=$6;
         _p16:x:=$E;
         _p24:x:=$7;
        end;
          {mov al,[md]  mov ah,[x]  mov bx,1  call C000h:64h
            mov al,1  call C000h:68h}
        inline($8A/$46/<md/$8A/$66/<x/$BB/>1/$9A/>$64/>$C000
              /$B8/>1/$9A/>$68/>$C000);
          end;
     __compaq:begin
        setmode:=safemode(md);
        if memmode=_p16 then outp($3C8+DAC_RS3,$38);
          end;
     __ET4w32,
     __ET4000:case hi(md) of
        0:setmode:=safemode(md);
        1:if tsvio($10e0,lo(md)) then
          begin
            {Diamond SpeedStar 24 does not clear memory}
            for x:=0 to 15 do         {clear memory}
            begin
              setbank(x);
              mem[$a000:0]:=0;
              fillchar(mem[$a000:1],65535,0);
            end;
          end else setmode:=false;
        2:if tsvio($10f0,md shl 8+$ff) then
          begin
            if bytes=2048 then
            begin     {Bug correction for the MEGAVGA BIOS}
              outp($3bf,3);
              outp(crtc+4,$a0);   {enable Tseng 4000 Extensions}
              wrinx(crtc,$13,0);
              setinx(crtc,$3f,$80);
            end
          end else setmode:=false;
        3:if tsvio($10f0,lo(md)) and setdac15 then
          else setmode:=false;
        4:if tsvio($10f0,lo(md)) and setdac16 then
          else setmode:=false;
          end;
     __everex:begin
        rp.bl:=md;
        vio($70);
          end;
      __oak87:if safemode(md) then
        case memmode of
          _p15:setmode:=setdac15;
          _p16:setmode:=setdac16;
          _p24:setmode:=setdac24;
        end
          else setmode:=false;
     __s3:if md<$100 then setmode:=safemode(md)
          else begin
        rp.bx:=md;
        vio($4f02);
        if rp.ax=$4f then
        begin
          if md<$200 then vesamodeinfo(md,NIL);
          if (memmode=_p16) and setdac16 then;
        end
        else begin
          setmode:=false;
          dac2comm;
          outp($3C6,0);
          dac2pel;
        end;
          end;
     __iitagx,
     __trid89:begin
        vio(md);
        if (rp.ah<>0) then setmode:=false;
        case memmode of   {9000i doesn't set HiColor modes}
          _p15:if not setdac15 then setmode:=false;
          _p16:if not setdac16 then setmode:=false;
        end;


          end;
     __video7:begin
        rp.bl:=md;
        vio($6f05);
          end;
       __vesa:begin
        rp.bx:=md;
        vio($4f02);
        if rp.ax<>$4f then setmode:=false
        else begin
          vesamodeinfo(md,NIL);
          chip:=__vesa;
        end;
          end;
    __UMC:begin
        setmode:=safemode(md);
        case memmode of
          _p15:setmode:=setdac15;
          _p16:setmode:=setdac16;
        end;
          end;
    __xbe:begin
        viop($4E03,md,0,instance,NIL);
        if rp.ax<>$4E then setmode:=false;
          end;
  else setmode:=safemode(md);
  end;

  if (inp($3CC) and 1)=0 then crtc:=$3B4 else crtc:=$3D4;
  case (rdinx(GRC,6) shr 2) and 3 of
    0,1:vseg:=$A000;
      2:vseg:=$B000;
      3:vseg:=$B800;
  end;


  case chip of
     __aheadA,
     __aheadB:begin
        setinx(GRC,$F,$20);
        if (memmode>_cga2) and (md<>$13) then setinx(GRC,$C,$20);
          end;
     __al2101:begin
        setinx(crtc,$1A,$10);    {Enable extensions}
        setinx(crtc,$19,2);  {Enable >256K}
        setinx(GRC,$F,4);    {Enable RWbank}
          end;
     __atiGUP,
       __ati2:begin
        setinx(IOadr,$B6,1);    {enable display >256K}
        setinx(IOAdr,$Be,8);    {enable RWbanks}
        setinx(IOAdr,$Bf,$1);
          end;
   __chips451,__chips452,__chips453:
          begin
        prt:=$46E8;
        x:=inp(prt);
        outp(prt,x or $10);
        y:=inp($103);
        outp($103,y or $80);
        outp(prt,x and $EF);
        if (y and $40)=0 then IOadr:=$3D6 else IOadr:=$3B6;
        setinx(IOadr,4,4);
        if chip<>__chips451 then
        begin
          modinx(IOadr,$B,3,1);
          wrinx(IOadr,$C,0);
        end;
          end;
      __cir54:begin
        wrinx(SEQ,6,$12);
        setinx(crtc,$1B,2);  {Enable mem >256K}
        if mm>1024 then
        begin
          setinx(GRC,11,$20);    {Set 16K banks}
          setinx(SEQ,$f,$80);    {Enable Ext mem}
        end;
        wrinx(crtc,$25,$FF);
          end;
      __cir64:begin
        wrinx(GRC,$A,$EC);   {Enable extensions}
        if memmode>_cga2 then setinx(GRC,$D,7);
          end;
     __compaq:begin
        modinx(GRC,$F,$f,5);
        setinx(GRC,$10,8);
          end;
     __ET3000:setinx(SEQ,4,2);
    __HMC:if memmode>=_cga2 then
          begin
        if memmode=_pl4 then
        begin
          setinx(SEQ,$E7,$4);
          clrinx(GRC,6,$C);
        end;
        setinx(SEQ,$E8,$9);

          end;
     __iitagx:begin
        modinx(GRC,6,$C,4);
        spcreg:=0;
        if (inp(IOadr) and 4)>0 then
        begin
          initxga;
          spcreg:=$1F0-(rdinx(IOadr+10,$75) and 3)*$10;
        end;
          end;
       __mxic:begin
        setinx(SEQ,$65,$40);
        wrinx(SEQ,$a7,$87);    {enable extensions}
        setinx(SEQ,$c3,4);     {Enable banks}
        setinx(SEQ,$f0,8);     {Enable display >256k}
          end;
    __ncr:begin
        wrinx(SEQ,5,5);
        wrinx(SEQ,$18,0);
        wrinx(SEQ,$19,0);
        wrinx(SEQ,$1A,0);
        wrinx(SEQ,$1B,0);
        wrinx(SEQ,$1C,0);
        wrinx(SEQ,$1D,0);
        setinx(SEQ,$1e,$1C);
          end;
    __oak:begin
        if memmode>=_pl4 then setinx($3DE,$D,$1C);
          end;
      __oak87:begin
        if memmode=_pl4 then setinx($3DE,$D,$10);
         (*   if md=$13 then
        begin
          wrinx(crtc,$14,0);
          wrinx(crtc,$13,20);
          wrinx(crtc,$17,$c3);
          setinx($3DE,$21,4);
        end; (* Creates a 320x200 mode without 64K limitations
            however there is no pixel doubling, creating a
            "double screen"  *)
          end;
   __paradise:begin
        modinx(GRC,$F,$17,5); {Enable extensions}
        wrinx(crtc,$29,$85);  {Enable extensions 2}
        clrinx(GRC,$B,8);
        clrinx(crtc,$2F,$62);
        setinx(SEQ,$11,$80);  {enable dual bank}
          end;
      __p2000:begin
        if memmode=_p16 then
        begin
          dac2comm;
          outp($3c6,$c0);
        end;
     (*   if memmode=_p24 then
        begin        {This can trick a ATT20c492 into 24bit mode}
          dactocomm;
          outp($3c6,$e0);
          bytes:=1600;
          pixels:=530;
        end;  *)
          end;
    __realtek:begin
        setinx(crtc,$19,$A2);   {display from upper 512k}
        setinx(GRC,$C,32);
        setinx(GRC,$F,4);   {dual bank}
          end;
     __s3:if memmode>_CGA2 then
          begin
        wrinx(crtc,$38,$48);
        wrinx(crtc,$39,$A5);
        setinx(crtc,$31,8);   {Enable access >256K}
        wrinx(crtc,$38,0);
        wrinx(crtc,$39,$5A);
          end;
     __trid89:begin
        setinx(crtc,$1e,$80);   (* Enable 17bit display start *)
        if (memmode>_cga2) AND (Version=TR_8900C) then
        begin
          wrinx(SEQ,$B,0);
          x:=inp(SEQ+1);    {Switch to new mode}
          x:=rdinx(SEQ,$E);
          wrinx(SEQ,$E,$80);
          setinx(SEQ,$C,$20);
          wrinx(SEQ,$E,x);
        end;
          end;
    __umc:begin
        OUTP($3BF,$AC);     {Enable extensions}
        setinx(SEQ,8,$80);    {Enable banks bit0}
        clrinx(crtc,$2F,$2);  {Enable >256K}
          end;
     __video7:begin
        wrinx(SEQ,6,$EA);  (* Enable extensions *)
        if Version>=V7_208A then
          setinx(SEQ,$E0,$80);  {Enable Dual bank}
          end;
     __Weitek:begin
        x:=rdinx(SEQ,$11);
        outp(SEQ+1,x);
        outp(SEQ+1,x);
        outp(SEQ+1,inp(SEQ+1) and $DF);
          end;
  __xbe,__xga:initxga;
  end;
  curbank:=$ffff;    {Set curbank invalid }
  planes:=1;
  setinx(SEQ,4,2);    {Set "more than 64K" flag}

  case memmode of
  _text,_text2,_text4,
  _pl1e,_pl2:planes:=2;
    _pl4:planes:=4;
  end;
  if vseg=$A000 then
    for x:=1 to mm div 64 do
    begin
      setbank(x-1);
      mem[vseg:$FFFF]:=0;
      fillchar(mem[vseg:0],$ffff,0);
    end;
  AnalyseMode;
end;

const
  set15:array[0..13] of byte=(0,0,$A0,$A0,$A0,$A0,$C1,0,$80,$F0,$A0,0,0,0);
  msk15:array[0..13] of byte=(0,0,$80,$C0,$FF,$E0,$C7,0,$C0,$FF,$E0,0,0,0);

  set16:array[0..13] of byte=(0,0,  0,$E0,$A6,$C0,$C5,0,$C0,$E1,$C0,0,0,0);
  msk16:array[0..13] of byte=(0,0,  0,$C0,$FF,$E0,$C7,0,$C0,$FF,$E0,0,0,0);

  set24:array[0..13] of byte=(0,0,  0,  0,$9E,$E0,$80,0,$60,$E5,$E0,0,0,0);
  msk24:array[0..13] of byte=(0,0,  0,  0,$FF,$E0,$C7,0,$E0,$FF,$E0,0,0,0);


function prepDAC:word;     {Sets DAC up to receive command word}
var x:word;
begin
  dac2comm;
  if dactype=_dacss24 then
  begin
    dac2comm;
    x:=8;
    while (x>0) and (daccomm<>$8E) do
    begin
      daccomm:=inp($3C6);
      dec(x);
    end;
    prepDAC:=daccomm;
  end
  else begin
    prepDAC:=inp($3C6);
    dac2comm;
  end;
end;

procedure dacmode(andmsk,ormsk:word);
begin
  ormsk:=ormsk and (not andmsk);
  if DAC_RS2<>0 then
  begin
    outp($3C6+DAC_RS2,(inp($3C6+DAC_RS2) and andmsk) or ormsk);
  end
  else begin
    outp($3C6,(prepDAC and andmsk) or ormsk);
    dac2pel;

  end;
end;

procedure setdac6;
var m:word;
begin
  case dactype of
   _dacSC24:begin
          dac2comm;
          outp($3C6,$10);
          outp($3C7,8);
          outp($3C8,0);
          outp($3C9,0);
          outp($3C6,0);
          dac2pel;
        end;
    _dacATT,_dacBt484:
        dacmode(0,0);
    _dacCEG,
      _dac8:;
  end;
end;

procedure setdac8;
begin
  case dactype of
   _dacSC24:begin
          dac2comm;
          outp($3C6,$10);
          outp($3C7,8);
          outp($3C8,1);
          outp($3C9,0);
          outp($3C6,0);
          dac2pel;
        end;
    _dacATT,_dacBt484:
        dacmode($FD,2);
    _dacCEG,
      _dac8:;
  end;
end;

function setdac15:boolean;
var m:word;
begin
  if msk15[dactype]=0 then setdac15:=false
  else begin
    m:=msk15[dactype];
    if (chip<>__ET4000) and (chip<>__ET4W32) and
      (dactype<=_dac16) then m:=m or $20;
    dacmode(not m,set15[dactype]);
    setdac15:=true;
  end;
end;

function setdac16:boolean;
var m:word;
begin
  if msk16[dactype]=0 then setdac16:=false
  else begin
    m:=msk15[dactype];
    if (chip<>__ET4000) and (chip<>__ET4W32) and
      (dactype<=_dac16) then m:=m or $20;
    dacmode(not m,set16[dactype]);
    setdac16:=true;
  end;
end;

function setdac24:boolean;
begin
  if msk24[dactype]=0 then setdac24:=false
  else begin
    dacmode(not msk24[dactype],set24[dactype]);
    setdac24:=true;
  end;
end;



procedure setvstart(x,y:word);       {Set the display start address}
var
  l:longint;
  stdvga:boolean;
begin
  stdvga:=true;

  case chip of
    __vesa:begin
           rp.bx:=0;
           rp.cx:=x;
           rp.dx:=y;
           vio($4f07);
           if rp.ax=0 then;
           stdvga:=false;
         end;
  else
    case memmode of
    _text,_text2,_text4:
          l:=(bytes*y+x*2)*2;
        _cga2:l:=(bytes*y+(x shr 2))*4;
  _cga1,_pl1,_pl2,_pl4:
          l:=(bytes*y+(x shr 3))*4;
         _pk4:l:=bytes*y+x shr 1;
          _p8:l:=bytes*y+x;
    _p15,_p16:l:=bytes*y+x*2;
         _p24:l:=bytes*y+x*3;
         _p32:l:=bytes*y+x*4;
    end;

    y:=(l shr 18) and (pred(mm) shr 8);
    case chip of
      __aheadb:begin
         if (memmode=_p8) and ((rdinx(GRC,$C) and $20)>0) then
         begin
           y:=y shr 1;
           l:=l shr 1;
         end;
         modinx(GRC,$1c,3,y);
           end;
    __ati1:modinx(IOAdr,$b0,$40,y shl 6);
      __atiGUP,
    __ati2:begin
         if (rdinx(IOadr,$B0) and $20)>0 then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx(IOadr,$b0,$40,y shl 6);
         modinx(IOadr,$A3,$10,y shl 3);
         modinx(IOadr,$AD,4,y);
           end;
      __al2101:begin
         if (rdinx(GRC,$C) and $10)<>0 then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx(crtc,$20,7,y);
           end;
    __chips452,__chips453:
           wrinx(IOadr,$C,y);
       __cir54:begin
         inc(y,y and 6);     {move bit 1-2 to 2-3}
         modinx(crtc,$1b,$d,y);
           end;
       __cir64:wrinx(GRC,$7C,y);
      __compaq:modinx(GRC,$42,$C,y shl 2);
      __ET3000:begin
         if (memmode=_p8) or ((rdinx(SEQ,7) and $40)>0) then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx(crtc,$23,2,y shl 1);
           end;
      __ET4000:modinx(crtc,$33,3,y);
      __ET4W32:modinx(crtc,$33,$F,y);
     __HMC:begin
         if (rdinx(SEQ,$E7) and 1)>0 then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx(SEQ,$ED,1,y);
           end;
      __iitagx:if (inp(IOadr) and 4)=0 then modinx(crtc,$1e,$20,y shl 5)
           else begin
         stdvga:=false;
         wrinx3(IOadr+10,$40,l shr 2);
           end;
    __mxic:modinx(SEQ,$F1,3,y);
     __ncr:modinx(crtc,$31,$f,y);
     __oak:begin
         if (memmode>_pl4) and (curmode<>$13) then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx($3DE,$14,8,y shl 3);  {lower bit}
         modinx($3DE,$16,8,y shl 2);  {upper bit}
           end;
       __oak87:begin
         if (memmode>_pl4) and ((rdinx($3DE,$21) and 4)>0) then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx($3DE,$17,7,y);
           end;
       __p2000:modinx(GRC,$21,$7,y);
    __paradise:modinx(GRC,$d,$18,y shl 3);
     __realtek:begin
         if (rdinx(GRC,$C) and $10)<>0 then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         if y>1 then inc(y,y and 2);   {shift high bit one up.}
         modinx(crtc,$19,$50,y shl 4);
           end;
      __s3:begin
         wrinx(crtc,$38,$48);
         wrinx(crtc,$39,$A5);
         modinx(crtc,$31,$30,y shl 4);
         modinx(crtc,$51,1,y shr 2);
         wrinx(crtc,$39,$5A);
         wrinx(crtc,$38,0);
           end;
      __tridcs:modinx(crtc,$1e,$20,y shl 5);
      __trid89:begin
    (*     wrinx(SEQ,$B,0);
         if (rdinx(SEQ,$D) and $10)>0 then l:=l shr 1;
         y:=rdinx(SEQ,$B);
         y:=l shr 18;
         modinx(crtc,$1E,$20,(y and 1) shl 5);
         wrinx(SEQ,$B,0);      {select old mode regs}
         modinx(SEQ,$E,1,y shr 1);
         if rdinx(SEQ,$B)=0 then;  {Select new mode regs}  *)

         wrinx(SEQ,$B,0);      {select old mode regs}
         if (rdinx(SEQ,$D) and $10)>0 then
         begin
           l:=l shr 1;
           y:=y shr 1;
         end;
         modinx(SEQ,$E,1,y shr 1);
         if rdinx(SEQ,$B)=0 then;  {Select new mode regs}
         modinx(crtc,$1E,$20,y shl 5);
         if Version=TR_8900CL then modinx(crtc,$27,3,y shr 1);
           end;
     __UMC:begin
        if (rgs.crtcregs.x[$33] and $10)>0 then
        begin
          l:=l shr 1;
          y:=y shr 1;
        end;
        modinx(crtc,$33,1,y);
           end;
      __video7:modinx(SEQ,$f6,$70,(y shl 4) and $30);
      __Weitek:modinx(GRC,$D,$18,y shl 3);
   __xbe,__xga:begin
         stdvga:=false;
         wrinx3(IOadr+10,$40,l shr 2);
           end;
    end;
  end;
  if stdvga then
  begin
    x:=l shr 2;
    wrinx(crtc,13,lo(x));
    wrinx(crtc,12,hi(x));
  end;
end;



procedure WD_wait;
begin
  if version=WD_90c33 then
  begin
    repeat until (inp($23CE) and 15)=0;
  end
  else
    repeat
      outpw($23C0,$1001);
    until (inpw($23C2) and $800)=0;
end;

procedure WD_outl(index:word;l:longint);
begin
  outpw($23C2,index+(l and $FFF));
  outpw($23C2,index+$1000+(l shr 12));
end;

procedure setHWcurmap(VAR map:CursorType);
var x,y,z,w,lbank,x0,y0:word;
  l:longint;
  bm:array[0..127] of byte;
  mp:record
       case integer of
    0:(b:array[0..2047] of byte);
    1:(w:array[0..1023] of word);
    2:(l:array[0..511] of longint);
     end;

procedure copyCurMap(bytes:word);
var x,y:word;
begin
  setbank(lbank);
  if memmode=_pl4 then
  begin
    wrinx(GRC,3,0);
    clrinx(GRC,5,$3);
    wrinx(GRC,8,$FF);
    y:=-(bytes div 4);
    for x:=0 to bytes-1 do
    begin
      wrinx(SEQ,2,1 shl (x and 3));
      y0:=mem[$a000:y];
      mem[$a000:y]:=mp.b[x];
      if (x and 3)=3 then inc(y);
    end;
  end
  else move(mp,mem[$A000:-bytes],bytes);
end;

function al_packmap(map:byte):word;
var i,j:word;
begin
  j:=0;
  for i:=0 to 7 do
  begin
    j:=j shl 2+2;
    if ((map shr i) and 1)>0 then dec(j);
  end;
  al_packmap:=j;
end;

function al_packmap2(map:byte):longint;
var i:word;
    j:longint;
begin
  j:=0;
  for i:=0 to 7 do
  begin
    j:=j shl 4+$A;
    if ((map shr i) and 1)>0 then dec(j,5);
  end;
  al_packmap2:=j;
end;

function pack8to16(w:word):word;
var x,i:word;
begin
  i:=0;
  for x:=0 to 7 do
  begin
    i:=i shl 2;
    if ((w shl x) and 128)>0 then inc(i,3);
  end;
  pack8to16:=i;
end;

function swapb(b:word):word;
var i,j:word;
begin
  j:=0;
  for i:=0 to 7 do
    if ((b shr i) and 1)>0 then inc(j,128 shr i);
  swapb:=j;
end;

begin
  if memmode=_pl4 then lbank:=(mm div 256)-1
          else lbank:=(mm div 64)-1;
  move(map,mp,128);
  move(map,bm,128);
  case chip of
    __al2101:begin
           x0:=0;
           w:=mm-1;
           fillchar(mp,1024,$aa);
           if memmode<=_p8 then
           begin
         y:=0;
         for x:=0 to 127 do
         begin
           mp.w[y+x]:=al_packmap(bm[x]);
           if (x and 3)=3 then inc(y,4);
         end;
           end
           else
         for x:=0 to 127 do  {Double size for 64k mode}
           mp.l[x]:=al_packmap2(bm[x]);
           CopyCurMap(1024);

           wrinx2(crtc,$27,w);
           x:=inp(crtc+6);     {force DAC to address mode}
           x:=inp($3C0);
           y:=rdinx($3C0,$31);
           z:=rdinx($3C0,$32);
           wrinx($3C0,$35,$f);
           wrinx($3C0,$36,0);
           wrinx($3C0,$31,y);
           wrinx($3C0,$32,z);
           outp($3C0,x);
         end;
    __atiGUP:begin      {Doesn't work yet}
           for x:=0 to 127 do mp.l[x]:=$ffaa5500;

           CopyCurMap(512);
           outpw($1AEE,$5533);
           outpw($1EEE,$2020);
           l:={(mm*longint(1024)-512) div 4} 0;
           outpw($AEE,l);
           outpw($EEE,(l shr 16) or $8000);
         end;
  __chips452:begin
           for x:=255 downto 0 do
         mp.w[x]:=mp.w[x div 4];
           CopyCurMap(512);

           wrinx(IOadr,$A,0);
           wrinx2m(IOadr,$30,mm*longint(64)-$20);
           wrinx(IOadr,$32,$ff);
           wrinx(IOadr,$37,1);
           wrinx(IOadr,$38,$FF);
           wrinx(IOadr,$39,0);
           wrinx(IOadr,$3A,$F);
         end;
    __compaq:begin
           outp($3C8,$80);
           for x:=0 to 127 do outp($13C7,255);
           outp($3C8,0);
           for x:=0 to 127 do outp($13C7,mp.b[x]);
           outp($13C9,(inp($13C9) and $FC) or 2);
         end;
     __cir54:begin
           clrinx(SEQ,$12,3);
           wrinx(GRC,11,$24);
           move(mp,mp.b[128],128);
           CopyCurMap(256);
           setHWcurcol($ff0000,$ff);
           wrinx(SEQ,$13,$3f);
         end;
    __ET4W32:begin
           for x:=0 to 511 do mp.l[x]:=$AAAAAAAA;
           y:=128;
        {   if memmode>_p8 then
           begin
         for x:=127 downto 0 do
         begin
           mp.l[x+y]:=al_packmap2(bm[x]);
           if (x and 3)=0 then dec(y,4);
         end;
         CopyCurMap(2048);
         wrinx($217A,$EE,2);
         wrinx($217A,$EB,4);
         l:=mm*longint(256)-512;
           end
           else} begin
         for x:=127 downto 0 do
         begin
           mp.w[x+y]:=al_packmap(bm[x]);
           if (x and 3)=0 then dec(y,4);
         end;
         CopyCurMap(1024);
         wrinx($217A,$EE,1);
         wrinx($217A,$EB,2);
         l:=mm*longint(256)-256;
           end;
           wrinx3($217A,$E8,l);

           wrinx($217A,$EF,2);
           wrinx($217A,$ED,0);
           wrinx($217A,$EC,0);
           wrinx($217A,$E2,0);
           wrinx($217A,$E6,0);
           setinx($217A,$F7,$80);
         end;
    __IITAGX:if spcreg<>0 then
         begin
           outp(IOadr+10,$51);
           outp(spcreg+3,$ff);
           outp(IOadr+10,0);
           outp($3C8,1);
           outp(IOadr+10,$51);
           outp($3C9,0);
           outp($3C9,0);
           outp($3C9,0);
           outp($3C9,$FF);
           outp($3C9,$FF);
           outp($3C9,$FF);
           outp(IOadr+10,0);
           outp($3C8,$80);
           for x:=1 to 128 do outp(spcreg+3,$ff);
           for x:=1 to 128 do outp(spcreg+3,0);
         end;
       __ncr:begin
           w:=(mm*longint(16))-4;    {256 bytes from the end of Vmem.}
           y:=128;
           for x:=127 downto 0 do
           begin
         mp.b[x+y]:=swapb(mp.b[x]);
         if (x and 3)=0 then dec(y,4);
           end;
           for x:=0 to 31 do
         mp.l[x*2]:=mp.l[x*2+1] xor $FFFFFFFF;

           wrinx2m(SEQ,$11,$101);
           CopyCurMap(256);

           wrinx(SEQ,$A,$f);
           wrinx(SEQ,$B,$0);
           wrinx2m(SEQ,$13,0);
           wrinx2m(SEQ,$15,w);
           wrinx(SEQ,$17,$ff);
           wrinx(SEQ,$C,3);
         end;
  __PARADISE:begin
           WD_wait;
           outp($23C0,2);
           for x:=127 downto 0 do
         mp.w[x]:=mp.b[x] shl 8+$ff;  {XOR cursor, how to set
                           fore&bkground colors ?}


           CopyCurMap(256);
           l:=mm*longint(256)-64;
           WD_outl($1000,l);

           if version=WD_90c33 then w:=$C000
                   else w:=$5000;
           outpw($23C2,w);
           if memmode>_p8 then w:=$810 else w:=$800;
           outpw($23C2,w);
           outpw($23C0,1);
         end;
    __S3:begin
           if memmode>_p8 then
           begin
         for x:=0 to 127 do
         begin
           y:=pack8to16(bm[x]);
           mp.l[x]:=(longint(lo(y)) shl 24)+(y and $FF00)+$FF00FF;
         end;
         for x:=256 to 511 do mp.w[x]:=$ff;
           end
           else begin
         for x:=0 to 255 do mp.l[x]:=$ffff;  {Transparent}
         y:=376;
         for x:=127 downto 0 do
         begin
           mp.b[x+y]:=bm[x];
           if (x and 1)=0 then dec(y,2);
           if (x and 3)=0 then dec(y,8);
         end;
         if memmode=_pk4 then
           for x:=0 to 511 do
             mp.b[x]:=lo((mp.b[x] shl 4)+(mp.b[x] shr 4));
           end;
           CopyCurMap(1024);
           wrinx(crtc,$39,$A0);
           wrinx(crtc,$45,2);
           wrinx2(crtc,$4E,0);
           wrinx(crtc,$4A,$FF);
           wrinx(crtc,$4B,0);
           wrinx2m(crtc,$4C,mm-1);
           wrinx(crtc,$39,0);
         end;
    __Video7:begin
           for x:=0 to 63 do mp.w[x]:=mp.w[x] xor $FFFF;
           move(map,mp.b[128],128);
           CopyCurMap(256);
           wrinx(SEQ,$94,$FF);
           modinx(SEQ,$FF,$60,(mm-1) shr 3);
           setinx(SEQ,$A5,$80); {Enable cursor}
         end;
 __xbe,__xga:begin
           wrinx(IOadr+10,$36,0);
           fillchar(mp,1024,$ff);
           wrinx2(IOadr+10,$60,0);
           for x:=0 to 1024 do wrinx(IOadr+10,$6A,mp.b[x]);


           setHWcurcol($ff0000,$ff);
           wrinx(IOadr+10,$32,0);
           wrinx(IOadr+10,$35,0);
           wrinx(IOadr+10,$36,1);
         end;
  end;
end;

procedure setHWcurcol(fgcol,bkcol:longint);
begin
  case chip of
     __cir54:begin
           modinx(SEQ,$12,3,2);
           outp($3C8,$ff);
           outp($3C9,lo(fgcol) shr 2);
           outp($3C9,hi(fgcol) shr 2);
           outp($3C9,fgcol shr 18);
           outp($3C8,0);
           outp($3C9,lo(bkcol) shr 2);
           outp($3C9,hi(bkcol) shr 2);
           outp($3C9,bkcol shr 18);
           modinx(SEQ,$12,3,1);
         end;
    __IITAGX,
 __xbe,__XGA:begin
           wrinx3m(IOadr+10,$38,fgcol);
           wrinx3m(IOadr+10,$3B,bkcol);
         end;
  end;
end;

procedure HWcuronoff(on:boolean);
begin
  case chip of

       __S3:begin
          wrinx(crtc,$39,$a0);
          modinx(crtc,$45,3,2+ord(on));
          wrinx(crtc,$39,0);
        end;
 __paradise:begin
          outp($23C0,2);
          outpw($23C2,ord(on)*$800);
        end;
__xbe,__xga:wrinx(IOadr+10,$36,0);
  end;
end;

procedure setHWcurpos(X,Y:word);
var l:longint;
begin

  if extpixfact>1 then x:=x*extpixfact;
  if extlinfact>1 then Y:=Y*extlinfact;
  case chip of
    __al2101:begin
           if (rdinx(crtc,$19) and 1)=0 then y:=y*2;
           if memmode>_p8 then x:=x*2;
           wrinx(crtc,$21,x shr 3);
           wrinx(crtc,$23,y shr 1);
           modinx(crtc,$25,$7f,((x and 7) shl 2) + (y shr 9)
                  +((y and 1) shl 6) or $20);
         end;
    __atiGUP:begin
           outpw($12EE,x and 7);
           outpw($16EE,y and 7);
           x:=x and $FFF8;
           case memmode of
        _p15,_p16:x:=x*2;
         _p24:x:=x*3;
           end;
           l:=((y and $FFF8)*bytes+x) div 4;
           outpw($2AEE,l);
           outpw($2EEE,l shr 16);
         end;
  __chips452:begin
           wrinx2m(IOadr,$33,x);
           wrinx2m(IOadr,$35,y);
         end;
     __CIR54:BEGIN
           outpw(SEQ,(x shl 5) or $10);
           outpw(SEQ,(y shl 5) or $11);
         END;
    __compaq:begin
           inline($fa);
           outpw($93C8,x+32);
           outpw($93C6,y+32);
           inline($fb);
         end;
    __ET4W32:begin
           case memmode of
        _p15,_p16:x:=x*2;
         _p24:x:=x*3;
           end;
           wrinx2($217A,$E0,x);
           wrinx2($217A,$E4,y);
         end;
    __IITAGX:if spcreg<>0 then
         begin
           outp(IOadr+10,$51);
           outpw(spcreg,x);
           outpw(spcreg,y);
           outp(IOadr+10,0);
         end;
       __ncr:begin
           wrinx2m(SEQ,$D,x);
           wrinx2m(SEQ,$F,y);
         end;
  __PARADISE:begin
           case memmode of
        _p15,_p16:x:=x*2;
         _p24:x:=x*3;
           end;
           outp($23C0,2);
           if version=WD_90c33 then
           begin
         outpw($23C2,$D000+x);
         outpw($23C2,$E000+y);
           end
           else begin
         outpw($23C2,$6000+x);
         outpw($23C2,$7000+y);
           end;
         end;
    __S3:begin
           if memmode>_p8 then x:=x*2;
           wrinx(crtc,$39,$A0);
           wrinx2m(crtc,$46,x);
           wrinx2m(crtc,$48,y);
           wrinx(crtc,$45,3);
           wrinx(crtc,$39,0);
         end;
    __Video7:begin
           wrinx2m(SEQ,$9C,X);
           wrinx2m(SEQ,$9E,Y);
         end;
 __xbe,__XGA:begin
           wrinx2(IOadr+10,$30,x);
           wrinx2(IOadr+10,$33,y);
         end;
  end;
end;



procedure AL_DstCoor(xst,yst:word);
var l:longint;
    w:word;
begin
  l:=yst*longint(pixels)+xst;
  repeat until (inp($82AA) and $F)=0;
  if memmode>_p8 then
  begin
    l:=l*2;
    outpw($828A,pixels*2);
  end
  else outpw($828A,pixels);
  outpw($8286,l);
  outp( $8288,l shr 16);
  outpw($829C,xst);
  outpw($829E,yst);
end;

procedure AL_BlitArea(dx,dy:word);
begin
  if memmode>_p8 then dx:=dx*2;
  outpw($828C,dx);
  outpw($828E,dy);
end;

procedure AL_SrcCoor(xst,yst:word);
var l:longint;
    w:word;
begin
  l:=yst*longint(pixels)+xst;
  if memmode>_p8 then
  begin
    l:=l*2;
    outpw($8284,pixels*2);
  end
  else outpw($8284,pixels);
  outpw($8280,l);
  outp( $8282,l shr 16);
end;

procedure WD_coor(index,x,y:word);
var l,b:longint;
begin
  b:=bytes;
  if memmode<=_pl4 then b:=b*8;
  case memmode of
  _p15,_p16:x:=x*2;
       _p24:x:=x*3;
  end;
  l:=b*y+x;
  WD_outl(index,l);
end;

procedure WD_DstCoor(X,Y,dx,dy:word);
var b:longint;
begin
  WD_coor($4000,X,Y);
  b:=bytes;
  if memmode<=_pl4 then b:=b*8;
  case memmode of
  _p15,_p16:dx:=dx*2;
       _p24:dx:=dx*3;
  end;
  outpw($23C2,$6000+dx);
  outpw($23C2,$7000+dy);
  outpw($23C2,$8000+b);
end;

procedure P2000_DstCoor(X,Y,dx,dy:word);
var l:longint;
begin
  l:=longint(pixels)*y+x;
  if memmode>_p8 then
  begin
    dx:=dx*2;
    l:=l*2;
    wrinx2(GRC,$3A,pixels*2);
  end
  else wrinx2(GRC,$3A,pixels);
  wrinx2(GRC,$33,dx);
  wrinx3(GRC,$37,l);
  wrinx2(GRC,$35,dy);
end;

procedure P2000_SrcCoor(X,Y:word);
var l:longint;
begin
  l:=longint(pixels)*y+x;
  if memmode>_p8 then l:=l*2;
  if memmode=_pl4 then wrinx(GRC,5,0);  {set write mode 0}
  wrinx3(GRC,$30,l);
  wrinx2(GRC,$1E,pixels);
end;

procedure P2000_cmd(cmd:word);
begin
  wrinx(GRC,$3D,cmd);
  repeat until (rdinx(GRC,$3D) and 1)=0;
  wrinx(GRC,$3D,0);
end;

procedure S3_fill(xst,yst,dx,dy,col:word);
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,yst);
  outpw($86E8,Xst);
  outpw($96E8,dx);
  outpw($A6E8,col);
  outpw($BAE8,$27);
  outpw($BEE8,dy-1);
  outpw($BEE8,$A000);
  outpw($9AE8,$40F1);
end;

procedure fillrect(xst,yst,dx,dy:word;col:longint);
const
  masks:array[0..3] of byte=(0,7,3,1);
  maske:array[0..3] of byte=($F8,$FC,$FE,$FF);
  masks4:array[0..7] of byte=(0,$7F,$3F,$1F,$F,7,3,1);
  maske4:array[0..7] of byte=($80,$C0,$E0,$F0,$F8,$FC,$FE,$FF);
var w:word;
    l:longint;
begin
  case chip of
    __al2101:begin
           AL_DstCoor(xst,yst);
           AL_BlitArea(dx,dy);
           wrinx(GRC,$D,col);
           outp( $8290,7);
           outp( $8292,$D);
           outp( $82AA,1);
         end;
    __compaq:begin
           case memmode of
        _pl4,_pk4:col:=(col and 15)*$11111111;
          _p8:col:=lo(col)*$1010101;
           end;
           repeat until (inp($33CE) and 1)=0;
           if rdinx(GRC,$F)=$A5 then
           begin
         if memmode=_p8 then
         begin
           l:=(yst*bytes+xst) shr 2;
           w:=bytes shr 2;
           outp($33C0,masks[xst and 3]);
           outp($33C1,maske[((xst+dx-1) and 3)]);
           outp($33C8,(-dx) and 3);
           outp($33C9,masks[dx and 3]);
           if ((xst and 3)=0) and ((dx and 3)=0) then inc(dx,4);
           outpw($23C2,(dx +(xst and 3) +3) shr 2);
         end
         else begin
           l:=yst*bytes+(xst shr 3);
           w:=bytes;
           outp($33C0,masks4[xst and 7]);
           outp($33C1,maske4[(xst+dx-1) and 7]);
           outp($33C8,(-dx) and 7);
           outp($33C9,masks4[dx and 7]);
           if ((xst and 7)=0) and ((dx and 7)=0) then inc(dx,8);
           outpw($23C2,(dx +(xst and 7) +7) shr 3);
         end;
         outpw($23C0,l);
         outpw($23CA,w);
         outpw($23CC,w);
        { outpw($33C0,$ffff); }
         outp($33c7,$c);
        { outpw($33c8,0); }
         w:=(l shr 2) and $C000;
         w:=w or ((dy shl 4) and $3000);
         outpw($23C4,dy+w);
          {   if (xst and 3)>0 then inc(dx,4);
         if ((xst+dx-1) and 3)>0 then inc(dx,4); }
         outp($33CF,$30);
           end
           else begin
         outpw($63CC,xst);
         outpw($63CE,yst);
         outpw($23C2,dx);
         outpw($23C4,dy);
         outp($33CF,$C0);
         wrinx(GRC,$5A,2);
           end;
           outpw($33CA,col);
           outpw($33CA,col);
           outpw($33CC,col);
           outpw($33CC,col);
           outp($33CE,9);
         end;
     __cir54:begin
         end;
     __P2000:begin
           wrinx(GRC,$3E,col);
           P2000_DstCoor(xst,yst,dx,dy);
           P2000_cmd($19);
         end;
  __paradise:begin
           WD_wait;
           outpw($23C2,$1000);
           outpw($23C2,$E0FF);
           outpw($23C2,$2000);
           outpw($23C2,$3000);
           WD_DstCoor(xst,yst,dx,dy);
           outpw($23C2,$9300);
           outpw($23C2,$A000+col);
           w:=$808;
           if memmode>_pl4 then w:=w+$100;
           outpw($23C2,w);
           WD_wait;
         end;
    __S3:if bytes>=1024 then
         begin
           S3_fill(xst,yst,dx,dy,lo(col));
           if (memmode>_p8) then
         S3_fill(xst+1024,yst,dx,dy,hi(col));
         end;
{ __xbe,__xga:begin
           repeat until (mem[xgaseg:$11] and $80)=0;
           mem[xgaseg:$12]:=1;
           mem[xgaseg:$48]:=3;
           memw[xgaseg:$58]:=col;
           memw[xgaseg:$78]:=xst;
           memw[xgaseg:$7A]:=yst;
           memw[xgaseg:$60]:=dx-1;
           memw[xgaseg:$62]:=dy-1;


           meml[xgaseg:$7C]:=$8118000;
         end; }
  end;
end;

procedure S3_copy(srcX,srcY,dstX,dstY,dx,dy:word);
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,SrcY);
  outpw($86E8,SrcX);
  outpw($8AE8,DstY);
  outpw($8EE8,DstX);

  outpw($96E8,dx);
  outpw($BAE8,$67);
  outpw($BEE8,dy-1);
  outpw($BEE8,$A000);
  repeat until (inp($9AE8) and $80)=0;
  outpw($9AE8,$C0F1);
end;

procedure copyrect(srcX,srcY,dstX,dstY,dx,dy:word);
var l:longint;
    w,dir:word;
    i1,i2:integer;
begin
  if (DstY<SrcY) or ((SrcY=DstY) and (DstX<SrcX)) then dir:=0
  else begin
    dir:=1;
    SrcX:=SrcX+dx-1;
    SrcY:=SrcY+dy-1;
    DstX:=DstX+dx-1;
    DstY:=DstY+dy-1;
  end;
  case chip of
    __al2101:begin
           AL_DstCoor(DstX,DstY);
           AL_BlitArea(dx,dy);
           AL_SrcCoor(SrcX,SrcY);
           outp( $8290,7);
           outpw($8292,$D);
           outp( $82AA,2);
         end;
    __compaq:begin
           repeat until (inp($33CE) and 1)=0;
           if rdinx(GRC,$F)=$A5 then   {AVGA}
           begin
         l :=srcy*bytes+srcx;
         w:=256;
         if (dir>0) then w:=$FF00;
        {     begin
           l:=l+(dy-1)*bytes+(dx-1);
           w:=$ff00;
         end; }
         i1:=dsty-srcy;
         i2:=dstx-srcx;
         outpw($23C0,l shr 2);
         outpw($23CC,lo(i1)*256+lo(i2 shr 2));
         outp($23C2,dx shr 2);
         outpw($23CA,w{bytes shr 2});
         outpw($33C0,$ffff);
         outp($33c7,$c);
         outpw($33c8,0);
         w:=(w and $c00) or ((l shr 4) and $C000);
         w:=w or ((i1 shl 4) and $3000);
         outpw($23C4,dy+w);
         outp($33CF,$30);
           end
           else begin        {QVision}
         outpw($63CC,DstX);
         outpw($63CE,DstY);
         outpw($63C0,SrcX);
         outpw($63C2,SrcY);
         outpw($23C2,dx);
         outpw($23C4,dy);
         outpw($23CA,256);
         outpw($23CC,256);
         outp($33CF,$C0);
         wrinx(GRC,$5A,1);
           end;
           outp($33CE,$11);
         end;
     __cir54:begin
           repeat until (rdinx(GRC,$31) and 1)=0;
           case memmode of
         _p15,_p16:w:=2;
          _p24:w:=3;
           else w:=1;
           end;
           wrinx2(GRC,$20,dx*w);
           wrinx2(GRC,$22,dy);
           wrinx2(GRC,$24,bytes);
           wrinx2(GRC,$26,bytes);
           wrinx3(GRC,$28,dstY*bytes+dstX*w);
           wrinx3(GRC,$2C,srcY*bytes+srcX*w);
           wrinx(GRC,$32,$d);
           wrinx(GRC,$31,2);
         end;
     __P2000:begin
           P2000_SrcCoor(SrcX,SrcY);
           P2000_DstCoor(DstX,DstY,dx,dy);
           P2000_Cmd(5);
         end;
  __paradise:begin
           WD_wait;
           outpw($23C2,$1000);
           outpw($23C2,$E0FF);
           WD_DstCoor(DstX,DstY,dx,dy);
           WD_Coor($2000,SrcX,SrcY);
           outpw($23C2,$9300);
           w:=$800;
           if memmode>_pl4 then w:=w+$100;
           if dir>0 then w:=w+$400;
           outpw($23C2,w);
           WD_wait;
         end;
    __S3:if bytes>=1024 then
         begin
           S3_copy(SrcX,SrcY,DstX,DstY,dx,dy);
           if (memmode>_p8) then
         S3_copy(SrcX+1024,SrcY,DstX+1024,DstY,dx,dy);
         end;
 __xbe,__xga:begin
           repeat until (mem[xgaseg:$11] and $80)=0;
           mem[xgaseg:$48]:=3;
           memw[xgaseg:$70]:=SrcX;
           memw[xgaseg:$72]:=SrcY;
           memw[xgaseg:$78]:=DstX;
           memw[xgaseg:$7A]:=DstY;
           memw[xgaseg:$60]:=dx-1;
           memw[xgaseg:$62]:=dy-1;


           memw[xgaseg:$7C]:=$8000;
           memw[xgaseg:$7E]:=$811;
         end;
  end;
end;

procedure swp(var i,j:integer);
var z:integer;
begin
  z:=i;
  i:=j;
  j:=z;
end;

procedure S3_line(x0,y0,x1,y1,col:integer);
var w,z:word;
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,Y0);
  outpw($86E8,X0);
  w:=0;z:=0;
  x1:=x1-x0;
  if x1<0 then
  begin
    x1:=-x1;
    w:=w or $20;
    z:=1;
  end;
  y1:=y1-y0;
  if y1<0 then
  begin
    y1:=-y1;
    w:=w or $80;
  end;
  if x1<y1 then
  begin
    swp(x1,y1);
    w:=w or $40;
  end;
  outpw($8AE8,2*y1);
  outpw($8EE8,2*(y1-x1));
  outpw($92E8,2*y1-x1-z);
  repeat until (inp($9AE8) and $FF)=0;
  outpw($96E8,x1);
  outpw($A6E8,col);
  outpw($BAE8,$27);
  outpw($BEE8,$A000);
  outpw($9AE8,$2017+w);
end;


procedure line(x0,y0,x1,y1:integer;col:longint);
var l:longint;
  z,w:word;
begin
  case chip of
    __al2101:begin
           AL_DstCoor(x0,y0);
           wrinx(GRC,$D,col);
           outpw($82A8,$FFFF);
           w:=0;
           x1:=x1-x0;
           if x1<0 then
           begin
         x1:=-x1;
         w:=w or $100;
           end;
           if memmode>_p8 then x1:=x1*2;
           y1:=y1-y0;
           if y1<0 then
           begin
         y1:=-y1;
         w:=w or $200;
           end;
           if x1<y1 then
           begin
         swp(x1,y1);
         w:=w or $400;
           end;
           outpw($82A2,2*y1);
           outpw($82A6,2*y1-x1);
           outpw($82A4,2*(y1-x1));
           outpw($828E,x1+1);
           outpw($8292,$80D+w);
           outp ($8290,0);
           outp ($82AA,8);
         end;
    __S3:if bytes>=1024 then
         begin
           S3_line(x0,y0,x1,y1,lo(col));
           if (memmode>_p8) then
         S3_line(x0+1024,y0,x1+1024,y1,hi(col));
         end;
 __xbe,__xga:begin
           repeat until (mem[xgaseg:$11] and $80)=0;
           meml[xgaseg:$7C]:=$5010000;

         end;
  end;
end;










begin
end
.