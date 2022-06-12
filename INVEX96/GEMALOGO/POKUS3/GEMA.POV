// POV-Ray 2.0 sample scene file
// Demo of extended light sources by Steve Anger

#include "colors.inc"
#include "textures.inc"
#include "shapes.inc"


// A rather boring texture but it renders quick

#declare Gema_Texture = texture {
   pigment { Red }
   finish {
      phong 2.0
      phong_size 80
      ambient 0.1
      diffuse 1.5
   }
}

#declare Soft_Texture = texture {
   pigment { Yellow }
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

    bounded_by { box { <-5.5, -9.5, -1.5> <5.5, 9.5, 1.5> } }
}

// ============================== GEMA ======================================

#declare Text_Gema = union {
    object { Letter_G  translate  -24*x }
    object { Letter_E  translate  -11*x }
    object { Letter_M  translate    5*x }
    object { Letter_A  translate   24*x }

    texture { Gema_Texture }
}

// ============================== Soft ======================================

#declare Text_Soft = union {
    object { Letter_S  translate -24*x }
    object { Letter_O  translate -11*x }
    object { Letter_F  translate   3*x }
    object { Letter_T  translate  16*x }

    texture { Soft_Texture }
}

// =========================== zobrazen¡ text– ===============================

object { Text_Gema translate 12*y }
object { Text_Soft translate 9.5*y scale 0.4 translate 26*x-10*z }

// ================================ svˆtla ===================================

// Floor
plane { y, 0
    pigment { Tan }
    finish {
        ambient 0.0
        diffuse 0.8
    }
}

// Something to light the front of the text
light_source { <0, 30, -90> color Gray30 }

// An extended area spotlight to backlight the letters
light_source {
   <0, 50, 100> color White

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

camera {
    direction <0, 0, 1.5>
    location <0, 30, -90>
    look_at <0, 0, -2>
}
