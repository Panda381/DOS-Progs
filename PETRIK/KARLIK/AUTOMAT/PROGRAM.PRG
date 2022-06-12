
(*****************************************************************************)
(*                 Vìhern¡ hrac¡ automat "The One Arm Bandit"                *)
(*                 (c) Ing. Miroslav NØmeŸek 1995, GEMA Soft                 *)
(*****************************************************************************)


(*============================ definice promØnnìch ==========================*)

# Znak                                     (* £schova znaku z kl vesnice     *)
# Skore                                    (* dosa§en‚ sk¢re                 *)
# Vyhra                                    (* vìhra v jedn‚ hýe              *)
# Zvuk                                     (* 1=zapnut zvuk, -1=vypnut       *)

(*============================ definice pý¡kaz… =============================*)

(*-------------------------- vymaz n¡ cel‚ho pole ---------------------------*)
! Vymaz
  (
    x=0 y=1 sever                          (* nastaven¡ vìchoz¡ pozice       *)
    NIC                                    (* vymaz n¡ prvn¡ho pol¡Ÿka       *)
    krok vpravo                            (* na 1. pol¡Ÿko a otoŸen¡ vpravo *)
    dokud neni ZED
      (
        dokud neni ZED (NIC krok)          (* vymaz n¡ ý dku zleva doprava   *)
        vpravo jestli neni ZED (krok vpravo) (* na zaŸ tek dalç¡ho ý dku     *)
        dokud neni zed (NIC krok)          (* vymaz n¡ ý dku zprava doleva   *)
        vlevo jestli neni ZED (krok vlevo) (* na zaŸ tek dalç¡ho ý dku       *)
      )
  )
(*------------------------------- vymaz n¡ Ÿ¡sla ----------------------------*)
! Vymaz_Cislo
  (
    vychod                                 (* ma§e se zleva doprava          *)
    opakuj 5 (DIG krok)                    (* vyma§e Ÿ¡slo                   *)
    krok vzad                              (* otoŸ¡ se na posledn¡ pozici    *)
  )
(*------------------------------- zobrazen¡ Ÿ¡sla ---------------------------*)
! Zobraz_Cislo
  (
    Vymaz_Cislo                            (* vymaz n¡ Ÿ¡sla                 *)
    opakuj 5                               (* opakuje se pro max. 5 Ÿ¡slic   *)
      (
        predmet ^($ mod 10)                (* vykreslen¡ nejni§ç¡ Ÿ¡slice    *)
        $=$/10                             (* zmençen¡ Ÿ¡sla o ý d           *)
        jestli $=0 prerus                  (* potlaŸen¡ nevìznamnìch nul     *)
        krok                               (* posun k dalç¡ Ÿ¡slici          *)
      )
  )
(*------------------------------- zobrazen¡ sk¢re ---------------------------*)
! Zobraz_Skore
  (
    $=Skore                                (* zobrazen‚ Ÿ¡slo - sk¢re        *)
    x=2 y=10                               (* pozice pýed Ÿ¡slem             *)
    Zobraz_Cislo                           (* zobrazen¡ Ÿ¡sla                *)
  )
(*----------------------------- vymaz n¡ Ÿ¡sla vìhry ------------------------*)
! Vymaz_Vyhru
  (
    x=2 y=8                                (* pozice pýed Ÿ¡slem             *)
    Vymaz_Cislo                            (* vymaz n¡ Ÿ¡sla                 *)
  )
(*------------------------------- zobrazen¡ vìhry ---------------------------*)
! Zobraz_Vyhru
  (
    $=Vyhra                                (* zobrazen‚ Ÿ¡slo - vìhra        *)
    x=2 y=8                                (* pozice pýed Ÿ¡slem             *)
    Zobraz_Cislo                           (* zobrazen¡ Ÿ¡sla                *)
  )
(*------------------------------ ohl çen¡ vìhry -----------------------------*)
! Hlas_Vyhru
  (
    jestli Zvuk > 0
      jestli Vyhra < 10 hudba "++1cg" jinak
        jestli Vyhra < 50 hudba "++1cgcgcg" jinak
          jestli Vyhra < 100 hudba "++1cgcgcgcgcg" jinak
            hudba "++1cgcgcgcgcgcgcgcg"

    opakuj 10                              (* poŸet zablik n¡ Ÿ¡sla          *)
      (
        Vymaz_Vyhru                        (* vymaz n¡ Ÿ¡sla vìhry           *)
        cekej                              (* mal  prodleva                  *)
        Zobraz_Vyhru                       (* zobrazen¡ dosa§en‚ vìhry       *)
        cekej cekej                        (* mal  prodleva                  *)
        Znak=klavesa                       (* naŸten¡ znaku z kl vesnice     *)
        jestli Znak = k_F10 nebo Znak = k_Esc prerus  (* pýeruçen¡ programu  *)
     )
  )
(*------------------------------- zjiçtØn¡ vìhry ----------------------------*)
! Zkus_Vyhru
  (
    Vyhra=0                                (* inicializace - nen¡ vìhra      *)
    x=3 y=4                                (* pozice prvn¡ho ok‚nka          *)

                                           (* test mince - 2 nebo 3 pozice   *)
    jestli pole x y = LOS1 a pole x+2 y = LOS1
      ( jestli pole x+4 y = LOS1 Vyhra = 20 jinak Vyhra = 2 )

                                           (* test týeçnØ - 2 nebo 3 pozice  *)
    jestli pole x y = LOS2 a pole x+2 y = LOS2
      ( jestli pole x+4 y = LOS2 Vyhra = 20 jinak Vyhra = 2 )

                                           (* test zvonku - 2 nebo 3 pozice  *)
    jestli pole x y = LOS3 a pole x+2 y = LOS3
      ( jestli pole x+4 y = LOS3 Vyhra = 50 jinak Vyhra = 5 )

                                           (* test Karla - 2 nebo 3 pozice   *)
    jestli pole x y = LOS4 a pole x+2 y = LOS4
      ( jestli pole x+4 y = LOS4 Vyhra = 100 jinak Vyhra = 10 )

                                           (* test Karly - 2 nebo 3 pozice   *)
    jestli pole x y = LOS5 a pole x+2 y = LOS5
      ( jestli pole x+4 y = LOS5 Vyhra = 100 jinak Vyhra = 10 )
  )
(*---------------------- zobrazen¡ hl çen¡ (mal‚ n povØdy) ------------------*)
! Zobraz_Hlaseni
  (
    jestli Zvuk > 0
      hlaseni "%*mezera%*=losov n¡    %*F2%*=vypnut¡ zvuku    %*F10%*=konec hry"
    jinak
      hlaseni "%*mezera%*=losov n¡    %*F2%*=zapnut¡ zvuku    %*F10%*=konec hry"
  )
(*------------------------ losov n¡ jednoho pol¡Ÿka -------------------------*)
! Losuj_Jedno
  (
    jestli Nahoda 3 = 0 $=LOS1 jinak       (* s 33% pravdØpodobnost¡ mince   *)
      jestli Nahoda 2 = 0 $=LOS2 jinak     (* s 33% pravdØpodobnost¡ týeçeå  *)
        jestli Nahoda 2 = 0 $=LOS3 jinak   (* s 16% pravdØpodobnost¡ zvonek  *)
          jestli Nahoda 2 = 0 $=LOS4 jinak (* s  8% pravdØpodobnost¡ Karel   *)
            $=LOS5                         (* s  8% pravdØpodobnost¡ Karla   *)
  )
(*---------------------------- losov n¡ -------------------------------------*)
! Losuj
(
  Vymaz_Vyhru                            (* vymaz n¡ Ÿ¡sla vìhry           *)
  jestli Skore > 0 Skore=Skore-1         (* sn¡§en¡ sk¢re o 1 jako vklad   *)
  Zobraz_Skore                           (* zobrazen¡ sn¡§en‚ho sk¢re      *)
  $=60                                   (* Ÿ¡taŸ pro poŸ¡t n¡ cykl…       *)
  dokud neni ($=0 nebo Znak = k_F10 nebo Znak = k_Esc)
  (
    jestli $>40 pole 3 4 = Losuj_Jedno (* losov n¡ prvn¡ho pole          *)
    jestli $>20 pole 5 4 = Losuj_Jedno (* losov n¡ druh‚ho pole          *)
    pole 7 4 = Losuj_Jedno             (* losov n¡ týet¡ho pole          *)
    cekej                              (* mal  prodleva pro zobrazen¡    *)
    $=$-1                              (* sn¡§en¡ Ÿ¡taŸe cykl…           *)
    Znak=klavesa                       (* naŸten¡ znaku z kl vesnice     *)
    jestli Znak=k_F2 (Zvuk = -Zvuk Zobraz_Hlaseni) (* zmØna zapnut¡ zvuku*)
    jestli Zvuk > 0 a ($=40 nebo $=20 nebo $=0) hudba "++1g"  (* zvuk    *)
  )
  Zkus_Vyhru                             (* naŸten¡ dosa§en‚ vìhry         *)
  jestli Vyhra<>0                        (* je nØjak  vìhra ?              *)
  (
    Hlas_Vyhru                         (* ohl çen¡ vìhry                 *)
        Skore=Skore+Vyhra                  (* pýiŸten¡ vìhry ke sk¢re        *)
        Zobraz_Skore                       (* zobrazen¡ nov‚ho sk¢re         *)
      )
    klavesa                                (* vypr zdnØn¡ bufferu kl vesnice *)
  )
(*----------------------- zobrazen¡ ský¡nØ automatu -------------------------*)
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
(*----------------------- zobrazen¡ panelu automatu -------------------------*)
! Zobraz_Panel
  (
    pole x y   = BOX1, BOX2, BOX3, BOX2, BOX3, BOX2, BOX4
    pole x y+1 = BOX5, LOS4, BOX7, LOS2, BOX7, LOS5, BOX8
    pole x y+2 = BOX9, BOXA, BOXB, BOXA, BOXB, BOXA, BOXC
  )
(*--------------------------- zobrazen¡ n povØdy ----------------------------*)
! Pomoc
  (
    pole x y   = LOS1, LOS1, CIS , CIS , CIS , CIS2  (* 2 mince .......... 2 *)
    pole x y+1 = LOS2, LOS2, CIS , CIS , CIS , CIS2  (* 2 týeçnØ ......... 2 *)
    pole x y+2 = LOS3, LOS3, CIS , CIS , CIS , CIS5  (* 2 zvonky ......... 5 *)
    pole x y+3 = LOS4, LOS4, CIS , CIS , CIS1, CIS0  (* 2 Karl¡ci ....... 10 *)
    pole x y+4 = LOS5, LOS5, CIS , CIS , CIS1, CIS0  (* 2 Karly ......... 10 *)
    pole x y+5 = LOS1, LOS1, LOS1, CIS , CIS2, CIS0  (* 3 mince ......... 20 *)
    pole x y+6 = LOS2, LOS2, LOS2, CIS , CIS2, CIS0  (* 3 týeçnØ ........ 20 *)
    pole x y+7 = LOS3, LOS3, LOS3, CIS , CIS5, CIS0  (* 3 zvonky ........ 50 *)
    pole x y+8 = LOS4, LOS4, LOS4, CIS1, CIS0, CIS0  (* 3 Karl¡ci ...... 100 *)
    pole x y+9 = LOS5, LOS5, LOS5, CIS1, CIS0, CIS0  (* 3 Karly ........ 100 *)
  )
(*------------------------- inicializace nov‚ hry ---------------------------*)
! Nova
  (
    Skore=100                              (* inicializace sk¢re             *)
    Vymaz                                  (* vymaz n¡ cel‚ plochy           *)
    x=1  y=2 Zobraz_Ram                    (* vykreslen¡ ský¡nØ automatu     *)
    x=2  y=3 Zobraz_Panel                  (* vykreslen¡ panelu automatu     *)
    Zobraz_Skore                           (* inicializaŸn¡ zobrazen¡ sk¢re  *)
    Vymaz_Vyhru                            (* vymaz n¡ Ÿ¡sla vìhry           *)
    x=11 y=2 Pomoc                         (* zobrazen¡ n povØdy             *)
    x=3 y=7 vychod text ""                 (* nadpis displeje vìhry          *)
                   text "    %$9Vìhra"
    x=3 y=9 vychod text ""                 (* nadpis displeje hotovosti      *)
                   text "   %$9Hotovost"
    Zobraz_Hlaseni                         (* zobrazen¡ mal‚ n povØdy        *)
  )
(*============================= hlavn¡ program ==============================*)

rychle                                     (* celì program v rychl‚m re§imu  *)
^0=Dig0,Dig1,Dig2,Dig3,Dig4,Dig5,Dig6,Dig7,Dig8,Dig9 (* inic. tabulky Ÿ¡slic *)
Znak=""                                    (* inicializace £schovy znaku     *)
Zvuk=1                                     (* pý¡znak zapnut¡ zvuku          *)
Nova                                       (* inicializace nov‚ hry          *)

Dokud neni (Znak=k_Esc nebo Znak=k_F10)    (* cyklus jedn‚ hry               *)
  (
    Znak=klavesa                           (* naŸten¡ znaku z kl vesnice     *)
    jestli Znak=k_F2 (Zvuk = -Zvuk Zobraz_Hlaseni) (* zmØna zapnut¡ zvuku    *)
    jestli Znak=k_mezera nebo Znak=k_Enter Losuj (* losov n¡ jedn‚ hry       *)
  )
prerus
