{ example for SetRGBPalette }

uses
  Graph;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal : Integer;
  end;
const
  EGAColors : array[0..MaxColors] of RGBRec =
    (                                             { NAME       COLOR  }
     ( RedVal:$00;  GreenVal:$00;  BlueVal:$00 ), { Black      EGA  0 }
     ( RedVal:$00;  GreenVal:$00;  BlueVal:$fc ), { Blue       EGA  1 }
     ( RedVal:$24;  GreenVal:$fc;  BlueVal:$24 ), { Green      EGA  2 }
     ( RedVal:$00;  GreenVal:$fc;  BlueVal:$fc ), { Cyan       EGA  3 }
     ( RedVal:$fc;  GreenVal:$14;  BlueVal:$14 ), { Red        EGA  4 }
     ( RedVal:$b0;  GreenVal:$00;  BlueVal:$fc ), { Magenta    EGA  5 }
     ( RedVal:$70;  GreenVal:$48;  BlueVal:$00 ), { Brown      EGA 20 }
     ( RedVal:$c4;  GreenVal:$c4;  BlueVal:$c4 ), { White      EGA  7 }
     ( RedVal:$34;  GreenVal:$34;  BlueVal:$34 ), { Gray       EGA 56 }
     ( RedVal:$00;  GreenVal:$00;  BlueVal:$70 ), { Lt Blue    EGA 57 }
     ( RedVal:$00;  GreenVal:$70;  BlueVal:$00 ), { Lt Green   EGA 58 }
     ( RedVal:$00;  GreenVal:$70;  BlueVal:$70 ), { Lt Cyan    EGA 59 }
     ( RedVal:$70;  GreenVal:$00;  BlueVal:$00 ), { Lt Red     EGA 60 }
     ( RedVal:$70;  GreenVal:$00;  BlueVal:$70 ), { Lt Magenta EGA 61 }
     ( RedVal:$fc;  GreenVal:$fc;  BlueVal:$24 ), { Yellow     EGA 62 }
     ( RedVal:$fc;  GreenVal:$fc;  BlueVal:$fc )  { Br. White  EGA 63 }
    );
var
  Driver, Mode,
  i : Integer;

begin
  Driver := IBM8514;                              { Override detection }
  Mode := IBM8514Hi;
  InitGraph(Driver, Mode, '');                 { Put in graphics mode }
  if GraphResult < 0 then
    Halt(1);

  { Zero palette, make all graphics output invisible }
  for i := 0 to MaxColors do
    with EGAColors[i] do
      SetRGBPalette(i, 0, 0, 0);

  { Display something }
  for i := i to MaxColors do     { Change 1st 16 8514 palette entries }
  begin
    SetColor(i);
    OutTextXY(10, i * 10, ' ..Press any key.. ');
  end;

  { Restore default EGA colors to 8514 palette }
  for i := 0 to MaxColors do
    with EGAColors[i] do
      SetRGBPalette(i, RedVal, GreenVal, BlueVal);

  Readln;
  Closegraph;
end.
