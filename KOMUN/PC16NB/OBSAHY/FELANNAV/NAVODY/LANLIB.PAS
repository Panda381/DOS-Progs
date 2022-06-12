unit lanlib;
(* Pascalsk‚ u‘ivatelsk‚ rozhran¡ komunika‡n¡ho ovlada‡e s¡tˆ FELAN *)
(* verze 2. 6. 1989                    M. B¡l˜, VS €VUT FEL         *)
interface
const
  er_busy = 255;	(* p©¡kaz se prov d¡
  er_formal = 1;	(* form ln¡ chyba po‘adavku *)
  er_alr_rec= 2;	(* nˆjak˜ po‘adovan˜ typ zpr v ji‘ nˆkdo p©ij¡m  *)
  er_norr   = 3;	(* p©¡li¨ mnoho po‘adavk– na trval˜ p©¡jem *)
  er_inv_rr = 4;	(* RCB nebyl uveden ve funkci 10 *)
  er_maxl   = 5;	(* chybn  d‚lka zpr vy - nula nebo v¡ce ne‘ 591 *)
  er_notr   = 6;	(* pr¡li¨ mnoho po‘adavk– na vys¡l n¡ *)
  er_noack  = 7;  	(* nebylo p©ijato vy‘ dan‚ potvrzen¡ *)
  er_trunc  = 8;        (* vymezen˜ buffer je kr tk˜, zpr va byla o©¡znuta *)
  er_tmout  = 9;        (* time-out pro p©¡jem nebo vys¡l n¡ *)

type

 SCB = record
	 s_reply: byte;            (* byte odpovˆdi *)
	 s_reserve: byte;          (* rezervov no *)
	 s_rqack: byte;		   (* ‘ dost o potvrzen¡ p©¡jmu *)
	 s_tmout: byte;		   (* time-out pro vys¡l n¡ *)
	 s_future: byte;	   (* adresa s¡tˆ odesilatele zpr vy *)
	 s_adrto: byte;		   (* adres t *)
	 s_len: word;		   (* d‚lka zpr vy  v bufferu *)
	 s_buf: pointer;           (* adresa bufferu *)
      end;

 RCB = record
	 r_reply: byte;            (* byte odpovˆdi *)
	 r_reserve: byte;	   (* rezervov no *)
	 r_min, r_max: byte;       (* rozsah p©ij¡man˜ch typ– zpr v *)
	 r_rcvd: byte;		   (* po‡et p©ijat˜ch a nep©evzatat˜ch zpr v *)
	 r_tmout: byte;		   (* time-out pro p©¡jem *)
	 r_future: byte;	   (* adresa s¡tˆ p©¡jemce *)
	 r_adrfrom: byte;          (* adresa odesilatele *)
	 r_len: word;              (* velikost bufferu - d‚lka zpr vy *)
	 r_buf: pointer;           (* adresa bufferu *)
      end;

procedure LAN_SEND    (var users_scb: scb);  (* vysl n¡ zpr vy *)
procedure LAN_RECREQ  (var users_rcb: rcb);  (* ‘ dost trval‚ho p©¡jmu *)
procedure LAN_RECEIVE (var users_rcb: rcb);  (* odebr n¡ p©ijat‚ zpr vy *)
procedure LAN_RECEND  (var users_rcb: rcb);  (* zru¨en¡ trval‚ho p©¡jmu *)

(* ************************************************************************* *)

implementation
uses dos;
const
  felan_int = $48;

  send    =   0;
  recreq  = $10;
  receive = $11;
  recend  = $12;

var reg: registers;

procedure LAN_SEND;
begin
  with reg do begin
    ah := send;
    es := seg(users_scb);
    bx := ofs(users_scb);
  end;
  intr(felan_int,reg);
end;

procedure LAN_RECREQ;
begin
  with reg do begin
    ah := recreq;
    es := seg(users_rcb);
    bx := ofs(users_rcb);
  end;
  intr(felan_int,reg);
end;

procedure LAN_RECEIVE;
begin
  with reg do begin
    ah := receive;
    es := seg(users_rcb);
    bx := ofs(users_rcb);
  end;
  intr(felan_int,reg);
end;

procedure LAN_RECEND;
begin
  with reg do begin
    ah := recend;
    es := seg(users_rcb);
    bx := ofs(users_rcb);
  end;
  intr(felan_int,reg);
end;

end.
