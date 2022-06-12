unit userlan;
(* U‘ivatelsk‚ rozhran¡ komunika‡n¡ho ovlada‡e s¡tˆ FELAN     *)
(* verze 3.11.1990              J.Ka¨par, KP FEL €VUT         *)
interface
type
buffer = record
	   address : word ;			(* adresa uzlu *)
	   length : word ;			(* d‚lka paketu v‡etnˆ typu *)
	   messagetype : byte ;			(* typ paketu *)
	   message : array [1..590] of byte ;	(* data *)
	 end ;

function MYaddress : word ;		       (* dod  adresu vlastn¡ho uzlu *)
function OPENLINE ( min,max : byte ) : integer ;
                           (* otev©en¡ kan lu - povol¡ p©¡jem paket– min..max*)
				(* 0 -> O.K.
				   1 -> chybn  ‡¡sla typu paketu
				   2 -> po‘adovan‚ typy paket– ji‘ nˆkdo p©ij¡m 
				   3 -> p©¡li¨ mnoho ‘ dost¡ o p©¡jem
				   7 -> druh‚ vol n¡ OPENLINE bez p©edchoz¡ho
						CLOSELINE *)
function RECEIVED : BOOLEAN ;	      (* je paket p©ijat ale dosud neodebr n? *)
function RECEIVE ( var buf : buffer ) : integer ;(* odebr n¡ p©ijat‚ho paketu *)
				(* 0 -> O.K.
				   4 -> nebyla provedena funkce OPENLINE
				   8 -> p©ijat  zpr va je del¨¡ ne‘ buffer
						- byla o©¡znuta
				   9 -> timeout *)
procedure CLOSELINE ;		  (* uzav©en¡ kan lu - zru¨en¡ p©¡jmu *)
function SEND ( var buf : buffer ) : integer ;	       (* vysl n¡ paketu *)
				(* 0 -> O.K.
				   1 -> chybn˜ typ paketu
				   4 -> nebyla provedena funkce OPENLINE
				   5 -> chybn  d‚lka paketu
				   6 -> chybn˜ adres t *)
function BROADCAST ( var buf : buffer ) : integer ;    (* vysl n¡ paketu v¨em *)
				(* 0 -> O.K.
				   1 -> chybn˜ typ paketu
				   4 -> nebyla provedena funkce OPENLINE
				   5 -> chybn  d‚lka paketu *)

(* ************************************************************************* *)

implementation
uses dos;
type

 SCB = record			(* SEND CONTROLL BLOCK		*)
	 result : byte;		(* v˜sledek operace		*)
	 flag : byte;		(* rezervov no			*)
	 rqack : byte;		(* ‘ dost o potvrzen¡ p©¡jmu	*)
	 timeout : byte;	(* timeout			*)
	 address_to : word;	(* adres t			*)
	 length : word;		(* d‚lka zpr vy  v bufferu	*)
	 buffer : pointer;	(* adresa bufferu		*)
      end;

 RCB = record			(* RECEIVE CONTROLL BLOCK	*)
	 result : byte ;	(* v˜sledek operace		*)
	 flag : byte ;		(* rezervov no			*)
	 min, max : byte ;	(* rozsah p©ij¡man˜ch typ– zpr v *)
	 received : byte ;	(* po‡et p©ijat˜ch a nep©evzat˜ch zpr v *)
	 timeout : byte;	(* timeout			*)
	 address_from : word;	(* odes¡latel			*)
	 length : word;		(* d‚lka zpr vy  v bufferu	*)
	 buffer : pointer;	(* adresa bufferu		*)
      end;

var
  q : registers;
  s : scb ;
  r : rcb ;
const
  listening : boolean = false ;

function SEND ( var buf : buffer ) : integer ;	       (* vysl n¡ paketu *)
begin
  if not listening
  then SEND := 4
  else
  if (lo(buf.address) > 250) or (hi(buf.address) > 250)
  then SEND := 6
  else
  if not buf.messagetype in [r.min..r.max]
  then SEND := 1
  else
  with q do
  begin
    s.rqack := 0 ;
    s.length := buf.length ;
    s.buffer := @buf.messagetype ;
    s.address_to := $100 * buf.address ;
    ah := $1 ;
    es := seg(s) ;
    bx := ofs(s) ;
    intr($48,q) ;
    while s.result = 255 do ;
    SEND := s.result ;
  end ;
end ;

function BROADCAST ( var buf : buffer ) : integer ;    (* vysl n¡ paketu v¨em *)
begin
  if not listening then BROADCAST := 4
  else
  if not buf.messagetype in [r.min..r.max]
  then BROADCAST := 1
  else
  with q do
  begin
    s.rqack := 0 ;
    s.length := buf.length ;
    s.buffer := @buf.messagetype ;
    s.address_to := $FF00 ;
    ah := $1 ;
    es := seg(s) ;
    bx := ofs(s) ;
    intr($48,q) ;
    while s.result = 255 do ;
    BROADCAST := s.result ;
  end ;
end ;

function OPENLINE ( min,max : byte ) : integer ;  (* otev©en¡ kan lu *)
begin
  if listening
  then OPENLINE := 7
  else
  if [MIN..MAX] * [160..239] = []
  then OPENLINE := 1
  else
  with q do
  begin
    with r do
      begin
        flag := 0 ;
        timeout := 0 ;
        received := 0 ;
      end ;
    with s do
      begin
        flag := 0 ;
        timeout := $ff ;
        rqack := 0 ;
      end ;
    r.min := min ;
    r.max := max ;
    ah := $10 ;
    es := seg(r) ;
    bx := ofs(r) ;
    intr($48,q) ;
    OPENLINE := q.al ;
    listening := true ;
  end ;
end ;

function RECEIVED : BOOLEAN ;         (* je paket p©ijat ale dosud neodebr n? *)
begin
  RECEIVED := r.received > 0 ;
end ;

function RECEIVE ( var buf : buffer ) : integer ;(* odebr n¡ p©ijat‚ho paketu *)
begin
  with q do
  begin
    r.length := 591 ;
    r.buffer := @buf.messagetype ;
    ah := $11 ;
    es := seg(r) ;
    bx := ofs(r) ;
    intr($48,q) ;
    while r.result = 255 do ;
    RECEIVE := r.result ;
    buf.address  := hi(r.address_from) ;
    buf.length := r.length ;
  end ;
end ;

procedure CLOSELINE ;		  (* uzav©en¡ kan lu - zru¨en¡ p©¡jmu *)
begin
  if listening then
  with q do
  begin
    ah := $12 ;
    es := seg(r) ;
    bx := ofs(r) ;
    intr($48,q) ;
    listening := false ;
  end ;
end ;

function MYaddress : word ;			       (* dod  vlastn¡ adresu *)
begin
  q.ah := 2 ;
  intr($48,q) ;
  MYaddress := mem[q.es:q.bx+10] ;
end ;

end.
