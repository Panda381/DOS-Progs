
(*****************************************************************************)
(*                                   "15"                                    *)
(*                 (c) Ing. Miroslav N�me�ek 1997, GEMA Soft                 *)
(*****************************************************************************)


(*============================ definice prom�nn�ch ==========================*)

# Znak                                     (* �schova znaku z kl�vesnice     *)

(*============================ definice p��kaz� =============================*)

(*-------------------- oto�en� sm�rem na v�chod = doprava -------------------*)
! NaVychod
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    dokud neni vychod vlevo                (* oto�en� na v�chod = doprava    *)
  )
(*---------------------- oto�en� sm�rem na jih = dol� -----------------------*)
! NaJih
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    dokud neni jih vlevo                   (* oto�en� na jih = dol�          *)
  )
(*--------------------- oto�en� sm�rem na z�pad = doleva --------------------*)
! NaZapad
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    dokud neni zapad vlevo                 (* oto�en� na z�pad = doleva      *)
  )
(*-------------------- oto�en� sm�rem na sever = nahoru ---------------------*)
! NaSever
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    dokud neni sever vlevo                 (* oto�en� na sever = nahoru      *)
  )
(*------------------------ navr�cen� na v�choz� pozici ----------------------*)
! Domu
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    NaSever                                (* oto�en� na sever = nahoru      *)
    dokud neni zed krok                    (* jde a� k horn�mu okraji        *)
    vlevo                                  (* oto�� se vlevo                 *)
    dokud neni zed krok                    (* jde a� k prav�mu okraji        *)
    vlevo                                  (* oto�� se sm�rem dol�           *)
  )
(*---------------------- vymaz�n� cel�ho pole -------------------------------*)
! Vymaz
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    Domu                                   (* nastaven� v�choz� pozice       *)
    krok                                   (* krok na jih = sm�rem dol�      *)
    vzad                                   (* oto�� se nahoru na prvn� ��dek *)
    Nic                                    (* vymaz�n� prvn�ho pol��ka       *)
    krok vpravo                            (* na 1. pol��ko a oto�en� vpravo *)
    dokud neni zed
      (
        dokud neni zed (Nic krok)          (* vymaz�n� ��dku zleva doprava   *)
        vpravo jestli neni zed (krok vpravo) (* na za��tek dal�ho ��dku     *)
        dokud neni zed (Nic krok)          (* vymaz�n� ��dku zprava doleva   *)
        vlevo jestli neni zed (krok vlevo) (* na za��tek dal�ho ��dku       *)
      )
  )
(*----------------------------- zobrazen� nadpisu ---------------------------*)
! Nadpis
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    Domu                                   (* navr�t� se na v�choz� pozici   *)
    krok krok                              (* jde kousek sm�rem dol�         *)
    vlevo                                  (* oto�en� na v�chod = doprava    *)
    opakuj 7 krok                          (* jde kousek sm�rem doprava      *)
    Cis1 krok Cis5                         (* zobrazen� ��slic "1" a "5"     *)
  )
(*-------------------- nastaven� na za��tek hrac� plochy --------------------*)
! Zacatek
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    Domu                                   (* navr�t� se na v�choz� pozici   *)
    opakuj 6 krok                          (* jde kousek sm�rem dol�         *)
    vlevo                                  (* oto�en� na v�chod = doprava    *)
    opakuj 6 krok                          (* jde kousek sm�rem doprava      *)
  )
(*----------------------- vykreslen� nov� hrac� plochy ----------------------*)
! Nova
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    Zacatek                                (* jde na za��tek hrac� plochy    *)

            (* nakreslen� prvn� �ady - jde zleva doprava *)
    Cis1  krok                             (* "1", vstoup� na ��slo "1"      *)
    Cis2  krok                             (* "2", vstoup� na ��slo "2"      *)
    Cis3  krok                             (* "3", vstoup� na ��slo "3"      *)
    Cis4  krok                             (* "4", vstoup� na ��slo "4"      *)

            (* nakreslen� druh� �ady - jde zprava doleva *)
    vpravo                                 (* oto�� se na jih = sm�rem dol�  *)
    Cis8  krok                             (* "8", vstoup� na ��slo "8"      *)
    vpravo                                 (* oto�� se na z�pad = doleva     *)
    Cis7  krok                             (* "7", vstoup� na ��slo "7"      *)
    Cis6  krok                             (* "6", vstoup� na ��slo "6"      *)
    Cis5  krok                             (* "5", vstoup� na ��slo "5"      *)

            (* nakreslen� t�et� �ady - jde zleva doprava *)
    vlevo                                  (* oto�� se na jih = sm�rem dol�  *)
    Cis9  krok                             (* "9", vstoup� na ��slo "9"      *)
    vlevo                                  (* oto�� se na v�chod = doprava   *)
    Cis10 krok                             (* "10", vstoup� na ��slo "10"    *)
    Cis11 krok                             (* "11", vstoup� na ��slo "11"    *)
    Cis12 krok                             (* "12", vstoup� na ��slo "12"    *)

            (* nakreslen� �tvrt� �ady - jde zprava doleva *)
    vpravo                                 (* oto�� se na jih = sm�rem dol�  *)
    Mezera  krok                           (* Mezera, vstoup� na mezeru      *)
    vpravo                                 (* oto�� se na z�pad = doleva     *)
    Cis15 krok                             (* "15", vstoup� na ��slo "15"    *)
    Cis14 krok                             (* "14", vstoup� na ��slo "14"    *)
    Cis13                                  (* "13", z�st�v� na "14"          *)

            (* navr�t� se na pol��ko s mezerou *)
    vzad                                   (* oto�� se na v�chod = doprava   *)
    krok krok                              (* popojde na pol��ko s mezerou   *)
  )
(*--------------------------- oto�en� n�hodn�m sm�rem -----------------------*)
! Otoc
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    $ = nahoda 4                           (* generov�n� n�hodn�ho ��sla 0-3 *)
    jestli $ = 0 vlevo                     (* 0: oto�� se vlevo              *)
    jestli $ = 1 vpravo                    (* 1: oto�� se vpravo             *)
    jestli $ = 2 vzad                      (* 2: oto�� se vzad               *)
                                           (* 3: z�stane rovn�               *)
  )
(*-------------------------- posunut� mezery vp�ed --------------------------*)
! Posun
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
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
(*-------------------------- n�vrat na pol��ko mezery -----------------------*)
! Navrat
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    Zacatek                                (* jde na za��tek hrac� plochy    *)

    Dokud neni Mezera
      (
        Dokud neni (Mezera nebo Nic) krok  (* jde k prav�mu okraji ��dku     *)
        jestli Nic (krok vpravo krok vpravo) (* je za prav�m okrajem ��dku   *)
        Dokud neni (Mezera nebo Nic) krok  (* jde k lev�mu okraji ��dku      *)
        jestli Nic (krok vlevo krok vlevo) (* je p�ed lev�m okrajem ��dku    *)
      )
    krok                                   (* krok na pol��ko mezery         *)
  )
(*-------------------------- zkou�ka dokon�en� hry --------------------------*)
! Zkouska
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    $=1                                    (* p��znak �sp��n�ho dokon�en�    *)
    Zacatek                                (* jde na za��tek hrac� plochy    *)

              (* test prvn� �ady - jde zleva doprava *)
    jestli neni Cis1  $=0  krok            (* "1", vstoup� na ��slo "1"      *)
    jestli neni Cis2  $=0  krok            (* "2", vstoup� na ��slo "2"      *)
    jestli neni Cis3  $=0  krok            (* "3", vstoup� na ��slo "3"      *)
    jestli neni Cis4  $=0  krok            (* "4", vstoup� na ��slo "4"      *)

               (* test druh� �ady - jde zprava doleva *)
    vpravo                                 (* oto�� se na jih = sm�rem dol�  *)
    jestli neni Cis8  $=0  krok            (* "8", vstoup� na ��slo "8"      *)
    vpravo                                 (* oto�� se na z�pad = doleva     *)
    jestli neni Cis7  $=0  krok            (* "7", vstoup� na ��slo "7"      *)
    jestli neni Cis6  $=0  krok            (* "6", vstoup� na ��slo "6"      *)
    jestli neni Cis5  $=0  krok            (* "5", vstoup� na ��slo "5"      *)

                (* test t�et� �ady - jde zleva doprava *)
    vlevo                                  (* oto�� se na jih = sm�rem dol�  *)
    jestli neni Cis9  $=0  krok            (* "9", vstoup� na ��slo "9"      *)
    vlevo                                  (* oto�� se na v�chod = doprava   *)
    jestli neni Cis10 $=0  krok            (* "10", vstoup� na ��slo "10"    *)
    jestli neni Cis11 $=0  krok            (* "11", vstoup� na ��slo "11"    *)
    jestli neni Cis12 $=0  krok            (* "12", vstoup� na ��slo "12"    *)

                (* test �tvrt� �ady - jde zprava doleva *)
    vpravo                                 (* oto�� se na jih = sm�rem dol�  *)
    jestli neni Mezera  $=0  krok          (* Mezera, vstoup� na mezeru      *)
    vpravo                                 (* oto�� se na z�pad = doleva     *)
    jestli neni Cis15 $=0  krok            (* "15", vstoup� na ��slo "15"    *)
    jestli neni Cis14 $=0  krok            (* "14", vstoup� na ��slo "14"    *)
    jestli neni Cis13 $=0                  (* "13", z�st�v� na "14"          *)

    Navrat                                 (* navr�cen� na pol��ko mezery    *)
  )
(*--------------------- n�hodn� m�ch�n� hrac� plochy ------------------------*)
! Michej
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    hlaseni "Stiskem libovoln� kl�vesy ukon��te m�ch�n�..."

    dokud klavesa="" (Otoc Posun)          (* m�ch�n� a� do stisku kl�vesy   *)
  )
(*--------------------- vykreslen� r�me�ku po v�h�e -------------------------*)
! Vyhra
  (
    rychle                                 (* provede se zrychlen� na pozad� *)
    hlaseni "%* **** Blahop�eji  ! **** %*     %*F9%*=nov� hra    %*F10%*=konec"
    Zacatek                                (* jde na za��tek hrac� plochy    *)
    vzad krok vpravo krok krok             (* v�choz� pozice pro horn� okraj *)
    opakuj 4
      (
        vpravo opakuj 7 (PetrikP krok cekej) (* nakreslen� r�mu kolem plochy *)
      )
  )
(*============================= hlavn� program ==============================*)

rychle                                     (* Pet��k nebude viditeln�        *)
Znak=""                                    (* inicializace �schovy znaku     *)

Dokud neni (Znak=K_Esc nebo Znak=K_F10)    (* �pln� ukon�en� hry             *)
  (
    Vymaz                                  (* vymaz�n� cel�ho pole           *)
    Nadpis                                 (* zobrazen� nadpisu              *)
    Nova                                   (* zobrazen� nov� hrac� plochy    *)
    Michej                                 (* zam�ch�n� hrac� plochy         *)
    hlaseni "%*kurzorov� kl�vesy%*=posun kostky    %*F9%*=nov� zam�ch�n�    %*F10%*=konec hry"
    Znak=""                                (* inicializace �schovy znaku     *)

    Dokud neni (Znak=K_Esc nebo Znak=K_F9 nebo Znak=K_F10) (* cyklus jedn� hry *)
      (
        Znak=klavesa                           (* na�ten� znaku z kl�vesnice *)
        jestli Znak=K_Vpravo (NaZapad  Posun)  (* posun kamene zleva doprava *)
        jestli Znak=K_Dolu   (NaSever  Posun)  (* posun kamene shora dol�    *)
        jestli Znak=K_Vlevo  (NaVychod Posun)  (* posun kamene zprava doleva *)
        jestli Znak=K_Nahoru (NaJih    Posun)  (* posun kamene zdola nahoru  *)

        jestli Zkouska
          (
            Vyhra                              (* zobrazen� hl��en� o v�h�e  *)
            Znak=""
            Dokud neni (Znak=K_Esc nebo Znak=K_F9 nebo Znak=K_F10)
                          Znak=klavesa        (* �ek�n� na znak z kl�vesnice *)
          )
      )
  )
prerus
