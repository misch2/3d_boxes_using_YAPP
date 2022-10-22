//-----------------------------------------------------------------------
// Yet Another Parameterized Projectbox generator
//
//  This is a box for <template>
//
//  Version 1.6 (06-10-2022)
//
// This design is parameterized based on the size of a PCB.
//
//  for many or complex cutoutGrills you might need to adjust
//  the number of elements:
//
//      Preferences->Advanced->Turn of rendering at 100000 elements
//                                                  ^^^^^^
//
//-----------------------------------------------------------------------


include <./library/YAPPgenerator_v16.scad>

// Note: length/lengte refers to X axis, 
//       width/breedte to Y, 
//       height/hoogte to Z

/*
            padding-back>|<---- pcb length ---->|<padding-front
                                 RIGHT
                   0    X-ax ---> 
               +----------------------------------------+   ---
               |                                        |    ^
               |                                        |   padding-right 
             ^ |                                        |    v
             | |    -5,y +----------------------+       |   ---              
        B    Y |         | 0,y              x,y |       |     ^              F
        A    - |         |                      |       |     |              R
        C    a |         |                      |       |     | pcb width    O
        K    x |         |                      |       |     |              N
               |         | 0,0              x,0 |       |     v              T
               |   -5,0  +----------------------+       |   ---
               |                                        |    padding-left
             0 +----------------------------------------+   ---
               0    X-ax --->
                                 LEFT
*/

// OK
printBaseShell      = true;
printLidShell       = true;

// Edit these parameters for your own board dimensions
// OK
wallThickness       = 2.0;
basePlaneThickness  = 2.0;
lidPlaneThickness   = 2.0;

//-- total height inside  = baseWallHeight + lidWallHeight 
// OK
baseWallHeight      = 15;
lidWallHeight       = 15;

// ridge where base and lid off box can overlap
// Make sure this isn't less than lidWallHeight
// OK
ridgeHeight         = 4;
ridgeSlack          = 0.2;
roundRadius         = 2.0;

// How much the PCB needs to be raised from the base
// to leave room for solderings and whatnot
// OK
standoffHeight      = 5.0;        // PCB needs 3mm, + 2mm reserve
pinDiameter         = 3.0 - 0.2;  // 3mm hole in the PCB - .2mm slack
pinHoleSlack        = 0.3;
standoffDiameter    = 5;    // larger than the holes, to support the PCV

// Total height of box = basePlaneThickness + lidPlaneThickness 
//                     + baseWallHeight + lidWallHeight
// OK
pcbLength           = 49;
pcbWidth            = 26;
pcbThickness        = 1.5;
                            
// padding between pcb and inside wall
// OK
paddingFront        = 5;
paddingBack         = 3;
paddingRight        = 5;
paddingLeft         = 5;


//-- D E B U G -------------------
showSideBySide      = true;
hideLidWalls        = false;
onLidGap            = 4;
shiftLid            = 10;
colorLid            = "yellow";
hideBaseWalls       = false;
colorBase           = "white";
showPCB             = true;
showMarkers         = false;
inspectX            = 0;  // 0=none, >0 from front, <0 from back
inspectY            = 0;  // 0=none, >0 from left, <0 from right


//-- pcb_standoffs  -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = { yappBoth | yappLidOnly | yappBaseOnly }
// (3) = { yappHole, YappPin }
pcbStands = [
                [2.1,  2.1, yappBoth, yappPin] 
               ,[2.1,  pcbWidth-2.1, yappBoth, yappPin] 
               ,[pcbLength-2.1,  2.1, yappBoth, yappPin] 
               ,[pcbLength-2.1,  pcbWidth-2.1, yappBoth, yappPin] 
             ];     

//-- Lid plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLid =  [
               //     [20, 20, 10, 20, 10, yappRectangle]  
               //   , [20, 50, 10, 20, 0, yappRectangle, yappCenter]
               //   , [50, 50, 10, 2, 0, yappCircle]
               //   , [pcbLength-10, 20, 15, 0, 0, yappCircle] 
               //   , [50, pcbWidth, 5, 7, 0, yappRectangle, yappCenter]
              ];

//-- base plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBase =   [
                 //   [10, 10, 20, 10, 45, yappRectangle]
                 // , [30, 10, 15, 10, 45, yappRectangle, yappCenter]
                 // , [20, pcbWidth-20, 15, 0, 0, yappCircle]
                 // , [pcbLength-15, 5, 10, 2, 0, yappCircle]
                ];

//-- front plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }

cutoutsFront =  [
//                    [0, 5, 10, 15, 0, yappRectangle]               // org
//                 ,  [25, 3, 10, 10, 0, yappRectangle, yappCenter]  // center
//                 ,  [60, 10, 15, 6, 0, yappCircle]                 // circle
                    [(pcbWidth - 20)/2, -1, 20, 4, 0, yappRectangle ]    // data cables to sensor
                ];

//-- back plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBack =   [
//                    [0, 0, 10, 8, 0, yappRectangle]                // org
//                  , [25, 18, 10, 6, 0, yappRectangle, yappCenter]  // center
//                  , [50, 0, 8, 8, 0, yappCircle]                   // circle
                    [13, -(1.25 + 3/2), 10, 5, 0, yappRectangle, yappCenter] // microUSB connector
                ];

//-- left plane   -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLeft =   [
//                    [25, 0, 6, 20, 0, yappRectangle]                       // org
//                  , [pcbLength-35, 0, 20, 6, 0, yappRectangle, yappCenter] // center
//                  , [pcbLength/2, 10, 20, 6, 0, yappCircle]                // circle
                ];

//-- right plane   -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsRight =  [
//                    [10, 0, 9, 5, 0, yappRectangle]                // org
//                  , [40, 0, 9, 5, 0, yappRectangle, yappCenter]    // center
//                  , [60, 0, 9, 5, 0, yappCircle]                   // circle
                ];

//-- cutoutGrills    -- origin is pcb[x0,y0, zx]
// (0) = xPos
// (1) = yPos
// (2) = grillWidth
// (3) = grillLength
// (4) = gWidth
// (5) = gSpace
// (6) = gAngle
// (7) = plane {"base" | "lid" }
// (8) = {polygon points}}

cutoutsGrill = [
//                 [35,  8, 70, 70, 2, 3, 50, "base" ]
//                ,[ 0, 20, 10, 40, 2, 3, 50, "lid"]
//                ,[45,  0, 50, 10, 2, 3, 45, "lid"]
                //,[15, 85, 50, 10, 2, 3,  20, "base"]
                //,[85, 15, 10, 50, 2, 3,  45, "lid"]
            [ 13,  2, 22,  22, 2, 2, 45, "base" ],
            [ 13,  2, 22,  22, 2, 2, 45, "lid" ],
            //[ 5,  7, 12,  40, 2, 2, 45, "lid" ],
               ];

//-- connectors -- origen = box[0,0,0]
// (0) = posx
// (1) = posy
// (2) = screwDiameter
// (3) = insertDiameter
// (4) = outsideDiameter
// (5) = { yappAllCorners }
connectors   =  [
//                    [8, 8, 2.5, 3.8, 5, yappAllCorners]
//                  , [30, 8, 5, 5, 5]
                ];
                
//-- connectorsPCB -- origin = pcb[0,0,0]
//-- a connector that allows to screw base and lid together through holes in the PCB
// (0) = posx
// (1) = posy
// (2) = screwDiameter
// (3) = insertDiameter
// (4) = outsideDiameter
// (5) = { yappAllCorners }
connectorsPCB   =  [
//                    [pcbLength/2, 10, 2.5, 3.8, 5]
//                   ,[pcbLength/2, pcbWidth-10, 2.5, 3.8, 5]
                ];

//-- snap Joins -- origen = box[x0,y0]
// (0) = posx | posy
// (1) = width
// (2..5) = yappLeft / yappRight / yappFront / yappBack (one or more)
// (n) = { yappSymmetric }
snapJoins   =     [
                    [2, 10, yappLeft, yappRight, yappSymmetric]
              //    [5, 10, yappLeft]
              //  , [shellLength-2, 10, yappLeft]
//                  , [30,  10, yappFront, yappBack]
              //  , [2.5, 3, 5, yappBack, yappFront, yappSymmetric]
                ];
               
//-- origin of labels is box [0,0,0]
// (0) = posx
// (1) = posy/z
// (2) = orientation
// (3) = plane {lid | base | left | right | front | back }
// (4) = font
// (5) = size
// (6) = "label text"
labelsPlane =  [
                    [10,  10,   0, "lid",   "Liberation Mono:style=bold", 7, "YAPP" ]
                  , [100, 90, 180, "base",  "Liberation Mono:style=bold", 7, "Base" ]
                  , [8,    8,   0, "left",  "Liberation Mono:style=bold", 7, "Left" ]
                  , [10,   5,   0, "right", "Liberation Mono:style=bold", 7, "Right" ]
                  , [40,  23,   0, "front", "Liberation Mono:style=bold", 7, "Front" ]
                  , [5,    5,   0, "back",  "Liberation Mono:style=bold", 7, "Back" ]
               ];


//========= MAIN CALL's ===========================================================
  
//===========================================================
module lidHookInside()
{
  //echo("lidHookInside(original) ..");
  
} // lidHookInside(dummy)
  
//===========================================================
module lidHookOutside()
{
  //echo("lidHookOutside(original) ..");
  
} // lidHookOutside(dummy)

//===========================================================
module baseHookInside()
{
  //echo("baseHookInside(original) ..");
  
} // baseHookInside(dummy)

//===========================================================
module baseHookOutside()
{
  //echo("baseHookOutside(original) ..");
  
} // baseHookOutside(dummy)




//---- This is where the magic happens ----
YAPPgenerate();
