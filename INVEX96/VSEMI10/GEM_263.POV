
#include "shapes.inc"
#include "colors.inc"
#include "textures.inc"

// ==================== Kamera =========================

camera {
   location <-5.750000, -11.500000+60.0, 51.750000-140.0>
   up <0.0, 1.0, 0.0>
   right <4/3, 0.0, 0.0>
   look_at <-34.500000, 20.0, 11.500000>
}

// ============== Stojanek s tuzkami ======================

#declare TeloTuzky = cylinder {
                        <0,0,0>, <0,30,0>, 0.5
                        finish {
                           crand 0.05
                           ambient 0.3
                           diffuse 0.7
                        }
                     }

#declare VrchTuzky = cylinder {
                        <0,30,0>, <0,32,0>, 0.5
                        finish {
                           crand 0.05
                           ambient 0.3
                           diffuse 0.7
                        }
                        pigment { Tan }
                     }

#declare CervenaTuzka = union {
                           object { TeloTuzky pigment { Red } }
                           object { VrchTuzky }
                        }

#declare ZelenaTuzka = union {
                          object { TeloTuzky pigment { Green } }
                          object { VrchTuzky }
                       }

#declare ModraTuzka = union {
                         object { TeloTuzky pigment { Blue } }
                         object { VrchTuzky }
                      }

// Stojanek s tuzkami
union {
   intersection {
      object { Cylinder_Y scale <5.0, 1.0, 5.0> }
      object { Cylinder_Y scale <4.8, 1.0, 4.8> inverse }
      plane { y, 0.0 inverse }
      plane { y, 15.0 rotate -45*x }

      finish {
         Shiny
         crand 0.05
         ambient 0.3
         diffuse 0.7
         reflection 0.4
         brilliance 6.0
      }
      pigment { colour red 0.7 green 0.6 blue 0.1 }
   }
   object {
      CervenaTuzka
      rotate -2*z
      translate <1.0, 0.0, 1.0>
   }
   object {
      ZelenaTuzka
      rotate 2.0*z
      translate <-1.0, 3.0, 0.0>
   }
   object { 
      ModraTuzka
      rotate <-2.0, 0.0, 3.0>
      translate <0.0, -2.0, -1.0>
   }

   bounded_by { box { <-6,-4,-6> <6,36,6> } }

   rotate 45*y
   translate <70.0, 0.0, -20.0>
}

// ================ Zadni stena ================

plane { z, 200.0
   finish {
      crand 0.1
      ambient 0.3
      diffuse 0.7
   }
   pigment { LightGray }
}

// ============= Povrch stolu =====================

box { <-125,-4,-100> <125,0,100>

   finish {
      crand 0.05
      ambient 0.4
      diffuse 0.6
      reflection 0.2
      brilliance 3.0
   }
   pigment {
      Dark_Wood
      scale <5.0, 1.0, 1.0>
   }

bounded_by { box { <-125.1,-4.1,-100.1> <125.1,0.1,100.1> } }
}

// ================== Psaci papir ===================


box { <0,0,0> <60,45,0.1>
      finish {
         ambient 0.05
         diffuse 0.9
      }
      pigment {
         image_map { gif "vsemi10.gif" once interpolate 2.0}
         scale <60, 45, 0.1>
      }

   rotate 90*x
   rotate -80.000000*x
   rotate -35.000000*y
   translate <-30,0.1,-70>
   translate <-35.000000,4.000000,44.000000>
}


// =============== Stolni lampa ========================

union {

   cylinder { <0,1.5,0>, <0,55,0>, 1.4
      pigment { White }
      bounded_by { box { <-2,1,-2> <2,56,2> } }
   }

   cylinder { <0,0,0>, <0,1.5,0>, 20
      pigment { SkyBlue }
      bounded_by { box { <-21,-0.1,-21> <21,2,21> } }
   }

   cylinder { <-30,55,-13>, <30,55,-13>, 10
      clipped_by { plane {-y,-55} }
      bounded_by { box { <-30.1,54.9,-23.1> <30.1,65.1,-2.9> } }
      pigment { SkyBlue }
      rotate 35*y
   }
   translate <50.0, 0.0, 30.0>
}

// ================== Zarivka v lampe ====================


light_source { <-27, 59.5, -13> color red 1.000000 blue 1.000000 green 1.000000 
    looks_like {
        cylinder { <0,-2,0>, <54,-2,0>, 2.4
        pigment { color red 1.000000 blue 1.000000 green 1.000000 }
        finish { ambient 1 diffuse 0 }
        bounded_by { box { <-0.1,-4.5,-2.5> <54.1,0.5,2.5> } }
        }
   }
   rotate 35*y
   translate <50.0, 0.0, 30.0>
}


// ================== Obrazek =======================


// Ramecek
union {
   box { <0,4,0> <60,49,0.1>
      finish {
         ambient 0.05
         diffuse 0.9
      }
      pigment { White }
   }

   difference {
      box { <-4,0,-2> <64,53,2> }
      box { <0,4,-2.1> <60,49,2.1> }
      texture { EMBWood1 scale 10 translate -50*y}
   }

   bounded_by { box {<-4.1,-0.1,-2.1> <64.1,53.1,2.1> } }

   rotate <10.0, -35.0, 0.0>
   translate <-65.0, 0.0, -25.0>
}


// =================== Zdroj svetla =======================

light_source { <20.0, 120.0, -200.0> color red 1.000000 blue 1.000000 green 1.000000 }
