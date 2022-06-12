/* Sample 3DS texture library for 3ds2pov */

#declare WHITE_PAINT_2S = texture {
//   pigment {
//      wood
//      turbulence 0.1
//      colour_map {
//         [ 0.0 0.35 colour red 0.7  green 0.4
//                    colour red 0.7  green 0.4  ]
//         [ 0.35 1.0 colour red 0.95 green 0.62
//                    colour red 0.95 green 0.62 ]
//      }
//      scale <0.6, 1000.0, 0.6>
//      translate <200.0, 0.0, 100.0>
//   }
//   finish {
//      specular 1
//      roughness 0.02
//   }
    finish {phong 1.0
    phong_size 70.0
    ambient 0.1
    diffuse 0.7}
//    pigment {color red 0.7 green 0.52 blue 0.4}
    pigment {color White}
}

#declare PLUM_PLASTIC = texture {
    finish {phong 1.0
    ambient 0.1
    diffuse 0.8
    phong_size 70.0}
    pigment {color Plum}
}

#declare ORANGE_PLASTIC = texture {
    finish {phong 1.0
    ambient 0.1
    diffuse 0.8
    phong_size 70.0}
    pigment {color red 1 green 0.5 blue 0.0 }
}

#declare RED_MATTE = texture {
    finish {Shiny}
    pigment {color Red}
}

#declare CHOPPER_BODY = texture {
    finish {Shiny}
    pigment {color Blue}
}

#declare WHITE_PLASTIC_2S = texture {
    finish {Shiny}
    pigment {color White}
}

#declare BIRD_LEGS_TEXP = texture {
    finish {Dull}
    pigment {color red 1 green 0.5 blue 0.3 }
}

#declare BIRD_GRAD_TEXP = texture {
    finish {Shiny}
    pigment {color red 0.2 green 0.8 blue 1}
}

#declare RED_PLASTIC = texture {
    finish {Shiny}
    pigment {color Red}
}

#declare BLACK_PLASTIC = texture {
    finish {Shiny}
    pigment {color Black}
}

#declare YELLOW_PLASTIC = texture {
    finish {phong 1.0
    ambient 0.1
    diffuse 0.8
    phong_size 70.0}
    pigment {color red 0.8 green 0.7 }
}

#declare Default = texture {
    finish {phong 1.0
    ambient 0.1
    diffuse 0.7
    phong_size 70.0}
    pigment {color White}
}

/* Obloha */

//sphere { <0, 0, -39000>, 40000
sphere { <0, 0, -78600>, 80000
   inverse

   pigment {
      bozo
      turbulence 0.6
      colour_map {
         [0 0.5 colour red 0.4 green 0.5 blue 1
                colour red 0.4 green 0.5 blue 1.0]
         [0.5 0.7 colour red 0.4 green 0.5 blue 1
                  colour red 1 green 1 blue 1.0]
         [0.7 1 colour red 1 green 1 blue 1
                colour red 0.7 green 0.7 blue 0.7]
      }
      scale 500
      quick_color red 0.4 green 0.5 blue 1
   }
   finish {
      ambient 1
      diffuse 0
   }
}

///* Zemˆ */
//plane { z, -300
//  pigment { Green }
//  finish {
//     crand 0.05
//     ambient 0.5
//     diffuse 0.5
//  }
//}

///* Light: goldlite */
//light_source {
//    <-500, -500, 700> color rgb <0.5, 0.45, 0.4>
//}
//
//light_source {
//    <500, -500, 700> color rgb <0.5, 0.45, 0.4>
//}
//
//light_source {
//    <-500, 500, 700> color rgb <0.5, 0.45, 0.4>
//}
//
//light_source {
//    <500, 500, 700> color rgb <0.5, 0.45, 0.4>
//}


///* Light: Light01 */
//light_source {
//    <4295.3286, 1533.5679, 833.7509> color rgb <1.00, 1.00, 1.00>
//}
