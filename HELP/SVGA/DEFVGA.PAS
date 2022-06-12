
const
  ATTR= $3C0;
  SEQ = $3C4;
  GRC = $3CE;

type
  str10=string[10];

  mmods=(_text,
         _text2,
         _text4,
         _herc,   {Hercules mono, 4 "banks" of 8kbytes}
         _cga1,   {CGA 2 color, 2 "banks" of 16kbytes}
         _cga2,   {CGA 4 color, 2 "banks" of 16kbytes}
         _pl1 ,   {plain mono, 8 pixels per byte}
         _pl1e,   {mono odd/even, 8 pixels per byte, two planes}
         _pl2 ,   {4 color odd/even planes}
         _pk2 ,   {4 color "packed" pixels 4 pixels per byte}
         _pl4 ,   {std EGA/VGA 16 color: 4 planes, 8 pixels per byte}
         _pk4 ,   {ATI mode 65h two 16 color pixels per byte}
         _p8  ,   {one 256 color pixel per byte}
         _p15 ,   {Sierra 15 bit}
         _p16 ,   {Sierra 16bit/XGA}
         _p24 ,   {RGB 3bytes per pixel}
         _p32 );  {RGBa 3+1 bytes per pixel }

  modetype=record
             md,xres,yres,bytes:word;
             memmode:mmods;
           end;

  CHIPS=(__EGA,__VGA,__chips451,__chips452,__chips453,__paradise,__video7
        ,__ET3000,__ET4000,__tridBR,__tridCS,__trid89,__everex,__ati1,__ati2
        ,__genoa,__oak,__cirrus,__aheadA,__aheadB,__ncr,__yamaha,__poach
        ,__s3,__al2101,__mxic,__vesa,__realtek,__p2000,__cir54,__cir64
        ,__Weitek,__WeitekP9,__xga,__compaq,__iitagx,__ET4w32,__oak87,__atiGUP
        ,__UMC,__HMC,__xbe,__none);

  CursorType=Array[0..31] of longint;  {32 lines of 32 pixels}

const

  header:array[CHIPS] of string[14]=
         ('EGA','VGA','Chips&Tech','Chips&Tech','Chips&Tech'
         ,'Paradise','Video7','ET3000','ET4000','Trident','Trident'
         ,'Trident','Everex','ATI','ATI','Genoa','Oak','Cirrus','Ahead'
         ,'Ahead','NCR','Yamaha','Poach','S3','AL2101','MXIC','VESA'
         ,'Realtek','PRIMUS','Cirrus54','Cirrus64','Weitek','WeitekP9'
         ,'XGA','COMPAQ','IITAGX','ET4000W32','Oak','ATI','UMC','HMC'
         ,'XBE','');


const   {Short name for chip families}
  chipnam:array[chips] of string[8]=
        ('EGA','VGA','CT451','CT452','CT453','WD','Video7'
        ,'ET3000','ET4000','TR8800BR','TR8800CS','TR8900','Everex','ATI18800'
        ,'ATI28800','Genoa','OAK','Cirrus','Ahead A','Ahead B','NCR','Yamaha','Poach'
        ,'S3','ALG','MXIC','VESA','Realtek','Primus','CL54xx','CL64xx'
        ,'Weitek','P9000','XGA','Compaq','IIT','ET4/W32','OAK 87','Mach 32'
        ,'UMC','HMC','XBE','?');



const

  {DAC types}

  _dac0     =0;   {No DAC (MDA/CGA/EGA ..}
  _dac8     =1;   {Std VGA DAC 256 cols.}
  _dac15    =2;   {Sierra 32k DAC}
  _dac16    =3;   {Sierra 64k DAC}
  _dacss24  =4;   {Sierra?? 24bit RGB DAC}
  _dacatt   =5;   {ATT 20c490/1/2  15/16/24 bit DAC}
  _dacADAC1 =6;   {Acumos ADAC1  15/16/24 bit DAC}

  _dacalg   =7;   {Avance Logic  16 bit DAC}
  _dacSC24  =8;   {Sierra SC15025 24bit DAC}
  _dacCL24  =9;   {Cirrus Logic 24bit RAMDAC for CL542x series}
  _dacMus   =10;  {Music MU9c1740 24bit DAC}
  _dacUnk9  =11;
  _dacBt484 =12;


  _dacCEG   =13;  {Edsun CEG DAC}


  {Flags for special features}

  ft_cursor = 1;   {Has hardware cursor}
  ft_blit   = 2;   {Can do BitBLTs}
  ft_line   = 4;   {Can do lines}
  ft_rwbank = 8;   {Suports seperate R/W banks}



  (* Chip versions *)

  VS_VBE      =   90;
  VS_XBE      =   91;

  CL_Unk54    =  100;
  CL_AVGA1    =  101;
  CL_AVGA2    =  102;
  CL_GD5401   =  103;
  CL_GD5402   =  104;
  CL_GD5402r1 =  105;
  CL_GD5420   =  106;
  CL_GD5420r1 =  107;
  CL_GD5422   =  108;
  CL_GD5424   =  109;
  CL_GD5426   =  110;
  CL_GD5428   =  111;
  CL_GD543x   =  112;

  CL_GD6205   =  115;
  CL_GD6215   =  116;
  CL_GD6225   =  117;
  CL_GD6235   =  118;

  CL_Unk64    =  120;
  CL_GD5410   =  121;
  CL_GD6410   =  122;
  CL_GD6412   =  123;

  CL_GD6420   =  124;
  CL_GD6440   =  125;

  WD_PVGA1A   =  130;
  WD_90c00    =  131;
  WD_90c10    =  132;
  WD_90c11    =  133;
  WD_90c20    =  134;
  WD_90c20A   =  135;
  WD_90c22    =  136;
  WD_90c24    =  137;
  WD_90c26    =  138;
  WD_90c30    =  139;
  WD_90c31    =  140;
  WD_90c33    =  141;

  CT_Unknown  =  160;
  CT_450      =  161;
  CT_451      =  162;
  CT_452      =  163;
  CT_453      =  164;
  CT_455      =  165;
  CT_456      =  166;
  CT_457      =  167;
  CT_65520    =  168;
  CT_65530    =  169;
  CT_65510    =  170;

  CL_old_unk  =  180;
  CL_V7_OEM   =  181;
  CL_GD5x0    =  182;
  CL_GD6x0    =  183;

  NCR_Unknown =  190;
  NCR_77c21   =  191;
  NCR_77c22   =  192;
  NCR_77c22e  =  193;
  NCR_77c22ep =  194;

  OAK_Unknown =  200;
  OAK_037     =  201;
  OAK_057     =  202;
  OAK_067     =  203;
  OAK_077     =  204;
  OAK_083     =  205;
  OAK_087     =  206;

  RT_Unknown  =  210;
  RT_3103     =  211;
  RT_3105     =  212;
  RT_3106     =  213;

  S3_Unknown  =  220;
  S3_911      =  221;
  S3_924      =  222;
  S3_801AB    =  223;
  S3_805AB    =  224;
  S3_801C     =  225;
  S3_805C     =  226;
  S3_801D     =  227;
  S3_805D     =  228;
  S3_928C     =  229;
  S3_928D     =  230;
  S3_928E     =  231;
  S3_928PCI   =  232;

  TR_Unknown  =  240;
  TR_8800BR   =  241;
  TR_8800CS   =  242;
  TR_8900B    =  243;
  TR_8900C    =  244;
  TR_9000     =  245;
  TR_8900CL   =  246;
  TR_9000i    =  247;
  TR_8900CXr  =  248;
  TR_LCD9100B =  249;
  TR_GUI9420  =  250;
  TR_LX8200   =  251;
  TR_LCD9320  =  252;
  TR_9200CXi  =  253;

  AH_A        =  260;
  AH_B        =  261;

  AL_2101     =  270;

  CPQ_Unknown =  280;
  CPQ_IVGS    =  281;
  CPQ_AVGA    =  282;
  CPQ_AVPORT  =  283;
  CPQ_QV1024  =  284;
  CPQ_QV1280  =  285;

  MX_86000    =  290;
  MX_86010    =  291;

  GE_5100     =  301;
  GE_5300     =  302;
  GE_6100     =  303;
  GE_6200     =  304;
  GE_6400     =  305;

  PR_2000     =  310;

  IIT_AGX     =  320;

  ET_4Unk     =  330;
  ET_3000     =  331;
  ET_4000     =  332;
  ET_4W32     =  333;
  ET_4W32i    =  334;
  ET_4W32p    =  335;

  V7_Unknown  =  340;
  V7_VEGA     =  341;
  V7_208_13   =  342;
  V7_208A     =  343;
  V7_208B     =  344;
  V7_208CD    =  345;
  V7_216BC    =  346;
  V7_216D     =  347;
  V7_216E     =  348;
  V7_216F     =  349;

  WT_5086     =  361;
  WT_5186     =  362;
  WT_5286     =  363;

  YA_6388     =  370;

  XGA_org     =  380;
  XGA_NI      =  381;

  UMC_408     =  390;

  ATI_Unknown =  400;
  ATI_EGA     =  401;
  ATI_18800   =  402;
  ATI_18800_1 =  403;
  ATI_28800_2 =  404;
  ATI_28800_4 =  405;
  ATI_28800_5 =  406;
  ATI_GUP_3   =  407;
  ATI_GUP_6   =  408;
  ATI_GUP_AX  =  409;
  ATI_GUP_LX  =  410;

  HMC_304     =  420;


type
  charr =array[1..255] of char;
  chptr =^charr;
  intarr=array[1..100] of word;




  {VESA VBE (VGA) record definitions}
  _vbe0=record
          sign  :longint;       {Must be 'VESA'}
          vers  :word;          {VBE version.}
          oemadr:chptr;
          capab :longint;
          model :^intarr;       {Ptr to list of modes}
          mem   :byte;          {#64k blocks}
          xx:array[0..499] of byte;   {Buffer is too large, as some cards
                                         can return more than 256 bytes}
        end;


  _vbe1=record
          attr  :word;
          wina  :byte;
          winb  :byte;
          gran  :word;
          winsiz:word;
          sega  :word;
          segb  :word;
          pagefunc:pointer;
          bytes :word;
          width :word;
          height:word;
          charw :byte;
          charh :byte;
          planes:byte;
          bits  :byte;   {bits per pixel}
          nbanks:byte;
          model :byte;
          banks :byte;
          images:byte;
          res   :byte;
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;

          x:array[byte] of byte;    {might get trashed by 4F01h}
        end;
  _vbe1p=^_vbe1;


  {VESA VXE (XGA) record definitions}
  _xbe0=record
          sign:longint;    {must be 'VESA'}
          vers:word;
          oemadr:chptr;
          capab:longint;
          xgas:word;
          xx:array[1..240] of byte;
        end;

  _xbe1=record
          oemadr:chptr;
          capab:longint;
          romadr:longint;
          memreg:longint;
          iobase:word;
          vidadr:longint;  {32bit address of video memory}
          adr4MB:longint;
          adr1MB:longint;
          adr64k:longint;
          adroem:longint;
          sizoem:word;
          modep :^intarr;
          memory:word;
          manid :longint;
          xx:array[1..206] of byte;
        end;

  _xbe2=record
          attrib:word;
          bytes :word;
          pixels:word;
          lins  :word;
          charw :byte;
          charh :byte;
          planes:byte;
          bits  :byte;
          model :byte;
          images:byte;
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;
          xx:array[1..234] of byte;
        end;

  _AT0=record
         SWvers:word;  {SW version}
         vid_sys,         {Number of video systems}
         cur_vid:word;    {Currently selected video system (1..)}
         curtime:longint; {Date & time of the test}
       end;
       {This record followed by: (Email),(Name&Address),(Video desc)
                    ,(System),(modenames)}

  _AT2=record
         mode:word;
        Mmode:mmods;
       pixels,
         lins,
        bytes,
         crtc,
         vseg:word;
      Cpixels,
        Clins,
       Cbytes,
        Cvseg:word;
       CMmode:mmods;
      ChWidth,
     ChHeight,
      ExtPixf,
      ExtLinf:byte;
         Vclk,
         Hclk,
         Fclk:real;
        iLace:boolean;
         Flag:byte;
       end;
       {This record followed by: (Comment), (reg values)}

  _AT3=record
         mode:word;
        Mmode:mmods;
         Flag:byte;
       end;
       {This record followed by: (Comment)}

  _ATff=record
          int10,
          int6D,
          m4a8,   {0:4A8h}
          fnt8h,
          fnt8l,
          fnt14,
          fnt14x9,
          fnt16,
          fnt16x9:word;
          Base:word;
          size:byte;
        end;

const

  novgamodes=14;
  stdmodetbl:array[1..novgamodes] of modetype=
            ((md: 0;xres: 40;yres: 25;bytes: 80;memmode:_TEXT)
            ,(md: 1;xres: 40;yres: 25;bytes: 80;memmode:_TEXT)
            ,(md: 2;xres: 80;yres: 25;bytes:160;memmode:_TEXT)
            ,(md: 3;xres: 80;yres: 25;bytes:160;memmode:_TEXT)
            ,(md: 4;xres:320;yres:200;bytes: 80;memmode:_cga2)
            ,(md: 5;xres:320;yres:200;bytes: 80;memmode:_cga2)
            ,(md: 6;xres:640;yres:200;bytes: 80;memmode:_cga1)
            ,(md:13;xres:320;yres:200;bytes: 40;memmode:_pl4)
            ,(md:14;xres:640;yres:200;bytes: 80;memmode:_pl4)
            ,(md:15;xres:640;yres:350;bytes: 80;memmode:_pl1)
            ,(md:16;xres:640;yres:350;bytes: 80;memmode:_pl4)
            ,(md:17;xres:640;yres:480;bytes: 80;memmode:_pl1)
            ,(md:18;xres:640;yres:480;bytes: 80;memmode:_pl4)
            ,(md:19;xres:320;yres:200;bytes:320;memmode:_p8));

  colbits:array[mmods] of integer=
               (0,0,0,1,1,1,1,2,2,2,4,4,8,15,16,24,24);
  modecols:array[mmods] of longint=
               (0,0,0,2,2,2,2,4,4,4,16,16,256,32768,65536,16777216,16777216);

  mdtxt:array[mmods] of string[20]=('Text','2 color Text','4 color Text'
                ,'Hercules','CGA 2 color','CGA 4 color','Monochrome','2 colors planar'
                ,'4 colors planar','4 colors packed','16 colors planar','16 colors packed'
                ,'256 colors packed','32K colors','64K colors'
                ,'16M colors','16M colors');

  mmodenames:array[mmods] of string[4]=('TXT ','TXT2','TXT4','HERC','CGA1','CGA2'
              ,'PL1 ','PL1E','PL2 ','PK2 ','PL4 ','PK4 ','P8  ','P15 ','P16 ','P24 ','P32 ');

  Debug:boolean=false;      {If set step through video tests one by one}
  Auto_test:boolean=false;  {If set run tests automatically}


  {Keys:}
  Ch_Cr       =  $0D;
  Ch_Esc      =  $1B;
  Ch_ArUp     = $148;
  Ch_ArLeft   = $14B;
  Ch_ArRight  = $14D;
  Ch_ArDown   = $150;
  Ch_PgUp     = $149;
  Ch_PgDn     = $151;
  Ch_Ins      = $152;
  Ch_Del      = $153;


var

  vids:word;
  vid:array[1..10] of
      record
        chip:chips;
        id:word;             {instance}
        IOadr:word;          {I/O adr}
        Xseg:word;
        Phadr:longint;
        version:word;        {version}
        subver:word;         {Subversion}
        DAC_RS2,DAC_RS3:word;{These address bits are fed to the
                              RS2 and RS3 pins of the palette chip}
        dac:word;            {The dac type}
        dacname:string[20];  {The Name of the DACtype}
        mem:word;            {#kilobytes of video memory}
        features:word;       {Flags for special features}
        sname:string[8];     {Short chip family name}
        name:string[40];     {Full chip name}
      end;



var
  rp:registers;

  video:string[20];
  dacname:string[20];
  _crt:string[20];
  secondary:string[20];

  planes:word;     {number of video planes}

  nomodes:word;
  modetbl:array[1..50] of modetype;



  dotest:array[CHIPS] of boolean;


  CHIP:CHIPS;
  mm:word;           {Video memory in kilobytes}
  vseg:word;         {Video buffer base segment}
  version:word;      {Version of chip or interface}
  subvers:word;      {Subversion, for Unknown versions}
  IOadr:word;        {I/O select address (ATI, XGA..)}
  instance:word;     {ID for XGA and other multi board systems.}
  features:word;     {Flags for special features   (ft_*) }
  biosseg:word;
  DAC_RS2,
  DAC_RS3:word;      {These address bits are fed to the
                      RS2 and RS3 pins of the palette chip}
  dactype:word;
  name:string[40];

  curmode:word;      {Current mode number}
  memmode:mmods;     {current memory mode}
  crtc:word;         {I/O address of CRTC registers}
  pixels:word;       {Pixels in a scanline in current mode}
  lins:word;         {lines in current mode}
  bytes:longint;     {bytes in a scanline}

  force_mm:word;     {Forced memory size in Kbytes}

  extpixfact:word;  {The number of times each pixel is shown}
  extlinfact:word;  {The number of times each scan line is shown}
  charwid   :word;  {Character width in pixels}
  charhigh  :word;  {Character height in scanlines}
  calcpixels,
  calclines,
  calcvseg,
  calcbytes:word;
  calcmmode:mmods;


  vclk,hclk,fclk:real;
  ilace:boolean;




function getkey:word;             {Waits for a key, and returns the keyID}
function peekkey:word;            {Checks for a key, and returns the keyID}

procedure pushkey(k:word);        {Simulates a keystroke}

function strip(s:string):string;       {strip leading and trailing spaces}
function upstr(s:string):string;       {convert a string to upper case}
function istr(w:longint):str10;
function hex2(w:word):str10;
function hex4(w:word):str10;
function dehex(s:string):word;


procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}

procedure viop(ax,bx,cx,dx:word;p:pointer);
                                {INT 10h reg AX-DX, ES:DI = p}

function inp(reg:word):byte;     {Reads a byte from I/O port REG}

procedure outp(reg,val:word);    {Write the low byte of VAL to I/O port REG}

procedure outpw(reg,val:word);    {Write the word byte of VAL to I/O port REG}

function rdinx(pt,inx:word):word;       {read register PT index INX}

procedure wrinx(pt,inx,val:word);       {write VAL to register PT index INX}

procedure modinx(pt,inx,mask,nwv:word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}

procedure setinx(pt,inx,val:word);

procedure clrinx(pt,inx,val:word);

procedure setbank(bank:word);

procedure setRbank(bank:word);

procedure setvstart(x,y:word);       {Set the display start to (x,y)}

function setmode(md:word):boolean;

procedure setdac6;
procedure setdac8;
function setdac15:boolean;
function setdac16:boolean;
function setdac24:boolean;

procedure vesamodeinfo(md:word;vbe1:_vbe1p);

procedure setHWcurmap(VAR map:CursorType);

procedure HWcuronoff(on:boolean);

procedure setHWcurpos(X,Y:word);

procedure setHWcurcol(fgcol,bkcol:longint);

procedure fillrect(xst,yst,dx,dy:word;col:longint);

procedure copyrect(srcX,srcY,dstX,dstY,dx,dy:word);

procedure line(x0,y0,x1,y1:integer;col:longint);


procedure dac2comm;

procedure dac2pel;

procedure findvideo;

{procedure AnalyseMode(mode:word; var pixs,lins,bytes,vseg:word;var mmode:mmods);}

function FormatRgs(var b:byte):word;   {Format registers for dump}

function dumpVGAregs:word;

procedure dumpVGAregfile;

procedure SelectVideo(Item:word);

implementation

uses crt;

procedure testdac;forward;


const
  mmmask :array[0..8] of byte=(0,0,0,0,1,3,3,7,15);

  hx:array[0..15] of char='0123456789ABCDEF';


var

  spcreg:word;    {Special register offset (IIT)}
  xgaseg:word;    {Segment address of memory mapped registers}
  Phadr:longint;  {Physical address of video buffer}

  old,curbank:word;

  vgran:word;



procedure disable; (* Disable interupts *)
begin
  inline($fa);  (* CLI instruction *)
end;

procedure enable;  (* Enable interrupts *)
begin
  inline($fb);  (* STI instruction *)
end;


function gtstr(var c:chptr):string;
var x:word;
  s:string;
begin
  s:='';x:=1;
  if c<>NIL then
    while (x<255) and (c^[x]<>#0) do
    begin
      if c^[x]<>#7 then s:=s+c^[x];
      inc(x);
    end;
  gtstr:=s;
end;

const
  key_stack:word=0;    {Stored key stroke 0=none}

function getkey:word;
var c:char;
begin
  if key_stack<>0 then
  begin
    getkey:=key_stack;
    key_stack:=0;
  end
  else begin
    c:=readkey;
    if c=#0 then getkey:=$100+ord(readkey)
            else getkey:=ord(c);
  end;
end;

function peekkey:word;
begin
  if (key_stack=0) and not keypressed then peekkey:=0
                                      else peekkey:=getkey;
end;

procedure pushkey(k:word);  {Simulates a key stroke}
var ch:char;
begin
  key_stack:=k;
  while keypressed do ch:=readkey;
end;


function strip(s:string):string;       {strip leading and trailing spaces}
begin
  while s[length(s)]=' ' do dec(s[0]);
  while copy(s,1,1)=' ' do delete(s,1,1);
  strip:=s;
end;

function upstr(s:string):string;       {convert a string to upper case}
var x:word;
begin
  for x:=1 to length(s) do
    s[x]:=upcase(s[x]);
  upstr:=s;
end;

function istr(w:longint):str10;
var s:str10;
begin
  str(w,s);
  istr:=s;
end;

function hex2(w:word):str10;
begin
  hex2:=hx[(w shr 4) and 15]+hx[w and 15];
end;

function hex4(w:word):str10;
begin
  hex4:=hex2(hi(w))+hex2(lo(w));
end;

function dehex(s:string):word;
var w,x:word;
    c:char;
begin
  w:=0;
  for x:=1 to length(s) do
  begin
    c:=s[x];
    case c of
      '0'..'9':w:=(w shl 4)+(ord(c) and 15);
      'a'..'f','A'..'F':
               w:=(w shl 4)+(ord(c) and 15 +9);
    end;
  end;
  dehex:=w;
end;



procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
begin
  rp.ax:=ax;
  intr($10,rp);
end;

procedure viop(ax,bx,cx,dx:word;p:pointer);
begin                            {INT 10h reg AX-DX, ES:DI = p}
  rp.ax:=ax;
  rp.bx:=bx;
  rp.cx:=cx;
  rp.dx:=dx;
  rp.di:=ofs(p^);
  rp.es:=seg(p^);
  intr($10,rp);
end;

function inp(reg:word):byte;     {Reads a byte from I/O port REG}
begin
  reg:=port[reg];
  inp:=reg;
end;

procedure outp(reg,val:word);    {Write the low byte of VAL to I/O port REG}
begin
  port[reg]:=val;
end;

function inpw(reg:word):word;    {Reads a word from I/O port REG}
begin
  reg:=portw[reg];
  inpw:=reg;
end;

procedure outpw(reg,val:word);
begin
  portw[reg]:=val;
end;

function rdinx(pt,inx:word):word;       {read register PT index INX}
var x:word;
begin
  if pt=$3C0 then x:=inp(CRTC+6);    {If Attribute Register then reset Flip-Flop}
  outp(pt,inx);
  rdinx:=inp(pt+1);
end;

procedure wrinx(pt,inx,val:word);       {write VAL to register PT index INX}
var x:word;
begin
  if pt=$3C0 then
  begin
    x:=inp(CRTC+6);
    outp(pt,inx);
    outp(pt,val);
  end
  else begin
    outp(pt,inx);
    outp(pt+1,val);
  end;
end;

procedure wrinx2(pt,inx,val:word);
begin
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
end;

procedure wrinx3(pt,inx:word;val:longint);
begin
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx+2,val shr 16);
end;

procedure wrinx2m(pt,inx,val:word); {Write VAL to the index pair (INX,INX+1)}
begin                               {in motorola (big endian) format}
  wrinx(pt,inx,hi(val));
  wrinx(pt,inx+1,lo(val));
end;

procedure wrinx3m(pt,inx:word;val:longint);
begin
  wrinx(pt,inx+2,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx,val shr 16);
end;

procedure modinx(pt,inx,mask,nwv:word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}
var temp:word;
begin
  temp:=(rdinx(pt,inx) and (not mask))+(nwv and mask);
  wrinx(pt,inx,temp);
end;

procedure modreg(reg,mask,nwv:word);  {In register REG sets the bits in
                                       MASK as in NWV other are left unchanged}
var temp:word;
begin
  temp:=(inp(reg) and (not mask))+(nwv and mask);
  outp(reg,temp);
end;


procedure setinx(pt,inx,val:word);
var x:word;
begin
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x or val);
end;

procedure clrinx(pt,inx,val:word);
var x:word;
begin
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x and (not val));
end;


function getbios(offs,lnn:word):string;
var s:string;
begin
  s[0]:=chr(lnn);
  move(mem[biosseg:offs],s[1],lnn);
  getbios:=s;
end;



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
  rgs:regtype;
  oldreg:boolean;


procedure opentxtfile(var t:text;name:string);
begin
  if ioresult=0 then;  {Clear any old error code}
  assign(t,name);
  {$i-}
  reset(t);
  {$i+}
  if ioresult<>0 then
  begin         {Fatal file error!!!}
    textmode(3);
    writeln('Fatal file error (',name,') !!');
    halt(1);
  end;
end;





procedure loadmodes;              {Load extended modes for this chip}
var
  t:text;
  s,pat:string;
  md,x,xres,yres,err,mreq,byt:word;
  vbe0:_vbe0;
  vbe1:_vbe1;
  xbe1:_xbe1;
  xbe2:_xbe2;
  ok:boolean;

function unhex(s:string):word;
var x:word;
begin
  for x:=1 to 4 do
    if s[x]>'9' then
      s[x]:=chr(ord(s[x]) and $5f-7);
  unhex:=(((word(ord(s[1])-48) shl 4
         +  word(ord(s[2])-48)) shl 4
         +  word(ord(s[3])-48)) shl 4
         +  word(ord(s[4])-48));
end;

function mmode(s:string;var md:mmods):boolean;
var x:mmods;
   ok:boolean;
begin
  ok:=false;
  for x:=_text to _p32 do
    if s=mmodenames[x] then
    begin
      md:=x;
      ok:=true;
    end;
  mmode:=ok;
end;

function VESAmemmode(model,bits,redinf,grninf,bluinf,resinf:word):mmods;
const
  mode6s=4;
  mode:array[1..mode6s] of mmods=(_p15,_p16,_p24,_p32);
  blui:array[1..mode6s] of word =(   5,   5,    8,    8);
  grni:array[1..mode6s] of word =($505,$506, $808, $808);
  redi:array[1..mode6s] of word =($A05,$B05,$1008,$1008);
  resi:array[1..mode6s] of word =($f01,   0,    0,$1808);
var x:word;
begin
  VESAmemmode:=_text;  {catch weird modes}
  if (bits=15) and (resinf=0) then resinf:=$F01;   {Bloody ATI Vesa driver @#$}
  case model of
    0:VESAmemmode:=_text;
    1:case bits of
        1:VESAmemmode:=_cga1;
        2:VESAmemmode:=_cga2;
      end;
    2:memmode:=_herc;
    3:case bits of
        2:VESAmemmode:=_pl2;
        4:VESAmemmode:=_pl4;
      end;
    4:case bits of
        4:VESAmemmode:=_pk4;
        8:VESAmemmode:=_p8;
       15:VESAmemmode:=_p15;
       16:VESAmemmode:=_p16;
       24:VESAmemmode:=_p24;
      end;
    5:;
    6:for x:=1 to mode6s do
      if (redinf=redi[x]) and (grninf=grni[x]) and (bluinf=blui[x])
        and (resinf=resi[x]) then VESAmemmode:=mode[x];
    7:;
  end;
end;


procedure addmode(md,xres,yres,bytes:word;memmode:mmods);
begin
  inc(nomodes);
  modetbl[nomodes].md     :=md;
  modetbl[nomodes].xres   :=xres;
  modetbl[nomodes].yres   :=yres;
  modetbl[nomodes].bytes  :=bytes;
  modetbl[nomodes].memmode:=memmode;
end;

begin
  nomodes:=0;
  case chip of
   __vesa:begin
            vbe0.sign:=$41534556;    (* VESA *)
            viop($4f00,0,0,0,@vbe0);

               {S3 VESA driver can return wrong segment if run with QEMM}
            IF seg(vbe0.model^)=$e000 then
              vbe0.model:=ptr($c000,ofs(vbe0.model^));
            x:=1;
            while vbe0.model^[x]<>$FFFF do
            begin
              vesamodeinfo(vbe0.model^[x],@vbe1);
              if (vbe1.attr and 1)<>0 then
              begin
                memmode:=VESAmemmode(vbe1.model,vbe1.bits,vbe1.redinf
                   ,vbe1.grninf,vbe1.bluinf,vbe1.resinf);
                addmode(vbe0.model^[x],vbe1.width,vbe1.height,vbe1.bytes,memmode);
              end;
              inc(x);
            end;
          end;
    __xbe:begin
            viop($4E01,0,0,instance,@xbe1);
            x:=1;
            while xbe1.modep^[x]<>$FFFF do
            begin
              viop($4E02,0,xbe1.modep^[x],instance,@xbe2);
              if (rp.ax=$4E) and ((xbe2.attrib and 1)>0) then
              begin
                memmode:=VESAmemmode(xbe2.model,xbe2.bits,xbe2.redinf
                   ,xbe2.grninf,xbe2.bluinf,xbe2.resinf);
                addmode(xbe1.modep^[x],xbe2.pixels,xbe2.lins,xbe2.bytes,memmode);
              end;
              inc(x);
            end;

          end;
  else
    pat:='['+header[chip]+']';
    opentxtfile(t,'whatvga.lst');
    s:=' ';
    while (not eof(t)) and (s<>pat) do readln(t,s);
    s:=' ';
    readln(t,s);
    while (s[1]<>'[') and (s<>'') do
    begin
      md:=unhex(copy(s,1,4));
      ok:=mmode(copy(s,6,4),memmode);
      val(copy(s,11,5),xres,err);
      val(copy(s,17,4),yres,err);
      case memmode of
 _text,_text2,_text4:bytes:=xres*2;
   _pl1e, _herc,_cga1,_pl1:
                     bytes:=xres shr 3;
     _pk2,_pl2,_cga2:bytes:=xres shr 4;
           _pl4,_pk4:bytes:=xres shr 1;
                 _p8:bytes:=xres;
           _p15,_p16:bytes:=xres*2;
                _p24:bytes:=xres*3;
                _p32:bytes:=xres*4;
      else
      end;
      case dactype of
        _dacCEG,
          _dac8:if memmode>_p8 then ok:=false;
         _dac15:if memmode>_p15 then ok:=false;
         _dac16:if memmode>_p16 then ok:=false;
      end;
      case version of
        S3_911,S3_924:if (md>$105) and (md<$200) then ok:=false;
    ATI_Unknown..ATI_GUP_LX:
          if md<$100 then
          begin
            rp.bx:=$5506;
            rp.bp:=$FFFF;
            rp.si:=0;
            vio($1200+md);
            if rp.bp=$FFFF then ok:=false;
          end;
      end;
      val(copy(s,22,5),byt,err);
      if (err=0) and (byt>0) then bytes:=byt;
      mreq:=(longint(bytes)*yres+1023) div 1024;
      case memmode of
        _pl4:bytes:=xres shr 3;
      end;
      if ok and (mm>=mreq) then
        addmode(md,xres,yres,bytes,memmode);
      readln(t,s);
    end;
    close(t);
  end;
end;

procedure SelectVideo(item:word);
begin
  chip    :=vid[item].chip;
  instance:=vid[item].id;
  IOadr   :=vid[item].IOadr;
  version :=vid[item].version;
  dactype :=vid[item].dac;
  dacname :=vid[item].dacname;
  mm      :=vid[item].mem;
  features:=vid[item].features;
  name    :=vid[item].name;
  XGAseg  :=vid[item].xseg;
  phadr   :=vid[item].phadr;
  subvers :=vid[item].subver;
  DAC_RS2 :=vid[item].DAC_RS2;
  DAC_RS3 :=vid[item].DAC_RS3;
  loadmodes;
  video:=header[chip];
end;


procedure addvideo;
var nam,s:string;
    t:text;
    nr,err:word;
begin
  nam:='';
  if version<>0 then
  begin
    opentxtfile(t,'chips.lst');
    while not eof(t) do
    begin
      readln(t,s);
      val(copy(s,1,4),nr,err);
      if nr=version then
      begin
        nam:=copy(s,7,255);
        if nam[length(nam)]='(' then nam:=nam+hex4(subvers)+')';
      end;
    end;
    close(t);
  end;
  nam:=nam+' '+name;
  if dactype=0 then testdac;
  if force_mm<>0 then mm:=force_mm;
  inc(vids);
  vid[vids].chip    :=chip;
  vid[vids].id      :=instance;   {instance (XBE)}
  vid[vids].ioadr   :=IOadr;      {base I/O adr}
  vid[vids].version :=version;
  vid[vids].dac     :=dactype;
  vid[vids].dacname :=dacname;
  vid[vids].mem     :=mm;
  vid[vids].features:=features;
  vid[vids].name    :=nam;
  vid[vids].xseg    :=XGAseg;
  vid[vids].phadr   :=phadr;
  vid[vids].subver  :=subvers;
  vid[vids].DAC_RS2 :=DAC_RS2;
  vid[vids].DAC_RS3 :=DAC_RS3;
  vid[vids].sname   :=chipnam[chip];
end;

procedure UNK(vers,code:word);
begin
  version:=vers;
  subvers:=code;
end;

procedure SetVersion(vers:word;nam:string);
begin
  Version:=vers;
  name:=nam;
end;


procedure SetDAC(typ:word;Name:string);
begin
  dactype:=typ;
  dacname:=name;
end;


function tstrg(pt,msk:word):boolean;       {Returns true if the bits in MSK
                                            of register PT are read/writable}
var old,nw1,nw2:word;
begin
  old:=inp(pt);
  outp(pt,old and not msk);
  nw1:=inp(pt) and msk;
  outp(pt,old or msk);
  nw2:=inp(pt) and msk;
  outp(pt,old);
  tstrg:=(nw1=0) and (nw2=msk);
end;

function testinx2(pt,rg,msk:word):boolean;   {Returns true if the bits in MSK
                                              of register PT index RG are
                                              read/writable}
var old,nw1,nw2:word;
begin
  old:=rdinx(pt,rg);
  wrinx(pt,rg,old and not msk);
  nw1:=rdinx(pt,rg) and msk;
  wrinx(pt,rg,old or msk);
  nw2:=rdinx(pt,rg) and msk;
  wrinx(pt,rg,old);
  testinx2:=(nw1=0) and (nw2=msk);
end;

function testinx(pt,rg:word):boolean;     {Returns true if all bits of
                                           register PT index RG are
                                           read/writable.}
var old,nw1,nw2:word;
begin
  testinx:=testinx2(pt,rg,$ff);
end;

procedure dac2pel;    {Force DAC back to PEL mode}
begin
  if inp($3c8)=0 then;
end;

var
  daccomm:word;

function trigdac:word;  {Reads $3C6 4 times}
var x:word;
begin
  x:=inp($3c6);
  x:=inp($3c6);
  x:=inp($3c6);
  trigdac:=inp($3c6);
end;

procedure dac2comm;    {Enter command mode of HiColor DACs}
begin
  dac2pel;
  daccomm:=trigdac;
end;

function getdaccomm:word;
begin
  if DAC_RS2<>0 then getdaccomm:=inp($3C6+DAC_RS2)
  else begin
    dac2comm;
    getdaccomm:=inp($3C6);
    dac2pel;
  end;
end;



procedure checkmem(mx:word);
var
  fail:boolean;
  ma:array[0..99] of byte;
  x:word;
begin
  memmode:=_p8;

  fail:=true;
  while (mx>1) and fail do
  begin
    setbank(mx-1);
    move(mem[$a000:0],ma,100);
    for x:=0 to 99 do
      mem[$a000:x]:=ma[x] xor $aa;
    setbank(mx-1);
    fail:=false;
    for x:=0 to 99 do
      if mem[$a000:x]<>ma[x] xor $aa then fail:=true;
    move(ma,mem[$a000:0],100);
    if not fail then
    begin
      setbank((mx shr 1)-1);
      for x:=0 to 99 do
        mem[$a000:x]:=ma[x] xor $55;
      setbank(mx-1);
      fail:=true;
      for x:=0 to 99 do
        if mem[$a000:x]<>ma[x] xor $55 then fail:=false;
      move(ma,mem[$a000:0],100);
    end;
    mx:=mx shr 1;
  end;
  mm:=mx*128;
end;
