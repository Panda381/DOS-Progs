
# xx
# typ_auta
# radek_cesty

! cesta_zleva (r sj cesta k l d ~zed(cesta k))
! cesta_zprava (r sj cesta2 k p d ~zed(cesta2 k))
! maluj_cestu (r cesta_zleva cesta_zprava)

! obl (obloha k)
! mra (mrak k)
! okn (okno k)
! ok2 (okno2 k)
! ste (stena k)
! plo (plot k)
! pls (plotstrm k)

! jede_auto (
            j $=4
             (x 0 y $-1 sj m auto c cesta l d ~zed (k p m auto c cesta l) 10 c)
            j $=5
             (x 0 y $-1 sj m auto c cesta2 l d ~zed (k p m auto c cesta2 l) 10 c)
            j $=6
             (x 17 y $-1 sj m auto2 c cesta p d ~zed (k l m auto2 c cesta p) 4 c)
            j $=7
             (x 17 y $-1 sj m auto2 c cesta2 p d ~zed (k l m auto2 c cesta2 p) 4 c)
            )

! zamava (x 0 y 3 sv 4(vsyn obloha m petrikp2 c c vsyn obloha m petrikp c c) )

r x 0 y 0 sj k k k @2 maluj_cestu

x 0 y 1 ss obl p obl mra @5 obl obloha m petrap k @5 obl mra obl slunce k obl
p mra p @3 obl strechap @7(k strecha) k strechal k @5 obl
l obl l @2 obl mra obl ok2 ste okn ste okn ste okn ste ok2 @4 obl
p obl p plo pls plo okn ste ok2 ste dvere k ste ok2 ste okn plo pls plo obl obl

x 0 y 3 sv obloha m petrikp

0(
   x nahoda 18 y 7+nahoda 6 sj petrap
   x nahoda 18 y 7+nahoda 6 sj petrikp

   j nahoda 0 zamava

   $=4+nahoda 4 jede_auto

   )
x 2 y 3 sj
