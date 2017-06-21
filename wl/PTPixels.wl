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
getColor::usage = "Returns the correct color.";
listen::usage = "Returns the serial buffer.";
getZColor::usage = "Returns a list of RGB values for the requested element.";
setZColor::usage = "Sets element color using format [Z, {R, G, B}]";

Begin["`Private`"];
$pauselength = 0.010;
$color = "Hue";
$arduino = Null;
$numelements = 118; (* for debugging *)
(* Full path to make integration with other programs easier *)
$propertyfile = "/home/pi/mandy/wl/elementdata.csv";
$properties = Null;
$maxbrightness = 64;
$version = 170528;

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
display[prop_Integer]:= Module[{cmd},
	blankScreen[];
	If[1 < prop <= Length[$properties[[1]]],
		cmd = Map[formatCommand[#[[1]],
				getColor[#[[2]]]] &, 
					RandomSample@$properties[[2;;,{1,prop}]]];
		setElement/@ cmd;
	]
]

getColor[x_]:=Module[{return},
	return = If[x==-1,
		RGBColor[0., 0., 0.],
		If[MemberQ[ColorData["Gradients"],$color],
			ColorData[$color][x],
			(* 0.8 is to avoid min and max being the same color (red) *)
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
End[];
EndPackage[];
