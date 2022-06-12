
#include "shapes.inc"
#include "shapes2.inc"
#include "colors.inc"
#include "textures.inc"

#include "gem_gem.inc"

// ============== Napis GEMA Soft ===========


object { Gema
    scale 1.6
    translate <0,70.000000,0.000000>
}


// ============== Kamera =================

camera {
   location <0.0, 0.0, -200.0>
   direction <0.0, 0.0, 1.0>
   up <0.0, 1.0, 0.0>
   right <4/3, 0.0, 0.0>
}

// ========== Jehlan 1 (zlat˜) ===========


object {
   Tetrahedron
   pigment { Gold }
   finish {
      crand 0.01
      ambient 0.1
      diffuse 0.7
      reflection 0.4
      brilliance 6.0

       diffuse 0.8
       brilliance 15

   }
   texture { Gold_Texture }
   bounded_by { sphere { <0,0,0>, 3.2 } }
   scale 10
   scale 0.800000
   rotate -90*z
   rotate (-0.000000-60)*x
   rotate -1969.500000*y
   rotate -5.000000*x
   rotate 2.000000*z
   translate <95.000000,70.000000,0.000000>

}

// ========= Jehlan 2 (st©¡brn˜) =========

object {
   Tetrahedron
   pigment { Silver }
   finish {
      crand 0.01
      ambient 0.1
      diffuse 0.7
      reflection 0.4
      brilliance 6.0
   }
   texture { Silver_Texture }
   bounded_by { sphere { <0,0,0>, 3.2 } }
   scale 10
   scale 0.800000
   rotate 90*z
   rotate -0.000000*x
   rotate -1969.500000*y
   rotate -5.000000*x
   rotate 2.000000*z
   translate <95.000000,70.000000,0.000000>

}



// ============== Svˆtlo ================

light_source { <60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate -0.000000*z
}
light_source { <-60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate -0.000000*z
}

// =========== Po‡¡ta‡ =================


union {

// R m monitoru:

   intersection {
      union {
         box { <-36,-34,25> <36,30,80> }
         box { <-36,-38,5> <36,-34,80> }
      }
      plane { <0,1,0.3>, 30}
      plane { <0,-1,0.8>, 70}
      plane { <1,0,0.1>, 40}
      plane { <-1,0,0.1>, 40}
   }

   intersection {
      cone { <0,0,-1>, 51.1 <0,0,31>, 51.1 }
      difference {
         box { <-40,-34,0> <40,34,30> }
         box { <-33,-27,-1> <33,27,20> }
      }
      plane { <0,1,1> 37}
      plane { <1,0,0.45> 43}
      plane { <-1,0,0.45> 43}
   }

// Obrazovka:

   intersection {
      sphere { <0,0,200>, 197}
      box { <-33,-27,0> <33,27,20>}
      texture {
         pigment { color red 0.1 green 0.2 blue 0.2 }
         finish {
            ambient 0.15
            diffuse 0.8
            brilliance 1.0 
            phong 1.0      
            phong_size 90
            reflection 0.15
         }
      }
   }

// Barva pro bednu po‡¡ta‡e:

   finish {
      ambient 0.2
      diffuse 0.8
   }
   pigment { color LightGray }
   bounded_by { box { <-42,-42,-2> <42,42,82> } }
   scale 1.000100
   rotate 0.000000*x
   translate <0.000000, 0.000000, 0.000000>
}


// ============ Obrazovka ==================


box { <-30,-25,0> <30,25,0.1>
   texture {
      pigment {
         image_map { gif "dosman2.gif" once }
         scale <60,50,1>
         translate <-30, -25, 2.5>
      }
      finish {
         ambient 0.15
         diffuse 0.8
         brilliance 1.0 
         phong 1.0      
         phong_size 90
         reflection 0.15
      }
   }
   bounded_by { box { <-31,-26,-1> <31,26,0.2> } }
   scale 1.000100
   translate <0.000000, 0.000000, 0.000000>
}

// ====================== N pis DOSMAN ================


object {Dosman
    scale 1.5
    translate <0,-70,0>
    scale 1.000000 + 0.00001
    translate -2*z
}




// =========== povrch Zeme =================

sphere { <0.0, 0.0, 0.0>, 1000.0
   pigment {
      bozo
      turbulence 0.5
      colour_map {
         [0.0 0.7  colour red 0.0 green 0.3 blue 0.8
                   colour red 0.0 green 0.3 blue 0.8]
         [0.7 1.0  colour red 0.0 green 0.7 blue 0.0
                   colour red 0.6 green 0.7 blue 0.0]
         [1.0 1.01 colour red 0.6 green 0.7 blue 0.0
                   colour red 0.7 green 0.3 blue 0.3]
      }
      quick_color Blue
      scale 200.0
   }
   finish {
      crand 0.08
      ambient 0.35
      diffuse 0.3
   }
rotate -766.500000*y
bounded_by { sphere {<0,0,0>, 1010} }
translate (2000--0.000000)*z
}

// =========== mraky nad Zemi ================

sphere { <0.0, 0.0, 0.0>, 1006
   pigment {
      bozo
      turbulence 1.0
      colour_map {
         [0.0 0.4 colour red 1.0 green 1.0 blue 1.0 filter 1.0
                  colour red 1.0 green 1.0 blue 1.0 filter 1.0]
         [0.4 0.9 colour red 1.0 green 1.0 blue 1.0 filter 1.0
                  colour red 1.0 green 1.0 blue 1.0]
         [0.9 1.0 colour red 1.0 green 1.0 blue 1.0
                  colour red 1.0 green 1.0 blue 1.0]
      }
      scale <240.0, 60.0, 240.0>
   }
   finish {
      ambient 0.35
      diffuse 0.3
   }
rotate (-766.500000/2)*y
bounded_by { sphere {<0,0,0>, 1010} }
translate (2000--0.000000)*z
}

// =========== hvezdy =================
//
//plane { z, 80.0
//     pigment {
//         image_map { gif "stars.gif" /*640x400*/ }
//         scale <200.0, 200.0, 200.0>
//         translate <100,100,0>
//     }
//   // pigment { Black }
//   finish {
//      ambient 1.0
//      diffuse 0.0
//   }
//}

