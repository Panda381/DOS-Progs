{ example for GetDriverName }

uses
  Graph;
var
  Driver, Mode : integer;

begin
  Driver := Detect;                           { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);
  OutText('Using driver ' + GetDriverName);
  Readln;
  Closegraph;
end.
