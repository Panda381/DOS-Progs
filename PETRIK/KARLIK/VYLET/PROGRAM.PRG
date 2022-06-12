
(*============================ definice promØnnìch ==========================*)

# Auto_Stop                                      (* Ÿ¡taŸ zastaven¡ autobusu *)
# Cit_Mav                                        (* Ÿ¡taŸ pro m v n¡ Karla   *)

(*============================ definice pý¡kaz… =============================*)

! Dal   (y=y+1 x=0 sever)                        (* pý¡prava pro dalç¡ ý dek *)
! Ukrok (p j ~zed k l)                           (* £krok doprava            *)

(*-------------------------- kreslen¡ domku ---------------------------------*)

                         (* kreslen¡ oblohy *)
! Sl    (Slunce Ukrok)                           (* slunce                   *)
! Ob    (Obloha Ukrok)                           (* obloha                   *)
! Mr    (Mrak Ukrok)                             (* mrak                     *)

                        (* kreslen¡ domku *)
! Dv    (Dvere Ukrok)                            (* dveýe                    *)
! Ok    (Okno Ukrok)                             (* okno                     *)
! Ok2   (Okno2 Ukrok)                            (* okno s kvØtinami         *)
! Ste   (Stena Ukrok)                            (* stØna                    *)
! OkS   (Ok2 Ste Ok)                             (* okno2, stØna a okno      *)

                    (* kreslen¡ stýechy domku *)
! Str   (Strecha Ukrok)                          (* stýecha                  *)
! StL   (StrechaL Ukrok)                         (* stýecha vlevo            *)
! StP   (StrechaP Ukrok)                         (* stýecha vpravo           *)

                        (* kreslen¡ plotu *)
! Pl    (Plot Ukrok)                             (* plot                     *)
! PlS   (PlotStrm Ukrok)                         (* strom za plotem          *)
! Pl2   (Pl PlS Pl)                              (* plot, strom a plot       *)

                     (* nakreslen¡ domku a oblohy *)
! Kresli_Domek
( r
 Dal 2 Ob Mr 11 Ob Mr Ob Sl Ob                   (* 1. ý dek - obloha+slunce *)
 Dal 7 Ob Mr 4 Ob Mr 5 Ob                        (* 2. ý dek - obloha        *)
 Dal Mr 4 Ob StL 7 Str StP 5 Ob                  (* 3. ý dek - stýecha       *)
 Dal 3 Ob Mr Ob Ok Ste OkS Ste OkS 3 Ob Mr       (* 4. ý dek - patro domku   *)
 Dal 2 Ob Pl2 OkS Ste Dv Ste Ok Ste Ok2 Pl2 2 Ob (* 5. ý dek - pý¡zem¡       *)
)

(*-------------------------- kreslen¡ tr vn¡ku ------------------------------*)

                          (* nakreslen¡ tr vn¡ku *)
! Kresli_Travnik
( r
 Dal 18 (Travnik Ukrok)
)

                       (* nakreslen¡ tr vn¡ku shora *)
! Kresli_Travnik2
( r
 y=y-1 x=17 jih 18 (Travnik Ukrok)
)

(*-------------------------- kreslen¡ silnice -------------------------------*)

! Kresli_Cestu                                   (* nakreslen¡ cesty         *)
( r
 Dal 18 (Cesta Ukrok)
 Dal 18 (Cesta2 Ukrok)
)

(*------------------------------ obsluha aut --------------------------------*)
(* Obsluha aut pou§¡v  2 tabulky:  ^600 a§ ^617 .... mapa doln¡ silnice      *)
(*                                 ^700 a§ ^717 .... mapa horn¡ silnice      *)
(* Tabulky obsahuj¡ pý¡znaky: 0=pr zdn  plocha, 1 a§ 4=Ÿ¡slo auta, 9=autobus *)

                         (* vytvoýen¡ nov‚ho auta *)
! Nove_Auto
( r
 j nahoda 25 = 1 a ^600=0 (^600=9 x=0 y=9 sever m Autobus)
 j nahoda 14 = 1 a ^600=0 (j nahoda 2 = 1
                                (^600=1 x=0 y=9 sever m Auto1)
                           i
                                (^600=3 x=0 y=9 sever m Auto3)
                           )
 j nahoda 20 = 1 a ^717=0 (j nahoda 2 = 1
                                 (^717=2 x=17 y=8 sever m Auto2)
                           i
                                 (^717=4 x=17 y=8 sever m Auto4)
                           )
)

                          (* obsluha pohybu aut *)

! Jedou_Auta
( r
 x=17 y=9 sever j ~ ^617=0 (^617=0 obnov)        (* vymaz n¡ auta na konci 1 *)
 $=17 17(x=x-1 $=$-1                             (* posun ukazatel… cyklu    *)
           j ^(600+$)=1 a ^(600+$+1)=0 (         (* je na pozici auto ?      *)
               (obnov p k l m Auto1 l k p)       (* posun auta vpravo        *)
               ^(600+$)=0 ^(600+$+1)=1           (* posun pý¡znak… auta      *)
           )
           j ^(600+$)=3 a ^(600+$+1)=0 (         (* je na pozici auto ?      *)
               (obnov p k l m Auto3 l k p)       (* posun auta vpravo        *)
               ^(600+$)=0 ^(600+$+1)=3           (* posun pý¡znak… auta      *)
           )
           j ^(600+$)=9 a ^(600+$+1)=0 a ($<>9 nebo Auto_Stop=0) (
                                                 (* je na pozici autobus ?   *)
               (obnov p k l m Autobus l k p)     (* posun autobusu vpravo    *)
               ^(600+$)=0 ^(600+$+1)=9           (* posun pý¡znak… autobusu  *)
           )
        )

 x=0 y=8 sever j ~ ^700=0 (^700=0 obnov)         (* vymaz n¡ auta na konci 2 *)
 $=0 17(x=x+1 $=$+1                              (* posun ukazatel… cyklu    *)
           j ^(700+$)=2 a ^(700+$-1)=0 (         (* je na pozici auto ?      *)
               (obnov l k p m auto2 p k l)       (* posun auta vlevo         *)
               ^(700+$)=0 ^(700+$-1)=2           (* posun pý¡znak… auta      *)
           )
           j ^(700+$)=4 a ^(700+$-1)=0 (         (* je na pozici auto ?      *)
               (obnov l k p m auto4 p k l)       (* posun auta vlevo         *)
               ^(700+$)=0 ^(700+$-1)=4           (* posun pý¡znak… auta      *)
           )
        )
 j ^609=9 a Auto_Stop=0 Auto_Stop=6              (* Ÿ¡taŸ zastaven¡ autobusu *)
 j Auto_Stop<>0 Auto_Stop=Auto_Stop-1            (* Ÿ¡t n¡ zastaven¡         *)
 Nove_Auto                                       (* vygenerov n¡ nov‚ho auta *)
)

(*------------------------------ obsluha Karly ------------------------------*)
(* Obsluha pou§¡v  tabulku: ^0 a§ ^251 .... mapa hrac¡ plochy                *)
(*                                              0 = pr zdn‚                  *)
(*                                              1 = Karel vpravo             *)
(*                                              2 = Karla dol…               *)
(*                                              3 = Karla vlevo              *)
(*                                              4 = Karla nahoru             *)

! Zobraz_Karlu
( r
    j ^$=1 m KarlaR
    j ^$=2 m KarlaP
    j ^$=3 m KarlaL
    j ^$=4 m KarlaZ
)

! Jde_Karla
( r
                                                 (* Karla vystoup¡ z autobusu*)

 j Auto_Stop=3  (j ^(9*18+ 9)=0 (x=9  y=8 jih m KarlaP ^(9*18+ 9)=2) jinak
                 j ^(9*18+10)=0 (x=10 y=8 jih m KarlaP ^(9*18+10)=2) jinak
                 j ^(9*18+ 8)=0 (x=8  y=8 jih m KarlaP ^(9*18+ 8)=2) jinak
                 j ^(9*18+11)=0 (x=11 y=8 jih m KarlaP ^(9*18+11)=2) jinak
                 j ^(9*18+ 7)=0 (x=7  y=8 jih m KarlaP ^(9*18+ 7)=2)
                )

 x=0 y=8 jih $=9*18 @(252-9*18)
    (  j ^$<>0 a nahoda 2 = 0
          (
           j nahoda 2 = 0
                (
                   j ((^$=1) a (x<17) a ^($+1)=0) (obnov x=x+1
                                  ^$=0 $=$+1 ^$=1 Zobraz_Karlu $=$-1 x=x-1)
                   j ((^$=2) a (y<12) a ^($+18)=0) (obnov y=y+1
                                 ^$=0 $=$+18 ^$=2 Zobraz_Karlu $=$-18 y=y-1)
                   j ((^$=3) a (x>0) a ^($-1)=0) (obnov x=x-1
                                 ^$=0 $=$-1 ^$=3 Zobraz_Karlu $=$+1 x=x+1)
                   j ((^$=4) a (y>8) a ^($-18)=0) (obnov y=y-1
                                ^$=0 $=$-18 ^$=4 Zobraz_Karlu $=$+18 y=y+1)
                )
             jinak
                (
                   j nahoda 2 = 0
                      (
                         ^$=^$+1 j (^$=5) (^$=1) obnov Zobraz_Karlu
                      )
                   jinak
                      (
                          ^$=^$-1 j (^$=0) (^$=4) obnov Zobraz_Karlu
                      )
                )
          )
       j x<17 (x=x+1) jinak (x=0 y=y+1)
       $=$+1
    )
  x=9 y=3 $=5*18+9
   j ^$=0 a Dvere2 Dvere
   y=4
   j ^$=4 (obnov ^$=0 y=y-1 m KarlaZ y=y+1)
   j ^$=1 (obnov ^$=4 Zobraz_Karlu y=y-1 Dvere2 y=y+1)

  x=8 y=4 $=5*18+8
  8 (
      j ^$<>0 (obnov ^$=0 $=$+1 x=x+1 ^$=1 Zobraz_Karlu x=x-1 $=$-1)
      $=$-1
      x=x-1
    )

  x=1 y=5 $=6*18+1
  4 (
      j ^$<>0 (obnov ^$=0 $=$-18 y=y-1 ^$=4 Zobraz_Karlu y=y+1 $=$+18)
      y=y+1 $=$+18
    )
)

(*------------------------------ obsluha Karla ------------------------------*)

! Zamava
( r
 x 0 y 4 vychod
 j nahoda 40=0 a Cit_Mav=0 Cit_Mav=12
 j Cit_Mav=4 nebo Cit_Mav=8 nebo Cit_Mav=12 (obnov m karlikp2)
 j Cit_Mav=2 nebo Cit_Mav=6 nebo Cit_Mav=10 (obnov m karlikp)
 j Cit_Mav <> 0 Cit_Mav=Cit_Mav-1
)

(*============================= hlavn¡ program ==============================*)

hlaseni "Jak robotka Karl¡ka pýijely navçt¡vit jeho sestýenky..."
Auto_Stop=0                                      (* Ÿ¡taŸ zastaven¡ autobusu *)
Cit_Mav=0                                        (* Ÿ¡taŸ pro m v n¡ Karla   *)
$=0 18( ^(600+$)=0  ^(700+$)=0 $=$+1)            (* inicializace tabulky aut *)
$=0 252(^$=0 $=$+1)                              (* inicializ. tabulky Karly *)

y=0 r                                            (* prvn¡ ý dek pro domek    *)
Kresli_Domek                                     (* nakreslen¡ domku         *)

2 Kresli_Travnik                                 (* nakreslen¡ tr vn¡ku      *)
Kresli_Cestu                                     (* nakreslen¡ silnice       *)
4 Kresli_Travnik                                 (* nakreslen¡ tr vn¡ku      *)
Kresli_Travnik2                                  (* tr vn¡k kreslenì shora   *)

x=7 y=0 vychod text "NedØln¡ %*vìlet%*"

0(
Jedou_Auta                                       (* obsluha aut na silnici   *)
Jde_Karla                                        (* obsluha pohybu Karly     *)
Zamava                                           (* m v n¡ Karla na Karlu    *)
c c                                              (* Ÿek n¡ 1 Ÿasovì krok     *)
j klavesa=k_esc prerus
)

x=1 y=4 jih                                      (* nastaven¡ klidov‚ pozice *)
u
