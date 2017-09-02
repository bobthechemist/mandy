(* ::Package:: *)

BeginPackage["PTPixels`"];

startCommunication::usage = "opens serial communication to Arduino.";
loadElementData::usage = "Reads and processes the properties file.";
blankScreen::usage = "Turns all pixels off.";
formatCommand::usage = "Converts arduino command into properly formatted string.";
sendCommand::usage = "Sends a properly formatted command string to arduino.";
setElement::usage = "Manually set an element to a specified color";
setBrightness::usage = "Change the maximum brightness of pixels";
stopCommunication::usage = "closes serial communication to Arduino.";
toByteRGB::usage = "Convert Mathematica 0-1 Real RGB values to 8-bit RGB value";
display::usage = "Displays a property.";
display2::usage = "Test new display.";
getColor::usage = "Returns the correct color.";
listen::usage = "Returns the serial buffer.";
getZColor::usage = "Returns a list of RGB values for the requested element.";
setZColor::usage = "Sets element color using format [Z, {R, G, B}]";
story::usage = "One of several storys that Mandy knows.";
notNumericQ::usage = "Opposite of NumericQ.";
mandyRescale::usage = "Rescale after deleting non-numeric values.";
Begin["`Private`"];
$pauselength = 0.010;
$color = "Hue";
$arduino = Null;
$numelements = 118; (* for debugging *)
(* Full path to make integration with other programs easier *)
$propertyfile = "/home/pi/mandy/wl/elementdata.csv";
$associationfile = "/home/pi/mandy/wl/rawelementdata.wl";
$properties = Null;
$dataset = Null;
$maxbrightness = 64;
$storydata = Null;
$version = 170820;

(* Messages *)
pixel::notconnected = "Requested pixel does not appear to be connected.";

(* Add check to see if connection active, flag to force reconnect and error messages *) 
startCommunication[port_String]:= Module[{},
	$arduino = DeviceOpen["Serial",{port, "BaudRate"->115200}];
	loadElementData[];

];

stopCommunication[]:=Module[{},
	DeviceClose[$arduino];
	$arduino = Null;
];

(* Arduino has a couple of fixed commands; 255,0,0,0 sets all pixels to black. *)
blankScreen[]:= Module[{},
	Pause[$pauselength];
	DeviceWrite[$arduino,"255,0,0,0\n"];
];

(* Sends a properly formatted command directly to Arduino, no error checking yet *)
(* Note duplication with setElment *)
Options[sendCommand] = {"PauseMultiplier"->1};
sendCommand[s0_Integer, s1_Integer, s2_Integer, s3_Integer, opts : OptionsPattern[]]:=sendCommand[
  StringJoin[ToString[s0],",",ToString[s1],",",ToString[s2],",",ToString[s3],"\n"],
  opts
];
sendCommand[s_String, opts: OptionsPattern[]]:=Module[{},
  Pause[$pauselength OptionValue["PauseMultiplier"]];
  DeviceWrite[$arduino, s];
];

(* Some error checking will be needed here to ensure a proper string is sent. *)
setElement[s_String]:=Module[{},
	Pause[$pauselength];
	If[StringTake[s,2]=="-1",Message[pixel::notconnected],
		DeviceWrite[$arduino,s];];
]

(* Shouldn't need to be called by end user *)
loadElementData[]:= Module[{},
	$properties = Import[$propertyfile];
  $dataset = Dataset[Get@$associationfile]; 
]

(* Takes an RGBColor and converts it to a list of 8-bit integers *)
toByteRGB[col_RGBColor]:=Module[{},
	IntegerPart[$maxbrightness*(col/.RGBColor->List)]
]

(* Takes an atomic number and color and converts to a proper command.  *)
formatCommand[z_Integer,col_RGBColor]:= Module[{str},
	str = ToString[Join[{z},toByteRGB[col]]];
	StringReplace[str<>"\n",{"{"->"","}"->"", " "->""}]
]

(* Requires a valid integer corresponding to a column in $properties or returns a blank screen *)
(* Overload with display[prop_List] to send custom displays *)
display[prop_Integer]:= Module[{cmd},
	blankScreen[];
	If[1 < prop <= Length[$properties[[1]]],
		cmd = Map[formatCommand[#[[1]],
				getColor[#[[2]]]] &, 
					RandomSample@$properties[[2;;,{1,prop}]]];
		setElement/@ cmd;
	]
]

display2[data_]:=Module[{cmd},
  blankScreen[];
  cmd = MapIndexed[formatCommand[#2[[1]],
    getColor[#1]]&,
    data];
  setElement/@RandomSample@cmd;
]


getColor[x_]:=Module[{return},
	return = If[x==-1,
		RGBColor[0., 0., 0.],
		If[MemberQ[ColorData["Gradients"],$color],
			ColorData[$color][x],
			ColorConvert[Hue[x],"RGB"]
		]
		
	]
]
	
setBrightness[i_Integer]:=Module[{},
  $maxbrightness = If[8 <= i <= 255,
    i,
    64];
]

listen[]:=Module[{},
  Pause[$pauselength];
  DeviceReadBuffer[$arduino]
]

getZColor[z_Integer]:=Module[{res},
  (* clear buffer *)
  listen[];
  sendCommand["251,"<>ToString[z]<>",0,0\n"];
  res = Drop[listen[],-2];
  FromDigits[#,2]& /@ Partition[IntegerDigits[ToExpression@FromCharacterCode@res,2,24],8]
]

setZColor[z_Integer, r_Integer, g_Integer, b_Integer]:=setZColor[z, {r, g, b}];
setZColor[z_Integer, rgb_List]:=Module[{noerr = True},
  noerr = And[0<z<=118,If[Length@rgb == 3,
    And@@Sequence[0<=#<256 & /@ rgb], False]];
  If[noerr,
    sendCommand[StringJoin[ToString[z],",",ToString/@Riffle[rgb,","],"\n"]];
  ]
]

(* Story data *)
story[1] := Module[{a,b,c,d},
  (* The most metallic elements *)
  (* Creates a subset of ranked data: BP, Dens, Th and Elec conduc *)
  a = Select[$properties[[2;;,{1,4,5,16,17}]], !MemberQ[#,-1]&];
  (* Create an averaged datafield *)
  b = {First@#, Mean@Rest@#} & /@ a;
  (* Rescales the data *)
  c = With[{limits = MinMax@b[[All,2]]}, {#[[1]], Rescale[#[[2]], limits, {0,0.75}]} & /@ b];
  (* Clear the display *)
  blankScreen[];
  (* Show the results *)
  d = Map[formatCommand[#[[1]],
				getColor[#[[2]]]] &, 
					RandomSample@c];
  setElement/@ d;
]

(* Helper functions for new display function *)

(* Not used here, but in creating dataset so here for documenation only *)
removeFormatting[x_] := Module[{},
  Switch[Head@x,
    Quantity, QuantityMagnitude@x,
    DateObject, x["Year"],
    (* Phase is in an EntityClass *)
    EntityClass, x[[2]],
    List, removeFormatting /@ x,
    _, x
  ]
]

notNumericQ[x_] := Not[NumericQ[x]];

Options[mandyRescale] = {"subvalue" -> Missing[]};
mandyRescale[x_, range_, OptionsPattern[]] := Module[{minmax},
  minmax = MinMax@DeleteCases[x, _?notNumericQ];
  If[NumericQ@#,
    Rescale[#, minmax, range],
    OptionValue["subvalue"]]& /@ x
]

(* STORY: Where are you from? *)
(* Thinking about the story structure.  WL is used for displaying Table elements and python is used for displaying to the LCD.  This doesn't make a tremendous amount of sense but I don't have an alternative at the moment. I envision WL code to be the story 'slides' so a call would be story[<storyID>,<slideID>].*)

story[2,slide_]:=Module[{notNumeriQ,f,ds, dsr, compare, dsrr, sl, cmd},
  (* Helper functions*)
  notNumericQ[x_]:=Not[NumericQ[x]];
  f[x_,y_]:=If[And[NumericQ[x],NumericQ[y]],x/y,Missing[]];

  (* Make story data *)
  ds = $elementassociation[All,{"HumanAbundance", "OceanAbundance", "SolarAbundance","CrustAbundance","MeteoriteAbundance"}, (Log10@QuantityMagnitude[#]/._?notNumericQ:>Missing[])&];
  compare = ds[All,"HumanAbundance",Rescale[#,{-15,0},{0,0.75}]/.{_?notNumericQ:>-1}&];
  dsr = ds[All, <|
    "Ocean"->(f[#HumanAbundance,#OceanAbundance]&),
    "Solar"->(f[#HumanAbundance,#SolarAbundance]&),
    "Crust"->(f[#HumanAbundance,#CrustAbundance]&),
    "Meteorite"->(f[#HumanAbundance,#CrustAbundance]&)
    |>];
  dsrr=dsr[All,All,Rescale[#,{0.1,2},{0.75,0}]/.{_?notNumericQ:>-1,_?(#<0&):>0}&];

  (* Generate story slides *)
  (*
  sl = <| 1->compare, 2->dsr["Crust"], 3->"Solar", 4->"Meteorite",5->"Ocean"|>;
	blankScreen[];
  cmd = Map[formatCommand[#[[1]],
      getColor[#[[2]]]] &, 
        RandomSample@sl[slide]];
  setElement/@ cmd;
  
 *)
]

End[];
EndPackage[];
