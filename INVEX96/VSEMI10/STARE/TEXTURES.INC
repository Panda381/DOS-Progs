// Persistence of Vision Raytracer 2.0
// Standard textures include file
// See textures.doc for info.

#declare Textures_Inc_Temp = version

#version 2.0

//*****************************************************************************
//                      STONE PIGMENTS
//*****************************************************************************

// Drew Wells' superb Jade.  Color map works nicely with other textures, too.
#declare Jade = 
 pigment 
  {marble
   turbulence 1.8
   color_map 
    {[0.0, 0.8   color red 0.1 green 0.6 blue 0.1
                 color red 0.0 green 0.3]
     [0.8, 1.001 color red 0.1 green 0.6 blue 0.1
                 color red 0.0 green 0.2]
   }
 }

// Classic white marble with red veins.  Over-worked, like checkers.
#declare Red_Marble = 
 pigment 
  {marble
   turbulence 1
   color_map 
    {[0.0, 0.8   color red 0.8 green 0.8 blue 0.6
                 color red 0.8 green 0.4 blue 0.4]
     [0.8, 1.001 color red 0.8 green 0.4 blue 0.4
                 color red 0.8 green 0.2 blue 0.2]
    }
  }

// White marble with black veins.
#declare White_Marble = 
 pigment 
  {marble
   turbulence 1
   color_map 
    {[0.0, 0.8  color red 0.9 green 0.9 blue 0.9
                color red 0.5 green 0.5 blue 0.5]
     [0.8, 1.01 color red 0.5 green 0.5 blue 0.5
                color red 0.2 green 0.2 blue 0.2]
    }
  }

// Light blue and black marble with a thin red vein 
// Try changing LBlue and Vein below to modify the marble.
#declare LBlue = color red 0.0 green 0.6 blue 0.6
#declare Vein = color red 0.6 green 0.0 blue 0.0
#declare Blood_Marble = 
 pigment 
  {marble
   turbulence 2.3
   color_map 
    {[0.0, 0.8   color Black  color LBlue]
     [0.8, 0.9   color LBlue  color Vein]
     [0.9, 1.001 color Vein   color Black]
    }
  }

// a grey blue agate -- kind of purplish.
#declare Blue_Agate = 
 pigment 
  {agate
   color_map 
    {[0.0, 0.5   color red 0.30 green 0.30 blue 0.50
                 color red 0.30 green 0.30 blue 0.50]
     [0.5, 0.55  color red 0.30 green 0.30 blue 0.50
                 color red 0.20 green 0.20 blue 0.30]
     [0.55, 0.6  color red 0.20 green 0.20 blue 0.30
                 color red 0.25 green 0.25 blue 0.35]
     [0.6, 0.7   color red 0.25 green 0.25 blue 0.35
                 color red 0.15 green 0.15 blue 0.26]
     [0.7, 0.8   color red 0.15 green 0.15 blue 0.26
                 color red 0.10 green 0.10 blue 0.20]
     [0.8, 0.9   color red 0.10 green 0.10 blue 0.20
                 color red 0.30 green 0.30 blue 0.50]
     [0.9, 1.001 color red 0.30 green 0.30 blue 0.50
                 color red 0.10 green 0.10 blue 0.20]
    }
  }

// Deep blue agate -- almost glows.
#declare Sapphire_Agate = 
 pigment 
  {agate
   color_map 
    {[0.0, 0.3   color blue 0.9
                 color blue 0.8]
     [0.3, 1.001 color blue 0.8
                 color blue 0.4]
    }
}

// Brown and white agate -- very pretty.
#declare Brown_Agate = 
 pigment 
  {agate
   color_map 
    {[0.0, 0.5   color White
                 color red 0.9 green 0.7 blue 0.6]
     [0.5, 0.6   color red 0.9 green 0.7 blue 0.6
                 color red 0.9 green 0.7 blue 0.4]
     [0.6, 1.001 color red 0.9 green 0.7 blue 0.4
                 color red 0.7 green 0.4 blue 0.2]
    }
  }

#declare Pink_Granite =  
 pigment 
  {granite
   color_map 
    {[0.0,  0.4  color Black  color Black]
     [0.4,  0.45 color Quartz color Quartz]
     [0.45, 0.5  color Quartz color Gray]
     [0.5,  0.55 color Gray   color Feldspar]
     [0.55, 0.8  color Feldspar color Feldspar]
     [0.8,  1.0  color Feldspar color Orange]
    }
  }

//*****************************************************************************
//                      STONE TEXTURES
//*****************************************************************************

// Gray-pink alabaster or marble.  Layers are scaled for a unit object
// and relative to each other.
#declare PinkAlabaster =
    // Underlying surface is very subtly mottled with bozo
 texture 
  {pigment
    {bozo
     turbulence 0.25
     color_map 
      {[0,  1 color red 0.9 green 0.75 blue 0.75
              color red 0.6 green 0.6  blue 0.6 ]
      }
     scale 0.4
    }
   finish{ambient 0.25}
  }

    // Second layer texture has some filter values, yet a fair amount of color
    // Viening is kept quite thin in color map and by the largish scale.
 texture 
  {pigment
    {granite
     color_map 
      {[0,   0.9 color DustyRose filter 1 color DustyRose filter 0.5]
       [0.9, 1   color DarkSlateGray     color DarkSlateGray]
      }
     scale 2       // Twice as large as unit shape
    }
        // I know this seem contradictory, but it seems to work!
   finish
    {specular 1   roughness 0.0001
     phong 0.25     phong_size 75
     brilliance 4
    }
  }


//*****************************************************************************
//                           SKY PIGMENTS
//*****************************************************************************

// Basic Blue Sky w/ clouds.
#declare Blue_Sky = 
 pigment 
  {bozo
   turbulence 0.3
   color_map 
    {[0.0, 0.5   color red 0.25 green 0.25 blue 0.5
                 color red 0.25 green 0.25 blue 0.5]
     [0.5, 0.6   color red 0.25 green 0.25 blue 0.5
                 color red 0.7  green 0.7  blue 0.7]
     [0.6, 1.001 color red 0.7  green 0.7  blue 0.7
                 color red 0.3  green 0.3  blue 0.3]
    }
  }

// Bright Blue Sky w/ very white clouds.
#declare Bright_Blue_Sky = 
 pigment 
  {bozo
   turbulence 0.56
   color_map 
    {[0.0, 0.5  color red 0.5 green 0.5 blue 1.0
                color red 0.5 green 0.5 blue 1.0]
     [0.5, 0.6  color red 0.5 green 0.5 blue 1.0
                color red 1.0 green 1.0 blue 1.0]
     [0.6, 1.01 color red 1.0 green 1.0 blue 1.0
                color red 0.5 green 0.5 blue 0.5]
    }
  }

// Another sky
#declare Blue_Sky2 = 
 pigment{
   agate
   color_map {
      [ 0, .3  color Blue color Blue  ]
      [.3,  1  color Blue   color White   ]
   }
   scale .75
}

// Small puffs of white clouds
#declare Blue_Sky3 = 
 pigment{
   granite
   turbulence 0.1
   color_map {
      [ 0, .3  color Blue color Blue  ]
      [.3,  1  color Blue   color White   ]
   }
   scale .75
}

// Red sky w/ yellow clouds -- very surreal.
#declare Blood_Sky = 
 pigment 
  {bozo
   turbulence 0.5
   color_map 
    {[0.0, 0.5  color red 0.9 green 0.7
                color red 0.3 green 0.2]
     [0.5, 0.6  color red 0.6 green 0.025
                color red 0.9 green 0.7]
     [0.6, 1.01 color red 0.6 green 0.025
                color red 0.6 green 0.025]
    }
  }

// Black sky with red and purple clouds 
// Try adding turbulence values from 0.1 - 5.0 -- CdW
#declare Apocalypse = 
 pigment 
  {bozo
   color_map 
    {[0.0, 0.4  color red 0.8
                color red 0.4 blue 0.4]
     [0.4, 0.6  color red 0.4 blue 0.4
                color         blue 0.2]
     [0.6, 1.01 color         blue 0.2
                color Black]
    }
  }

// White clouds w/ transparent sky.
#declare Clouds = 
 pigment 
  {bozo
   turbulence 0
   color_map 
    {[0.0, 0.1   color red 0.8 green 0.8 blue 0.8
                 color red 0.8 green 0.8 blue 0.8]
     [0.1, 0.5   color red 0.8 green 0.8 blue 0.8
                 color Clear]
     [0.5, 1.001 color Clear
                 color Clear]
    }
  }

//*****************************************************************************
//                           WOODEN PIGMENTS
//*****************************************************************************

// Several wooden pigments by Tom Price:
// A light reddish wood.
#declare Cherry_Wood = 
 pigment 
  {wood
   turbulence 0.3
   color_map 
    {[0.0, 0.8  color red 0.666 green 0.312 blue 0.2
                color red 0.666 green 0.312 blue 0.2]
     [0.8, 1.01 color red 0.4 green 0.133 blue 0.066
                color red 0.2 green 0.065 blue 0.033]
    }
  }

// A light tan wood with greenish rings.
#declare Pine_Wood = 
 pigment 
  {wood
   turbulence 0.2
   color_map 
    {[0.0, 0.8  color red 1.0 green 0.71875 blue 0.25
                color red 1.0 green 0.71875 blue 0.25]
     [0.8, 1.01 color red 0.5 green 0.5     blue 0.066
                color red 0.4 green 0.4     blue 0.033]
    }
  }

// Dark wood with a greenish hue to it.
#declare Dark_Wood = 
 pigment 
  {wood
   turbulence 0.2
   color_map 
    {[0.0, 0.8  color red 0.42857 green 0.23810 blue 0.04762
                color red 0.42857 green 0.23810 blue 0.04762]
     [0.8, 1.01 color red 0.4     green 0.333   blue 0.066
                color red 0.2     green 0.033   blue 0.033]
    }
  }

// Light tan wood with brown rings.
#declare Tan_Wood = 
 pigment 
  {wood
   turbulence 0.1
   color_map 
    {[0.0, 0.8  color red 0.888 green 0.600 blue 0.3
                color red 0.888 green 0.600 blue 0.3]
     [0.8, 1.01 color red 0.6   green 0.4   blue 0.2
                color red 0.4   green 0.3   blue 0.2]
    }
  }

// A very pale wood with tan rings -- kind of balsa-ish.
#declare White_Wood = 
 pigment 
  {wood
   turbulence 0.6
   color_map 
    {[0.0, 0.8  color red 0.93 green 0.71 blue 0.532
                color red 0.98 green 0.81 blue 0.6]
     [0.8, 1.01 color red 0.6 green 0.333 blue 0.266
                color red 0.7 green 0.6 blue 0.23]
    }
  }

// Brown wood - looks stained.
#declare Tom_Wood = 
 pigment 
  {wood
   turbulence 0.31
   color_map 
    {[0.0, 0.8   color red 0.7 green 0.3
                 color red 0.7 green 0.3]
     [0.8, 1.01  color red 0.5 green 0.2
                 color red 0.4 green 0.1]
    }
  }

// The scaling in these definitions is relative to a unit-sized object
// (radius 1).  Note that woods are functionally equivilent to a log lying
// along the z axis.  For best results, think like a woodcutter trying to
// extract the nicest board out of that log.  A little tilt along the x axis
// will give elliptical rings of grain like you'd expect to find on most
// boards.  Experiment.
// (The first five came from DODEC2.POV in the POV Scenefile Library.)
#declare DMFWood1 = 
 pigment 
  {wood
   turbulence 0.04
   octaves 3
   scale <0.05, .05, 1>
   color_map 
    {[0.00, 0.10 color red 0.60 green 0.30 blue 0.18
                 color red 0.60 green 0.30 blue 0.18]
     [0.10, 0.90 color red 0.60 green 0.30 blue 0.18
                 color red 0.30 green 0.15 blue 0.09]
     [0.90, 1.0  color red 0.30 green 0.15 blue 0.09
                 color red 0.30 green 0.15 blue 0.09]
    }
  }

#declare DMFWood2 = 
 pigment 
  {wood
   turbulence 0.03
   octaves 4
   scale <0.05, .05, 1>
   color_map 
    {[0.00, 0.10 color red 0.52 green 0.37 blue 0.26
                 color red 0.52 green 0.37 blue 0.26]
     [0.10, 0.90 color red 0.52 green 0.37 blue 0.26
                 color red 0.42 green 0.26 blue 0.15]
     [0.90, 1.0  color red 0.42 green 0.26 blue 0.15
                 color red 0.42 green 0.26 blue 0.15]
    }
  }

#declare DMFWood3 = 
 pigment 
  {wood
   turbulence 0.05
   octaves 2
   scale <0.05, .05, 1>
   color_map 
    {[0.00, 0.10 color red 0.4 green 0.133 blue 0.066
                 color red 0.4 green 0.133 blue 0.066]
     [0.10, 0.90 color red 0.4 green 0.133 blue 0.066
                 color red 0.2 green 0.065 blue 0.033]
     [0.90, 1.0  color red 0.2 green 0.065 blue 0.033
                 color red 0.2 green 0.065 blue 0.033]
    }
  }

#declare DMFWood4 = 
 pigment 
  {wood
   turbulence 0.04
   octaves 3
   scale <0.05, .05, 1>
   color_map 
    {[0.00, 0.10 color red 0.888 green 0.600 blue 0.3
                 color red 0.888 green 0.600 blue 0.3]
     [0.10, 0.90 color red 0.888 green 0.600 blue 0.3
                 color red 0.6 green 0.4 blue 0.2]
     [0.90, 1.0  color red 0.6 green 0.4 blue 0.2
                 color red 0.6 green 0.4 blue 0.2]
    }
  }

#declare DMFWood5 = 
 pigment 
  {wood
   turbulence 0.05
   octaves 6
   scale <0.075, .075, 1>
   color_map 
    {[0.00, 0.10 color red 0.3 green 0.1 blue 0.05
                 color red 0.3 green 0.1 blue 0.05]
     [0.10, 0.90 color red 0.3 green 0.1 blue 0.05
                 color red 0.25 green 0.07 blue 0.038]
     [0.90, 1.0  color red 0.25 green 0.07 blue 0.038
                 color red 0.25 green 0.07 blue 0.038]
    }
  }

// Is this really oak?  I dunno.  Quite light, maybe more like spruce.
#declare DMFLightOak =  
 pigment 
  {wood
   turbulence 0.05            // For best results,  keep this low!
   scale <0.2, 0.2, 1>        // Scaled for a unit object
   color_map 
    {[0.00, 0.10 color red 0.42 green 0.26 blue 0.15
                 color red 0.42 green 0.26 blue 0.15]
     [0.10, 0.90 color red 0.42 green 0.26 blue 0.15
                 color red 0.52 green 0.37 blue 0.26]
     [0.90, 1.01 color red 0.52 green 0.37 blue 0.26
                 color red 0.52 green 0.37 blue 0.26]
    }
  }

// Looks like old desk oak if used correctly.
#declare DMFDarkOak = 
 pigment 
  {wood
   turbulence 0.04            // For best results,  keep this low!
   octaves 3
   scale <0.2, 0.2, 1>        // Scaled for a unit object
   color_map 
    {[0.00, 0.10 color red 0.60 green 0.30 blue 0.18
                 color red 0.60 green 0.30 blue 0.18]
     [0.10, 0.90 color red 0.60 green 0.30 blue 0.18
                 color red 0.30 green 0.15 blue 0.09]
     [0.90, 1.01 color red 0.30 green 0.15 blue 0.09
                 color red 0.30 green 0.15 blue 0.09]
    }
  }

// Wood by Eric Barish
#declare EMBWood1 = texture {  /* Bottom wood-grain layer */
   pigment {
      wood
      turbulence 0.05
      colour_map {
         [0.00 0.34  color red 0.58 green 0.45 blue 0.23
                     color red 0.65 green 0.45 blue 0.25]
         [0.34 0.40  color red 0.65 green 0.45 blue 0.25
                     color red 0.33 green 0.23 blue 0.13]
         [0.40 0.47  color red 0.33 green 0.23 blue 0.13
                     color red 0.60 green 0.40 blue 0.20]
         [0.47 1.00  color red 0.60 green 0.40 blue 0.20
                     color red 0.25 green 0.15 blue 0.05]
      }
   }
   finish {
      crand 0.02
      ambient 0.32
      diffuse 0.63
      phong 0.2
      phong_size 10
   }
   normal { bumps 0.05 }
}
texture {     /* top layer, adds small dark spots */
   pigment {
      bozo
      color_map {
         [0.00 0.80  color red 1.00 green 1.00 blue 1.00 filter 1.00
                     color red 1.00 green 0.90 blue 0.80 filter 0.80]
         [0.80 1.00  color red 1.00 green 0.90 blue 0.80 filter 0.80
                     color red 0.30 green 0.20 blue 0.10 filter 0.40]
      }
      scale 0.25
   }
}


//   Doug Otwell woods
//   Yellow pine, close grained
//
#declare Yellow_Pine = texture {
 pigment {
   wood
   turbulence 0.02
   color_map {
      [0.000, 0.222  color red  0.808  green  0.671  blue  0.251  filter  0.000
                     color red  0.808  green  0.671  blue  0.251  filter  0.000]
      [0.222, 0.342  color red  0.808  green  0.671  blue  0.251  filter  0.000
                     color red  0.600  green  0.349  blue  0.043  filter  0.000]
      [0.342, 0.393  color red  0.600  green  0.349  blue  0.043  filter  0.000
                     color red  0.808  green  0.671  blue  0.251  filter  0.000]
      [0.393, 0.709  color red  0.808  green  0.671  blue  0.251  filter  0.000
                     color red  0.808  green  0.671  blue  0.251  filter  0.000]
      [0.709, 0.821  color red  0.808  green  0.671  blue  0.251  filter  0.000
                     color red  0.533  green  0.298  blue  0.027  filter  0.000]
      [0.821, 1      color red  0.533  green  0.298  blue  0.027  filter  0.000
                     color red  0.808  green  0.671  blue  0.251  filter  0.000]
   }
   scale 0.1
   translate <10, 0, 0>
   }
}
// Yellow_Pine layer 2
texture {
 pigment {
   wood
   turbulence 0.01
   color_map {
      [0.000, 0.120   color red  1.000  green  1.000  blue  1.000  filter  1.000
                      color red  0.702  green  0.412  blue  0.118  filter  0.608]
      [0.120, 0.231   color red  0.702  green  0.412  blue  0.118  filter  0.608
                      color red  0.702  green  0.467  blue  0.118  filter  0.608]
      [0.231, 0.496   color red  0.702  green  0.467  blue  0.118  filter  0.608
                      color red  1.000  green  1.000  blue  1.000  filter  1.000]
      [0.496, 0.701   color red  1.000  green  1.000  blue  1.000  filter  1.000
                      color red  1.000  green  1.000  blue  1.000  filter  1.000]
      [0.701, 0.829   color red  1.000  green  1.000  blue  1.000  filter  1.000
                      color red  0.702  green  0.467  blue  0.118  filter  0.608]
      [0.829, 1       color red  0.702  green  0.467  blue  0.118  filter  0.608
                      color red  1.000  green  1.000  blue  1.000  filter  1.000]
   }
   scale 0.5 
   translate <10, 0, 0>
 }
}

//
//   Rosewood
//
#declare Rosewood = texture {
 pigment {
   bozo
   turbulence 0.04
   color_map {
      [0.000, 0.256   color red  0.204  green  0.110  blue  0.078  filter  0.000
                      color red  0.231  green  0.125  blue  0.090  filter  0.000]
      [0.256, 0.393   color red  0.231  green  0.125  blue  0.090  filter  0.000
                      color red  0.247  green  0.133  blue  0.090  filter  0.000]
      [0.393, 0.581   color red  0.247  green  0.133  blue  0.090  filter  0.000
                      color red  0.204  green  0.110  blue  0.075  filter  0.000]
      [0.581, 0.726   color red  0.204  green  0.110  blue  0.075  filter  0.000
                      color red  0.259  green  0.122  blue  0.102  filter  0.000]
      [0.726, 0.983   color red  0.259  green  0.122  blue  0.102  filter  0.000
                      color red  0.231  green  0.125  blue  0.086  filter  0.000]
      [0.983, 1       color red  0.231  green  0.125  blue  0.086  filter  0.000
                      color red  0.204  green  0.110  blue  0.078  filter  0.000]
   }
   scale <0.5, 0.5, 1>
   translate <10, 0, 0>
 }
 finish {
   ambient 0.5
   diffuse 0.8
 }
}
// Rosewood layer 2
texture {
 pigment {
   wood
   turbulence 0.04
   color_map {
      [0.000, 0.139   color red  0.545  green  0.349  blue  0.247  filter  1.000
                      color red  0.000  green  0.000  blue  0.000  filter  0.004]
      [0.139, 0.148   color red  0.000  green  0.000  blue  0.000  filter  0.004
                      color red  0.000  green  0.000  blue  0.000  filter  0.004]
      [0.148, 0.287   color red  0.000  green  0.000  blue  0.000  filter  0.004
                      color red  0.545  green  0.349  blue  0.247  filter  1.000]
      [0.287, 0.443   color red  0.545  green  0.349  blue  0.247  filter  1.000
                      color red  0.545  green  0.349  blue  0.247  filter  1.000]
      [0.443, 0.626   color red  0.545  green  0.349  blue  0.247  filter  1.000
                      color red  0.000  green  0.000  blue  0.000  filter  0.004]
      [0.626, 0.635   color red  0.000  green  0.000  blue  0.000  filter  0.004
                      color red  0.000  green  0.000  blue  0.000  filter  0.004]
      [0.635, 0.843   color red  0.000  green  0.000  blue  0.000  filter  0.004
                      color red  0.545  green  0.349  blue  0.247  filter  1.000]
      [0.843, 1       color red  0.545  green  0.349  blue  0.247  filter  1.000
                      color red  0.545  green  0.349  blue  0.247  filter  1.000]
   }
   scale <0.5, 0.5, 1>
   translate <10, 0, 0>
 }
 finish {
   ambient 0.5
   diffuse 0.8
 }
}

//
//   Sandalwood ( makes a great burled maple, too)
//
#declare Sandalwood = texture {
 pigment {
   bozo
   turbulence 0.2
   color_map {
      [0.000, 0.171   color red  0.725  green  0.659  blue  0.455  filter  0.000
                      color red  0.682  green  0.549  blue  0.420  filter  0.000]
      [0.171, 0.274   color red  0.682  green  0.549  blue  0.420  filter  0.000
                      color red  0.557  green  0.451  blue  0.322  filter  0.000]
      [0.274, 0.393   color red  0.557  green  0.451  blue  0.322  filter  0.000
                      color red  0.725  green  0.659  blue  0.455  filter  0.000]
      [0.393, 0.564   color red  0.725  green  0.659  blue  0.455  filter  0.000
                      color red  0.682  green  0.549  blue  0.420  filter  0.000]
      [0.564, 0.701   color red  0.682  green  0.549  blue  0.420  filter  0.000
                      color red  0.482  green  0.392  blue  0.278  filter  0.000]
      [0.701, 1       color red  0.482  green  0.392  blue  0.278  filter  0.000
                      color red  0.725  green  0.659  blue  0.455  filter  0.000]
   }
   scale <0.2, 0.2, 1>
   scale 2
 }
}
// Sandalwood layer 2
texture {
 pigment {
   bozo
   turbulence 0.8
   color_map {
      [0.000, 0.087   color red  0.682  green  0.604  blue  0.380  filter  1.000
                      color red  0.761  green  0.694  blue  0.600  filter  0.020]
      [0.087, 0.226   color red  0.761  green  0.694  blue  0.600  filter  0.020
                      color red  0.635  green  0.553  blue  0.325  filter  1.000]
      [0.226, 0.348   color red  0.635  green  0.553  blue  0.325  filter  1.000
                      color red  0.761  green  0.694  blue  0.600  filter  0.020]
      [0.348, 0.496   color red  0.761  green  0.694  blue  0.600  filter  0.020
                      color red  0.682  green  0.604  blue  0.380  filter  1.000]
      [0.496, 0.565   color red  0.682  green  0.604  blue  0.380  filter  1.000
                      color red  0.761  green  0.694  blue  0.600  filter  0.020]
      [0.565, 0.661   color red  0.761  green  0.694  blue  0.600  filter  0.020
                      color red  0.682  green  0.604  blue  0.380  filter  1.000]
      [0.661, 0.835   color red  0.682  green  0.604  blue  0.380  filter  1.000
                      color red  0.761  green  0.694  blue  0.600  filter  0.020]
      [0.835, 1       color red  0.761  green  0.694  blue  0.600  filter  0.020
                      color red  0.682  green  0.604  blue  0.380  filter  1.000]
   }
   scale 0.2
   scale 2
 }
}


//*****************************************************************************
//                     SURFACE FINISHES
//*****************************************************************************


// Dull creates a large, soft highlight on the object's surface
#declare Dull = finish {specular 0.5 roughness 0.15}

// Shiny creates a small, tight highlight on the object's surface
#declare Shiny = finish {specular 1 roughness 0.001}

// Phong highlights are less "realistic" than specular, but useful
// for different effects.
// Dull creates a large, soft highlight on the object's surface
#declare Phong_Dull = finish {phong 0.5  phong_size 1}

// Shiny creates a small, tight highlight on the object's surface
#declare Phong_Shiny = finish {phong 1  phong_size 200}

// Very shiny with very tight highlights and a fair amount of reflection
#declare Glossy = finish {specular 1 roughness 0.0001 reflection 0.13}
#declare Phong_Glossy = finish {phong 1 phong_size 300 reflection 0.13}

// Luminous for shadowless skies and light_sources.
#declare Luminous = finish {ambient 1  diffuse 0}

// a perfectly mirrored finish with no highlights
#declare Mirror = finish {ambient 0  diffuse 0 reflection 1}

//*****************************************************************************
//                           GLASS TEXTURES
//*****************************************************************************


#declare Glass_Finish= 
  finish
   {Shiny
    ambient 0
    diffuse 0
    reflection 0.1
    refraction 1
    ior 1.5
   }

#declare Glass = 
 texture
   {pigment
     {color White filter 0.7}
    finish
     {Glass_Finish}
   }

// Probably more of a "Plexiglas" than glass
#declare Glass2 = 
 texture
   {pigment {color Clear}
    finish 
     {ambient 0
      diffuse 0
      reflection 0.5
      refraction 0.85
      ior 1.5
      phong 0.3
      phong_size 60
     }
   }

// An excellent lead crystal glass!
#declare Glass3 = 
 texture
   {pigment
     {color red 0.98 green 0.98 blue 0.98 filter 0.9}
    finish 
     {ambient 0.1
      diffuse 0.1
      specular 0.8
      reflection 0.1
      refraction 0.9
      ior 1.45
      roughness 0.0003
      phong 1 phong_size 400
     }
   }

#declare Green_Glass = 
 texture 
   {Glass3
    pigment {color red 0.8 green 1 blue 0.95 filter 0.9}
   }

//*****************************************************************************
//                           METAL FINISHES
//*****************************************************************************

#declare Metal = 
 finish
  {metallic
   ambient 0.2
   diffuse 0.7
   brilliance 6
   reflection 0.25
   phong 0.75
   phong_size 80
  }

//*****************************************************************************
//                           METAL TEXTURES
//*****************************************************************************


// Good looking "metal" textures 
// IMPORTANT: They REQUIRE that colors.inc be included BEFORE textures.inc!

#declare Chrome_Texture = 
 texture 
  {pigment{color LightGray}
   finish
    {ambient 0.3
     diffuse 0.7
     reflection 0.15
     brilliance 8
     specular 0.8
    roughness 0.1
   }
  }

// A series of metallic textures using the Metal texture:
#declare Brass_Texture   = texture {pigment{color Brass     }finish{Metal}}
#declare Gold_Texture    = texture {pigment{color BrightGold}finish{Metal}}
#declare Bronze_Texture  = texture {pigment{color Bronze    }finish{Metal}}
#declare Copper_Texture  = texture {pigment{color Copper    }finish{Metal}}
#declare Silver_Texture  = texture {pigment{color Silver    }finish{Metal}}

// In the future, please refer to Chrome_Texture by this name.  I'd like
// to scrap the old name someday. Ditto with other "_Texture" names!
#declare Chrome_Metal = texture { Chrome_Texture }
#declare Brass_Metal  = texture { Brass_Texture  }
#declare Bronze_Metal = texture { Bronze_Texture }
#declare Gold_Metal   = texture { Gold_Texture   }
#declare Bronze_Metal = texture { Bronze_Texture }
#declare Copper_Metal = texture { Copper_Texture }

// A couple highly reflective metal textures.
#declare Polished_Chrome = texture {
    pigment { Gray20 }
    finish {
        ambient 0.1
        diffuse 0.7
        brilliance 6.0
        reflection 0.6
        phong 0.8
        phong_size 120
    }
}

#declare Polished_Brass = texture {
    pigment { color red 0.578 green 0.422 blue 0.195 }
    finish {
        metallic
        ambient 0.1
        diffuse 0.8
        brilliance 6.0
        reflection 0.4
        phong 0.8
        phong_size 120
   }
}


// Beautiful military brass texture!
declare New_Brass = texture {
   pigment { color red 0.70  green 0.56  blue 0.37 }
   finish {
       ambient 0.35
       diffuse 1.00
       brilliance 15
       phong 0.41
       phong_size 5
   }
}


// Spun Brass texture for cymbals & such
#declare Spun_Brass = texture { New_Brass
    normal { waves 0.35 frequency 2 scale 0.01 }
}


#declare SilverFinish = finish {
    metallic
    ambient 0.25
    diffuse 0.65
    reflection 0.45
    brilliance 6
    phong 1
    phong_size 100
}


// Each of these looks good.  Slightly bluer as you go down
#declare Silver1_Colour = color  red 0.94 green 0.93 blue 0.83
#declare Silver2_Colour = color  red 0.94 green 0.93 blue 0.86
#declare Silver3_Colour = color  red 0.94 green 0.93 blue 0.90

#declare Silver1 = texture {
    pigment { Silver1_Colour }
    finish { SilverFinish }
}

#declare Silver2 = texture {
    pigment { Silver2_Colour }
    finish { SilverFinish }
}

#declare Silver3 = texture {
    pigment { Silver3_Colour }
    finish { SilverFinish }
}


// Interesting texture -- Give it a try.
// Sort of a "Black Hills Gold", black, white, and orange specks or splotches.
#declare Brass_Valley = 
 texture 
  {pigment
    {granite
     color_map 
      {[0.0, 0.3   color Feldspar  color Feldspar]
       [0.3, 0.6   color Mica      color Quartz]
       [0.6, 1.001 color Feldspar  color Quartz]
      }
    }
   finish
    {metallic
     brilliance 6.0
     reflection 0.75
     phong 0.75
    }
  }

#declare Rusty_Iron = 
 pigment 
  {agate
   color_map 
    {[0.0, 0.5   color red 0.21 green 0.1 blue 0.1
                 color red 0.25 green 0.25 blue 0.01]
     [0.5, 0.6   color red 0.25 green 0.25 blue 0.01
                 color red 0.3 green 0.1 blue 0.1]
     [0.6, 1.001 color red 0.15 green 0.1 blue 0.1
                 color red 0.15 green 0.1 blue 0.1]
    }
  }

#declare Rust = 
 pigment 
  {spotted
   color_map 
    {[0.0, 0.4   color red 0.89 green 0.51 blue 0.28
                 color red 0.70 green 0.13]
     [0.4, 0.5   color red 0.70 green 0.13
                 color red 0.69 green 0.41 blue 0.08]
     [0.5, 0.6   color red 0.69 green 0.41 blue 0.08
                 color red 0.49 green 0.31 blue 0.28]
     [0.6, 1.001 color red 0.49 green 0.31 blue 0.28
                 color red 0.89 green 0.51 blue 0.28]
    }
  }


//*****************************************************************************
//                    SPECIAL EFFECTS
//*****************************************************************************

// Red & white stripes - Looks best on a y axis Cylinder
// It "spirals" because it's gradient on two axis
#declare Candy_Cane = 
 pigment 
  {gradient x+y
   color_map 
    {[0.00, 0.25  color Red 
                  color Red]
     [0.25, 0.75  color White
                  color White]
     [0.75, 1.001 color Red 
                  color Red]
    }
  }

// Orange and Clear stripes spiral around the texture
// to make an object look like it was "Peeled"
// Now, you too can be M.C. Escher 
#declare Peel = texture {
 pigment 
  {gradient < 1, 1, 0 > 
   color_map {
      [0.00, 0.25  color Orange
                   color Orange]
      [0.25, 0.75  color Clear
                   color Clear]
      [0.75, 1.001 color Orange
                   color Orange]
   }
 }
}

#declare Y_Gradient = 
 pigment 
  {gradient y
   color_map 
    {[0.00, 0.33  color Red 
                  color Blue]
     [0.33, 0.66  color Blue 
                  color Green]
     [0.66, 1.001 color Green
                  color Red]
    }
  }

#declare X_Gradient = 
 pigment 
  {gradient x
   color_map 
    {[0.00, 0.33  color Red 
                  color Blue]
     [0.33, 0.66  color Blue
                  color White]
     [0.66, 1.001 color White
                  color White]
    }
  }

// A good wavy water example.
// Requires a sub-plane, and may require scaling to fit your scene.
#declare Water = 
  texture 
   {pigment{color Blue filter 0.9}
    normal
     {ripples 0.75
      frequency 10
     }
    finish
     {reflection 0.3
      refraction 0.5
      ior 1.33
     }
   }

#declare Cork = texture {
  pigment {
    granite
    color_map {
      [0.0, 0.6  color red 0.93 green 0.71 blue 0.532
                 color red 0.98 green 0.81 blue 0.60]
      [0.6, 0.65 color red 0.50 green 0.30 blue 0.20
                 color red 0.50 green 0.30 blue 0.20]
      [0.65, 1.0 color red 0.80 green 0.53 blue 0.46
                 color red 0.85 green 0.75 blue 0.35]
    }
    scale 0.25     // Generally looks best scaled
                   // longer on one axis
   }
   finish{specular 0.1 roughness 0.5 }// Very dull 
}

#version Textures_Inc_Temp 

// end of file
