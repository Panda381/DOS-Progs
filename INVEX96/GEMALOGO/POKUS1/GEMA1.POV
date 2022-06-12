// sc‚na pro POV-Ray 2.0

#include "colors.inc"
#include "textures.inc"
#include "shapes.inc"
#include "ior.inc"

// ============================ materi ly ===================================

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

// =============================== krystal =================================

#declare Krystal = intersection {

    box { <-41,-22, -12>, <41, 22, 12> }              // z kladn¡ kv dr
    box { <-41, -20.1, -20.1>, <41, 20.1, 20.1> rotate 45*x } // vodorovn‚ hrany
    box { <-35.2, -22, -35.2>, <35.2, 22, 35.2> rotate 45*y } // svisl‚ hrany
    box { <-41, -41, -12>, <41, 41, 12> rotate 45*z } // zkosen‚ rohy

    pigment { color White filter 1 }
    finish {
       ambient 0.1
       diffuse 0.7
       refraction 1
       ior Diamond_Ior
//       phong 1
//       phong_size 50
    }

    bounded_by { box { <-41,-22, -12>, <41, 22, 12> } }
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

#declare Text_Soft = union {                // rozmˆry 49 * 6.27 * 0.99, st©ed 0
    object { Letter_S  translate -19*x }
    object { Letter_O  translate -6.5*x }
    object { Letter_F  translate  6.7*x }
    object { Letter_T  translate  19*x }
    scale 0.33                              // zmen¨en¡
    texture { Soft_Texture }
    bounded_by { box { <-24.5,-3.135,-0.495>, <24.5, 3.135, 0.495> } }
}

// =============================== Gema =====================================

#declare Gema = union {
    object { Text_Gema }
    object { Text_Soft translate 26*x-8*z-7*y }
    object { Krystal }
}

object { Gema rotate (clock-1)*(360/48)*y }

// ============================== rovina (podklad) ==========================

// Floor
plane { y, 0
    pigment { color red 0.75 green 0.82 blue 0.89 }
    finish {
        ambient 0.0
        diffuse 0.8
    }
    translate -30*y
}

// ================================ svˆtla ===================================

// Something to light the front of the text
light_source { <40, 200, -200> color red 0.5 green 0.52 blue 0.6 }
//light_source { <-80, 40, -90> color Gray30 }
//light_source { <0, -20, -200> color Gray30 }

// An extended area spotlight to backlight the letters
light_source {
   <-40, 50, -100> color Gray60

   // The spotlight parameters
   spotlight
   point_at <0, 0, -5>
   radius 6
   falloff 22

   // The extended area light paramaters
   area_light <6, 0, 0>, <0, 6, 0>, 9, 9
   adaptive 0
   jitter
}

//light_source { <-90, 30, 0> color White }

camera {
    direction <0, 0, 0.9>
    location <0, 0, -100>                   // pohled zep©edu
//    location <-30, 20, -110>                 // ¨im˜ pohled zleva
//    location <-90, 1, 0>                      // pohled zleva
//    location <-60, 20,-10>                    // pohled zleva a shora
//    location <0, 90, -1>                   // pohled shora (X+Z nesm¡ b˜t 0 !)
    look_at <0, 0, 0>
}
