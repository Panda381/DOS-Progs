unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, TabNotBk, Menus, Tabs, StdCtrls, Buttons, Grids,
  Spin;

const
  IconWidth = 39;
  IconWidthL = (IconWidth+7) and not 7;
  IconHeight = 29;
  IconXNum = 15;
  IconYNum = 10;
  IconPageNum = IconXNum * IconYNum;  { dìlitelné 3 !!! }

  SizeHeadBank = 4 + 3*16;
  SizeHBank = 6;
  SizeBnk = IconWidthL*IconHeight*4 div 8+SizeHBank;

  BMPPageNum = IconPageNum div 3;
  SizeBank = SizeBnk*BMPPageNum;
  SizeHBMP = SizeOf(TBitmapFileHeader) +
             SizeOf(TBitmapInfoHeader) + 4*256;
  SizeBMP = IconWidthL*IconHeight*BMPPageNum+SizeHBMP;

type

{  PLogPal = ^TLogPal;
  TLogPal = packed record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array[0..15] of LongInt;
  end; }

  TBMPIcon = packed record
    bmData: array [0..(IconWidthL*IconHeight-1)] of Byte;
  end;

  TBMPBitmap = packed record
    bmFileHeader: TBitmapFileHeader;
    bmInfoHeader: TBitmapInfoHeader;
    bmPalette: array [0..(4*256-1)] of Byte;
    bmIcon: array [0..(BMPPageNum-1)] of TBMPIcon;
  end;

  TBankIcon = packed record
    biLastX: Byte;   { 38 }
    biRes1: Byte;    { 1 }
    biLastY: Byte;   { 28 }
    biRes2: Byte;    { 255 }
    biData: array [0..(IconWidthL*IconHeight*4 div 8 - 1)] of Byte;
    biRes3: Byte;    { $D8 }
    biRes4: Byte;    { $D3 }
  end;

  TBankBitmap = packed record
    BankIcon: array [0..(BMPPageNum-1)] of TBankIcon;
  end;

  TMainForm = class(TForm)
    PanelStatus: TPanel;
    MainMenu1: TMainMenu;
    Soubor1: TMenuItem;
    Nov1: TMenuItem;
    Otevt1: TMenuItem;
    Uloit1: TMenuItem;
    N1: TMenuItem;
    Konec1: TMenuItem;
    Npovda1: TMenuItem;
    Oprogramu1: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    BitBtn1: TBitBtn;
    Tabbed: TTabbedNotebook;
    GridRoom: TStringGrid;
    GridExec: TStringGrid;
    GridProg: TStringGrid;
    GridPic: TStringGrid;
    TabSetProg: TTabSet;
    GridProgH: TStringGrid;
    GridExecH: TStringGrid;
    TabSetPic: TTabSet;
    BitBtn2: TBitBtn;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure Konec1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TabbedClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
    procedure GridProgHDrawCell(Sender: TObject; ColL, RowL: Longint;
      RectL: TRect; State: TGridDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ColL, RowL: Longint;
      RectL: TRect; State: TGridDrawState);
  private
    procedure LoadBMIcon;
    procedure ClearBMIcon;
  public
  end;

const
  DefaultPal: array [0..4*16-1] of Byte = (
     0,   0,   0,  0,
     0, 170,   0,  0,
   255,   0,   0,  0,
   170,   0,   0,  0,
    85,   0, 170,  0,
     0,   0, 170,  0,
    85, 170, 170,  0,
   170, 170, 170,  0,
    85,  85,  85,  0,
     0, 255,   0,  0,
   255, 255,   0,  0,
   255,  85, 170,  0,
    21,  85, 255,  0,
     0, 170, 255,  0,
     0, 255, 255,  0,
   255, 255, 255,  0);

var
  MainForm: TMainForm;

  HomeDir: String;

  Bank1: array [0..199] of TBitmap; { sloupec   0 ..  49 }
  Bank2: array [0..199] of TBitmap; { sloupec  50 ..  99 }
  Bank3: array [0..199] of TBitmap; { sloupec 100 .. 149 }

  {  Paleta: TLogPal;
  PaletteHandle: HPalette;}

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
var I, J: Integer;
begin
  HomeDir := ExtractFilePath(ExpandFileName(ParamStr(0)));
  Application.HelpFile := HomeDir + 'Baltik.hlp';
  Application.OnHint := ShowHint;
  Application.Title := 'Baltík';
  Caption := 'Baltík';

  for I := 0 to 199 do
  begin
    Bank1[I] := nil;
    Bank2[I] := nil;
    Bank3[I] := nil;
  end;

{
  Paleta.palVersion := $300;
  Paleta.PalNumEntries := 16;
  Paleta.palPalEntry[0] := clBlue;
  Paleta.palPalEntry[1] := clBlack;
  Paleta.palPalEntry[2] := clWhite;
  Paleta.palPalEntry[3] := clYellow;
  Paleta.palPalEntry[4] := clRed;
  Paleta.palPalEntry[5] := clGreen;
  Paleta.palPalEntry[6] := 6;
  Paleta.palPalEntry[7] := 7;
  Paleta.palPalEntry[8] := 8;
  Paleta.palPalEntry[9] := 9;
  Paleta.palPalEntry[10] := 10;
  Paleta.palPalEntry[11] := 100;
  Paleta.palPalEntry[12] := 400;
  Paleta.palPalEntry[13] := 1000;
  Paleta.palPalEntry[14] := 2000;
  Paleta.palPalEntry[15] := 5000;
  CreatePal;
}

  LoadBMIcon;

  with GridProgH do
  begin
    for I := 0 to 15 do Cells[I,0] := ' ';
    for I := 0 to 15 do Cells[I,1] := ' ';
    for I := 0 to 15 do Cells[I,2] := ' ';
  end;

  with GridExecH do
    for I := 0 to 15 do Cells[I,0] := ' ';

  Width := 630;
  Height := 450;
  Left := (Screen.Width - Width) div 2;
  if Left < 0 then Left := 0;
  Top := (Screen.Height - Height - 25) div 2;
  if Top < 0 then Top := 0;

  FormResize(Sender);
  Tabbed.PageIndex := 4;
  TabbedClick(Sender);
end;

procedure TMainForm.ClearBMIcon;
var
  I: Integer;
begin
  for I := 0 to 199 do
  begin
    if Assigned(Bank1[I]) then Bank1[I].Free;
    if Assigned(Bank2[I]) then Bank2[I].Free;
    if Assigned(Bank3[I]) then Bank3[I].Free;
  end;
end;

procedure TMainForm.LoadBMIcon;
var
  CisloBanky: Integer;
  VerzeBanky: Integer;
  JmenoBanky: string;
  FileHandle: Integer;
  I: Integer;
{  Bitmap: TBitmap;   }     { výstupní obrázek banky }
  Stream: TMemoryStream;
  BankBitmap: ^TBankBitmap; { 50 obrázkù ve formátu BANK }
  BMPBitmap: ^TBMPBitmap; { 50 obrázkù ve formátu BMP }

  procedure KonvIcon(Dest, Src: pointer; PageNum: Integer);
  begin
{ 16 bitù }
    asm
      push ax
      push bx
      push cx
      push dx
      push si
      push di
      push ds
      push es

      cld
      lds  si,Src
      les  di,Dest
      add  di,BMPPageNum*IconHeight*IconWidthL-IconWidthL

@@0:  mov  bh,IconHeight
@@1:  mov  bl,IconWidthL/8
@@2:  mov  cx,8007h
@@3:  mov  al,ds:[si]
      and  al,ch
      shr  al,cl
      mov  ah,al
      shl  ah,1

      mov  al,ds:[si+IconWidthL/8]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,ds:[si+2*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,ds:[si+3*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   al,ah

      stosb

      dec  cl
      shr  ch,1
      jnz  @@3

      inc  si
      dec  bl
      jnz  @@2

      sub  di,2*IconWidthL
      add  si,IconWidthL*3/8
      dec  bh
      jnz  @@1

      add  si,SizeHBank
      dec  PageNum
      jnz  @@0

      pop  es
      pop  ds
      pop  di
      pop  si
      pop  dx
      pop  cx
      pop  bx
      pop  ax
    end;

{ 32 bitù }
{    asm
      push eax
      push ebx
      push ecx
      push edx
      push esi
      push edi

      cld
      mov  esi,Src
      mov  edi,Dest
      add  edi,BMPPageNum*IconHeight*IconWidthL-IconWidthL

@@0:  mov  bh,IconHeight
@@1:  mov  bl,IconWidthL/8
@@2:  mov  cx,8007h
@@3:  mov  al,[esi]
      and  al,ch
      shr  al,cl
      mov  ah,al
      shl  ah,1

      mov  al,[esi+IconWidthL/8]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,[esi+2*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,[esi+3*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   al,ah

      mov  [edi],al
      inc  edi

      dec  cl
      shr  ch,1
      jnz  @@3

      inc  esi
      dec  bl
      jnz  @@2

      sub  edi,2*IconWidthL
      add  esi,IconWidthL*3/8
      dec  bh
      jnz  @@1

      add  esi,SizeHBank
      dec  PageNum
      jnz  @@0

      pop  edi
      pop  esi
      pop  edx
      pop  ecx
      pop  ebx
      pop  eax
    end; }
  end;

begin
  Stream := TMemoryStream.Create;
  try { except }
    New(BankBitmap);
    try { finaly }
      New(BMPBitmap);
      try { finaly }
        ClearBMIcon;
{ inicializace záhlaví BMP souboru }
        with BMPBitmap^ do
        begin
          with bmFileHeader do
          begin
            bfType := $4d42;
            bfSize := SizeBMP;
            bfReserved1 := 0;
            bfReserved2 := 0;
            bfOffBits := SizeHBMP;
          end;

          with bmInfoHeader do
          begin
            biSize := SizeOf(TBitmapInfoHeader);
            biWidth := IconWidth;
            biHeight := IconHeight*BMPPageNum;
            biPlanes := 1;
            biBitCount := 8;
            biCompression := 0;
            biSizeImage := IconWidthL*IconHeight*BMPPageNum;
            biXPelsPerMeter := 640;
            biYPelsPerMeter := 480;
            biClrUsed := 0;
            biClrImportant := 0;
          end;

          for I := 0 to (16*4-1) do
            bmPalette[I] := DefaultPal[I];

          for I := 16*4 to (256*4-1) do
            bmPalette[I] := 0;
        end;
{ cyklus otevøení souborù bank }
        for CisloBanky := 0 to 199 do
        begin
          case CisloBanky of
            0..9:     JmenoBanky := HomeDir + 'BALTIK.B0'
                        + IntToStr(CisloBanky);
            10..99:   JmenoBanky := HomeDir + 'BALTIK.B'
                        + IntToStr(CisloBanky);
            100..109: JmenoBanky := HomeDir + 'BALTIK.C0'
                        + IntToStr(CisloBanky-100);
            110..199: JmenoBanky := HomeDir + 'BALTIK.C'
                        + IntToStr(CisloBanky-100);
          end;
          if FileExists(JmenoBanky) then
            FileHandle := FileOpen(JmenoBanky,fmOpenRead)
          else
            FileHandle := -1;

          if FileHandle > 0 then with BankBitmap^ do
          try { finaly FileClose }
            FileRead(FileHandle,BankIcon,SizeHeadBank);
            Bank1[CisloBanky] := TBitmap.Create;
            Bank2[CisloBanky] := TBitmap.Create;
            Bank3[CisloBanky] := TBitmap.Create;

            for VerzeBanky := 1 to 3 do
            begin
              FileRead(FileHandle,BankIcon,SizeOf(BankIcon));

              KonvIcon(@(BMPBitmap^.bmIcon[0].bmData[0]),
                     @(BankIcon[0].biData[0]),BMPPageNum);

{              for CisloIkony := 0 to (BMPPageNum-1) do
                with  BankIcon[CisloIkony],
                         BMPBitmap^.bmIcon[CisloIkony] do
                begin
                  for I := 0 to IconHeight-1 do
                    for J := 0 to (IconWidthL div 8 - 1) do
                    begin
                      M := $80;
                      for K := 0 to 7 do
                      begin
                  bmData[(IconHeight-1-I)*IconWidthL+J*8+K] :=
   (((biData[I*IconWidthL div 2+J] and M) shr (7-K)) shl 3) or
   (((biData[I*IconWidthL div 2+J+IconWidthL div 8] and M) shr (7-K)) shl 2) or
   (((biData[I*IconWidthL div 2+J+2*IconWidthL div 8] and M) shr (7-K)) shl 1) or
   (((biData[I*IconWidthL div 2+J+3*IconWidthL div 8] and M) shr (7-K)) shl 0);
                        M := M shr 1;
                      end;
                    end;
                end; }{ for - with BankIcon }

              Stream.Position := 0;
              Stream.WriteBuffer(BMPBitmap^,SizeOf(TBMPBitmap));
              Stream.Position := 0;
              Case VerzeBanky of
                1: Bank1[CisloBanky].LoadFromStream(Stream);
                2: Bank2[CisloBanky].LoadFromStream(Stream);
                3: Bank3[CisloBanky].LoadFromStream(Stream);
              end;
            end;  { for VerzeBanky }
            Bank1[CisloBanky].Dormant;
            Bank2[CisloBanky].Dormant;
            Bank3[CisloBanky].Dormant;
          finally
            FileClose(FileHandle);
          end;
        end;     { for CisloBanky }
      finally
        Dispose(BMPBitmap);
      end;
    finally
      Dispose(BankBitmap);   { pro 50 obrázkù BANK }
    end;
  except
  end;
  Stream.Free;
end;

{
procedure TMainForm.CreatePal;
begin
  PaletteHandle := CreatePalette(PLogPalette(@Paleta)^);
end; }

procedure TMainForm.ShowHint(Sender: TObject);
begin
  PanelStatus.Caption := Application.Hint;
end;

procedure TMainForm.Konec1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormResize(Sender: TObject);
var I: Integer;
begin
  with GridRoom do
  begin
    I := (Tabbed.Width - Width - 10) div 2;
    if I < 0 then I := 0;
    Left := I;

    I := (Tabbed.Height - Height - 31) div 2;
    if I < 0 then I := 0;
    Top := I;
  end;

  with GridExecH do
  begin
    Left := GridRoom.Left;
    GridExec.Left := Left;

    I := (Tabbed.Height - Height - GridExec.Height - 31) div 2;
    if I < 0 then I := 0;
    Top := I;
    GridExec.Top := I + Height;
  end;

  with GridPic do
  begin
    Left := GridRoom.Left;
    TabSetPic.Left := Left;

    I := (Tabbed.Height - Height - TabSetPic.Height - 31) div 2;
    if I < 0 then I := 0;
    Top := I;
    TabSetPic.Top := Top + Height;
  end;
end;

procedure TMainForm.TabbedClick(Sender: TObject);
begin
  case Tabbed.PageIndex of
    0: ActiveControl := GridRoom;
    1: ActiveControl := GridExec;
    2: ActiveControl := GridProg;
    3: ActiveControl := GridPic;
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_TAB: begin
              if Shift = [ssCtrl] then with Tabbed do
                Case PageIndex of
                  0: PageIndex := 1;
                  1: PageIndex := 2;
                  2: PageIndex := 3;
                  3: PageIndex := 0;
                end;
              if Shift = [ssCtrl]+[ssShift] then with Tabbed do
                Case PageIndex of
                  0: PageIndex := 3;
                  1: PageIndex := 0;
                  2: PageIndex := 1;
                  3: PageIndex := 2;
                end;
              TabbedClick(Sender);
            end;
  end;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  TabbedClick(Sender);
end;

procedure TMainForm.GridProgHDrawCell(Sender: TObject; ColL, RowL: Longint;
  RectL: TRect; State: TGridDrawState);
begin
  if Sender is TStringGrid then with TStringGrid(Sender) do
    Canvas.CopyRect(RectL,Bank1[101].Canvas,
       Rect(0,(ColL+RowL*15)*29,39,(1+ColL+RowL*15)*29));
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ClearBMIcon;
end;

procedure TMainForm.StringGrid1DrawCell(Sender: TObject; ColL, RowL: Longint;
  RectL: TRect; State: TGridDrawState);
begin
  if Sender is TStringGrid then with TStringGrid(Sender) do
  begin
    with Canvas do
      if Assigned(Bank1[101]) then
      begin
        Draw(RectL.Left,RectL.Top,Bank1[101]);
      end
      else
        FillRect(RectL);
  end;
end;

end.
