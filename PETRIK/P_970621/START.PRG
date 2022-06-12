
# xx
# typ_auta
# radek_cesty

! cesta_zleva (y j cesta k l d ~zed(cesta k))
! cesta_zprava (y j cesta2 k r d ~zed(cesta2 k))
! maluj_cestu (y cesta_zleva cesta_zprava)

! obl (obloha k)
! mra (mrak k)
! okn (okno k)
! ok2 (okno2 k)
! ste (stena k)
! plo (plot k)
! pls (plotstrm k)

! jede_auto (
            jestli $=6 nebo $=4
             (p 0 $-1 j m auto c cesta l d ~zed (k r m auto c cesta l) 10 c)
            jinak
             (p 17 $-1 j m auto2 c cesta2 r d ~zed (k l m auto2 c cesta2 r) 4 c)
            )

! zamava (p 0 3 v 4(vsyn obloha m petrikp2 c c vsyn obloha m petrikp c c) )

y p 0 0 j k k k @2 maluj_cestu

p 0 1 s obl r obl mra @5 obl obloha m petrap k @5 obl mra obl slunce k obl
r mra r @3 obl strechap @7(k strecha) k strechal k @5 obl
l obl l @2 obl mra obl ok2 ste okn ste okn ste okn ste ok2 @4 obl
r obl r plo pls plo okn ste ok2 ste dvere k ste ok2 ste okn plo pls plo obl obl

p 0 3 v obloha m petrikp

0(
   p nahoda 18 7+nahoda 6 j petrap
   p nahoda 18 7+nahoda 6 j petrikp

   $ 4 + nahoda 4 jede_auto
   jestli nahoda 0 zamava

   )
p 2 3 j
