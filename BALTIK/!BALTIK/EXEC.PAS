unit Exec;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons;

type
  TExecForm = class(TForm)
    TimerExec: TTimer;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    ButtonExit: TSpeedButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImageExecMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ExecInit;
    procedure MazExec;
    procedure MazIconExec(Cislo: Longint;Pozice,Radek: Integer);
    procedure MaskIconExec(Cislo: Longint;Pozice,Radek: Integer);
    procedure DispBaltExec(OCanvas: TCanvas);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TimerExecTimer(Sender: TObject);
    procedure AddTime;
    procedure AddTimeKey;
    procedure AktIkon(Poz,Rad: Integer);
    procedure ExecIdle(Sender: TObject; var Done: Boolean);
    procedure FormPaint(Sender: TObject);
    function GetExecTime(OldTime: Longint): Longint;
    procedure ExecDisp;
    procedure ButtonExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowModal2;
    { Public declarations }
  end;

const
  RychlTab: array [0..9] of Integer
       =  (  2,  4,  3,  2, 2, 2, 1, 1,1,0);
{       = (100,250,180,120,80,60,40,30,0,0);}
  ExecRamTop = 20;
  ExecRamLeft = 20;
  ExecRamBottom = 20;
  ExecRamRight = 20;

var
  ExecForm: TExecForm;
  NextTime: Longint; { TDateTime;}
  AktTime: Longint;

  TimerAktiv: Boolean;
  CekaKlavesu: Boolean;

  ZmenaLeft: Integer;
  ZmenaTop: Integer;
  ZmenaRight: Integer;
  ZmenaBottom: Integer;

implementation

uses Main;
{$R *.DFM}

procedure TExecForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if CekaKlavesu then
    CekaKlavesu := False
  else
    if Key = VK_ESCAPE then Close;
  Key := 0;
end;

function TExecForm.GetExecTime(OldTime: Longint): Longint;
begin
  Result := Round(Frac(Now)*24*60*60*18.20648);
  while Result < OldTime-100 do
    Result := Result + 1573040;
end;

procedure TExecForm.ImageExecMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssRight in Shift then Close;
  CekaKlavesu := False;
end;

procedure TExecForm.FormCreate(Sender: TObject);
begin
{ pøíprava plochy k bìhu programu }
  TimerAktiv := False;
  ExecTopLine := 0;

  ClientWidth := IconWidth*IconXNum + ExecRamLeft + ExecRamRight;
  ClientHeight := IconHeight*IconYNum + ExecRamTop + ExecRamBottom + 50;
end;

procedure TExecForm.ShowModal2;
begin
  FormStyle := fsStayOnTop;
  Show;
  repeat
    Application.HandleMessage;
  until not BeziProgram;
  Hide;
end;

procedure TExecForm.FormShow(Sender: TObject);
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;

  ExecSubX := 0;
  ExecSubXX := -1;
  ExecSubY := 0;
  ExecSubYY := -1;
  ExecSubC := 0;
  ExecSubCX := -1;
  ExecSubCY := -1;
  ZmenaLeft := IconWidth*IconXNum;
  ZmenaTop := IconHeight*IconYNum;
  ZmenaRight := 0;
  ZmenaBottom := 0;
  CekaKlavesu := False;

  ExecCitac := ProgBuff^.pfProgSize;
  ExecIndex := 0;
  ExecVidit := True;
  ExecRychlost := 5;
  ExecLine := 0;
  ExecOblak := True;

  if ExecTopLine = 0 then
    ExecFast := False
  else
    ExecFast := True;

  ZasobPocet := 0;
  ZasobNeniZavorka := 0;

  ExecInit;
  AktTime := GetExecTime(0);
  NextTime := AktTime + 9;
  BeziProgram := True;
  TimerExec.Enabled := True;
  Application.OnIdle := ExecForm.ExecIdle;
  FormPaint(Sender);
end;

procedure TExecForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  BeziProgram := False;
  TimerExec.Enabled := False;
  Application.OnIdle := nil;
  CanClose := True;
end;

procedure TExecForm.ExecInit;
var I,J: Integer;
begin
  with ExecBuff^ do
  begin
    for J := 0 to (IconYNum-1) do
     for I := 0 to (IconXNum-1) do
       sfData[J+I*IconYNum] := BAL_PODKLAD;
    sfIdent[0] := '2'; sfIdent[1] := 'w';
    sfIdent[2] := '#'; sfIdent[3] := 'E';
    sfXXX1 := 5;
    sfSmer := 1;
    sfXXX2 := 0;
    sfSloupec := 1;
    sfRadek := 10;
    sfXXX3 := 0;
    sfSloupcu := 15;
    sfRadku := 10;
  end;
  MazExec;
  FormPaint(ExecForm);
end;

procedure TExecForm.MazExec;
var I,J: Integer;
begin
  for I := 0 to IconXNum-1 do
    for J := 0 to IconYNum-1 do
      MazIconExec(ExecBuff^.sfData[J+I*IconYNum],I,J);
end;

procedure TExecForm.MazIconExec(Cislo: Longint;
                               Pozice,Radek: Integer);
var Banka: Integer;
    DRect, SRect: TRect;
begin
  DRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  Cislo := Cislo - 1;
  if Cislo < 0 then Cislo := BAL_PODKLAD;
  Banka := Cislo div 1000;
  Cislo := Cislo mod 1000;
  Pozice := Cislo mod IconXNum;
  Radek := Cislo div IconXNum;

  SRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  if Assigned(ProgramBank[Banka]^.bnBitmap) then
    ExecBitmap.Canvas.CopyRect(DRect,
        ProgramBank[Banka]^.bnBitmap.Canvas,SRect)
  else
  begin
    ExecBitmap.Canvas.Brush.Color := clBlack;
    ExecBitmap.Canvas.FillRect(DRect);
  end;

  AktIkon(DRect.Left div IconWidth,DRect.Top div IconHeight);
end;

procedure TExecForm.MaskIconExec(Cislo: Longint;
                               Pozice,Radek: Integer);
var Banka: Integer;
    DRect: TRect;
begin
  DRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  Cislo := Cislo - 1;
  if Cislo < 0 then Cislo := BAL_PODKLAD;
  Banka := Cislo div 1000;
  Cislo := Cislo mod 1000;

{  if (Banka < 0) or (Banka >= MaxBank) or
    (Cislo < 0) or (Cislo >= IconPageNum) then Exit;}

  if Assigned(ProgramBank[Banka]^.bnBitmap) then
    DispMaskIcon(ExecBitmap.Canvas,DRect.Left,DRect.Top,
    @ProgramBank,Banka,Cislo);

  AktIkon(DRect.Left div IconWidth,DRect.Top div IconHeight);
end;

procedure TExecForm.DispBaltExec(OCanvas: TCanvas);
var Cislo: Longint;
    NextPoz, NextRad: Integer;
begin
  with ExecBuff^ do
  begin
    if ExecVidit and (ExecRychlost < 9) then
    begin
      Case sfSmer of
        1: Cislo := 100001;
        2: Cislo := 100006;
        3: Cislo := 100011;
        else Cislo := 100016;
      end;

      Case Round(Abs(ExecSubX)/IconWidth*8) +
           Round(Abs(ExecSubY)/IconHeight*8) of
        1,5: Inc(Cislo,2);
        3,7: Inc(Cislo);
      end;

      if (ExecSubC > 0) and (ExecSubC < 6) then Inc(Cislo,4);

      if CekaKlavesu then
        if Frac(Now*24*60*60*3) > 0.5 then
          Inc(Cislo,3);

      DispMaskIcon(OCanvas,(sfSloupec-1)*IconWidth+Round(ExecSubX),
        (sfRadek-1)*IconHeight+Round(ExecSubY),@ProgramBank,
        (Cislo-1) div 1000, (Cislo-1) mod 1000);
    end;

{ obsluha èarování }
    if (ExecSubC > 0) and (ExecSubC < 9) then
    begin
      NextPoz := sfSloupec;
      NextRad := sfRadek;
      Case sfSmer of
        1: Inc(NextPoz);
        2: Inc(NextRad);
        3: Dec(NextPoz);
        else Dec(NextRad);
      end;

      DispMaskIcon(OCanvas,(NextPoz-1)*IconWidth,
        (NextRad-1)*IconHeight,@ProgramBank,BAL_CARUJ_FAZE1 div 1000,
        (BAL_CARUJ_FAZE1+ExecSubC-1) mod 1000);
    end;
  end;
end;

procedure TExecForm.AddTime;
begin
  if not ExecFast then
    NextTime := NextTime +
      RychlTab[ExecRychlost]; { /(24*60*60*1000);}
end;

procedure TExecForm.AddTimeKey;
begin
  if (ExecRychlost = 0) and not ExecFast then
    CekaKlavesu := True
  else
    AddTime;
end;

procedure TExecForm.AktIkon(Poz,Rad: Integer);
begin
  Poz := Poz*IconWidth;
  Rad := Rad*IconHeight;
  if Poz < ZmenaLeft then ZmenaLeft := Poz;
  if Rad < ZmenaTop then ZmenaTop := Rad;
  if Poz+IconWidth > ZmenaRight then ZmenaRight := Poz+IconWidth;
  if Rad+IconHeight > ZmenaBottom then ZmenaBottom := Rad+IconHeight;
end;

procedure TExecForm.ExecIdle(Sender: TObject; var Done: Boolean);
begin
  Done := False;
  if CekaKlavesu then Exit;
{  Dec(AktTime);}
  ExecForm.TimerExecTimer(Sender);
end;

procedure TExecForm.TimerExecTimer(Sender: TObject);
var Prikaz: Longint;
    Stradac: Longint;
    Pokusu: Integer;
    X, Y: Integer;
begin
  if GetExecTime(AktTime) > AktTime then
    Inc(AktTime);

  if TimerAktiv then Exit;
  TimerAktiv := True;
  Pokusu := 0;

{ indikace èekání na stisk klávesy }
  if CekaKlavesu then
  begin
    NextTime := AktTime;
    AktIkon(ExecBuff^.sfSloupec-1,ExecBuff^.sfRadek-1);
  end;

{ zahájení cyklu opakování }
{ while (ExecFast or (Now >= NextTime)) and}
while (AktTime >= NextTime) and
      (not CekaKlavesu) and
       BeziProgram and
      (Pokusu < 30) do
begin

{ provedení jednoho kroku Baltíka }
  if ExecSubX <> ExecSubY then with ExecBuff^ do
  begin
    AktIkon(sfSloupec-1,sfRadek-1);
    AktIkon(ExecSubXX,ExecSubYY);

    if ExecSubX > 0 then
    begin
      ExecSubX := ExecSubX + IconWidth/8;
      if ExecSubX > IconWidth-1 then
        begin Inc(sfSloupec); ExecSubX := 0; end;
    end;

    if ExecSubY > 0 then
    begin
      ExecSubY := ExecSubY + IconHeight/8;
      if ExecSubY > IconHeight-1 then
        begin Inc(sfRadek); ExecSubY := 0; end;
    end;

    if ExecSubX < 0 then
    begin
      ExecSubX := ExecSubX - IconWidth/8;
      if ExecSubX < -IconWidth+1 then
        begin Dec(sfSloupec); ExecSubX := 0; end;
    end;

    if ExecSubY < 0 then
    begin
      ExecSubY := ExecSubY - IconHeight/8;
      if ExecSubY < -IconHeight+1 then
        begin Dec(sfRadek); ExecSubY := 0; end;
    end;

    if ExecSubX = ExecSubY then
    begin
      ExecSubXX := -1;
      ExecSubYY := -1;
      AddTimeKey;
    end
    else
      AddTime;

  end  { if ExecSubX <> ExecSubY }

  else

{ provedení èarování }
  if ExecSubC > 0 then with ExecBuff^ do
  begin
    AktIkon(sfSloupec-1,sfRadek-1);
    X := ExecSubCX;
    Y := ExecSubCY;
    AktIkon(X,Y);

    if ExecSubC = 4 then
    begin
      sfData[Y+X*IconYNum] := ExecPredmet;
      MaskIconExec(ExecPredmet,X,Y);
    end;

    if ExecSubC < 8 then
      Inc(ExecSubC)
    else
    begin
      ExecSubC := 0;
      ExecSubCX := -1;
      ExecSubCY := -1;
    end;

    if ExecSubC = 0 then
      AddTimeKey
    else
      if (ExecRychlost <> 8) or (ExecSubC mod 2 <> 1) then
        AddTime;

  end

  else

{ ukonèení programu }
  if (ExecCitac = 0) and (ZasobNeniZavorka <> 2) then
  begin
    BeziProgram := False;
    Application.OnIdle := nil;
    TimerExec.Enabled := False;
    Close;
  end

  else

{ pøíprava dalšího pøíkazu }
  begin

    if ZasobNeniZavorka = 2 then
      Prikaz := BAL_PRAVA_ZAVORKA
    else
    begin
      Prikaz := ProgBuff^.pfData[ExecIndex];
      Inc(ExecIndex);
      Dec(ExecCitac);
    end;
    if ZasobNeniZavorka > 0 then Dec(ZasobNeniZavorka);

{ krok }
    if Prikaz = BAL_KROK then with ExecBuff^ do
    begin

      X := sfSloupec-1;
      Y := sfRadek-1;
      Case sfSmer of
        1: Inc(X);
        2: Inc(Y);
        3: Dec(X);
        else Dec(Y);
      end;

      if (X >= 0) and (X < IconXNum) and
         (Y >= 0) and (Y < IconYNum) then
      begin
       { Prikaz := sfData[Y+X*IconYNum];}
        AktIkon(sfSloupec-1,sfRadek-1);
        AktIkon(X,Y);
        AddTime;
        if (ExecRychlost < 8) and ExecVidit and not ExecFast then
        begin
          Case sfSmer of
            1:    ExecSubX := IconWidth/8;
            2:    ExecSubY := IconHeight/8;
            3:    ExecSubX := -IconWidth/8;
            else  ExecSubY := -IconHeight/8;
          end;
          ExecSubXX := X;
          ExecSubYY := Y;
        end
        else { if ExecRychlost }
        begin
          sfSloupec := X+1;
          sfRadek := Y+1;
        end;  { if ExecRychlost }
      end;  { if (X >= 0) }
      Prikaz := -1;
    end;  { if Prikaz = BAL_KROK }

{ vlevo }
    if Prikaz = BAL_VLEVO then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      Dec(sfSmer);
      if sfSmer < 1 then sfSmer := 4;
      AddTimeKey;
      Prikaz := -1;
    end;

{ vpravo }
    if Prikaz = BAL_VPRAVO then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      Inc(sfSmer);
      if sfSmer > 4 then sfSmer := 1;
      AddTimeKey;
      Prikaz := -1;
    end;

{ východ }
    if Prikaz = BAL_VYCHOD then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      sfSmer := 1;
      AddTimeKey;
      Prikaz := -1;
    end;

{ jih }
    if Prikaz = BAL_JIH then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      sfSmer := 2;
      AddTimeKey;
      Prikaz := -1;
    end;

{ západ }
    if Prikaz = BAL_ZAPAD then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      sfSmer := 3;
      AddTimeKey;
      Prikaz := -1;
    end;

{ sever }
    if Prikaz = BAL_SEVER then with ExecBuff^ do
    begin
      AktIkon(sfSloupec-1,sfRadek-1);
      sfSmer := 4;
      AddTimeKey;
      Prikaz := -1;
    end;

{ konec øádku }
    if Prikaz = BAL_CR then
    begin
      Inc(ExecLine);
      if (ExecLine >= ExecTopLine) and ExecFast then
      begin
        FormPaint(Sender);
        ExecFast := False;
      end;
      Prikaz := -1;
    end;

{ prázdné políèko }
    if Prikaz = BAL_NIC then Prikaz := -1;

{ opakování }
    if Prikaz = BAL_KRAT then Prikaz := -1;

{ obláèek vypnout }
    if Prikaz = BAL_CARUJ_VYP then
    begin
      ExecOblak := False;
      Prikaz := -1;
    end;

{ obláèek zapnout }
    if Prikaz = BAL_CARUJ_ZAP then
    begin
      ExecOblak := True;
      Prikaz := -1;
    end;

{ neviditelnost vypnout }
    if Prikaz = BAL_NEVID_VYP then with ExecBuff^ do
    begin
      if not ExecVidit then
      begin
        ExecVidit := True;
        AktIkon(sfSloupec-1,sfRadek-1);
      end;
      Prikaz := -1;
    end;

{ neviditelnost zapnout }
    if Prikaz = BAL_NEVID_ZAP then with ExecBuff^ do
    begin
      if ExecVidit then
      begin
        ExecVidit := False;
        AktIkon(sfSloupec-1,sfRadek-1);
      end;
      Prikaz := -1;
    end;

{ èekání na klávesu }
    if Prikaz = BAL_CEKEJ_KLAV then
    begin
      if not ExecFast then CekaKlavesu := True;
      Prikaz := -1;
    end;

{ pípnutí }
    if Prikaz = BAL_PIPNI then
    begin
      if not ExecFast then MessageBeep(MB_OK);
      Prikaz := -1;
    end;

{ vymazání obrazovky }
    if Prikaz = BAL_VYMAZ then with ExecBuff^, ProgBuff^ do
    begin
      Prikaz := -1;
      while (ExecCitac > 0) and
            (pfData[ExecIndex] >= BAL_0) and
            (pfData[ExecIndex] <= BAL_9) do
      begin
        if Prikaz = -1 then Prikaz := 0;
        Prikaz := Prikaz*10 + pfData[ExecIndex] - BAL_0;
        if Prikaz > HighLongint then Prikaz := HighLongint;
        Dec(ExecCitac);
        Inc(ExecIndex);
      end;
      if Prikaz > 299 then Prikaz := -1;

        for Y := 0 to IconYNum-1 do
          for X := 0 to IconXNum-1 do
            if Prikaz = -1 then
              sfData[Y+X*IconYNum] := BAL_PODKLAD
            else
              if Prikaz < 200 then
                sfData[Y+X*IconYNum] := Prikaz*1000+X+Y*IconXNum+1
              else
                sfData[Y+X*IconYNum] := ProgSceneBuff^.
                  sbScenes[Prikaz-200].sfData[Y+X*IconYNum];

      MazExec;
      AddTimeKey;
      Prikaz := -1;
    end;

{ neplatný øádek }
    if Prikaz = BAL_NEPLATNE then with ProgBuff^ do
    begin
      while (ExecCitac > 0) and
        (pfData[ExecIndex] <> BAL_CR) do
      begin
          Dec(ExecCitac);
          Inc(ExecIndex);
      end;

      Inc(ExecLine);
      if ExecLine >= ExecTopLine then ExecFast := False;
      Prikaz := -1;
    end;

{ èekání po dobu 0.1 sekundy }
    if Prikaz = BAL_CEKEJ_CAS then
    begin
      if not ExecFast then
{        NextTime := NextTime + 100/(24*60*60*1000);}
        NextTime := NextTime + 2;
      Prikaz := -1;
    end;

{ pravá závorka }
    if Prikaz = BAL_PRAVA_ZAVORKA then
    begin
      if ZasobPocet > 0 then with Zasobnik^ do
      begin
        Dec(zasCitac[ZasobPocet-1]);
        if zasCitac[ZasobPocet-1] = 0 then
          Dec(ZasobPocet)
        else
        begin
          ExecIndex := zasIndex[ZasobPocet-1];
          ExecCitac := zasCitProg[ZasobPocet-1];
          ExecLine := zasRadek[ZasobPocet-1];
          if ExecLine >= ExecTopLine then ExecFast := False;
          if ZasobNeniZavorka > 0 then ZasobNeniZavorka := 3;
        end;
      end;
      Prikaz := -1;
    end;

{ levá závorka }
    if Prikaz = BAL_LEVA_ZAVORKA then
    begin
      if ZasobPocet < MaxZasob then with Zasobnik^ do
      begin
        zasCitac[ZasobPocet] := 1;
        zasIndex[ZasobPocet] := ExecIndex;
        zasCitProg[ZasobPocet] := ExecCitac;
        zasRadek[ZasobPocet] := ExecLine;
        Inc(ZasobPocet);
      end;
      Prikaz := -1;
    end;

{ opakování }
    if (Prikaz >= BAL_0) and (Prikaz <= BAL_9) then
    begin
      if ZasobPocet < MaxZasob then with Zasobnik^, ProgBuff^ do
      begin
        Stradac := 1;
        zasCitac[ZasobPocet] := 0;
        repeat
          zasCitac[ZasobPocet] :=
            zasCitac[ZasobPocet]*10 + Prikaz - BAL_0;
          if zasCitac[ZasobPocet] > HighLongint then
            zasCitac[ZasobPocet] := HighLongint;
          repeat
            if ExecCitac > 0 then
            begin
              Prikaz := pfData[ExecIndex];
              Dec(ExecCitac);
              Inc(ExecIndex);
            end
            else Prikaz := BAL_LEVA_ZAVORKA;

            if Prikaz = BAL_CR then
            begin
              Inc(ExecLine);
              if (ExecLine >= ExecTopLine) and ExecFast then
              begin
                FormPaint(Sender);
                ExecFast := False;
              end;
            end;

            if Prikaz = BAL_KRAT then
            begin
              if zasCitac[ZasobPocet] > 0 then
              try
                Stradac := Stradac * zasCitac[ZasobPocet]
              except end;
              if Stradac > HighLongint then
                Stradac := HighLongint;
              zasCitac[ZasobPocet] := 0;
            end;

          until not ((Prikaz = BAL_CR) or
                     (Prikaz = BAL_NIC) or
                     (Prikaz = BAL_KRAT));
        until (Prikaz < BAL_0) or (Prikaz > BAL_9);

        if zasCitac[ZasobPocet] > 0 then
        try
          Stradac := Stradac * zasCitac[ZasobPocet]
        except end;
        if Stradac > HighLongint then
          Stradac := HighLongint;
        zasCitac[ZasobPocet] := Stradac;

        if not (Prikaz = BAL_LEVA_ZAVORKA) then
        begin
          Inc(ExecCitac);
          Dec(ExecIndex);
          ZasobNeniZavorka := 3;
        end
        else ZasobNeniZavorka := 0;

        zasIndex[ZasobPocet] := ExecIndex;
        zasCitProg[ZasobPocet] := ExecCitac;
        zasRadek[ZasobPocet] := ExecLine;
        Inc(ZasobPocet);
      end;
      Prikaz := -1;
    end;

{ nastavení rychlosti }
    if Prikaz = BAL_RYCHLOST then with ProgBuff^ do
    begin
      if ExecCitac > 0 then Prikaz := pfData[ExecIndex];
      Prikaz := Prikaz - BAL_0;
      if (Prikaz >= 0) and (Prikaz <= 9) then
      begin
        Dec(ExecCitac);
        Inc(ExecIndex);
        ExecRychlost := Prikaz;
        if (Prikaz = 9) and ExecVidit then
        begin
         { ExecVidit := False; }
          AktIkon(ExecBuff^.sfSloupec-1,ExecBuff^.sfRadek-1);
        end;
      end;
      Prikaz := -1;
    end;

{ obsluha èarování - musí být uvedena jako poslední !!! }
    if Prikaz <> -1 then with ExecBuff^, ProgBuff^ do
    begin
      X := sfSloupec-1;
      Y := sfRadek-1;
      Case sfSmer of
        1: Inc(X);
        2: Inc(Y);
        3: Dec(X);
        else Dec(Y);
      end;

      if (X >= 0) and (X < IconXNum) and
         (Y >= 0) and (Y < IconYNum) then
      begin
        AktIkon(X,Y);
        if not ExecFast then
          if ExecOblak then
          begin
            if ExecVidit and (ExecRychlost < 9) then
              AktIkon(sfSloupec-1,sfRadek-1);
            ExecSubC := 1;
            ExecSubCX := X;
            ExecSubCY := Y;
            AddTime;
            ExecPredmet := Prikaz;
          end
          else
          begin
            sfData[Y+X*IconYNum] := Prikaz;
            MaskIconExec(Prikaz,X,Y);
            AddTimeKey;
          end;
      end;
    end;


  end;  { obsluha pøíkazù }

{ ukonèení opakovacího cyklu }
  Inc(Pokusu);

end;

{ pøekreslení obrazovky }
  ExecDisp;
  TimerAktiv := False;
end;

procedure TExecForm.FormPaint(Sender: TObject);
begin
  ZmenaLeft := 0;
  ZmenaTop := 0;
  ZmenaRight := IconWidth*IconXNum;
  ZmenaBottom := IconHeight*IconYNum;
  ExecDisp;
end;

procedure TExecForm.ExecDisp;
var LRect,DRect: TRect;
begin
  if (ZmenaLeft < ZmenaRight) and
     (ZmenaTop < ZmenaBottom) and
     not ExecFast then
  begin
    LRect := Rect(ZmenaLeft,ZmenaTop,ZmenaRight,ZmenaBottom);
    DRect := Rect(ZmenaLeft+ExecRamLeft,ZmenaTop+ExecRamTop,
                 ZmenaRight+ExecRamLeft,ZmenaBottom+ExecRamTop);
    if ExecVidit and (ExecRychlost < 9) or (ExecSubC > 0) then
    begin
      ExecTempBitmap.Canvas.CopyRect(LRect,ExecBitmap.Canvas,LRect);
      DispBaltExec(ExecTempBitmap.Canvas);
      ExecForm.Canvas.CopyRect(DRect,ExecTempBitmap.Canvas,LRect);
    end
    else
      ExecForm.Canvas.CopyRect(DRect,ExecBitmap.Canvas,LRect);

    ZmenaLeft := IconWidth*IconXNum;
    ZmenaTop := IconHeight*IconYNum;
    ZmenaRight := 0;
    ZmenaBottom := 0;
  end;
end;

procedure TExecForm.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

end.
