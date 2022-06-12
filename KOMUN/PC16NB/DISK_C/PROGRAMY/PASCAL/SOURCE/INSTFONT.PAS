{ example for InstallUserFont }

uses
  Graph;
var
  Driver, Mode : Integer;
  TestFont : Integer;
begin
  TestFont := InstallUserFont('TEST');         { Install the font }
  if GraphResult <> grOk then
  begin
    Writeln('Error installing TestFont (using DefaultFont)');
    Readln;
  end;
  Driver := Detect;                            { Put in graphics mode }
  Mode := 0;
  InitGraph(Driver, Mode, '');
  if GraphResult <> grOk then
    Halt(1);
  SetTextStyle(TestFont, HorizDir, 2);         { Use new font }
  OutText('Installable fonts supported...');
  Readln;
  Closegraph;
end.
