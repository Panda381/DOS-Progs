
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
   rotate -529.500000*y
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
   rotate -529.500000*y
   rotate -5.000000*x
   rotate 2.000000*z
   translate <95.000000,70.000000,0.000000>

}



// ============== Obloha ================

plane { y, 500.0
   pigment {
      Bright_Blue_Sky
      quick_colour red 0.5 green 0.5 blue 0.8
      scale <2000.0, 500.0, 1000.0>
   }
   finish {
      crand 0.05
      ambient 0.7*1.000000
      diffuse 0.0
   }
translate <0,-0.000000,-0.000000>
rotate 0.000000*z
}

// ============== Oce n ================

plane { y, -100
   pigment {colour blue 1 green 0.3}
   normal {
      waves 1
      frequency 500
      scale 3000
   }
   finish {reflection 1}
   translate <114.600000, 0, 0>
translate <0,-0.000000,-0.000000>
rotate 0.000000*z
}

// ============= Sk ly ===================

height_field {
   gif "fract003.gif" 
   pigment {
      image_map { gif "fract003.gif" }
      quick_color White
      rotate 90*x
      scale <320.0, 1.0, 200.0>
      translate <0.0, 0.0, -1.0>
   }
   bounded_by { box { <-1.5,-1.5,-1.5> <1.5,1.5,1.5> } }
   scale <320, 256, 200>
   translate <-160.0, 0, -100.0>

   scale <4.0, 0.5, 4.0>
   rotate 140*y
   translate <400.0, -110.0, 800.0>
translate <0,-0.000000,-0.000000>
rotate 0.000000*z
}


// ============== Svˆtlo ================

light_source { <60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate 0.000000*z
}
light_source { <-60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate 0.000000*z
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
   scale 0.485600
   translate <73.500000, 55.125000, -59.170488>
}

// ====================== N pis DOSMAN ================



