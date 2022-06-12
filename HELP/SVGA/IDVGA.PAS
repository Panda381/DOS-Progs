
    (* Analyse the current mode *)

procedure AnalyseMode; {(mode:word;var pixs,lins,bytes,vseg:word;var mmode:mmods);}


procedure dumprg(base,start,ende:word;var rg:regblk);
var six,ix:word;
  same:boolean;
begin
  rg.base:=base;
  six:=inp(base);
  outp(base,0);
  ix:=inp(base) xor 255;
  outp(base,255);
  ix:=ix and inp(base);

  if ende=0 then
    if ix>127 then ende:=255
    else if ix>63 then ende:=127
    else if ix>31 then ende:=63
    else if ix>15 then ende:=31
    else if ix>7 then ende:=15
    else ende:=7;
  for ix:=start to ende do
    rg.x[ix]:=rdinx(base,ix);
  rg.nbr:=ende;
  outp(base,six);
  same:=true;
  while (rg.nbr>7) and same do    {Check for doubles}
  begin
    six:=succ(rg.nbr) div 2;
    for ix:=0 to six-1 do
      if rg.x[ix]<>rg.x[ix+six] then same:=false;
    if same then rg.nbr:=rg.nbr div 2;
  end;

end;

procedure DumpTridOldRegs;
begin
  wrinx(SEQ,$B,0);
  rgs.tridold0d:=rdinx(SEQ,$D);
  rgs.tridold0e:=rdinx(SEQ,$E);
  oldreg:=true;
end;

procedure DumpXGAregs;
var x:word;
begin
  dumprg(IOadr+10,0,0,rgs.xxregs);
  for x:=0 to 15 do
    rgs.xgaregs[x]:=inp(IOadr+x);
end;
const
  tridclk:array[0..15] of real=(25.175,28.322,44.9,36,57.272,65,50.35,40
                              ,88,98,118.89,108,72,77,80,75);
  triddiv:array[0..3] of real=(1,2,4,1.5);
  HMCclk:array[0..7] of real=(25.175,28.322,0,37.2,40,44.9,0,65);
  v7clk:array[0..7] of real=(25.175,28.322,30,32.514,34,36,38,40);
  aticlk1:array[0..7] of real=(50.175,56.644,0,44.9,44.9,50.157,0,36);
  aticlk2:array[0..15] of real=(42.954,48.771,16.657,36,50.35,56.64
       ,28.322,44.9,30.24,32,37.5,39,40,56.644,75,65);
  atidiv:array[0..3] of integer=(1,2,3,4);
  WDclk:array[0..7] of real=(40,50,0,44.9,25.175,28.322,65,36.242);
var x,m,wid,wordadr,pixwid,clksel:word;
    force256,graph:boolean;
    vtot:word;
begin

  case chip of  (* Enable ext *)
    __S3:begin
           wrinx(crtc,$38,$48);
           wrinx(crtc,$39,$A5);
         end;
  end;
  fillchar(rgs,sizeof(rgs),0);
  oldreg:=false;
  vclk:=0;
  for x:=$3C2 to $3DF do rgs.stdregs[x]:=inp(x);
  rgs.stdregs[$3DA]:=inp(CRTC+6);
  rgs.stdregs[$3C0]:=inp($3C0);
  for x:=0 to 31 do rgs.attregs[x]:=rdinx($3C0,x);
  x:=rdinx($3C0,$30);
  rgs.mode:=curmode;
  dumprg(CRTC,0,0,rgs.crtcregs);
  dumprg(SEQ,0,0,rgs.seqregs);
  dumprg(GRC,0,0,rgs.grcregs);
  case chip of
    __ati1,__ati2,__atiGUP:
          dumprg(IOadr,$A0,$BF,rgs.xxregs);
  __chips451,__chips452,__chips453:
          dumprg(IOadr,0,0,rgs.xxregs);
 __compaq:begin
            for x:=1 to 15 do
              for m:=0 to 15 do
                rgs.xxregs.x[(x-1)*16+m]:=inp(x*$1000+$3C0+m);
            rgs.xxregs.base:=$3C;
            rgs.xxregs.nbr:=240;

          end;
 __ET4W32:dumprg($217A,0,0,rgs.xxregs);
    __hmc:dumprg(SEQ,$0,$FF,rgs.xxregs);
  __oak87,
    __oak:dumprg($3DE,0,0,rgs.xxregs);
    __trid89,__tridBR,__tridCS:
          DumpTridOldRegs;
 __iitagx:if (inp(IOadr) and 4)=0 then DumpTridOldRegs
          else DumpXGAregs;
    __xga:DumpXGAregs;
  else rgs.xxregs.base:=0;
  end;
  case chip of  (* Disable ext *)
    __S3:begin
           wrinx(crtc,$38,0);
            wrinx(crtc,$39,$5A);
         end;
  end;

  m:=rgs.grcregs.x[6];
  case (m shr 2) and 3 of
  0,1:calcvseg:=$a000;
    2:calcvseg:=$b000;
    3:calcvseg:=$b800;
  end;
  clksel:=(rgs.stdregs[$3CC] shr 2) and 3;

  begin
    ilace:=false;
    extpixfact:=1;
    extlinfact:=1;

    calclines:=rgs.crtcregs.x[$12]+1;
    x:=rgs.crtcregs.x[7];
    if (x and 2)<>0 then inc(calclines,256);
    if (x and 64)<>0 then inc(calclines,512);
    pixwid:=8;
    calcpixels:=rgs.crtcregs.x[1]+1;
    force256:=false;
    vtot:=rgs.crtcregs.x[0]+5;

    graph:=(rgs.attregs[$10] and 1)>0;
    if graph then
    begin
      extlinfact:=(rgs.crtcregs.x[9] and $1F)+1;
      if (rgs.crtcregs.x[9] and $80)>0 then extlinfact:=extlinfact*2;
    end
    else begin
      if (rgs.attregs[$10] and 4)>0 then charwid:=9 else charwid:=8;
      charhigh:=(rgs.crtcregs.x[9] and $1f)+1;
    end;

    wid:=rgs.crtcregs.x[$13];
    wordadr:=2;
    if (rgs.crtcregs.x[$14] and 64)<>0 then wordadr:=8
    else if (rgs.crtcregs.x[$17] and 64)=0 then wordadr:=4;
    case chip of
    __aheada,__aheadb:
             begin
               if (rgs.grcregs.x[$1c] and 12)=12 then ilace:=true;
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;

             end;
      __ati1:begin
               if (rgs.xxregs.x[$B2] and 1)<>0 then ilace:=true;
               if (rgs.xxregs.x[$B2] and 64)>0 then inc(clksel,4);
               if (rgs.xxregs.x[$B0] and $20)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
               vclk:=aticlk1[clksel]/atidiv[rgs.xxregs.x[$B8] shr 6];
             end;
    __atiGUP,
      __ati2:begin
               if (rgs.xxregs.x[$BE] and 2)<>0 then ilace:=true;
               if (rgs.xxregs.x[$B0] and $20)>0 then
               begin
                 force256:=true;
                 wordadr:=16;
               end;
               if version=ATI_18800_1 then
               begin
                 if (rgs.xxregs.x[$BE] and 16)>0 then inc(clksel,4);
                 vclk:=aticlk1[clksel];
               end
               else begin
                 if (rgs.xxregs.x[$B9] and 2)>0 then inc(clksel,4);
                 if (rgs.xxregs.x[$BE] and 16)>0 then inc(clksel,8);
                 vclk:=aticlk2[clksel];
               end;
               vclk:=vclk/atidiv[rgs.xxregs.x[$B8] shr 6];
             end;
    __al2101:begin
               if ((rgs.grcregs.x[$C] and $10)<>0) then wordadr:=wordadr shl 1;
               if (rgs.crtcregs.x[$19] and 1)<>0 then
               begin
                 ilace:=true;
                 wordadr:=wordadr shr 1;
               end;
             end;
  __chips451,__chips453,
  __chips452:begin
               if (rgs.xxregs.x[$D] and 1)<>0 then inc(wid,256);
               if (rgs.seqregs.x[4] and 8)<>0 then
               begin
                 wordadr:=8;
                 calcpixels:=calcpixels shr 1;
               end;
             end;
     __cir54:begin
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
               if (rgs.crtcregs.x[$1B] and 16)<>0 then inc(wid,256);
               if (rgs.crtcregs.x[$1A] and 1)<>0 then ilace:=true;
               vclk:=(14.31818*rgs.seqregs.x[$B+clksel])/(rgs.seqregs.x[$1B+clksel] shr 1);
               if (rgs.seqregs.x[$1B+clksel] and 1)>0 then vclk:=vclk/2;
               case (rgs.seqregs.x[7] and 6) of
                 2:vclk:=vclk/2;
                 4:vclk:=vclk/3;
               end;
             end;
     __cir64:begin
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
               if (rgs.grcregs.x[$82] and 7)=2 then pixwid:=4;
             end;
    __compaq:begin
               if (rgs.grcregs.x[$F] and $F0)=0 then wordadr:=8;
               if (rgs.grcregs.x[$42] and 1)>0 then inc(wid,256);
               if (rgs.crtcregs.x[$14] and 64)>0 then pixwid:=4;
             end;
    __ET3000:begin
               if (rgs.crtcregs.x[$25] and $80)>0 then ilace:=true;
               if (rgs.grcregs.x[5] and $40)>0 then wordadr:=16;
               if (rgs.seqregs.x[7] and $40)>0 then
               begin
                 pixwid:=pixwid*2;
                 wordadr:=wordadr*2;
               end;
             end;
    __ET4w32,
    __ET4000:if (rgs.crtcregs.x[$3f] and 128)<>0 then inc(wid,256);
     __genoa:if (rgs.crtcregs.x[$2F] and 1)<>0 then ilace:=true;
       __hmc:begin
               IF (rgs.xxregs.x[$E7] and 1)>0 then ilace:=true;
               if (rgs.xxregs.x[$E7] and 2)>0 then force256:=true;
               if (rgs.xxregs.x[$E7] and 64)>0 then inc(clksel,4);
               vclk:=HMCclk[clksel];
             end;
    __iitagx:if (inp(IOadr) and 4)=0 then
             begin
               if (rgs.tridold0d and 16)<>0 then wordadr:=wordadr*2;
               if (rgs.seqregs.x[4] and 8)>0 then pixwid:=4;
             end
             else begin
               calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
               pixwid:=8;
               calclines :=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
               wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
               wordadr:=8;
             end;
      __mxic:if (rgs.seqregs.x[$F0] and 3)=3 then ilace:=true;
       __NCR:begin
               if (rgs.seqregs.x[$20] and 2)<>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
               if (rgs.seqregs.x[$1F] and $10)<>0 then
                 case rgs.seqregs.x[$1F] and 15 of
                   0:pixwid:=4;
                  11:pixwid:=16;
                 else pixwid:=(rgs.seqregs.x[$1F] and 15)+6;
                 end;
               if (rgs.crtcregs.x[$30] and 2)<>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$30] and $10)<>0 then
               begin
                 ilace:=true;
                 extlinfact:=1;
               end;
             end;
       __oak:begin
               if (rgs.xxregs.x[$14] and 128)<>0 then ilace:=true;
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;
                                          {Cheat for 256 color mode}
             end;
     __oak87:begin
               if (rgs.xxregs.x[$14] and 128)<>0 then ilace:=true;
               if (rgs.seqregs.x[4] and 8)<>0 then
                 if (rgs.xxregs.x[$21] and 4)>0 then wordadr:=16
                                                else pixwid:=4;
             end;
     __p2000:begin
               if (rgs.grcregs.x[$13] and 64)<>0 then
               begin
                 wordadr:=wordadr shr 1;
                 ilace:=true;
               end;
               if (rgs.grcregs.x[$21] and 32)<>0 then inc(wid,256);
             end;
  __paradise:begin

               if (version>=WD_90c00) and ((rgs.crtcregs.x[$2D] and $20)<>0) then ilace:=true;
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
                                          {Cheat for 256 color mode}
               if (rgs.grcregs.x[$C] and 2)>0 then inc(clksel,4);
               vclk:=WDclk[clksel];
               if (version>=WD_90c33) and ((rgs.crtcregs.x[$3E] and $20)>0) then inc(vtot,256);
             end;
   __realtek:begin
               if (rgs.seqregs.x[4] and 8)<>0 then pixwid:=4;
               if (rgs.grcregs.x[$C] and $10)<>0 then
               begin
                 pixwid:=pixwid*2;
                 wid:=wid*2;
               end;
               if (rgs.crtcregs.x[$19] and 1)<>0 then
               begin
                 ilace:=true;
                 wid:=wid div 2;
               end;
             end;
        __s3:begin
               if (rgs.crtcregs.x[$42] and $20)<>0 then ilace:=true;
               if (rgs.crtcregs.x[$43] and 4)<>0   then inc(wid,256);
               if (rgs.crtcregs.x[$43] and 128)<>0 then pixwid:=pixwid*2;
               if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8 else wordadr:=2;
               if (rgs.attregs[$10] and 1)=0 then wid:=wid*2;
             end;
    __tridCS,
    __trid89:begin
               if (rgs.tridold0d and 16)<>0 then wordadr:=wordadr*2
               else if (rgs.seqregs.x[4] and 8)>0 then pixwid:=pixwid div 2;
               if (rgs.crtcregs.x[$1e] and 4)<>0 then
               begin
                 ilace:=true;
                 wordadr:=wordadr div 2;
               end;
               if (rgs.tridold0E and $10)>0 then inc(clksel,8)
               else if (rgs.seqregs.x[$D] and 1)>0 then inc(clksel,4);
               vclk:=tridclk[clksel]/triddiv[(rgs.seqregs.x[$D] shr 1) and 3];
             end;
       __UMC:begin
               if (rgs.crtcregs.x[$2F] and 1)>0 then
               begin
                 ilace:=true;
                 wordadr:=wordadr div 2;
               end;
               if (rgs.crtcregs.x[$33] and $10)>0 then wordadr:=16;
             end;
    __video7:begin
               if (rgs.seqregs.x[$E0] and $10)<>0 then ilace:=true;
               vclk:=v7clk[(rdinx(SEQ,$A4) shr 2) and 7];
             end;
       __xbe,
       __xga:begin
               calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
               pixwid:=8;
               calclines:=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
               wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
               wordadr:=8;
             end;
    end;
    if ilace then calclines:=calclines*2;
    if (rgs.attregs[$10] and 1)=0 then  {Text}
    begin
      calclines:=calclines div ((rgs.crtcregs.x[9] and $1F)+1);
      if (rgs.attregs[$10] and 2)=0 then calcmmode:=_TEXT
                                    else calcmmode:=_TEXT4;
      pixwid:=charwid;
    end
    else begin
      if (rgs.crtcregs.x[$17] and 1)=0 then {CGA}
      begin
        if (rgs.crtcregs.x[$17] and $40)>0 then calcmmode:=_cga1
                                           else calcmmode:=_cga2;
        extlinfact:=extlinfact shr 1;
      end
      else if ((rgs.attregs[$10] and 64)=0) and ((rgs.grcregs.x[5] and 64)=0)
       and not force256 then  {16 color}
      begin
        if {((rgs.crtcregs.x[$17] and $20)=0)
         or} ((rgs.attregs[$10] and 2)>0) then calcmmode:=_pl1
        else if (rgs.attregs[$12]=5) then
        begin
          calcmmode:=_pl2;
          pixwid:=pixwid*2;
        end
        else if (rgs.seqregs.x[4] and 8)>0 then calcmmode:=_pk4
                                           else calcmmode:=_pl4;
      end
      else begin
        calcmmode:=_p8;
        if dactype>_dac8 then
        begin
          x:=getdaccomm;

          case dactype of
            _dac15:if x>127 then calcmmode:=_p15;
            _dac16:case (x and $c0) of
                     $80:calcmmode:=_p15;
                     $c0:calcmmode:=_p16;
                   end;
          _dacss24:begin
                 (*    while x<>$8e do x:=inp($3C6); *)
                     x:=inp($3C6);
                     rgs.stdregs[$3c1]:=x;
                     case x of
                      $a6:calcmmode:=_p16;
                      $A0:calcmmode:=_p15;
                      $9E:calcmmode:=_p24;
                     end;
                   end;
           _dacatt:case (x and $E0) of
                 $80,$A0:calcmmode:=_p15;
                     $C0:calcmmode:=_p16;
                     $E0:calcmmode:=_p24;
                   end;
         _dacadac1:case (x and $C7) of
                     $C1:calcmmode:=_p16;
                     $C5:calcmmode:=_p24;
                     $80:calcmmode:=_p15;
                   end;
          _dacSC24:case (x and $E0) of
                 $80,$A0:calcmmode:=_p15;
                 $C0,$E0:calcmmode:=_p16;
                     $60:calcmmode:=_p24;
                   end;
          _dacCL24:case x of
                     $F0:calcmmode:=_p15;
                     $E1:calcmmode:=_p16;
                     $E5:calcmmode:=_p24;
                   end;
           _dacmus:case (x and $e0) of
                     $a0:calcmmode:=_p15;
                     $c0:calcmmode:=_p16;
                     $e0:calcmmode:=_p24;
                   end;
           _dacalg:if (rgs.crtcregs.x[$19] and 16)<>0 then calcmmode:=_p16;
         _dacBt484:case inp($3C8+DAC_RS3) and $78 of
                     $10:calcmmode:=_p32;
                     $30:calcmmode:=_p15;
                     $38:calcmmode:=_p16;
                   end;
          end;
          if (dactype<>_dacCL24) and (dactype<>_dacBt484) then
            case calcmmode of               {Adjust for HiColor}
          _p15,_p16:calcpixels:=calcpixels div 2;
               _p24:calcpixels:=calcpixels div 3;
            end;
        end;
      end;
      calcpixels:=calcpixels*pixwid;
    end;
    calcbytes:=wid*wordadr;
  end;
  if (rgs.seqregs.x[1] and 8)>0 then vclk:=vclk/2;
  if vclk>0 then
  begin
    hclk:=(vclk*1000)/(vtot*pixwid);
    x:=rgs.crtcregs.x[6]+2;
    if (rgs.crtcregs.x[7] and 1)>0 then inc(x,256);
    if (rgs.crtcregs.x[7] and $20)>0 then inc(x,512);
    fclk:=hclk*1000/x;
  end;
  if extlinfact>0 then calclines:=calclines div extlinfact;

  rgs.bytes :=calcbytes;
  rgs.pixels:=calcpixels;
  rgs.lins  :=calclines;
  rgs.mmode :=calcmmode;
  rgs.chip  :=chip;
end;



procedure wrregs(var rg:regblk);
var x:word;
begin
  write(hex4(rg.base)+':');
  for x:=0 to rg.nbr do
  begin
    if (x mod 25=0) and (x>0) then
      write('('+hex2(x)+'):');

    write(' '+hex2(rg.x[x]));
  end;
  writeln;
end;

function dumpVGAregs:word;
var x:word;
begin
  textmode($103);  {Set 43/50 line text mode}
  writeln('Mode: '+hex2(rgs.mode)+'h Pixels: '+istr(rgs.pixels)+' lines: '+istr(rgs.lins)
       +' bytes: '+istr(rgs.bytes)+' colors: '+istr(modecols[rgs.mmode]));
  writeln;
  if oldreg then writeln('SEQ (OLD): 0Dh: ',hex2(rgs.tridold0d)
                                  ,' 0Eh: ',hex2(rgs.tridold0e));

  for x:=$3C0 to $3CF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  for x:=$3D0 to $3DF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  write('03C0:');
  for x:=0 to 31 do
  begin
    if x=25 then write('(19):');
    write(' '+hex2(rgs.attregs[x]));
  end;
  writeln;
  wrregs(rgs.seqregs);
  wrregs(rgs.grcregs);
  wrregs(rgs.crtcregs);
  if rgs.xxregs.base<>0 then
  begin
    if (rgs.xxregs.base and $ff8f)=$210A then
    begin
      write(hex4(rgs.xxregs.base and $fff0)+':');
      for x:=0 to 15 do write(' '+hex2(rgs.xgaregs[x]));
      writeln;
    end;
    wrregs(rgs.xxregs);
  end;
  writeln;
  dumpVGAregs:=getkey;
end;

function FormatRgs(var b:byte):word;   {Format registers for dump}
type
  barr=array[1..2000] of byte;
var
  blk:^barr;
  bts,x:word;

procedure appb(b:byte);
begin
  inc(bts);
  blk^[bts]:=b;
end;

procedure appw(w:word);
begin
  appb(lo(w));
  appb(hi(w));
end;

procedure apprgs(var r:regblk);
var x:word;
begin
  appw(1);
  appw(r.base);
  appb(0);
  appb(r.nbr);
  for x:=0 to r.nbr do appb(r.x[x]);
end;

begin
  blk:=@b;
  bts:=0;
  appw(1);
  appw($3C0);
  appb(0);
  appb(31);
  for x:=0 to 31 do appb(rgs.attregs[x]);
  apprgs(rgs.seqregs);
  apprgs(rgs.grcregs);
  apprgs(rgs.crtcregs);
  if rgs.xxregs.base<>0 then apprgs(rgs.xxregs);
  if oldreg then
  begin
    appw($FF);
    appw(0);
    appb(rgs.tridold0d);
    appw($FF);
    appw(1);
    appb(rgs.tridold0e);
  end;
  if (rgs.xxregs.base and $FF8F)=$210A then
  begin
    appw(16);
    appw(rgs.xxregs.base-$A);
    for x:=0 to 15 do appb(rgs.xgaregs[x]);
  end;
  appw($3C2);
  appb(rgs.stdregs[$3C2]);
  appw(8);
  appw($3C6);
  for x:=$3C6 to $3CD do appb(rgs.stdregs[x]);
  appw(8);
  appw(crtc+4);
  for x:=$3D8 to $3DF do appb(rgs.stdregs[x]);
  appw(0);
  FormatRgs:=bts;
end;


procedure dumpVGAregfile;
var
  f:file of regtype;
begin
  assign(f,'register.vga');
  {$i-}
  reset(f);
  {$i+}
  if ioresult=0 then seek(f,filesize(f)) else rewrite(f);
  write(f,rgs);
  close(f);
end;





   (*  Tests for various adapters  *)


procedure _ahead;
var old:word;
begin
  old:=rdinx(GRC,$F);
  wrinx(GRC,$F,0);
  if not testinx2(GRC,$C,$FB) then
  begin
    wrinx(GRC,$F,$20);
    if testinx2(GRC,$C,$FB) then
    begin
      case rdinx(GRC,$F) and 15 of
        0:begin
            Version:=AH_A;
            chip:=__aheadA;
          end;
        1:begin
            Version:=AH_B;
            chip:=__aheadB;
            features:=ft_rwbank;
          end;
      end;
      case rdinx(GRC,$1F) and 3 of
        0:mm:=256;
        1:mm:=512;
        2:;
        3:mm:=1024;
      end;
      addvideo;
    end;
  end;
  wrinx(GRC,$F,old);
end;

procedure _al2101;
begin
  old:=rdinx(crtc,$1A);
  clrinx(crtc,$1A,$10);
  if not testinx(crtc,$19) then
  begin
    setinx(crtc,$1A,$10);
    if testinx(crtc,$19) and testinx2(crtc,$1A,$3F) then
    begin
      Version:=AL_2101;
      chip:=__al2101;
      features:=ft_rwbank+ft_blit+ft_cursor+ft_line;
      case rdinx(crtc,$1e) and 3 of
        0:mm:=256;
        1:mm:=512;
        2:mm:=1024;
        3:mm:=2048;
      end;
      SetDAC(_dacalg,'ALG1101');
      addvideo;
    end;
  end;
  wrinx(crtc,$1A,old);
end;

procedure _ati;
var w:word;
begin
  if getbios($31,9)='761295520' then
  begin
    case memw[biosseg:$40] of
     $3133:begin
             IOadr:=memw[biosseg:$10];
             w:=rdinx(IOadr,$BB);
             case w and 15 of
               0:_crt:='EGA';
               1:_crt:='Analog Monochrome';
               2:_crt:='Monochrome';
               3:_crt:='Analog Color';
               4:_crt:='CGA';
               6:_crt:='';
               7:_crt:='IBM 8514/A';
             else _crt:='Multisync';
             end;
             chip:=__ati2;
             SubVers:=mem[biosseg:$43];
             case SubVers of
              $31:begin
                    Version:=ATI_18800;
                    chip:=__ati1;
                  end;
              $32:Version:=ATI_18800_1;
              $33:Version:=ATI_28800_2;
              $34:Version:=ATI_28800_4;
              $35:Version:=ATI_28800_5;
              $61:begin
                    chip:=__atiGUP;
                    SubVers:=inpw($FAEE);
                    case SubVers and $3FF of
                     $2F7:Version:=ATI_GUP_6;
                     $177:Version:=ATI_GUP_LX;
                     $017:Version:=ATI_GUP_AX;
                        0:Version:=ATI_GUP_3;
                    end;
                    SetDAC(_daccl24,'ATI Bogus DAC');
                  end;
             else Version:=ATI_Unknown;
             end;
             if Version>=ATI_18800_1 then features:=ft_rwbank;
             case Version of
           ATI_18800,ATI_18800_1:
                       if (rdinx(IOadr,$bb) and 32)<>0 then mm:=512;
           ATI_28800_2:if (rdinx(IOadr,$b0) and 16)<>0 then mm:=512;
           ATI_28800_4,ATI_28800_5:
                       case rdinx(IOadr,$b0) and $18 of
                           0:mm:=256;
                         $10:mm:=512;
                       8,$18:mm:=1024;
                       end;
           ATI_GUP_3..ATI_GUP_LX:
                       case inp($36EE) and $C of
                         0:mm:=512;
                         4:mm:=1024;
                         8:mm:=2048;
                        12:mm:=4096;
                       end;
             end;
           end;
     $3233:begin
             Version:=ATI_EGA;
             video:='EGA';
             chip:=__ega;
           end;
    end;
    addvideo;
  end;
end;

procedure _chipstech;
var prt,old,x:word;
begin
  prt:=$46E8;    {Should be $94 for MCA systems}
  old:=inp(prt);     {This can cause problems for non-CT chips,
                      as their 46E8h port may be updated incorrectly}
  outp(prt,$E);
  if inp($104)<>$A5 then
  begin
    outp(prt,$1E);

    if inp($104)=$A5 then
    begin
      x:=inp($103);
      outp($103,x or $80);  {Enable extensions}
      outp(prt,$E);
      if (x and $40)=0 then IOadr:=$3D6 else IOadr:=$3B6;
      SubVers:=rdinx(IOadr,0);
      case SubVers shr 4 of
        0:Version:=CT_451;
        1:Version:=CT_452;
        2:Version:=CT_455;
        3:Version:=CT_453;
        4:Version:=CT_450;
        5:Version:=CT_456;
        6:Version:=CT_457;
        7:Version:=CT_65520;
        8:Version:=CT_65530;
        9:Version:=CT_65510;
      else Version:=CT_Unknown;
      end;
      case Version of
        CT_452:begin
                 CHIP:=__chips452;
                 features:=ft_cursor;
               end;
        CT_450,
        CT_453:CHIP:=__chips453;
      else chip:=__chips451;
      end;
      case rdinx(IOadr,4) and 3 of
        1:mm:=512;
      2,3:mm:=1024;
      end;
      addvideo;
    end;
  end;
end;

procedure _cirrus;
var old,old6:word;
begin
  old6:=rdinx(SEQ,6);
  old:=rdinx(crtc,$C);
  outp(crtc+1,0);
  SubVers:=rdinx(crtc,$1F);
  wrinx(SEQ,6,lo(Subvers shr 4) or lo(Subvers shl 4));
                         {The SubVers value is rotated by 4}
  if inp(SEQ+1)=0 then
  begin
    outp($3c5,SubVers);
    if inp($3c5)=1 then
    begin
      case SubVers of
        $EC:Version:=CL_GD5x0;
        $CA:Version:=CL_GD6x0;
        $EA:Version:=CL_V7_OEM;
      else Version:=CL_old_unk;
      end;
      chip:=__cirrus;
      addvideo;
    end;
  end;
  wrinx(crtc,$C,old);
  wrinx(SEQ,6,old6);
end;


procedure _cirrus54;
var x,old:word;
begin
  old:=rdinx(SEQ,6);
  wrinx(SEQ,6,0);
  if (rdinx(SEQ,6)=$F) then
  begin
    wrinx(SEQ,6,$12);
    if (rdinx(SEQ,6)=$12) and testinx2(SEQ,$1E,$3F) {and testinx2(crtc,$1B,$ff)} then
    begin
      case rdinx(SEQ,$A) and $18 of    {memory}
        0:mm:=256;
        8:mm:=512;
       16:mm:=1024;
       24:mm:=2048;
      end;
      SubVers:=rdinx(crtc,$27);
      if testinx(GRC,9) then
      begin
        case SubVers of
            $18:Version:=CL_AVGA2;
            $88:Version:=CL_GD5402;
            $89:Version:=CL_GD5402r1;
            $8A:Version:=CL_GD5420;
            $8B:Version:=CL_GD5420r1;
       $8C..$8F:Version:=CL_GD5422;
       $90..$93:Version:=CL_GD5426;
       $94..$97:Version:=CL_GD5424;
       $98..$9B:Version:=CL_GD5428;
       $A4..$A7:Version:=CL_GD543x;
        else Version:=CL_Unk54;
        end;
        SetDAC(_dacCL24,'Cirrus CL24');
      end
      else if testinx(SEQ,$19) then
        case SubVers shr 6 of
          0:Version:=CL_GD6205;
          1:Version:=CL_GD6235;
          2:Version:=CL_GD6215;
          3:Version:=CL_GD6225;
        end
      else begin
        Version:=CL_AVGA2;
        case rdinx(SEQ,$A) and 3 of
          0:mm:=256;
          1:mm:=512;
          2:mm:=1024;
        end;
      end;
      features:=ft_cursor;
      chip:=__cir54;
      addvideo;
    end;
  end
  else wrinx(SEQ,6,old);
end;

procedure _cirrus64;
var x,old:word;
begin
  old:=rdinx(GRC,$A);
  wrinx(GRC,$A,$CE);  {Lock}
  if (rdinx(GRC,$A)=0) then
  begin
    wrinx(GRC,$A,$EC);  {unlock}
    if (rdinx(GRC,$A)=1) then
    begin
      SubVers:=rdinx(GRC,$AA);
      case SubVers shr 4 of
        4:Version:=CL_GD6440;
        5:Version:=CL_GD6412;
        6:Version:=CL_GD5410;
        7:Version:=CL_GD6420;
        8:Version:=CL_GD6410;
      else Version:=CL_Unk64;
      end;
      case rdinx(GRC,$BB) shr 6 of
        0:mm:=256;
        1:mm:=512;
        2:mm:=768;
        3:mm:=1024;
      end;
      chip:=__cir64;
      addvideo;
    end;
  end;
  wrinx(GRC,$A,old);
end;


procedure _compaq;
var old,x:word;
begin
  old:=rdinx(GRC,$F);
  wrinx(GRC,$F,0);
  if not testinx(GRC,$45) then
  begin
    wrinx(GRC,$F,5);
    if testinx(GRC,$45) then
    begin
      chip:=__compaq;
      features:=ft_blit;
      SubVers:=rdinx(GRC,$C) shr 3;
      case SubVers of
        3:Version:=CPQ_IVGS;
        5:Version:=CPQ_AVGA;
        6:Version:=CPQ_QV1024;
       $E:if (rdinx(GRC,$56) and 4)<>0 then Version:=CPQ_QV1280
                                       else Version:=CPQ_QV1024;
      $10:Version:=CPQ_AVPort;
      else Version:=CPQ_Unknown;
      end;
      if (rdinx(GRC,$C) and $B8)=$30 then  {QVision}
      begin
        features:=features + ft_cursor;
        wrinx(GRC,$F,$F);
        case rdinx(GRC,$54) of
          0:mm:=1024;  {QV1024 fix}
          2:mm:=512;
          4:mm:=1024;
          8:mm:=2048;
        end;
        DAC_RS2:=$8000;
        DAC_RS3:=$1000;
      end
      else begin
        rp.bx:=0;
        rp.cx:=0;
        vio($BF03);
        if (rp.ch and 64)=0 then mm:=512;
      end;
      addvideo;
    end
  end;
  wrinx(GRC,$F,old);
end;

procedure _everex;
var x:word;
begin
  rp.bx:=0;
  vio($7000);
  if rp.al=$70 then
  begin
    x:=rp.dx shr 4;
    if  (x<>$678) and (x<>$236)
    and (x<>$620) and (x<>$673) then     {Some Everex boards use Trident chips.}
    begin
      case rp.ch shr 6 of
        0:mm:=256;
        1:mm:=512;
        2:mm:=1024;
        3:mm:=2048;
      end;
      name:='Everex Ev'+hx[x shr 8]+hx[(x shr 4) and 15]+hx[x and 15];
      chip:=__everex;
      addvideo;
    end;
  end;
end;

procedure _genoa;
var ad:word;
begin
  ad:=memw[biosseg:$37];
  if (memw[biosseg:ad+2]=$6699) and (mem[biosseg:ad]=$77) then
  begin
    case mem[biosseg:ad+1] of
      0:Version:=GE_6200;
    $11:begin
          Version:=GE_6400;
          mm:=512;
        end;
    $22:Version:=GE_6100;
    $33:Version:=GE_5100;  {Do we need to detect the Tseng versions ??}
    $55:begin
          Version:=GE_5300;
          mm:=512;
        end;
    end;
    if mem[biosseg:ad+1]<$33 then chip:=__genoa else chip:=__ET3000;
    addvideo;
  end
end;

procedure _hmc;
begin
  if testinx(SEQ,$E7) and testinx(SEQ,$EE) then
  begin
    if (rdinx(SEQ,$E7) and $10)>0 then mm:=512;
    chip:=__HMC;
    Version:=HMC_304;
    addvideo;
  end;
end;

procedure _mxic;
begin
  old:=rdinx(SEQ,$A7);
  wrinx(SEQ,$A7,0);       {disable extensions}
  if not testinx(SEQ,$C5) then
  begin
    wrinx(SEQ,$A7,$87);   {enable extensions}
    if testinx(SEQ,$C5) then
    begin
      chip:=__mxic;
      if (rdinx(SEQ,$26) and 1)=0 then Version:=MX_86010
      else Version:=MX_86000;   {Does this work, else test 85h bit 1 ??}
      case (rdinx(SEQ,$C2)  shr 2) and 3 of
        0:mm:=256;
        1:mm:=512;
        2:mm:=1024;
      end;
      addvideo;
    end;
  end;
  wrinx(SEQ,$A7,old);
end;

procedure _ncr;
var x:word;
begin
  if testinx2(SEQ,5,5) then
  begin
    wrinx(SEQ,5,0);        {Disable extended registers}
    if not testinx(SEQ,$10) then
    begin
      wrinx(SEQ,5,1);        {Enable extended registers}
      if testinx(SEQ,$10) then
      begin
        chip:=__ncr;
        SubVers:=rdinx(SEQ,8);
        case SubVers shr 4 of
          0:Version:=NCR_77C22;
          1:Version:=NCR_77C21;
          2:Version:=NCR_77C22E;
      8..15:Version:=NCR_77C22Ep;
        else Version:=NCR_Unknown;
        end;
        features:=ft_rwbank+ft_cursor;
        name:=name+' Rev. '+istr(rdinx(SEQ,8) and 15);
        if setmode($13) then;
        checkmem(64);
        addvideo;
      end;
    end;
  end;
end;

procedure _oak;
var i:word;
begin
  if testinx2($3DE,$D,$38) then
  begin
    features:=ft_rwbank;
    if testinx2($3DE,$23,$1F) then
    begin
      case rdinx($3DE,2) and 6 of
        0:mm:=256;
        2:mm:=512;
        4:mm:=1024;
        6:mm:=2048;
      end;
      chip:=__oak87;
      if (rdinx($3DE,0) and 2)=0 then Version:=OAK_087
                                 else version:=OAK_083;
    end
    else begin
      SubVers:=inp($3DE) shr 5;
      case SubVers of
        0:Version:=OAK_037;
        2:Version:=OAK_067;
        5:Version:=OAK_077;
        7:Version:=OAK_057;
      else Version:=OAK_Unknown;
      end;

      case rdinx($3de,13) shr 6 of
        2:mm:=512;
      1,3:mm:=1024;    {1 might not give 1M??}
      end;
      chip:=__oak;
    end;
    features:=ft_rwbank;
    addvideo;
  end;
end;

procedure _p2000;
begin
  if testinx2(GRC,$3D,$3F) and tstrg($3D6,$1F) and tstrg($3D7,$1F) then
  begin
    Version:=PR_2000;
    chip:=__p2000;
    features:=ft_rwbank+ft_blit;
    if setmode($13) then;
    checkmem(32);
    addvideo;
  end;
end;

procedure _paradise;
var old,old2:word;
begin
  old:=rdinx(GRC,$F);
  setinx(GRC,$F,$17);   {Lock registers}

  if not testinx2(GRC,9,$7F) then
  begin
    wrinx(GRC,$F,5);      {Unlock them again}
    if testinx2(GRC,9,$7F) then
    begin
      old2:=rdinx(crtc,$29);
      modinx(crtc,$29,$8F,$85);   {Unlock WD90Cxx registers}
      if not testinx(crtc,$2B) then Version:=WD_PVGA1A
      else begin
        wrinx(SEQ,6,$48);   {Enable C1x extensions}
        if not testinx2(SEQ,7,$F0) then Version:=WD_90C00
        else if not testinx(SEQ,$10) then
        begin
          if testinx2(crtc,$31,$68) then Version:=WD_90c22
          else if testinx2(crtc,$31,$90) then Version:=WD_90c20A
          else Version:=WD_90C20;
          wrinx(crtc,$34,$A6);
          if (rdinx(crtc,$32) and $20)<>0 then wrinx(crtc,$34,0);
        end
        else begin
          features:=ft_rwbank;
          if testinx2(SEQ,$14,$F) then
          begin
            SubVers:=(rdinx(crtc,$36) shl 8)+rdinx(crtc,$37);
            case SubVers of
              $3234:Version:=WD_90c24;
              $3236:Version:=WD_90C26;
              $3330:Version:=WD_90c30;
              $3331:begin
                      Version:=WD_90C31;
                      features:=features+ft_cursor+ft_blit;
                    end;
              $3333:begin
                      Version:=WD_90C33;
                      features:=features+ft_cursor;
                    end;
            end;
          end
          else if not testinx2(SEQ,$10,4) then Version:=WD_90C10
                                          else Version:=WD_90C11;
        end;
      end;
      case rdinx(GRC,11) shr 6 of
             2:mm:=512;
             3:mm:=1024;
      end;
      if (Version>=WD_90c33) and ((rdinx(crtc,$3E) and $80)>0) then mm:=2048;
      wrinx(crtc,$29,old2);
      chip:=__paradise;
      addvideo;
    end;
  end;
  wrinx(GRC,$F,old);
end;

procedure _realtek;
var x:word;
begin
  if testinx2(crtc,$1F,$3F) and tstrg($3D6,$F) and tstrg($3D7,$F) then
  begin
    chip:=__realtek;
    SubVers:=rdinx(crtc,$1A) shr 6;
    case SubVers of
      0:Version:=RT_3103;
      1:Version:=RT_3105;
      2:Version:=RT_3106;
    else Version:=RT_unknown;
    end;
    case rdinx(crtc,$1e) and 15 of
      0:mm:=256;
      1:mm:=512;
      2:if x=0 then mm:=768  else mm:=1024;
      3:if x=0 then mm:=1024 else mm:=2048;
    end;
    features:=ft_rwbank;
    addvideo;
  end;
end;

procedure _s3;
begin
  wrinx(crtc,$38,0);
  if not testinx2(crtc,$35,$F) then
  begin
    wrinx(crtc,$38,$48);
    if testinx2(crtc,$35,$F) then
    begin
      features:=ft_blit+ft_line+ft_cursor;
      SubVers:=rdinx(crtc,$30);
      case SubVers of
        $81:Version:=S3_911;
        $82:Version:=S3_924;
        $90:Version:=S3_928C;
        $91:Version:=S3_928D;
   $94..$95:Version:=S3_928E;
        $A0:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801AB
                                          else Version:=S3_805AB;
   $A2..$A4:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801C
                                          else Version:=S3_805C;
        $A5:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801D
                                          else Version:=S3_805D;
        $B0:Version:=S3_928PCI;
      else Version:=S3_Unknown;
      end;
      if (SubVers<$90) then    (* 911 and 924 *)
      begin
        if (rdinx(crtc,$41) and $10)<>0 then mm:=1024
                                        else mm:=512;
      end
      else case rdinx(crtc,$36) and $E0 of
           0,$80:mm:=2048;
         $C0,$40:mm:=1024;
         $E0,$60:mm:=512;
           end;
      chip:=__S3;
      addvideo;
    end;
  end;
end;

procedure _trident;
var old,val,Xseg:word;
  Phadr:longint;
begin
  wrinx(SEQ,$B,0);
  SubVers:=inp(SEQ+1);
  old:=rdinx(SEQ,$E);
  outp(SEQ+1,0);
  val:=inp(SEQ+1);
  outp(SEQ+1,old);
  if (val and 15)=2 then
  begin
    outp($3c5,old xor 2);   (* Trident should restore bit 1 reversed *)
    case SubVers of
      1:Version:=TR_8800BR;   {This'll never happen}
      2:Version:=TR_8800CS;
      3:Version:=TR_8900B;
  4,$13:Version:=TR_8900C;
    $23:Version:=TR_9000;
    $33:Version:=TR_8900CL;
    $43:Version:=TR_9000i;
    $53:Version:=TR_8900CXr;
    $63:Version:=TR_LCD9100B;
    $83:Version:=TR_LX8200;
    $93:Version:=TR_9200CXi;
    $A3:Version:=TR_LCD9320;
$73,$F3:Version:=TR_GUI9420;
    else Version:=TR_Unknown;
    end;
    case SubVers and 15 of
      1:chip:=__tridbr;
      2:chip:=__tridCS;
    3,4:chip:=__trid89;
    end;
    if (pos('Zymos Poach 51',getbios(0,255))>0) or
       (pos('Zymos Poach 51',getbios(230,255))>0) then
    begin
      name:=name+' (Zymos Poach)';
      chip:=__poach;
    end;
    if (SubVers=2) and (tstrg($2168,$f)) then
    begin
      IOadr:=$2160;
      chip:=__IITAGX;
      Version:=IIT_AGX;
      if setmode($65) then;
      checkmem(32);
      XGAseg:=$B1F0;
      Phadr:=$FF800000;

    end
    else begin
      if (SubVers>=3) then
      begin
        case rdinx(crtc,$1f) and 3 of
          0:mm:=256;
          1:mm:=512;
          2:mm:=768;
          3:mm:=1024;
        end;
      end
      else
      if (rdinx(crtc,$1F) and 2)>0 then mm:=512;
    end;
    addvideo;
  end
  else begin  {Trident 8800BR tests}
    if (subvers=1) and testinx2(SEQ,$E,6) then
    begin
      Version:=TR_8800BR;
      chip:=__tridBR;
      if (rdinx(crtc,$1F) and 2)>0 then mm:=512;
      addvideo;
    end;
  end;
end;

procedure _tseng;
var x,vs:word;
begin
  outp($3bf,3);
  outp(crtc+4,$A0);    {Enable Tseng 4000 extensions}
  if tstrg($3CD,$3F) then
  begin
    features:=ft_rwbank;
    if testinx2(crtc,$33,$F) then
    begin
      if tstrg($3CB,$33) then
      begin
        features:=features+ft_cursor;
        chip:=__ET4w32;
        SubVers:=rdinx($217A,$EC);
        case SubVers shr 4 of
          0:Version:=ET_4W32;
          3:Version:=ET_4W32i;
          2:Version:=ET_4W32p;
        else Unk(ET_4Unk,SubVers);
        end;
        case rdinx(crtc,$37) and $9 of
           0:mm:=2048;
           1:mm:=4096;
         {  9:mm:=256;}
           8:mm:=512;
           9:mm:=1024;
        end;
        if (Version<>ET_4W32) and ((rdinx(crtc,$32) and $80)>0) then
          mm:=mm*2;
    end
      else begin
        chip:=__ET4000;
        Version:=ET_4000;
        case rdinx(crtc,$37) and $B of
         3,9:mm:=256;
          10:mm:=512;
          11:mm:=1024;
        end;
      end;
    end
    else begin
      Version:=ET_3000;
      chip:=__ET3000;
      if setmode($13) then;
      x:=inp(CRTC+6);
      x:=rdinx($3c0,$36);
      outp($3C0,x or $10);
      case (rdinx(GRC,6) shr 2) and 3 of
       0,1:vs:=$a000;
         2:vs:=$b000;
         3:vs:=$b800;
      end;

      meml[vs:1]:=$12345678;
      if memw[vs:2]=$3456 then mm:=512;

      wrinx($3c0,$36,x);     {reset value and reenable DAC}
    end;
    addvideo;
  end;
end;

procedure _UMC;
begin
  old:=inp($3BF);
  outp($3BF,3);
  if not testinx(SEQ,6) then
  begin
    outp($3BF,$AC);
    if testinx(SEQ,6) then
    begin
      version:=UMC_408;
      chip:=__UMC;
      case rdinx(SEQ,7) shr 6 of
        1:mm:=512;
      2,3:mm:=1024;
      end;
      features:=ft_rwbank;
      addvideo;
    end;
  end;
  outp($3BF,old);
end;


procedure _video7;
var ram:string[10];
begin
  vio($6f00);
  if rp.bx=$5637 then
  begin
    vio($6f07);
    if rp.ah<128 then ram:='VRAM' else ram:='FASTWRITE';

 (* old:=rdinx(crtc,$C);
  wrinx(crtc,$C,old);
  wrinx($3C4,6,$EA);    {Enable Extensions}
  if rdinx(crtc,$1F)=(old XOR $EA) then
  begin
    wrinx(crtc,$C,old XOR $FF);
    if rdinx(crtc,$1F)=(old XOR $15) then
    begin
      SubVers:=(rdinx($3C4,$8F) shl 8)+rdinx($3C4,$8E);
    end;
  end;

  wrinx(crtc,$C,old);  *)


    Subvers:=(rdinx(SEQ,$8F) shl 8)+rdinx(SEQ,$8E);
    case Subvers of
  $8000..$FFFF:Version:=V7_VEGA;
  $7000..$70FF:Version:=V7_208_13;
  $7140..$714F:Version:=V7_208A;
         $7151:Version:=V7_208B;
         $7152:Version:=V7_208CD;
         $7760:Version:=V7_216BC;
         $7763:Version:=V7_216D;
         $7764:Version:=V7_216E;
         $7765:Version:=V7_216F;
    else Version:=V7_Unknown;
    end;
    case rp.ah and 127 of
      2:mm:=512;
      4:mm:=1024;
    end;
    chip:=__video7;
    features:=ft_cursor;
    if Version>=V7_208A then Features:=features+ft_rwbank;
    addvideo;
  end
end;

procedure _Weitek;
var x:word;
begin
  old:=rdinx(SEQ,$11);
  outp(SEQ+1,old);
  outp(SEQ+1,old);
  outp(SEQ+1,inp(SEQ+1) or $20);
  if not testinx(SEQ,$12) then
  begin
    x:=rdinx(SEQ,$11);
    outp(SEQ+1,old);
    outp(SEQ+1,old);
    outp(SEQ+1,inp(SEQ+1) and $DF);
    if testinx(SEQ,$12) and tstrg($3CD,$FF) then
    begin
      chip:=__Weitek;
      Version:=WT_5186;  {Should check for version and memory}
      mm:=256;
      addvideo;
    end;
  end;
  wrinx(SEQ,$11,old);
end;

procedure _XGA;
var p:pointer;
 posbase,cardid,xga_base,x,cx:word;
 temp0,temp1,temp2,temp3:byte;
begin
  getintvec($15,p);
  if (seg(p^)<>0) then
  begin
    rp.ax:=$C400;
    rp.dx:=$ffff;
    intr($15,rp);
    if not odd(rp.flags) and (rp.dx<>$ffff) then
    begin
      posbase:=rp.dx;
      for cx:=0 to 9 do
      begin
        disable;   (* CLI -  Disable interrupts *)
        if cx=0 then outp($94,$DF)
        else begin
          rp.ax:=$C401;
          rp.bx:=cx;
          intr($15,rp);
        end;
        cardid:=inpw(posbase);
        temp0:=inp(posbase+2);
        temp1:=inp(posbase+3);
        temp2:=inp(posbase+4);
        temp3:=inp(posbase+5);
        if cx=0 then outp($94,$FF)
        else begin
          rp.ax:=$C402;
          rp.bx:=cx;
          intr($15,rp);
        end;
        enable;   (* STI -  Enable interrupts *)
        if (cardid>=$8FD8) and (cardid<=$8FDB) then
        begin
          IOadr:=$2100+(temp0 and $E)*8;
          x:=rdinx(IOadr+10,$52) and 15;
          if (x<>0) and (x<>15) then
          begin
            chip:=__XGA;
            outp(IOadr+4,0);
            outp(IOadr,4);
            checkmem(16);
            case cardid of
             $8FDA:Version:=XGA_NI;
             $8FDB:Version:=XGA_org;
            end;

            XGAseg:=(temp0 shr 4)*$2000+$C1C0+(temp0 and $E)*4;
            Phadr:=((temp2 and $FE)*word(8)+(temp0 and $E))*longint($200000);
            addvideo;
          end;
        end;
      end;
    end;
  end;
end;

procedure _yamaha;
begin
  if testinx2(crtc,$7C,$7C) then
  begin
    Version:=YA_6388;
    addvideo;
  end;
end;

procedure _xbe;
var
  x:word;
  xbe0:_xbe0;
  xbe1:_xbe1;

begin
  viop($4E00,0,0,0,@xbe0);
  if (rp.ax=$4E) and (xbe0.sign=$41534556) then
  begin
    for x:=0 to xbe0.xgas-1 do
    begin
      viop($4E01,0,0,x,@xbe1);
      if (rp.ax=$4E) then
      begin
        chip:=__xbe;
        mm:=xbe1.memory*longint(64);
        Instance:=x;
        IOadr :=xbe1.iobase;
        XGAseg:=xbe1.memreg;
        Phadr :=xbe1.vidadr;
        name:=gtstr(xbe1.oemadr);
        UNK(VS_XBE,xbe0.vers);
        addvideo;
      end;
    end;
  end;
end;

procedure _vesa;
var
  vesarec:_vbe0;
  x:word;
begin
  viop($4f00,0,0,0,@vesarec);
  if (rp.ax=$4f) and (vesarec.sign=$41534556) then
  begin
    chip:=__vesa;
    mm:=vesarec.mem*longint(64);
    name:=gtstr(vesarec.oemadr);
    UNK(VS_VBE,vesarec.vers);
    dactype:=_dac8;    {Dummy, to keep Cirrus 542x out of trouble}
    addvideo;
  end;
end;


type
  pel=record
        index,red,green,blue:byte;
      end;

procedure readpelreg(index:word;var p:pel);
begin
  p.index:=index;
  disable;
  outp($3C7,index);
  p.red  :=inp($3C9);
  p.blue :=inp($3C9);
  p.green:=inp($3C9);
  enable;
end;

procedure writepelreg(var p:pel);
begin
  disable;
  outp($3C8,p.index);
  outp($3C9,p.red);
  outp($3C9,p.blue);
  outp($3C9,p.green);
  enable;
end;

function setcomm(cmd:word):word;
begin
  dac2comm;
  outp($3c6,cmd);
  dac2comm;
  setcomm:=inp($3c6);
end;


procedure testdac;      {Test for type of DAC}
var
  x,y,z,v,oldcomm,oldpel,notcomm:word;
  dac8,dac8now:boolean;


procedure waitforretrace;
begin
  repeat until (inp(CRTC+6) and 8)=0;
  repeat until (inp(CRTC+6) and 8)>0;    {Wait until we're in retrace}
end;

function dacis8bit:boolean;
var
  pel2,x,v:word;
  pel1:pel;
begin
  pel2:=inp($3C8);
  readpelreg(255,pel1);
  v:=pel1.red;
  pel1.red:=255;
  writepelreg(pel1);
  readpelreg(255,pel1);
  x:=pel1.red;
  pel1.red:=v;
  writepelreg(pel1);
  outp($3C8,pel2);
  dacis8bit:=(x=255);
end;

function testdacbit(bit:word):boolean;
var v:word;
begin
  dac2pel;
  outp($3C6,oldpel and (bit xor $FF));
  dac2comm;
  disable;
  outp($3C6,oldcomm or bit);
  v:=inp($3C6);
  outp($3C6,v and (bit xor $FF));
  enable;
  testdacbit:=(v and bit)<>0;
end;

begin
  setDAC(_dac8,'Normal');
  dac2comm;
  oldcomm:=inp($3c6);
  dac2pel;
  oldpel:=inp($3c6);

  dac2comm;
  outp($3C6,0);
  dac8:=dacis8bit;
  dac2pel;

  notcomm:=oldcomm xor 255;
  outp($3C6,notcomm);
  dac2comm;
  v:=inp($3C6);
  if v<>notcomm then
  begin
    if (setcomm($E0) and $E0)<>$E0 then
    begin
      dac2pel;
      x:=inp($3C6);
      repeat
        y:=x;         {wait for the same value twice}
        x:=inp($3C6);
      until (x=y);
      z:=x;
      dac2comm;
      if daccomm<>$8E then
      begin                 {If command register=$8e, we've got an SS24}
        y:=8;
        repeat
          x:=inp($3C6);
          dec(y);
        until (x=$8E) or (y=0);
      end
      else x:=daccomm;
      if x=$8e then setDAC(_dacss24,'SS24')
               else setDAC(_dac15,'Sierra SC11486');
      dac2pel;
    end
    else begin
      if (setcomm($60) and $E0)=0 then
      begin
        if (setcomm(2) and 2)>0 then setDAC(_dacatt,'ATT 20c490')
                                else setDAC(_dacatt,'ATT 20c493');
      end
      else begin
        x:=setcomm(oldcomm);
        if inp($3C6)=notcomm then
        begin
          if setcomm($FF)<>$FF then setDAC(_dacadac1,'Acumos ADAC1')
          else begin
            dac8now:=dacis8bit;
            dac2comm;
            outp($3C6,(oldcomm or 2) and $FE);
            dac8now:=dacis8bit;
            if dac8now then
              if dacis8bit then setDAC(_dacatt,'ATT 20c491')
                           else setDAC(_dacCL24,'Cirrus 24bit DAC')
            else setDAC(_dacatt,'ATT 20c492');
          end;
        end
        else begin
          if trigdac=notcomm then setDAC(_dacCL24,'Cirrus 24bit DAC')
          else begin
            dac2pel;
            outp($3C6,$FF);
            case trigdac of
              $44:setDAC(_dacmus,'MUSIC ??');  {4870 ??}
              $82:setDAC(_dacmus,'MUSIC MU9C4910');
              $8E:setDAC(_dacss24,'Diamond SS2410');
            else
              if testdacbit($10) then setDAC(_dacsc24,'Sierra 16m')
              else if testdacbit(4) then setDAC(_dacUnk9,'Unknown DAC #9')
                                else setDAC(_dac16,'Sierra 32k/64k');
            end;
          end;
        end;
      end;
    end;

    dac2comm;
    outp($3c6,oldcomm);
  end;
  dac2pel;
  outp($3c6,oldpel);

  if (dactype=_dac8) and (DAC_RS2<>0) and (DAC_RS3<>0) then
  begin
    oldpel :=inp($3C6);
    oldcomm:=inp($3C6+DAC_RS2);
    outp($3C6+DAC_RS2,oldpel xor $FF);
    if (inp($3C6)=oldpel) and (inp($3C6+DAC_RS2)=(oldpel xor $FF)) then
      SetDAC(_dacBt484,'Brooktree Bt484');

    outp($3C6+DAC_RS2,oldcomm);
    outp($3C6,oldpel);
  end;



  if dactype=_dac8 then
  begin
    WaitforRetrace;
    outp($3C8,222);
    outp($3C9,$43);
    outp($3C9,$45);
    outp($3C9,$47);    {Write 'CEGEDSUN' + mode to DAC index 222}
    outp($3C8,222);
    outp($3C9,$45);
    outp($3C9,$44);
    outp($3C9,$53);
    outp($3C8,222);
    outp($3C9,$55);
    outp($3C9,$4E);
    outp($3C9,13);     {Should be in CEG mode now}
    outp($3C6,255);
    x:=(inp($3c6) shr 4) and 7;
    if x<7 then
    begin
      setDAC(_dacCEG,'Edsun CEG rev. '+chr(x+48));
      WaitforRetrace;
      outp($3C8,223);
      outp($3C9,0);    {Back in normal dac mode}
    end;
  end;
end;


procedure findbios;     {Finds the most likely BIOS segment}
var
  score:array[0..7] of byte;
  x,y:word;
begin
  biosseg:=$c000;
  for x:=0 to 6 do score[x]:=1;
  for x:=0 to 7 do
  begin
    rp.bh:=x;
    vio($1130);
    if (rp.es>=$c000) and ((rp.es and $7ff)=0) then
      inc(score[(rp.es-$c000) shr 11]);
  end;

  for x:=0 to 6 do
  begin
    y:=$c000+(x shl 11);
    if (memw[y:0]<>$aa55) or (mem[y:2]<48) then
      score[x]:=0;                       {fail if no rom}
  end;
  for x:=6 downto 0 do
    if score[x]>0 then
      biosseg:=$c000+(x shl 11);
end;

type
  fnctyp=procedure;

const
  chps=24;
  chptype:array[1..chps] of chips=(__paradise,__Video7,__MXIC,__UMC
            ,__Genoa,__Everex,__Trid89,__ati2,__Aheadb,__NCR,__S3,__AL2101
            ,__Cir54,__Cir64,__Weitek,__ET4000,__Realtek,__P2000
            ,__Yamaha,__Oak,__Cirrus,__Compaq,__HMC,__chips451);

var
  chp,vid1:word;

procedure findvideo;
begin
  vids:=0;
  dactype:=_dac0;
  features:=0;
  if odd(inp($3CC)) then CRTC:=$3D4 else CRTC:=$3B4;
  if dotest[__VESA] then _vesa;
  if dotest[__XBE] then _xbe;
  if dotest[__XGA] then _XGA;

  _crt:='';
  chip:=__none;
  secondary:='';
  name:='';
  DAC_RS2:=0;DAC_RS3:=0;
  video:='none';
  rp.bx:=$1010;
  vio($1200);
  if rp.bh<=1 then
  begin
    video:='EGA';
    chip:=__ega;

    mm:=rp.bl;
    vio($1a00);
    if rp.al=$1a then
    begin
      if (rp.bl<4) and (rp.bh>3) then
      begin
        old:=rp.bl;
        rp.bl:=rp.bh;
        rp.bh:=old;
      end;
      video:='MCGA';
      case rp.bl of
        2,4,6,10:_crt:='TTL Color';
        1,5,7,11:_crt:='Monochrome';
            8,12:_crt:='Analog Color';
      end;
      case rp.bh of
        1:secondary:='Monochrome';
        2:secondary:='CGA';
      end;
      findbios;
      if (getbios($31,9)='') and (getbios($40,2)='22') then
      begin
        video:='EGA';       {@#%@  lying ATI EGA Wonder !}
        name:='ATI EGA Wonder';
        addvideo;
      end else
      if (rp.bl<10) or (rp.bl>12) then
      begin

        chp:=0;vid1:=vids;
        while (vids=vid1) and (chp<chps) do
        begin
          inc(chp);

          video:='VGA';
          chip:=__vga;
          mm:=256;
          features:=0;
          dactype:=_dac0;
          version:=0;
          subvers:=0;

          if debug then
          begin
            writeln('Testing: '+header[chptype[chp]]);
            if readkey='' then;
          end;

          if dotest[chptype[chp]] then
            case chptype[chp] of
              __Aheadb:_Ahead;
              __AL2101:_AL2101;
                __ati2:_Ati;
            __chips451:_chipstech;
               __Cir54:_Cirrus54;
               __Cir64:_Cirrus64;
              __Cirrus:_Cirrus;
              __Compaq:_Compaq;
              __Everex:_Everex;
               __Genoa:_Genoa;
                 __HMC:_HMC;
                __MXIC:_MXIC;
                 __NCR:_NCR;
                 __Oak:_Oak;
               __P2000:_P2000;
            __paradise:_paradise;
             __Realtek:_Realtek;
                  __S3:_S3;
              __Trid89:_Trident;
              __ET4000:_Tseng;
                 __UMC:_UMC;
              __Video7:_Video7;
              __Weitek:_weitek;
              __Yamaha:_Yamaha;
            end;
        end;
        if vids=vid1 then addvideo;
      end;
    end;
  end;
end;
