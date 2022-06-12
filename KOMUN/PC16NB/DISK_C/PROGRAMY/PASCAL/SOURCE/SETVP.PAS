uses Graph;
const
  vp1 : ViewPortType =
    (x1: 10; y1: 80; x2: 100; y2: 150; Clip : ClipOn);
  vp2 : ViewPortType =
    (x1: 110; y1: 0; x2: 200; y2:  70; Clip : ClipOn);
var
  GraphDriver, GraphMode : integer;

begin
  GraphDriver := Detect;
  InitGraph(GraphDriver,GraphMode,'');
  if GraphResult <> grOk then
    Halt(1);
  with vp1 do
  begin
    Rectangle(Succ(x1),Succ(y1), { Outline viewport 1 }
              Pred(x2),Pred(y2));
    SetViewPort(x1, y1, x2, y2, ClipOn);
    OutText('ViewPort1');
  end;

  { Full screen }
  SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOn);
  with vp2 do
  begin
    { Outline viewport 2 }
    Rectangle(Succ(x1),Succ(y1),
              Pred(x2),Pred(y2));
    SetViewPort(x1, y1, x2, y2, ClipOn);
    OutText('ViewPort2');
  end;
  Readln;
  CloseGraph;
end.