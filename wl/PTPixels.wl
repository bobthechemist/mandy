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



Begin["`Private`"];
$pauselength = 0.010;
$color = "Hue";
$arduino = Null;
$numelements = 118; (* for debugging *)
(* Full path to make integration with other programs easier *)
$propertyfile = "/home/pi/mandy/wl/elementdata.csv";
$properties = Null;
$maxbrightness = 64;
$version = 170416;

(* Messages *)
pixel::notconnected = "Requested pixel does not appear to be connected.";

(* Add check to see if connection active, flag to force reconnect and error messages *) 
startCommunication[port_String]:= Module[{},
	$arduino = DeviceOpen["Serial",port];
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
(* Not needed as it duplicates setElement[] *)
sendCommand[s_String]:=Module[{},
  Pause[$pauselength];
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
			ColorConvert[Hue[0.8 x],"RGB"]
		]
		
	]
]
	
setBrightness[i_Integer]:=Module[{},
  $maxbrightness = If[8 <= i <= 255,
    i,
    64];
]

End[];
EndPackage[];
