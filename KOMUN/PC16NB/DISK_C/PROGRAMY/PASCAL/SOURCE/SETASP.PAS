{ Example for SetAspectRatio }

uses
  Crt, Graph;
const
  R = 50;
var
  Driver, Mode : Integer;
  Xasp, Yasp : Word;
begin
  DirectVideo := false;
  Driver := Detect;                    { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);
  GetAspectRatio(Xasp, Yasp);          { Get default aspect ratio }
  { adjust for VGA and 8514, they have 1:1 aspect }
  if Xasp = Yasp then
    Yasp := 5 * Xasp;
  { Keep modifying aspect ratio until 1:1 or a key is pressed }
  while (Xasp < Yasp) and not KeyPressed do
  begin
    SetAspectRatio(Xasp, Yasp);
    Circle(GetMaxX div 2, GetMaxY div 2, R);
    Inc(Xasp, 20);
  end;
  SetTextJustify(CenterText, CenterText);
  OutTextXY(GetMaxX div 2, GetMaxY div 2, 'Done!');
  Readln;
  Closegraph;
end.
