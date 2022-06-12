program broadcasting(output) ;
uses crt,userlan ;
const
  msgnumber = 239 ;			(* ‡¡slo pou‘¡van‚ zpr vy *)
var
  rb,sb : buffer ;	(* vyrovn vac¡ pamˆti pro p©¡jem a vys¡l n¡ *)
  stop : boolean ;
  k : char ;
  i,e : integer ;
begin
  writeln ;
  writeln('FELAN : BROADCAST              (C) JK KP FEL CVUT,1990 ') ;
  writeln('NODE : ',MYaddress) ;
  writeln ;
  writeln('Help :') ;
  writeln ;
  writeln('<RETURN>  ->  send message') ;
  writeln(' <ESC>    ->  end of run') ;
  writeln ;
  writeln ;
  write('BRO> ') ;			(* prompt *)
  sb.length := 1 ;			(* vypr zdnˆn¡ vys¡lac¡ho bufferu *)
  sb.messagetype := msgnumber ;		(* typ (‡¡slo) odes¡lan˜ch zpr v *)
  stop := false ;
  e := openline ( msgnumber,msgnumber ) ;
			(* chceme p©ij¡mat zpr vy ‡.250 *)
  if e <> 0 then
      writeln('OPENLINE ERROR ',E) ;
  while not stop do
  begin
    if keypressed then
    begin				(* byla stisknuta kl vesa *)
      k := readkey ;			(* k¢d stisknut‚ kl vesy *)
      if k = chr(0) then  k := readkey	(* speci ln¡ kl vesa *)
      else				(* oby‡ejn  kl vesa *)
      with sb do
      begin
        if length > 560 then k := chr($0d) ;  (* konec bufferu - jako return *)
        if ord(k) in [0..$1f] then	(* nezobraziteln˜ znak *)
          case ord(k) of
          $0d: begin			(* return -> odesl n¡ zpr vy *)
                 writeln ;
                 e := BROADCAST(sb) ;	(* vys¡lej zpr vu pro v¨echny *)
                 if e <> 0		(* do¨lo k chybˆ p©i vys¡l n¡ ? *)
                   then writeln('BROADCAST ERROR ',E)	(* ano *)
                   else writeln('MESSAGE SENT') ;	(* ne *)
                 length := 1 ;		(* vypr zdnˆn¡ vys¡lac¡ho bufferu *)
                 write('BRO> ') ;	(* prompt *)
               end ;
          $1B: stop := true ;		(* ESC -> konec *)
          else ;
          end
        else
        begin
          write(k) ;			(* echo na obrazovku *)
          message[length] := ord(k) ;	(* p©id n¡ znaku na konec zpr vy *)
          length := length + 1 ;	(* zpr va bude o 1 znak del¨¡ *)
        end ;
      end ;
    end ;
    if received then			(* nˆco n m p©i¨lo *)
    begin
      e := receive(rb) ;		(* p©e‡ten¡ zpr vy *)
      if e <> 0				(* do¨lo k chybˆ p©i ‡ten¡ zpr vy ? *)
        then writeln('RECEIVE ERROR ',E)	(* ano *)
        else					(* bez chyb *)
        with rb do
        if address <> MYaddress then	(* mnou odeslan‚ zpr vy se nevypisuj¡ *)
        begin
          writeln ;
          writeln('MESSAGE FROM NODE ',address,':') ;
          for i := 1 to length - 1 do write(chr(message[i])) ;
          writeln ;			(* opis p©ijat‚ zpr vy na obrazovku *)
          write('BRO> ') ;		(* prompt *)
          if sb.length <> 1 then	(* obnoven¡ rozepsan‚ zpr vy *)
            for i := 1 to sb.length - 1 do write(chr(sb.message[i])) ;
        end ;
    end ;
  end ;
  closeline ;			(* ukon‡en¡ p©¡jmu zpr v *)
end.
