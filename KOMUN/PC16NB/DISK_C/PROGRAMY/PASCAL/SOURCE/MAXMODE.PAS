{ example for GetMaxMode &&&& GetModeName }

uses
  Graph;
var
  Driver, Mode : Integer;
  i : Integer;
begin
  Driver := Detect;                { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);
  for i := 0 to GetMaxMode do      { display all the mode names }
    OutTextXY(10, 10 * Succ(i), GetModeName(i));
  Readln;
  Closegraph;
end.
