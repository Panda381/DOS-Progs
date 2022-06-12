unit Crc32;
{ Copyrigth (c)1996,1997,1998 Tom æupka }

(*///////////////////////////////////////////////////
 *// TCRC32 - CRC generation, (c)1996 Tom Supka
 *// created: 960927 TS
 *//          980126 TS Turbo Pascal implementation
 *//
 *// implementation
 *)

interface

type
  TCRC32Value = LongInt;
  TCRC32 = object
    private
      CRCValue: TCRC32Value;
    public
      constructor Init0;
      constructor Init( n: TCRC32Value );
      procedure Reset;
      function  Get: TCRC32Value;
      function  IsOK: Boolean;
      procedure PutByte( B: Byte );
      procedure ScrambleByte( var B: Byte );
      procedure DescrambleByte( var B: Byte );
      procedure PutBlock( const Block; Size: Word );
      procedure ScrambleBlock( var Block; Size: Word );
      procedure DescrambleBlock( var Block; Size: Word );
      procedure PutCRC( CRC: TCRC32Value );
    end;

{$ifdef CRC32Table}
procedure PrintTable;
procedure GenerateTable;
{$endif CRC32Table}

implementation

const
  LookUpTable: array[0..15] of TCRC32Value = (
    { $00 } $00000000, $1DB71064, $3B6E20C8, $26D930AC,
    { $04 } $76DC4190, $6B6B51F4, $4DB26158, $5005713C,
    { $08 } $EDB88320, $F00F9344, $D6D6A3E8, $CB61B38C,
    { $0C } $9B64C2B0, $86D3D2D4, $A00AE278, $BDBDF21C
    );

constructor TCRC32.Init0;
begin
  Reset;
end;

constructor TCRC32.Init( n: TCRC32Value );
begin
  CRCValue:= n;
end;

procedure TCRC32.Reset;
begin
  CRCValue:= $FFFFFFFF;
end;

function  TCRC32.Get: TCRC32Value;
begin
  Get:= CRCValue;
end;

function  TCRC32.IsOK: Boolean;
begin
  IsOK:= CRCValue=$DEBB20E3;
end;

procedure TCRC32.PutByte( B: Byte );
var
  i: Word;
begin
  {1st nibble}
  i:= (CRCValue xor B) and $000F;
  CRCValue:= (CRCValue shr 4) xor LookUpTable[i];
  {2nd nibble}
  B:= B shr 4;
  i:= (CRCValue xor B) and $000F;
  CRCValue:= (CRCValue shr 4) xor LookUpTable[i];
end;

procedure TCRC32.ScrambleByte( var B: Byte );
var nb: Byte;
begin
  nb:= (CRCValue shr 24) xor B;
  PutByte(B);
  B:= nb;
end;

procedure TCRC32.DescrambleByte( var B: Byte );
var nb: Byte;
begin
  nb:= (CRCValue shr 24) xor B;
  PutByte(nb);
  B:= nb;
end;

type
  PByte = ^Byte;

procedure TCRC32.PutBlock( const Block; Size: Word );
var
  n: Word;
  t: PByte;
begin
  t:= @Block;
  n:= Size;
  while n>0 do begin
    PutByte(t^);
    Inc(PChar(t));
    Dec(n);
    end;
end;

procedure TCRC32.ScrambleBlock( var Block; Size: Word );
var
  n: Word;
  t: PByte;
begin
  t:= @Block;
  n:= Size;
  while n>0 do begin
    ScrambleByte(t^);
    Inc(PChar(t));
    Dec(n);
    end;
end;

procedure TCRC32.DescrambleBlock( var Block; Size: Word );
var
  n: Word;
  t: PByte;
begin
  t:= @Block;
  n:= Size;
  while n>0 do begin
    DescrambleByte(t^);
    Inc(PChar(t));
    Dec(n);
    end;
end;

procedure TCRC32.PutCRC( CRC: TCRC32Value );
begin
  PutBlock(CRC,SizeOf(CRC));
end;

{$ifdef CRC32Table}
function HexStr( Val: LongInt; Digits: Byte ): String;
var
  Res: String[8];
  i: Byte;
  d: Byte;
begin
  for i:= Digits downto 1 do begin
    d:= Val and $0f;
    if d>=10 then Res[i]:= chr(d-10+ord('A'))
    else Res[i]:= chr(d+ord('0'));
    Val:= Val shr 4;
    end;
  Res[0]:= chr(Digits);
  HexStr:= Res;
end;

procedure GenerateTable;
var
  Polynom: TCRC32Value;
  i: Word;
begin
  Polynom:= (1 shl (31-26)) or (1 shl (31-23)) or (1 shl (31-22)) or
            (1 shl (31-16)) or (1 shl (31-12)) or (1 shl (31-11)) or
            (1 shl (31-10)) or (1 shl (31- 8)) or (1 shl (31- 7)) or
            (1 shl (31- 5)) or (1 shl (31- 4)) or (1 shl (31- 2)) or
            (1 shl (31- 1)) or (1 shl (31- 0));
  for i:= Low(LookUpTable) to High(LookUpTable) do begin
    if (i and $08) <> 0 then
      LookUpTable[i]:= LookUpTable[i] xor (Polynom shr 0);
    if (i and $04) <> 0 then
      LookUpTable[i]:= LookUpTable[i] xor (Polynom shr 1);
    if (i and $02) <> 0 then
      LookUpTable[i]:= LookUpTable[i] xor (Polynom shr 2);
    if (i and $01) <> 0 then
      LookUpTable[i]:= LookUpTable[i] xor (Polynom shr 3);
    end;
end;

procedure PrintTable;
var
  i: Word;
begin
  WriteLn;
  Write('= {CRC32 Nibble Look-Up Table} (');
  for i:= Low(LookUpTable) to High(LookUpTable) do begin
    if (i and $03) = 0 then begin
      WriteLn;
      Write('  { $',HexStr(i,2),' }');
      end
    else begin
      end;
    Write(' $',HexStr(LookUpTable[i],8),',');
    end;
  WriteLn;
  WriteLn(');');
end;
{$endif CRC32Table}

end.
