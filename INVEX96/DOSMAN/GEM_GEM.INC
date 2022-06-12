
#declare Gema_Texture = texture {           // barva pro text "Gema"
   pigment { Red }
   finish {
      phong 2.0
      phong_size 80
      ambient 0.1
      diffuse 1.5
   }
}

#declare Soft_Texture = texture {           // barva pro text "Soft"
   pigment { Yellow }
   finish {
      phong 2.0
      phong_size 80
      ambient 0.1
      diffuse 1.5
   }
}

#declare Dosman_Texture = texture {       // barva pro text "Dosman"
   pigment { color red 0.1 blue 0.1 green 0.4 }
   finish {
      phong 2.0
      phong_size 80
      ambient 0.1
      diffuse 1.5
   }
}


// ================================== G =====================================

#declare Letter_G = union {
    torus { 4.0, 1.5                        // horn¡ p–loblou‡ek
        rotate 90*x

        clipped_by { box { <-5.5, 0, -1.5> <5.5, 5.5, 1.5> } }
        bounded_by { clipped_by }
        translate 4*y
    }

    torus { 4.0, 1.5                        // doln¡ p–loblou‡ek
        rotate 90*x

        clipped_by { box { <-5.5, -5.5, -1.5> <5.5, 0, 1.5> } }
        bounded_by { clipped_by }
        translate -4*y
    }

    cylinder { <-4, -4, 0>, <-4, +4, 0>, 1.5 }  // lev˜ sloupe‡ek
    cylinder { <+4, -8, 0>, <+4, -1.5, 0>, 1.5 } // prav˜ sloupe‡ek
    cylinder { <+1, -1.5, 0>, <+4, -1.5, 0>, 1.5 } // vodorovn  ‡ rka

    sphere { <4, 4, 0>, 1.5 }                   // zarovn n¡ konce horn¡ho oblou‡ku
    sphere { <+4, -8, 0>, 1.5 }                 // zarovn n¡ spodku prav‚ho sloupe‡ku
    sphere { <+4, -1.5, 0>, 1.5 }               // zarovn n¡ rohu vpravo uprost©ed
    sphere { <+1, -1.5, 0>, 1.5 }               // zarovn n¡ vodorovn‚ ‡ rky vlevo

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== E =====================================

#declare Letter_E = union {
    cylinder { <-4, -8, 0>, <-4, 8, 0>, 1.5 }  // lev  svisl  ‡ ra
    cylinder { <-4, 0, 0>, <1.5, 0, 0>, 1.5 }  // st©edn¡ vodorovn  ‡ rka
    cylinder { <-4, 8, 0>, <4, 8, 0>, 1.5 }    // horn¡ vodorovn  ‡ ra
    cylinder { <-4, -8, 0>, <4, -8, 0>, 1.5 }  // spodn¡ vodorovn  ‡ ra

    sphere { <-4, -8, 0>, 1.5 }               // zarovn n¡ rohu vlevo dole
    sphere { <-4, 8, 0>, 1.5 }                // zarovn n¡ rohu vlevo naho©e
    sphere { <4, 8, 0>, 1.5 }                 // zarovn n¡ okraje horn¡ ‡ ry
    sphere { <1.5, 0, 0>, 1.5 }               // zarovn n¡ okraje st©edn¡ ‡ rky
    sphere { <4, -8, 0>, 1.5 }                // zarovn n¡ okraje doln¡ ‡ ry

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== M =====================================

#declare Letter_M = union {
    cylinder { <-8, -8, 0>, <-4, 8, 0>, 1.5 }  // lev  svisl  ‡ ra
    cylinder { <-4, 8, 0>, <0,-6, 0>, 1.5 }    // lev  ¨ikm  ‡ ra
    cylinder { <0, -6, 0>, <4, 8, 0>, 1.5 }    // prav  ¨ikm  ‡ ra
    cylinder { <4, 8, 0>, <8, -8, 0>, 1.5 }    // prav  svisl  ‡ ra

    sphere { <-8, -8, 0>, 1.5 }                // zarovn n¡ lev‚ho doln¡ho okraje
    sphere { <-4,  8, 0>, 1.5 }                // zarovn n¡ lev‚ho horn¡ho rohu
    sphere { < 0,-6, 0>, 1.5 }                 // zarovn n¡ st©edn¡ho rohu
    sphere { < 4, 8, 0>, 1.5 }                 // zarovn n¡ prav‚ho horn¡ho rohu
    sphere { <8, -8, 0>, 1.5 }                 // zarovn n¡ prav‚ho doln¡ho okraje

    bounded_by { box { <-9.5, -9.5, -1.5>, <9.5, 9.5, 1.5> } }
}

// ================================== A =====================================

#declare Letter_A = union {
    cylinder { <-6, -8, 0>, <0, 8, 0>, 1.5 }   // lev  svisl  ‡ ra
    cylinder { <0, 8, 0>, <6, -8, 0>, 1.5 }    // prav  svisl  ‡ ra
    cylinder { <-4, -4, 0>, <4, -4, 0>, 1.5 }  // st©edn¡ vodorovn  ‡ rka

    sphere { <-6, -8, 0>, 1.5 }                // zarovn n¡ lev‚ho doln¡ho okraje
    sphere { < 0, 8, 0>, 1.5 }                 // zarovn n¡ st©edn¡ho rohu
    sphere { <6, -8, 0>, 1.5 }                 // zarovn n¡ prav‚ho doln¡ho okraje

    bounded_by { box { <-7.5, -9.5, -1.5>, <7.5, 9.5, 1.5> } }
}


// ================================== S =====================================

#declare Letter_S = union {
    difference {                            // horn¡ 3/4 oblou‡ek
       torus { 4.0, 1.5 rotate 90*x }
       box { <0, -5.5, -1.5>, <5.5, 0, 1.5> }

       bounded_by { box { <-5.5, -5.5, -1.5>, <5.5, 5.5, 1.5> } }
       translate 4*y
    }

    difference {                            // doln¡ 3/4 oblou‡ek
       torus { 4.0, 1.5 rotate 90*x }
       box { <-5.5, 0, -1.5>, <0, 5.5, 1.5> }

       bounded_by { box { <-5.5, -5.5, -1.5>, <5.5, 5.5, 1.5> } }
       translate -4*y
    }

    sphere { <4, 4, 0>, 1.5 }               // zarovn n¡ horn¡ho oblou‡ku
    sphere { <-4, -4, 0>, 1.5 }             // zarovn n¡ doln¡ho oblou‡ku

    bounded_by { box { <-5.5, -9.5, -1.5> <5.5, 9.5, 1.5> } }
}

// ================================== O =====================================

#declare Letter_O = union {
    torus { 4.0, 1.5                        // horn¡ p–loblou‡ek
        rotate 90*x

        clipped_by { box { <-5.5, 0, -1.5> <5.5, 5.5, 1.5> } }
        bounded_by { clipped_by }
        translate 4*y
    }

    torus { 4.0, 1.5                        // doln¡ p–loblou‡ek
        rotate 90*x

        clipped_by { box { <-5.5, -5.5, -1.5> <5.5, 0, 1.5> } }
        bounded_by { clipped_by }
        translate -4*y
    }

    cylinder { <-4, -4, 0>, <-4, +4, 0>, 1.5 }  // lev˜ sloupe‡ek
    cylinder { <+4, -4, 0>, <+4, +4, 0>, 1.5 }  // prav˜ sloupe‡ek

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== D =====================================

#declare Letter_D = union {
    intersection {
       torus { 4.0, 1.5                        // horn¡ ‡tvrtoblou‡ek
           rotate 90*x
           translate 4*y
       }
       box { <0,4,-1.5> <5.5,9.5,1.5> }
    }

    intersection {
       torus { 4.0, 1.5                        // doln¡ ‡tvrtoblou‡ek
           rotate 90*x
           translate -4*y
       }
       box { <0,-9.5,-1.5> <5.5,-4,1.5> }
    }
    cylinder { <-4, -8, 0>, <-4, 8, 0>, 1.5 }  // lev  svisl  ‡ ra
    cylinder { <+4, -4, 0>, <+4, +4, 0>, 1.5 }  // prav˜ sloupe‡ek
    cylinder { <-4, 8, 0>, <0, 8, 0>, 1.5 }    // horn¡ vodorovn  ‡ ra
    cylinder { <-4, -8, 0>, <0, -8, 0>, 1.5 }  // spodn¡ vodorovn  ‡ ra

    sphere { <-4, -8, 0>, 1.5 }               // zarovn n¡ rohu vlevo dole
    sphere { <-4, 8, 0>, 1.5 }                // zarovn n¡ rohu vlevo naho©e

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== N =====================================

#declare Letter_N = union {
    cylinder { <-4, -8, 0>, <-4, 8, 0>, 1.5 }  // lev  svisl  ‡ ra
    cylinder { <4, -8, 0>, <4, 8, 0>, 1.5 }   // prav  svisl  ‡ ra
    cylinder { <-4, 8, 0>, <4,-8, 0>, 1.5 }   // st©edn¡ ¨ikm  ‡ ra

    sphere { <-4, -8, 0>, 1.5 }               // zarovn n¡ rohu vlevo dole
    sphere { <-4, 8, 0>, 1.5 }                // zarovn n¡ rohu vlevo naho©e
    sphere { <4, -8, 0>, 1.5 }                // zarovn n¡ rohu vpravo dole
    sphere { <4, 8, 0>, 1.5 }                 // zarovn n¡ rohu vpravo naho©e

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== F =====================================

#declare Letter_F = union {
    cylinder { <-4, -8, 0>, <-4, 8, 0>, 1.5 }  // lev  svisl  ‡ ra
    cylinder { <-4, 0, 0>, <1.5, 0, 0>, 1.5 }  // st©edn¡ vodorovn  ‡ rka
    cylinder { <-4, 8, 0>, <4, 8, 0>, 1.5 }    // horn¡ vodorovn  ‡ ra

    sphere { <-4, -8, 0>, 1.5 }                // zarovn n¡ spodn¡ho okraje
    sphere { <-4, 8, 0>, 1.5 }                // zarovn n¡ rohu vlevo naho©e
    sphere { <4, 8, 0>, 1.5 }                 // zarovn n¡ okraje horn¡ ‡ ry
    sphere { <1.5, 0, 0>, 1.5 }               // zarovn n¡ okraje st©edn¡ ‡ rky

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ================================== T =====================================

#declare Letter_T = union {
    cylinder { <0, -8, 0>, <0, 8, 0>, 1.5 }  // st©edn¡ svisl  ‡ ra
    cylinder { <-4, 8, 0>, <4, 8, 0>, 1.5 }  // horn¡ vodorovn  ‡ ra

    sphere { <-4, 8, 0>, 1.5 }               // zarovn n¡ lev‚ho konce
    sphere { <+4, 8, 0>, 1.5 }               // zarovn n¡ prav‚ho konce
    sphere { <0, -8, 0>, 1.5 }               // zarovn n¡ doln¡ho konce

    bounded_by { box { <-5.5, -9.5, -1.5>, <5.5, 9.5, 1.5> } }
}

// ============================== GEMA ======================================

#declare Text_Gema = union {                // rozmˆry 60 * 19 * 3, st©ed 0
    object { Letter_G  translate  -24.5*x }
    object { Letter_E  translate  -11.4*x }
    object { Letter_M  translate    4.7*x }
    object { Letter_A  translate   22.5*x }
    texture { Gema_Texture }
    bounded_by { box { <-30,-9.5,-1.5>, <30, 9.5, 1.5> } }
}

// ============================== Soft ======================================

#declare Text_Soft = union {            // rozmˆry 16.17 * 6.27 * 0.99, st©ed 0
    object { Letter_S  translate -19*x }
    object { Letter_O  translate -6.5*x }
    object { Letter_F  translate  6.7*x }
    object { Letter_T  translate  19*x }
    scale 0.33                              // zmen¨en¡
    texture { Soft_Texture }
    bounded_by { box { <-24.5,-3.135,-0.495>, <24.5, 3.135, 0.495> } }
}

// ============================== DOSMAN ====================================

#declare Dosman = union {                   // rozmery 84 * 19 * 3, stred 0
    object { Letter_D translate -35.9*x }
    object { Letter_O translate -23.6*x }
    object { Letter_S translate -10.9*x }
    object { Letter_M translate   4.6*x }
    object { Letter_A translate  22.1*x }
    object { Letter_N translate  35.9*x }
    texture { Dosman_Texture }
    bounded_by { box { <-42,-9.5,-1.5>, <42, 9.5, 1.5> } }
}

// =============================== Gema =====================================

#declare Gema = union {
    object { Text_Gema }
    object { Text_Soft translate 26*x-8*z-7*y }
}
