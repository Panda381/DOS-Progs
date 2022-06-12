{ example for Sector }

uses
  Graph;
const
  R = 50;
var
  Driver, Mode : Integer;
  Xasp, Yasp : Word;

begin
  Driver := Detect;                         { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);

  Sector(GetMaxX div 2, GetMaxY div 2, 0, 45, R, R); { draw sector }

  GetAspectRatio(Xasp, Yasp);               { draw circular sector }
  Sector(GetMaxX div 2, GetMaxY div 2,              { center point }
             180, 135,                        { mirror angle above }
             R, R * LongInt(Xasp) div Yasp);            { circular }

  Readln;
  Closegraph;
end.
