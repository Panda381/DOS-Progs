uses dos;
const
  hx:array[0..15] of char='0123456789ABCDEF';
var
  x,y:word;
  f:file;
  t:text;
  rp:registers;


function hex4(w:word):string;
begin
  hex4:=hx[w shr 12]+hx[hi(w) and 15]+hx[lo(w) shr 4]+hx[w and 15];
end;

begin
  x:=$c000;
  while x<$f000 do
  begin
    if memw[x:0]=$aa55 then
    begin
      y:=mem[x:2];
      assign(f,'dmp'+hex4(x)+'.rom');
      rewrite(f,512);
      if y>63 then
      begin
        blockwrite(f,mem[x:0],64);
        inc(x,2048);
        dec(y,64);
      end;
      blockwrite(f,mem[x:0],y);
      close(f);
      inc(x,y shl 5);
    end
    else inc(x,128);
  end;
  assign(t,'vectors.rom');
  rewrite(t);
  writeln(t,'INT 10h = '+hex4(memw[0:$42])+':'+hex4(memw[0:$40]));
  writeln(t,'INT 6Dh = '+hex4(memw[0:$1b6])+':'+hex4(memw[0:$1b4]));
  writeln(t,'State Table = '+hex4(memw[0:$4aa])+':'+hex4(memw[0:$4a8]));
  for x:=0 to 7 do
  begin
    rp.ax:=$1130;
    rp.bh:=x;
    intr(16,rp);
    writeln(t,'FNT'+chr(x+48)+' = '+hex4(rp.es)+':'+hex4(rp.bp));
  end;
  close(t);
end.