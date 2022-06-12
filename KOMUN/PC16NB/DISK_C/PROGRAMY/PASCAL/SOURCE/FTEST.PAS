program mkfile;
type rec=record
          name: string[12];
          emp: integer;
          result: 0..100;
          nxtres: 0..100;
          avg: real
         end;
var S: rec;
    nxt:char;
    iofile: file of rec;

begin
 Assign(iofile, '..\lsd\test.dat');
 rewrite(iofile);
 write('Name [10]: ');readln(S.name);
 while S.name<>'' do
 begin
  write('Emp.number: ');readln(S.emp);
  write('Result '); readln(S.result);
  write('NxtRes: ');readln(S.nxtres);
  S.avg:=(S.result+S.nxtres)/2.0;
  write(iofile,S);
  write('Name [10]: '); readln(S.name)
end;
Close(iofile); write('test over');
end.