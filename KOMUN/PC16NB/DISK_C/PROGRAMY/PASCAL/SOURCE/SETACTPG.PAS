uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  if (Gd = HercMono) or (Gd = EGA) or
     (Gd = EGA64)    or (Gd = VGA) then
    begin
      SetVisualPage(0);
      SetActivePage(1);
      Rectangle(10, 20, 30, 40);
      SetVisualPage(1);
    end
  else
    OutText('No paging supported.');
  Readln;
  CloseGraph;
end.