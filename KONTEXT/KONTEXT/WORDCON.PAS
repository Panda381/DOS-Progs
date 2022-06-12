(* ==========================================================================*)
(*                    Konvertierung Wordstar ---> CONTEXT                    *)
(* ==========================================================================*)

(* Beim Aufruf kann als Kommandoparameter ein U Åbergeben werden, falls der  *)
(* Text mit den Wordstar-Versionen 3.1 - 3.3 oder CP/M-Wordstar erstellt     *)
(* wurde. In diesem Fall werden die Umlaute an den IBM-Zeichensatz angepa·t. *)
(* Ab Wordstar 3.4 ist das nicht mehr erforderlich.                          *)

var wf: File of Char;                (* Wordstar-File *)
    cf: Text[4096];                  (* CONTEXT-File *)
    ch,tc: Char;
    wsname,conname: String[64];      (* Dateinamen *)
    VersStr: String[20];             (* Wordstar Versionsangabe *)
    conline: String[255];            (* CONTEXT-Zeile *)
    clg: byte absolute conline;      (* LÑnge ConLine *)
    count: Integer;                  (* ZeilenzÑhler *)
    uflag: Boolean;                  (* Flag fÅr Umlaute konvertieren *)


Procedure GetChar;
          (* Liest ein Zeichen aus dem WS-File *)

begin
   if eof(wf) then ch := #26 else read(wf,ch);
end;


Procedure NewLine;
          (* CONTEXT-Zeile wegschreiben *)
          var flag: Boolean;

begin
   flag := conline[clg] = #17;           (* Absatzendmarkierung gesetzt ? *)
                         (* Unnîtige Blanks und Steuerzeichen entfernen *)
   while (conline[clg] <= #32) and (clg > 0) do clg := pred(clg);
                          (* Eventuell Absatzendmarkierung ergÑnzen *)
   if flag and (clg > 0) then conline := conline + #17;
   writeln(cf,conline); conline := '';
   count := succ(count);
   gotoxy(1,8); write('Zeilen:',count:6);
end;


Procedure PutChar(c: Char);
          (* Zeichen an CONTEXT-Zeile anhÑngen *)

begin
   if clg = 254 then NewLine;
   conline := conline + c;
end;



Procedure UConvert(var ch: Char);
          (* Konvertiert Umlaute und ·, falls der Text mit den
             Wordstar-Versionen 3.1..3.3 oder CP/M-Wordstar erstellt wurde *)
begin
   case ch of
      '@': ch := #21;    (* Paragraphenzeichen *)
      '[': ch := 'é';
      '\': ch := 'ô';
      ']': ch := 'ö';
      '{': ch := 'Ñ';
      '|': ch := 'î';
      '}': ch := 'Å';
      '~': ch := '·';
   end;
end;



begin (* Main *)

   if ParamCount > 0 then   (* Sollen Umlaute konvertiert werden? *)
      uflag := ((ParamStr(1) = 'u') or (ParamStr(1) = 'U'))
   else uflag := false;
   if uflag then VersStr := '3.1 - 3.3' else VersStr := '3.4';

   ClrScr; Writeln;
   writeln('*****  Konvertierung Wordstar ',VersStr,' ---> CONTEXT  *****');
   Writeln;
   write('Name der Wordstar-Datei: '); readln(wsname);
   writeln;
   write('Name der CONTEXT-Datei: '); readln(conname);
   writeln;
   assign(wf,wsname); assign(cf,conname);
   reset(wf); rewrite(cf);
   conline := ''; count := 0;
   repeat
      GetChar;
      if ch = #141 then begin                (* Soft Return *)
         NewLine; ch := #0;
      end;
      ch := chr(ord(ch) and $7F);            (* Bit 7 zurÅcksetzen *)
      case ch of
         #2:  PutChar(#4);     (* Fettschrift *)
         #4:  PutChar(#4);     (* Doppelanschlag -> Fettschrift *)
         #19: PutChar(#3);     (* Unterstreichen *)
         #20: PutChar(#0);     (* Exponent *)
         #22: PutChar(#1);     (* Index *)
         #13: begin PutChar(#17); NewLine; end;    (* Hard Return *)
         #27: begin GetChar; PutChar(ch); end;     (* IBM-Zeichen folgt *)
         #30: begin                                (* Trennfuge *)
                tc := conline[clg]; conline[clg] := #6;
                PutChar(tc); PutChar(#6);
              end;
         #31: begin PutChar(#6); PutChar('-'); end;   (* weicher Trennstrich *)
         #32..#126: begin                             (* normales Zeichen *)
                      if uflag then UConvert(ch);
                      PutChar(ch);
                    end;
      end;
   until ch = #26;                                    (* EOF *)
   NewLine;
   close(wf); close(cf);
   writeln; writeln;
   writeln('Konvertierung beendet');
end.
