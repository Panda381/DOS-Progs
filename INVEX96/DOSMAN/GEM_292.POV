
#include "shapes.inc"
#include "shapes2.inc"
#include "colors.inc"
#include "textures.inc"

#include "gem_gem.inc"

// ============== Napis GEMA Soft ===========


object { Gema
    scale 1.6
    translate <0,270.000000,360.000000>
}


// ============== Kamera =================

camera {
   location <0.0, 0.0, -200.0>
   direction <0.0, 0.0, 1.0>
   up <0.0, 1.0, 0.0>
   right <4/3, 0.0, 0.0>
}

// ========== Jehlan 1 (zlat�) ===========


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
   scale 1.000000
   rotate -90*z
   rotate (-0.000000-60)*x
   rotate -108.000000*y
   rotate -0.000000*x
   rotate 0.000000*z
   translate <0.000000,0.000000,-100.000000>

}

// ========= Jehlan 2 (st��brn�) =========

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
   scale 1.000000
   rotate 90*z
   rotate -0.000000*x
   rotate -108.000000*y
   rotate -0.000000*x
   rotate 0.000000*z
   translate <0.000000,0.000000,-100.000000>

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

// ============== Oce�n ================

plane { y, -100
   pigment {colour blue 1 green 0.3}
   normal {
      waves 1
      frequency 500
      scale 3000
   }
   finish {reflection 1}
   translate <58.400000, 0, 0>
translate <0,-0.000000,-0.000000>
rotate 0.000000*z
}

// ============= Sk�ly ===================

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


// ============== Sv�tlo ================

light_source { <60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate 0.000000*z
}
light_source { <-60.0, 60.0, -200.0> colour red 1.000000 blue 1.000000 green 1.000000
rotate 0.000000*z
}

// =========== Po��ta� =================


// ============ Obrazovka ==================

// ====================== N�pis DOSMAN ================



