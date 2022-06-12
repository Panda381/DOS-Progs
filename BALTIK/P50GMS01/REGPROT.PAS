unit RegProt;
{ Copyright (c)1998 Tom æupka }

{.$define RegProtGenerator}
{$O+,F+}
{$X+}

interface

uses CRC32;

const
  LicenceNumLength = 12;

type

  TRegUserDataStr = String[40];

  TRegUserData = record
    Name:    TRegUserDataStr;
    Firm:    TRegUserDataStr;
    Address: TRegUserDataStr;
    City:    TRegUserDataStr;
    Region:  TRegUserDataStr;
    ZIP:     TRegUserDataStr;
    Country: TRegUserDataStr;
    end;

  TDate = record
    Year: Word;
    Month: Byte;
    Day: Byte;
    end;

  TRegData = record
    UserId: TCRC32Value;
    LicenceNum: String[LicenceNumLength];
    Product: Word;
    Version: Word; { e.g. 500 }
    NetLicCount: Byte; { 0 means no net, $FF - unlimited }
    {Duration in days - 0 means forever }
    Duration: Byte;
    {Validity Date - the zero year mean valid forever }
    ValidityDate: TDate;
    end;

  TComputerId = record
    DirId: LongInt;
    Date: TDate; { the date of the registration installation }
    { !!! not applicable in WINDOWS enviroment }
    BIOSId: TCRC32Value;
    HDSerial: LongInt;
    HDNet: Boolean;
    end;

{$ifndef RegProtGenerator}
function WriteRegistration( const filename: String;
                            var   user: TRegUserData;
                            const regnum: String;
                            var reg: TRegData ): Integer;
{ input: filename, user, regnum
  output: reg, written R/O filename
  returns:
     0 - OK
  >  0 - registration number error - returns an invalid char position
    -1 - invalid registration number checksum
    -2 - invalid user data checksum
  < -1000 - i/o error (i/o error code (=IOResult) is -Result-1000)
}

function ReadRegistration( const filename: String;
                           var   user: TRegUserData;
                           var   reg: TRegData;
                           minversion: Word ): Integer;
{ input: filename, minversion
  output: user, reg
  returns:
     0 - OK
    -2 - invalid user data checksum
    -3 - invalid file format
    -4 - invalid registration version (SGP of the version <minversion>
         cannot be used with this registration
    -5 - valid registration expiration due to limited duration
    -6 - valid registration expiration due to out-of-date condition
    -7 - invalid computer (not runnning on the registration computer)
  < -1000 - i/o error (i/o error code (=IOResult) is -Result-1000)
}
{$endif not RegProtGenerator}

{$ifdef RegProtGenerator}
function GenerateRegistrationNum( var user: TRegUserData;
                                  var reg:  TRegData ): String;
{ input: user, reg
  output: reg.UserId, registration number
  returns: registration number
}
function StrToReg( const s: String; var reg: TRegData ): Integer;
{  0 - OK }
{ >0 - registration number error - returns an invalid char position }
{ -1 - invalid checksum }
{$endif RegProtGenerator}

implementation

{$ifndef RegProtGenerator}
  {$ifdef WINDOWS}
  uses SysUtils;
  {$else}
  uses Dos;
  {$endif}
{$endif not RegProtGenerator}

  { Registration file}
    { Header }
      const RegHeader = 'SGP Registration'^Z;
    { Version }
      const RegVersion = 100; {1.00}
    { RegUserData }
    { RegData }
    { ComputerId }
    { CRC32 }

const RegDataPassword  = $AFE5CD7A;
const UserDataPassword = $3ABE4ADA;

const Year0 = 1990;

function DateToWord( const Date: TDate ): Word;
begin
  if Date.Year=0 then
    DateToWord:= 0
  else
    DateToWord:= (Date.Year-Year0)*(12*31)+(Date.Month-1)*31+(Date.Day-1);
end;

procedure WordToDate( w: Word; var Date: TDate );
begin
  if w=0 then begin
    with Date do begin
      Year:= 0; Month:= 0; Day:= 0;
      end;
    end
  else begin
    with Date do begin
      Year:= (w div (12*31))+Year0;
      w:= w mod (12*31);
      Month:= w div 31 + 1;
      Day:= w mod 31 + 1;
      end;
    end;
end;

type
  TLongRec = record
    case Integer of
      0: (l:LongInt);
      1: (wl,wh: Word );
      2: (wlbl, wlbh, whbl, whbh: Byte );
    end;

{$ifdef RegProtGenerator}
function RegToStr( const Reg: TRegData ): String;
var
  l1, l2, l3: TLongRec;
  crc32: TCRC32;
  res: String;

  function DecToStr( d: Word; n: Word; zeros: Boolean ): String;
  var res: String[5]; i: Byte;
  begin
    for i:= n downto 1 do begin
      res[i]:= chr((d mod 10)+ord('0'));
      d:= d div 10;
      end;
    res[0]:= chr(n);
    if not zeros then begin
      i:= 1;
      while (i<=n) and (res[i]='0') do Inc(i);
      DecToStr:= Copy(res,i,n-i+1);
      end
    else
      DecToStr:= res;
  end;

  function LongToStr( d: LongInt; nd: Integer ): String;
  var res: String[8]; i, n: Byte;
  const base = ord('z')-ord('a')+1+ord('9')-ord('0')+1;
  begin
    for i:= nd downto 1 do begin
      n:= d mod base;
      if n>=10 then
        res[i]:= chr((n-10)+ord('a'))
      else
        res[i]:= chr(n+ord('0'));
      d:= d div base;
      end;
    res[0]:= chr(nd);
    LongToStr:= res;
  end;

begin
  crc32.Init(RegDataPassword);
  crc32.PutBlock(Reg,SizeOf(Reg));
  l3.l:= crc32.Get;
  res:= DecToStr(Reg.Product,4,true)+'-';
  Insert(DecToStr(Reg.Version,3,true)+'-',res,Length(res)+1);
  Insert(Reg.LicenceNum+'-',res,Length(res)+1);
  l2.wh:= {crc}l3.wh xor l3.wl;
  l1.l:= Reg.UserId;
  l3.wl:= l1.wh; l3.wh:= 0;
  l1.whbl:= Reg.NetLicCount;
  l1.whbh:= Reg.Duration;
  l2.wl:= DateToWord(Reg.ValidityDate);
  crc32.Init(RegDataPassword);
  crc32.ScrambleBlock(l1,SizeOf(l1));
  crc32.ScrambleBlock(l2,SizeOf(l2));
  if (l1.l and $80000000) <> 0 then begin
    l3.whbl:= l3.whbl or $01;
    l1.l:= l1.l and $7fffffff;
    end;
  if (l2.l and $80000000) <> 0 then begin
    l3.whbl:= l3.whbl or $02;
    l2.l:= l2.l and $7fffffff;
    end;
  Insert(LongToStr(l1.l,6)+'-',res,Length(res)+1);
  Insert(LongToStr(l2.l,6)+'-',res,Length(res)+1);
  Insert(LongToStr(l3.l,4),res,Length(res)+1);
  RegToStr:= res;
end;
{$endif RegProtGenerator}


function StrToReg( const s: String; var reg: TRegData ): Integer;
{  0 - OK }
{ >0 - registration number error - returns an invalid char position }
{ -1 - invalid checksum }
label SyntaxErr, SyntaxExit;
var i, j, l: Byte; l1, l2, l3: TLongRec; crc32: TCRC32;

  function GetWord( var w: Word ): Boolean;
  begin
    w:= 0;
    j:= i;
    while (i<=l) and (s[i] in ['0'..'9']) do begin
      w:= w*10+(ord(s[i])-ord('0'));
      Inc(i);
      end;
    GetWord:= i>j;
  end;

  function GetLong( var w: LongInt ): Boolean;
  var d: Byte; c: Char;
  const base = ord('Z')-ord('A')+1+ord('9')-ord('0')+1;
  begin
    w:= 0;
    j:= i;
    while (i<=l) and (s[i] in ['0'..'9','A'..'Z','a'..'z']) do begin
      c:= Upcase(s[i]);
      if c<='9' then
        d:= ord(c)-ord('0')
      else
        d:= ord(c)-ord('A')+(ord('9')-ord('0')+1);
      w:= w*base+d;
      Inc(i);
      end;
    GetLong:= i>j;
  end;

begin
  FillChar(reg,SizeOf(Reg),0);
  l:= Length(s);
  i:= 1;
  { product id }
  if not GetWord(Reg.Product) then goto SyntaxErr;
  { - }
  if (i>l) or (s[i]<>'-') then goto SyntaxErr;
  Inc(i);
  { product version }
  if not GetWord(Reg.Version) then goto SyntaxErr;
  { - }
  if (i>l) or (s[i]<>'-') then goto SyntaxErr;
  Inc(i);
  { licence }
  j:= i;
  while (i<=l) and (s[i]<>'-') do Inc(i);
  Reg.LicenceNum:= Copy(s,j,i-j);
  { - }
  if (i>l) or (s[i]<>'-') then goto SyntaxErr;
  Inc(i);
  { 1st long }
  if not GetLong(l1.l) then goto SyntaxErr;
  { - }
  if (i>l) or (s[i]<>'-') then goto SyntaxErr;
  Inc(i);
  { 2nd long }
  if not GetLong(l2.l) then goto SyntaxErr;
  { - }
  if (i>l) or (s[i]<>'-') then goto SyntaxErr;
  Inc(i);
  { last }
  if not GetLong(l3.l) then goto SyntaxErr;
  if i<=l then goto SyntaxErr;

  { checking }
  if (l3.wh and $FFFC)<>0 then begin
    StrToReg:= -1;
    Exit;
    end;
  if (l3.whbl and $01) <> 0 then
    l1.l:= l1.l or $80000000;
  if (l3.whbl and $02) <> 0 then
    l2.l:= l2.l or $80000000;
  crc32.Init(RegDataPassword);
  crc32.DescrambleBlock(l1,SizeOf(l1));
  crc32.DescrambleBlock(l2,SizeOf(l2));
  Reg.NetLicCount:= l1.whbl;
  Reg.Duration:= l1.whbh;
  l1.wh:= l3.wl;
  Reg.UserId:= l1.l;
  WordToDate(l2.wl,Reg.ValidityDate);
  crc32.Init(RegDataPassword);
  crc32.PutBlock(Reg,SizeOf(Reg));
  l3.l:= crc32.Get;
  if l2.wh<>l3.wh xor l3.wl then begin
    StrToReg:= -1;
    Exit;
    end;
  StrToReg:= 0;
  goto SyntaxExit;
SyntaxErr: ;
  StrToReg:= i;
SyntaxExit:
end;

procedure WipeStr( var s: OpenString );
begin
  FillChar(s[Length(s)+1],High(s)-Length(s),0);
end;

procedure UnifyStr( var s: OpenString );
var
  i: Byte;
begin
  i:= 1;
  while (i<=Length(s)) do begin
    if s[i] in ['0'..'9','a'..'z','A'..'Z'] then begin
      s[i]:= Upcase(s[i]);
      Inc(i);
      end
    else begin
      Delete(s,i,1);
      end;
    end;
  WipeStr(s);
end;

function GetUserId( var user: TRegUserData ): TCRC32Value;
var temp: TRegUserDataStr;
    Crc: TCRC32;
begin
  WipeStr(user.Name);
  WipeStr(user.Firm);
  WipeStr(user.Address);
  WipeStr(user.City);
  WipeStr(user.Region);
  WipeStr(user.ZIP);
  WipeStr(user.Country);
  Crc.Init(UserDataPassword);
  temp:= user.Name; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.Firm; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.Address; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.City; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.Region; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.ZIP; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  temp:= user.Country; UnifyStr(temp);
  Crc.PutBlock(temp,Length(temp)+1);
  GetUserId:= Crc.Get;
end;


{$ifndef RegProtGenerator}
  {$ifdef WINDOWS}
  function GetDirId( const filename: String ): LongInt;
  var d: String;
      f: TSearchRec;
  begin
    d:= ExtractFilePath(filename);
    if (Length(d)>0) and (d[Length(d)]='\') then Delete(d,Length(d),1);
    if FindFirst(d,faAnyFile,f)=0 then GetDirId:= f.Time
    else GetDirId:= 0;
  end;
  {$else}
  function GetDirId( const filename: String ): LongInt;
  var d: DirStr; n: NameStr; x: ExtStr;
      f: SearchRec;
  begin
    FSplit(filename,d,n,x);
    if (Length(d)>0) and (d[Length(d)]='\') then Delete(d,Length(d),1);
    FindFirst(d,AnyFile,f);
    if DosError=0 then GetDirId:= f.Time
    else GetDirId:= 0;
  end;
  {$endif}

  {$ifdef WINDOWS}
  function GetHDSerial( const filename: String; var net: Boolean ): LongInt;
  begin
    net:= false;
    GetHDSerial:= 0;
  end;
  {$else}
  function GetHDSerial( const filename: String; var net: Boolean ): LongInt;
  var drive: Byte; dattr: Word;
  type
    TMIDRec = record
      InfoLevel: Word;
      SerialNum: LongInt;
      VolLabel: array[0..10] of char;
      FileSysType: array[0..7] of char;
      end;
  var MID: TMIDRec;
  label noerr;
  begin
    net:= false;
    if (Length(filename)>=2) then begin
      if Copy(filename,1,2)='\\' then begin
        { network name }
        net:= true;
        GetHDSerial:= 0;
        Exit;
        end;
      if filename[2]=':' then drive:= ord(Upcase(filename[1]))-ord('A')+1
      else drive:= 0;
      end
    else begin
      drive:= 0;
      end;
    { is drive remote? }
    asm
      mov ax, $4409
      mov bl, [drive]
      int $21
      jnc @@noerr
      xor dx, dx
    @@noerr:
      mov [dattr], dx
    end;
    net:= (dattr and (1 shl 12))<>0;
    if Lo(DOSVersion)>=4 then begin
      FillChar(MID,SizeOf(MID),0);
      asm
        mov bl, [drive]
        xor bh, bh
        mov cx, $0866
        lea dx, [MID]
        push ds
        mov ax, ss
        mov ds, ax
        mov ax, $440d
        int $21
        pop ds
        jnc noerr
      end;
      GetHDSerial:= 0;
      Exit;
     noerr:
      GetHDSerial:= MID.SerialNum;
      end
    else
      GetHDSerial:= 0;
  end;
  {$endif}

procedure GetComputerId( var cid: TComputerId; const filename: String );
var
  year, month, day, dayow: Word;
  crc: TCRC32;
begin
  FillChar(cid,SizeOf(cid),0);
  cid.DirId:= GetDirId(filename);
  {$ifdef WINDOWS}
  DecodeDate(Date,year,month,day);
  {$else}
  GetDate(year,month,day,dayow);
  {$endif}
  cid.Date.Year:= year;
  cid.Date.Month:= month;
  cid.Date.Day:= day;
  {$ifdef WINDOWS}
  cid.BIOSId:= 0;
  {$else}
  crc.Init0;
  crc.PutBlock(Ptr($fe00,$0000)^,256);
  crc.PutBlock(Ptr($fff0,$0000)^,256);
  cid.BIOSId:= crc.Get;
  {$endif}
  cid.HDSerial:= GetHDSerial(filename,cid.HDNet);
end;

function WriteRegistration( const filename: String;
                            var   user: TRegUserData;
                            const regnum: String;
                            var   reg: TRegData ): Integer;
label IOError;
var
  res: Integer;
  f: file;
  Crc, Scm: TCRC32;
  l: TLongRec;
  cid: TComputerId;
const
  Header: String[Length(RegHeader)]= RegHeader;
  Ver: Word = RegVersion;

begin
  res:= StrToReg(regnum,reg);
  if res<>0 then begin
    WriteRegistration:= res;
    Exit;
    end;
  if GetUserId(user) <> reg.UserId then begin
    WriteRegistration:= -2;
    Exit;
    end;
  GetComputerId(cid,filename);
  {$I-}
  Assign(f,filename);
  { reset R/O file attribute }
  {$ifdef WINDOWS}
  FileSetAttr(filename,FileGetAttr(filename) and not (faReadOnly or faHidden));
  {$else}
  GetFAttr(f,l.wl);
  SetFAttr(f, not $03 and l.wl);
  {$endif}
  if IOResult<>0 then ;
  Erase(f);
  if IOResult<>0 then ;
  Rewrite(f,1);
  res:= IOresult;
  if res<>0 then goto IOError;
  BlockWrite(f,Header[1],Length(Header));
  BlockWrite(f,Ver,SizeOf(Ver));
  Crc.Init0;
  Crc.PutBlock(user,SizeOf(user));
  Crc.PutBlock(reg,SizeOf(reg));
  Crc.PutBlock(cid,SizeOf(cid));
  l.l:= Crc.Get;
  BlockWrite(f,user,SizeOf(user));
  Scm.Init(RegDataPassword);
  Scm.ScrambleBlock(reg,SizeOf(Reg));
  Scm.ScrambleBlock(cid,SizeOf(cid));
  BlockWrite(f,reg,SizeOf(reg));
  BlockWrite(f,cid,SizeOf(cid));
  Scm.Init(RegDataPassword);
  Scm.DescrambleBlock(reg,SizeOf(Reg));
  Scm.DescrambleBlock(cid,SizeOf(cid));
  BlockWrite(f,l.l,SizeOf(l.l));
  WriteRegistration:= 0;
  Close(f);
  res:= IOResult;
  if res<>0 then begin
   IOError:
    WriteRegistration:= -1000-res;
    Exit;
    end;
  { set R/O and Hidden file attribute }
  {$ifdef WINDOWS}
  FileSetAttr(filename,FileGetAttr(filename) or (faReadOnly or faHidden));
  {$else}
  GetFAttr(f,l.wl);
  SetFAttr(f,$03 or l.wl);
  {$endif}
  if IOResult<>0 then ;
  {$I+}
end;


function ReadRegistration( const filename: String;
                           var   user: TRegUserData;
                           var   reg: TRegData;
                           minversion: Word ): Integer;
label IOError, FileFormatError;
var
  res: Integer;
  f: file;
  Crc, Scm: TCRC32;
  l: TLongRec;
  cid, cid2: TComputerId;
  Header: String[Length(RegHeader)];
  Ver: Word;
  SavFileMode: Byte;

begin
  FillChar(user,SizeOf(user),0);
  FillChar(reg,SizeOf(reg),0);
  {$I-}
  Assign(f,filename);
  SavFileMode:= FileMode;
  FileMode:= 0;
  Reset(f,1);
  FileMode:= SavFileMode;
  res:= IOresult;
  if res<>0 then goto IOError;
  Header[0]:= chr(Length(RegHeader));
  BlockRead(f,Header[1],Length(RegHeader));
  if Header<>RegHeader then begin
   FileFormatError:
    Close(f);
    if IOResult<>0 then ;
    ReadRegistration:= -3;
    Exit;
    end;
  BlockRead(f,Ver,SizeOf(Ver));
  if Ver<>RegVersion then goto FileFormatError;
  BlockRead(f,user,SizeOf(user));
  BlockRead(f,reg,SizeOf(reg));
  BlockRead(f,cid,SizeOf(cid));
  BlockRead(f,l.l,SizeOf(l.l));
  Close(f);
  res:= IOResult;
  if res<>0 then begin
   IOError:
    ReadRegistration:= -1000-res;
    Exit;
    end;
  {$I+}
  Scm.Init(RegDataPassword);
  Scm.DescrambleBlock(reg,SizeOf(Reg));
  Scm.DescrambleBlock(cid,SizeOf(cid));
  Crc.Init0;
  Crc.PutBlock(user,SizeOf(user));
  Crc.PutBlock(reg,SizeOf(reg));
  Crc.PutBlock(cid,SizeOf(cid));
  if l.l<>Crc.Get then goto FileFormatError;
  if GetUserId(user) <> reg.UserId then begin
    ReadRegistration:= -2;
    Exit;
    end;
  GetComputerId(cid2,filename);
  { version check }
  if reg.Version<minversion then begin
    ReadRegistration:= -4;
    Exit;
    end;
  { duration check }
  if reg.Duration<>0 then begin
    l.l:= cid2.Date.Year*12*28+cid2.Date.Month*28+cid2.Date.Day -
         (cid.Date.Year*12*28 +cid.Date.Month*28 +cid.Date.Day);
    if (l.l>reg.Duration) or (l.l<0) then begin
      ReadRegistration:= -5;
      Exit;
      end;
    end;
  { validity date check }
  if reg.ValidityDate.Year<>0 then begin
    if (cid2.Date.Year>reg.ValidityDate.Year)
       or
       (cid2.Date.Year=reg.ValidityDate.Year) and
       (cid2.Date.Month>reg.ValidityDate.Month)
       or
       (cid2.Date.Year=reg.ValidityDate.Year) and
       (cid2.Date.Month=reg.ValidityDate.Month) and
       (cid2.Date.Day>reg.ValidityDate.Day)
     then begin
      ReadRegistration:= -6;
      Exit;
      end;
    end;
  { computer id check }
  if reg.NetLicCount=0 then begin
    { single computer }
    if cid.BIOSId<>cid2.BIOSId then begin
      ReadRegistration:= -7;
      Exit;
      end;
    end;
  { HD id check }
  if reg.NetLicCount=0 then begin
    { single computer }
    if (cid.HDNet xor cid2.HDNet) or
      not cid.HDNet and (cid.HDSerial<>cid2.HDSerial)
      then begin
      ReadRegistration:= -7;
      Exit;
      end;
    end;
  { dir id check }
  if cid.DirId<>cid2.DirId then begin
    ReadRegistration:= -7;
    Exit;
    end;
  ReadRegistration:= 0;
end;
{$endif not RegProtGenerator}

{$ifdef RegProtGenerator}
function GenerateRegistrationNum( var user: TRegUserData;
                                  var reg:  TRegData ): String;
begin
  WipeStr(reg.LicenceNum);
  reg.UserId:= GetUserId(user);
  GenerateRegistrationNum:= RegToStr(reg);
end;
{$endif RegProtGenerator}

end.