
(*****************************************************************************)
(*                 V�hern� hrac� automat "The One Arm Bandit"                *)
(*                 (c) Ing. Miroslav N�me�ek 1997, GEMA Soft                 *)
(*****************************************************************************)


(*============================ definice prom�nn�ch ==========================*)

# Znak                                     (* �schova znaku z kl�vesnice     *)
# Skore                                    (* dosa�en� sk�re                 *)
# Vyhra                                    (* v�hra v jedn� h�e              *)
# Zvuk                                     (* 1=zapnut zvuk, -1=vypnut       *)

(*============================ definice p��kaz� =============================*)

(*-------------------------- vymaz�n� cel�ho pole ---------------------------*)
! Vymaz
  (
    x=0 y=1 sever                          (* nastaven� v�choz� pozice       *)
    NIC                                    (* vymaz�n� prvn�ho pol��ka       *)
    krok vpravo                            (* na 1. pol��ko a oto�en� vpravo *)
    dokud neni ZED
      (
        dokud neni ZED (NIC krok)          (* vymaz�n� ��dku zleva doprava   *)
        vpravo jestli neni ZED (krok vpravo) (* na za��tek dal�ho ��dku     *)
        dokud neni zed (NIC krok)          (* vymaz�n� ��dku zprava doleva   *)
        vlevo jestli neni ZED (krok vlevo) (* na za��tek dal�ho ��dku       *)
      )
  )
(*------------------------------- vymaz�n� ��sla ----------------------------*)
! Vymaz_Cislo
  (
    vychod                                 (* ma�e se zleva doprava          *)
    opakuj 5 (DIG krok)                    (* vyma�e ��slo                   *)
    krok vzad                              (* oto�� se na posledn� pozici    *)
  )
(*------------------------------- zobrazen� ��sla ---------------------------*)
! Zobraz_Cislo
  (
    Vymaz_Cislo                            (* vymaz�n� ��sla                 *)
    opakuj 5                               (* opakuje se pro max. 5 ��slic   *)
      (
        predmet ^($ mod 10)                (* vykreslen� nejni�� ��slice    *)
        $=$/10                             (* zmen�en� ��sla o ��d           *)
        jestli $=0 prerus                  (* potla�en� nev�znamn�ch nul     *)
        krok                               (* posun k dal� ��slici          *)
      )
  )
(*------------------------------- zobrazen� sk�re ---------------------------*)
! Zobraz_Skore
  (
    $=Skore                                (* zobrazen� ��slo - sk�re        *)
    x=2 y=10                               (* pozice p�ed ��slem             *)
    Zobraz_Cislo                           (* zobrazen� ��sla                *)
  )
(*----------------------------- vymaz�n� ��sla v�hry ------------------------*)
! Vymaz_Vyhru
  (
    x=2 y=8                                (* pozice p�ed ��slem             *)
    Vymaz_Cislo                            (* vymaz�n� ��sla                 *)
  )
(*------------------------------- zobrazen� v�hry ---------------------------*)
! Zobraz_Vyhru
  (
    $=Vyhra                                (* zobrazen� ��slo - v�hra        *)
    x=2 y=8                                (* pozice p�ed ��slem             *)
    Zobraz_Cislo                           (* zobrazen� ��sla                *)
  )
(*------------------------------ ohl��en� v�hry -----------------------------*)
! Hlas_Vyhru
  (
    jestli Zvuk > 0
      jestli Vyhra < 10 hudba "++1cg" jinak
        jestli Vyhra < 50 hudba "++1cgcgcg" jinak
          jestli Vyhra < 100 hudba "++1cgcgcgcgcg" jinak
            hudba "++1cgcgcgcgcgcgcgcg"

    opakuj 10                              (* po�et zablik�n� ��sla          *)
      (
        Vymaz_Vyhru                        (* vymaz�n� ��sla v�hry           *)
        cekej                              (* mal� prodleva                  *)
        Zobraz_Vyhru                       (* zobrazen� dosa�en� v�hry       *)
        cekej cekej                        (* mal� prodleva                  *)
        Znak=klavesa                       (* na�ten� znaku z kl�vesnice     *)
        jestli Znak = k_F10 nebo Znak = k_Esc prerus  (* p�eru�en� programu  *)
     )
  )
(*------------------------------- zji�t�n� v�hry ----------------------------*)
! Zkus_Vyhru
  (
    Vyhra=0                                (* inicializace - nen� v�hra      *)
    x=3 y=4                                (* pozice prvn�ho ok�nka          *)

                                           (* test mince - 2 nebo 3 pozice   *)
    jestli pole x y = LOS1 a pole x+2 y = LOS1
      ( jestli pole x+4 y = LOS1 Vyhra = 20 jinak Vyhra = 2 )

                                           (* test t�e�n� - 2 nebo 3 pozice  *)
    jestli pole x y = LOS2 a pole x+2 y = LOS2
      ( jestli pole x+4 y = LOS2 Vyhra = 20 jinak Vyhra = 2 )

                                           (* test zvonku - 2 nebo 3 pozice  *)
    jestli pole x y = LOS3 a pole x+2 y = LOS3
      ( jestli pole x+4 y = LOS3 Vyhra = 50 jinak Vyhra = 5 )

                                           (* test Petra - 2 nebo 3 pozice   *)
    jestli pole x y = LOS4 a pole x+2 y = LOS4
      ( jestli pole x+4 y = LOS4 Vyhra = 100 jinak Vyhra = 10 )

                                           (* test Petry - 2 nebo 3 pozice   *)
    jestli pole x y = LOS5 a pole x+2 y = LOS5
      ( jestli pole x+4 y = LOS5 Vyhra = 100 jinak Vyhra = 10 )
  )
(*---------------------- zobrazen� hl��en� (mal� n�pov�dy) ------------------*)
! Zobraz_Hlaseni
  (
    jestli Zvuk > 0
      hlaseni "%*mezera%*=losov�n�    %*F2%*=vypnut� zvuku    %*F10%*=konec hry"
    jinak
      hlaseni "%*mezera%*=losov�n�    %*F2%*=zapnut� zvuku    %*F10%*=konec hry"
  )
(*------------------------ losov�n� jednoho pol��ka -------------------------*)
! Losuj_Jedno
  (
    jestli Nahoda 3 = 0 $=LOS1 jinak       (* s 33% pravd�podobnost� mince   *)
      jestli Nahoda 2 = 0 $=LOS2 jinak     (* s 33% pravd�podobnost� t�e�e�  *)
        jestli Nahoda 2 = 0 $=LOS3 jinak   (* s 16% pravd�podobnost� zvonek  *)
          jestli Nahoda 2 = 0 $=LOS4 jinak (* s  8% pravd�podobnost� Petr    *)
            $=LOS5                         (* s  8% pravd�podobnost� Petra   *)
  )
(*---------------------------- losov�n� -------------------------------------*)
! Losuj
(
  Vymaz_Vyhru                            (* vymaz�n� ��sla v�hry           *)
  jestli Skore > 0 Skore=Skore-1         (* sn��en� sk�re o 1 jako vklad   *)
  Zobraz_Skore                           (* zobrazen� sn��en�ho sk�re      *)
  $=60                                   (* ��ta� pro po��t�n� cykl�       *)
  dokud neni ($=0 nebo Znak = k_F10 nebo Znak = k_Esc)
  (
    jestli $>40 pole 3 4 = Losuj_Jedno (* losov�n� prvn�ho pole          *)
    jestli $>20 pole 5 4 = Losuj_Jedno (* losov�n� druh�ho pole          *)
    pole 7 4 = Losuj_Jedno             (* losov�n� t�et�ho pole          *)
    cekej                              (* mal� prodleva pro zobrazen�    *)
    $=$-1                              (* sn��en� ��ta�e cykl�           *)
    Znak=klavesa                       (* na�ten� znaku z kl�vesnice     *)
    jestli Znak=k_F2 (Zvuk = -Zvuk Zobraz_Hlaseni) (* zm�na zapnut� zvuku*)
    jestli Zvuk > 0 a ($=40 nebo $=20 nebo $=0) hudba "++1g"  (* zvuk    *)
  )
  Zkus_Vyhru                             (* na�ten� dosa�en� v�hry         *)
  jestli Vyhra<>0                        (* je n�jak� v�hra ?              *)
  (
    Hlas_Vyhru                         (* ohl��en� v�hry                 *)
        Skore=Skore+Vyhra                  (* p�i�ten� v�hry ke sk�re        *)
        Zobraz_Skore                       (* zobrazen� nov�ho sk�re         *)
      )
    klavesa                                (* vypr�zdn�n� bufferu kl�vesnice *)
  )
(*----------------------- zobrazen� sk��n� automatu -------------------------*)
! Zobraz_Ram
  (
    pole x y   = AUT1, AUT2, AUT2, AUT2, AUT2, AUT2, AUT2, AUT2, AUT3
    pole x y+1 = AUT4                             pole x+8 y+1 = AUT6
    pole x y+2 = AUT4                             pole x+8 y+2 = AUT6
    pole x y+3 = AUT4                             pole x+8 y+3 = AUT6
    pole x y+4 = AUT4, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT6
    pole x y+5 = AUT4, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT6
    pole x y+6 = AUT4, AUT5                 pole x+7 y+6 = AUT5, AUT6
    pole x y+7 = AUT4, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT5, AUT6
    pole x y+8 = AUT4, AUT5                 pole x+7 y+8 = AUT5, AUT6
    pole x y+9 = AUT7, AUT8, AUT8, AUT8, AUT8, AUT8, AUT8, AUT8, AUT9
  )
(*----------------------- zobrazen� panelu automatu -------------------------*)
! Zobraz_Panel
  (
    pole x y   = BOX1, BOX2, BOX3, BOX2, BOX3, BOX2, BOX4
    pole x y+1 = BOX5, LOS4, BOX7, LOS2, BOX7, LOS5, BOX8
    pole x y+2 = BOX9, BOXA, BOXB, BOXA, BOXB, BOXA, BOXC
  )
(*--------------------------- zobrazen� n�pov�dy ----------------------------*)
! Pomoc
  (
    pole x y   = LOS1, LOS1, CIS , CIS , CIS , CIS2  (* 2 mince .......... 2 *)
    pole x y+1 = LOS2, LOS2, CIS , CIS , CIS , CIS2  (* 2 t�e�n� ......... 2 *)
    pole x y+2 = LOS3, LOS3, CIS , CIS , CIS , CIS5  (* 2 zvonky ......... 5 *)
    pole x y+3 = LOS4, LOS4, CIS , CIS , CIS1, CIS0  (* 2 Pet�i ......... 10 *)
    pole x y+4 = LOS5, LOS5, CIS , CIS , CIS1, CIS0  (* 2 Petry ......... 10 *)
    pole x y+5 = LOS1, LOS1, LOS1, CIS , CIS2, CIS0  (* 3 mince ......... 20 *)
    pole x y+6 = LOS2, LOS2, LOS2, CIS , CIS2, CIS0  (* 3 t�e�n� ........ 20 *)
    pole x y+7 = LOS3, LOS3, LOS3, CIS , CIS5, CIS0  (* 3 zvonky ........ 50 *)
    pole x y+8 = LOS4, LOS4, LOS4, CIS1, CIS0, CIS0  (* 3 Pet�i ........ 100 *)
    pole x y+9 = LOS5, LOS5, LOS5, CIS1, CIS0, CIS0  (* 3 Petry ........ 100 *)
  )
(*------------------------- inicializace nov� hry ---------------------------*)
! Nova
  (
    Skore=100                              (* inicializace sk�re             *)
    Vymaz                                  (* vymaz�n� cel� plochy           *)
    x=1  y=2 Zobraz_Ram                    (* vykreslen� sk��n� automatu     *)
    x=2  y=3 Zobraz_Panel                  (* vykreslen� panelu automatu     *)
    Zobraz_Skore                           (* inicializa�n� zobrazen� sk�re  *)
    Vymaz_Vyhru                            (* vymaz�n� ��sla v�hry           *)
    x=11 y=2 Pomoc                         (* zobrazen� n�pov�dy             *)
    x=3 y=7 vychod text ""                 (* nadpis displeje v�hry          *)
                   text "    %$9V�hra"
    x=3 y=9 vychod text ""                 (* nadpis displeje hotovosti      *)
                   text "   %$9Hotovost"
    Zobraz_Hlaseni                         (* zobrazen� mal� n�pov�dy        *)
  )
(*============================= hlavn� program ==============================*)

rychle                                     (* cel� program v rychl�m re�imu  *)
^0=Dig0,Dig1,Dig2,Dig3,Dig4,Dig5,Dig6,Dig7,Dig8,Dig9 (* inic. tabulky ��slic *)
Znak=""                                    (* inicializace �schovy znaku     *)
Zvuk=1                                     (* p��znak zapnut� zvuku          *)
Nova                                       (* inicializace nov� hry          *)

Dokud neni (Znak=k_Esc nebo Znak=k_F10)    (* cyklus jedn� hry               *)
  (
    Znak=klavesa                           (* na�ten� znaku z kl�vesnice     *)
    jestli Znak=k_F2 (Zvuk = -Zvuk Zobraz_Hlaseni) (* zm�na zapnut� zvuku    *)
    jestli Znak=k_mezera nebo Znak=k_Enter Losuj (* losov�n� jedn� hry       *)
  )
prerus
