@echo off
rem COMLINK verze 1.0; (c) Miroslav Nemecek
rem Parametry: =x     - tato stanice bude v siti
rem                     oznacena pismenem x (x=A az Z)
rem            #c     - spojeni pres port COMc (c=1 az 4)
rem            !n     - koeficient prenosove rychlosti
rem                     n = 115200/prenosova rychlost
rem            $ABC...- k vlastnim diskum A,B,C, ... je
rem                     mozny pristup pro cteni i zapis
rem            &DEF...- k vlastnim diskum D,E,F, ... je
rem                     mozny pristup jen pro cteni
rem           @MNOP..- disk N stanice M bude pristupny
rem                    jako disk 1 (1. rezervovany disk)
rem                  - disk P stanice O bude pristupny
rem                    jako disk 2 (2. rezervovany disk)
rem - disky a stanice se oznacuji pismeny A az Z
comlink =a #1 !12 $d &c @bdbc
