{ Example for FillEllipse }

uses
  Graph;
const
  R = 30;
var
  Driver, Mode : Integer;
  Xasp, Yasp : Word;
begin
  Driver := Detect;                    { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);

  FillEllipse(GetMaxX div 2, GetMaxY div 2, 50, 50); { draw ellipse }

  GetAspectRatio(Xasp, Yasp);
  FillEllipse(R, R, R, R * LongInt(Xasp) div Yasp);  { circular ellipse }

  Readln;
  Closegraph;
end.
