//-----------------------------------------------------------------------
// Yet Another Parameterized Projectbox generator
//
//  This is a box for BME 280 sensor board with inline connector
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


// V1: initial version, large slack, too long, too large opening for cables, too high
// V2: smaller slack, shorter and lower box, smaller opening.

printBaseShell      = true;
printLidShell       = true;

// Edit these parameters for your own board dimensions
wallThickness       = 2.0;
basePlaneThickness  = 2.0;
lidPlaneThickness   = 2.0;

//-- total height inside  = baseWallHeight + lidWallHeight 
baseWallHeight      = 5;
lidWallHeight       = 2.5;

// ridge where base and lid off box can overlap
// Make sure this isn't less than lidWallHeight
ridgeHeight         = 3.5;
ridgeSlack          = 0.2;
roundRadius         = 2.0;

// How much the PCB needs to be raised from the base
// to leave room for solderings and whatnot
standoffHeight      = 2.0;        // 2mm reserve is perfectly OK
pinDiameter         = 3.0 - 0.1;  // 3mm hole in the PCB - .1mm slack
pinHoleSlack        = 0.3;  // slack only for the top lid pinhole, not for PCB!
standoffDiameter    = 5;    // larger than the pins, to better support the PCB

// Total height of box = basePlaneThickness + lidPlaneThickness 
//                     + baseWallHeight + lidWallHeight
pcbLength           = 30;
pcbWidth            = 16;
pcbThickness        = 1.6;
                            
// padding between pcb and inside wall
paddingFront        = 3;
paddingBack         = 6;
paddingRight        = 3;
paddingLeft         = 3;


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


// pcbStands fixate the PCB between the base and the lid.
//-- pcb_standoffs  -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = { yappBoth | yappLidOnly | yappBaseOnly }
// (3) = { yappHole, YappPin }
pcbStands = [
                [pcbLength-2.4,  2.4, yappBoth, yappPin] 
               ,[pcbLength-2.4,  pcbWidth-2.4, yappBoth, yappPin] 
             ];     

//-- Lid plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLid = [];

//-- base plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBase = [];

//-- front plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsFront = [];

//-- back plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBack =   [
  [ (pcbWidth - 12)/2, -2, 12, 2, 0, yappRectangle ]    // data cables to sensor
];

//-- left plane   -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLeft = [];

//-- right plane   -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsRight = [];

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
  [ -1,  -1, pcbWidth+2, 23, 2, 2, 45, "base" ],
  [ -1,  -1, pcbWidth+2, 23, 2, 2, 45, "lid" ],
];

// Connectors between Base and Lid (not touching the PCB). For holding the Base and the Lid together if needed.
//-- connectors -- origen = box[0,0,0]
// (0) = posx
// (1) = posy
// (2) = screwDiameter
// (3) = insertDiameter
// (4) = outsideDiameter
// (5) = { yappAllCorners }
connectors = [];

// ConnectorsPCB between Base and Lid that fixates the PCB. Larger than pcbStands (to fit screws in) but with a space between them for PCB.
//-- connectorsPCB -- origin = pcb[0,0,0]
//-- a connector that allows to screw base and lid together through holes in the PCB
// (0) = posx
// (1) = posy
// (2) = screwDiameter
// (3) = insertDiameter
// (4) = outsideDiameter
// (5) = { yappAllCorners }
connectorsPCB = [];


// SnapJoins keep the Base and Lid together.
//-- snap Joins -- origen = box[x0,y0]
// (0) = posx | posy
// (1) = width
// (2..5) = yappLeft / yappRight / yappFront / yappBack (one or more)
// (n) = { yappSymmetric }
snapJoins   =     [
                    [2, 10, yappLeft, yappRight, yappSymmetric]
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
