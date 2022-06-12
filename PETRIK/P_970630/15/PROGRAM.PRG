
(*****************************************************************************)
(*                                   "15"                                    *)
(*                 (c) Ing. Miroslav NØmeŸek 1997, GEMA Soft                 *)
(*****************************************************************************)


(*============================ definice promØnnìch ==========================*)

# Znak                                     (* £schova znaku z kl vesnice     *)

(*============================ definice pý¡kaz… =============================*)

(*-------------------- otoŸen¡ smØrem na vìchod = doprava -------------------*)
! NaVychod
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    dokud neni vychod vlevo                (* otoŸen¡ na vìchod = doprava    *)
  )
(*---------------------- otoŸen¡ smØrem na jih = dol… -----------------------*)
! NaJih
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    dokud neni jih vlevo                   (* otoŸen¡ na jih = dol…          *)
  )
(*--------------------- otoŸen¡ smØrem na z pad = doleva --------------------*)
! NaZapad
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    dokud neni zapad vlevo                 (* otoŸen¡ na z pad = doleva      *)
  )
(*-------------------- otoŸen¡ smØrem na sever = nahoru ---------------------*)
! NaSever
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    dokud neni sever vlevo                 (* otoŸen¡ na sever = nahoru      *)
  )
(*------------------------ navr cen¡ na vìchoz¡ pozici ----------------------*)
! Domu
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    NaSever                                (* otoŸen¡ na sever = nahoru      *)
    dokud neni zed krok                    (* jde a§ k horn¡mu okraji        *)
    vlevo                                  (* otoŸ¡ se vlevo                 *)
    dokud neni zed krok                    (* jde a§ k prav‚mu okraji        *)
    vlevo                                  (* otoŸ¡ se smØrem dol…           *)
  )
(*---------------------- vymaz n¡ cel‚ho pole -------------------------------*)
! Vymaz
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    Domu                                   (* nastaven¡ vìchoz¡ pozice       *)
    krok                                   (* krok na jih = smØrem dol…      *)
    vzad                                   (* otoŸ¡ se nahoru na prvn¡ ý dek *)
    Nic                                    (* vymaz n¡ prvn¡ho pol¡Ÿka       *)
    krok vpravo                            (* na 1. pol¡Ÿko a otoŸen¡ vpravo *)
    dokud neni zed
      (
        dokud neni zed (Nic krok)          (* vymaz n¡ ý dku zleva doprava   *)
        vpravo jestli neni zed (krok vpravo) (* na zaŸ tek dalç¡ho ý dku     *)
        dokud neni zed (Nic krok)          (* vymaz n¡ ý dku zprava doleva   *)
        vlevo jestli neni zed (krok vlevo) (* na zaŸ tek dalç¡ho ý dku       *)
      )
  )
(*----------------------------- zobrazen¡ nadpisu ---------------------------*)
! Nadpis
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    Domu                                   (* navr t¡ se na vìchoz¡ pozici   *)
    krok krok                              (* jde kousek smØrem dol…         *)
    vlevo                                  (* otoŸen¡ na vìchod = doprava    *)
    opakuj 7 krok                          (* jde kousek smØrem doprava      *)
    Cis1 krok Cis5                         (* zobrazen¡ Ÿ¡slic "1" a "5"     *)
  )
(*-------------------- nastaven¡ na zaŸ tek hrac¡ plochy --------------------*)
! Zacatek
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    Domu                                   (* navr t¡ se na vìchoz¡ pozici   *)
    opakuj 6 krok                          (* jde kousek smØrem dol…         *)
    vlevo                                  (* otoŸen¡ na vìchod = doprava    *)
    opakuj 6 krok                          (* jde kousek smØrem doprava      *)
  )
(*----------------------- vykreslen¡ nov‚ hrac¡ plochy ----------------------*)
! Nova
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    Zacatek                                (* jde na zaŸ tek hrac¡ plochy    *)

            (* nakreslen¡ prvn¡ ýady - jde zleva doprava *)
    Cis1  krok                             (* "1", vstoup¡ na Ÿ¡slo "1"      *)
    Cis2  krok                             (* "2", vstoup¡ na Ÿ¡slo "2"      *)
    Cis3  krok                             (* "3", vstoup¡ na Ÿ¡slo "3"      *)
    Cis4  krok                             (* "4", vstoup¡ na Ÿ¡slo "4"      *)

            (* nakreslen¡ druh‚ ýady - jde zprava doleva *)
    vpravo                                 (* otoŸ¡ se na jih = smØrem dol…  *)
    Cis8  krok                             (* "8", vstoup¡ na Ÿ¡slo "8"      *)
    vpravo                                 (* otoŸ¡ se na z pad = doleva     *)
    Cis7  krok                             (* "7", vstoup¡ na Ÿ¡slo "7"      *)
    Cis6  krok                             (* "6", vstoup¡ na Ÿ¡slo "6"      *)
    Cis5  krok                             (* "5", vstoup¡ na Ÿ¡slo "5"      *)

            (* nakreslen¡ týet¡ ýady - jde zleva doprava *)
    vlevo                                  (* otoŸ¡ se na jih = smØrem dol…  *)
    Cis9  krok                             (* "9", vstoup¡ na Ÿ¡slo "9"      *)
    vlevo                                  (* otoŸ¡ se na vìchod = doprava   *)
    Cis10 krok                             (* "10", vstoup¡ na Ÿ¡slo "10"    *)
    Cis11 krok                             (* "11", vstoup¡ na Ÿ¡slo "11"    *)
    Cis12 krok                             (* "12", vstoup¡ na Ÿ¡slo "12"    *)

            (* nakreslen¡ Ÿtvrt‚ ýady - jde zprava doleva *)
    vpravo                                 (* otoŸ¡ se na jih = smØrem dol…  *)
    Mezera  krok                           (* Mezera, vstoup¡ na mezeru      *)
    vpravo                                 (* otoŸ¡ se na z pad = doleva     *)
    Cis15 krok                             (* "15", vstoup¡ na Ÿ¡slo "15"    *)
    Cis14 krok                             (* "14", vstoup¡ na Ÿ¡slo "14"    *)
    Cis13                                  (* "13", z…st v  na "14"          *)

            (* navr t¡ se na pol¡Ÿko s mezerou *)
    vzad                                   (* otoŸ¡ se na vìchod = doprava   *)
    krok krok                              (* popojde na pol¡Ÿko s mezerou   *)
  )
(*--------------------------- otoŸen¡ n hodnìm smØrem -----------------------*)
! Otoc
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    $ = nahoda 4                           (* generov n¡ n hodn‚ho Ÿ¡sla 0-3 *)
    jestli $ = 0 vlevo                     (* 0: otoŸ¡ se vlevo              *)
    jestli $ = 1 vpravo                    (* 1: otoŸ¡ se vpravo             *)
    jestli $ = 2 vzad                      (* 2: otoŸ¡ se vzad               *)
                                           (* 3: z…stane rovnØ               *)
  )
(*-------------------------- posunut¡ mezery vpýed --------------------------*)
! Posun
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    jestli Cis1  ( Mezera krok vzad Cis1  vzad ) jinak
    jestli Cis2  ( Mezera krok vzad Cis2  vzad ) jinak
    jestli Cis3  ( Mezera krok vzad Cis3  vzad ) jinak
    jestli Cis4  ( Mezera krok vzad Cis4  vzad ) jinak
    jestli Cis5  ( Mezera krok vzad Cis5  vzad ) jinak
    jestli Cis6  ( Mezera krok vzad Cis6  vzad ) jinak
    jestli Cis7  ( Mezera krok vzad Cis7  vzad ) jinak
    jestli Cis8  ( Mezera krok vzad Cis8  vzad ) jinak
    jestli Cis9  ( Mezera krok vzad Cis9  vzad ) jinak
    jestli Cis10 ( Mezera krok vzad Cis10 vzad ) jinak
    jestli Cis11 ( Mezera krok vzad Cis11 vzad ) jinak
    jestli Cis12 ( Mezera krok vzad Cis12 vzad ) jinak
    jestli Cis13 ( Mezera krok vzad Cis13 vzad ) jinak
    jestli Cis14 ( Mezera krok vzad Cis14 vzad ) jinak
    jestli Cis15 ( Mezera krok vzad Cis15 vzad )
  )
(*-------------------------- n vrat na pol¡Ÿko mezery -----------------------*)
! Navrat
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    Zacatek                                (* jde na zaŸ tek hrac¡ plochy    *)

    Dokud neni Mezera
      (
        Dokud neni (Mezera nebo Nic) krok  (* jde k prav‚mu okraji ý dku     *)
        jestli Nic (krok vpravo krok vpravo) (* je za pravìm okrajem ý dku   *)
        Dokud neni (Mezera nebo Nic) krok  (* jde k lev‚mu okraji ý dku      *)
        jestli Nic (krok vlevo krok vlevo) (* je pýed levìm okrajem ý dku    *)
      )
    krok                                   (* krok na pol¡Ÿko mezery         *)
  )
(*-------------------------- zkouçka dokonŸen¡ hry --------------------------*)
! Zkouska
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    $=1                                    (* pý¡znak £spØçn‚ho dokonŸen¡    *)
    Zacatek                                (* jde na zaŸ tek hrac¡ plochy    *)

              (* test prvn¡ ýady - jde zleva doprava *)
    jestli neni Cis1  $=0  krok            (* "1", vstoup¡ na Ÿ¡slo "1"      *)
    jestli neni Cis2  $=0  krok            (* "2", vstoup¡ na Ÿ¡slo "2"      *)
    jestli neni Cis3  $=0  krok            (* "3", vstoup¡ na Ÿ¡slo "3"      *)
    jestli neni Cis4  $=0  krok            (* "4", vstoup¡ na Ÿ¡slo "4"      *)

               (* test druh‚ ýady - jde zprava doleva *)
    vpravo                                 (* otoŸ¡ se na jih = smØrem dol…  *)
    jestli neni Cis8  $=0  krok            (* "8", vstoup¡ na Ÿ¡slo "8"      *)
    vpravo                                 (* otoŸ¡ se na z pad = doleva     *)
    jestli neni Cis7  $=0  krok            (* "7", vstoup¡ na Ÿ¡slo "7"      *)
    jestli neni Cis6  $=0  krok            (* "6", vstoup¡ na Ÿ¡slo "6"      *)
    jestli neni Cis5  $=0  krok            (* "5", vstoup¡ na Ÿ¡slo "5"      *)

                (* test týet¡ ýady - jde zleva doprava *)
    vlevo                                  (* otoŸ¡ se na jih = smØrem dol…  *)
    jestli neni Cis9  $=0  krok            (* "9", vstoup¡ na Ÿ¡slo "9"      *)
    vlevo                                  (* otoŸ¡ se na vìchod = doprava   *)
    jestli neni Cis10 $=0  krok            (* "10", vstoup¡ na Ÿ¡slo "10"    *)
    jestli neni Cis11 $=0  krok            (* "11", vstoup¡ na Ÿ¡slo "11"    *)
    jestli neni Cis12 $=0  krok            (* "12", vstoup¡ na Ÿ¡slo "12"    *)

                (* test Ÿtvrt‚ ýady - jde zprava doleva *)
    vpravo                                 (* otoŸ¡ se na jih = smØrem dol…  *)
    jestli neni Mezera  $=0  krok          (* Mezera, vstoup¡ na mezeru      *)
    vpravo                                 (* otoŸ¡ se na z pad = doleva     *)
    jestli neni Cis15 $=0  krok            (* "15", vstoup¡ na Ÿ¡slo "15"    *)
    jestli neni Cis14 $=0  krok            (* "14", vstoup¡ na Ÿ¡slo "14"    *)
    jestli neni Cis13 $=0                  (* "13", z…st v  na "14"          *)

    Navrat                                 (* navr cen¡ na pol¡Ÿko mezery    *)
  )
(*--------------------- n hodn‚ m¡ch n¡ hrac¡ plochy ------------------------*)
! Michej
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    hlaseni "Stiskem libovoln‚ kl vesy ukonŸ¡te m¡ch n¡..."

    dokud klavesa="" (Otoc Posun)          (* m¡ch n¡ a§ do stisku kl vesy   *)
  )
(*--------------------- vykreslen¡ r meŸku po vìhýe -------------------------*)
! Vyhra
  (
    rychle                                 (* provede se zrychlenØ na pozad¡ *)
    hlaseni "%* **** Blahopýeji  ! **** %*     %*F9%*=nov  hra    %*F10%*=konec"
    Zacatek                                (* jde na zaŸ tek hrac¡ plochy    *)
    vzad krok vpravo krok krok             (* vìchoz¡ pozice pro horn¡ okraj *)
    opakuj 4
      (
        vpravo opakuj 7 (PetrikP krok cekej) (* nakreslen¡ r mu kolem plochy *)
      )
  )
(*============================= hlavn¡ program ==============================*)

rychle                                     (* Petý¡k nebude viditelnì        *)
Znak=""                                    (* inicializace £schovy znaku     *)

Dokud neni (Znak=K_Esc nebo Znak=K_F10)    (* £pln‚ ukonŸen¡ hry             *)
  (
    Vymaz                                  (* vymaz n¡ cel‚ho pole           *)
    Nadpis                                 (* zobrazen¡ nadpisu              *)
    Nova                                   (* zobrazen¡ nov‚ hrac¡ plochy    *)
    Michej                                 (* zam¡ch n¡ hrac¡ plochy         *)
    hlaseni "%*kurzorov‚ kl vesy%*=posun kostky    %*F9%*=nov‚ zam¡ch n¡    %*F10%*=konec hry"
    Znak=""                                (* inicializace £schovy znaku     *)

    Dokud neni (Znak=K_Esc nebo Znak=K_F9 nebo Znak=K_F10) (* cyklus jedn‚ hry *)
      (
        Znak=klavesa                           (* naŸten¡ znaku z kl vesnice *)
        jestli Znak=K_Vpravo (NaZapad  Posun)  (* posun kamene zleva doprava *)
        jestli Znak=K_Dolu   (NaSever  Posun)  (* posun kamene shora dol…    *)
        jestli Znak=K_Vlevo  (NaVychod Posun)  (* posun kamene zprava doleva *)
        jestli Znak=K_Nahoru (NaJih    Posun)  (* posun kamene zdola nahoru  *)

        jestli Zkouska
          (
            Vyhra                              (* zobrazen¡ hl çen¡ o vìhýe  *)
            Znak=""
            Dokud neni (Znak=K_Esc nebo Znak=K_F9 nebo Znak=K_F10)
                          Znak=klavesa        (* Ÿek n¡ na znak z kl vesnice *)
          )
      )
  )
prerus
