# TODO
- Improve `listen[]` to convert character codes.  Use `{x___, PaternSequence[13,10], y___}` to capture linefeed

## data structure
Currently, two data structures are used.  The more recent one is an association that is more easily manipulated; however, both are still in use until I move the older functions over to the new association.  The association was created by:

    DeleteCases[ElementData["Properties"], 
      Alternatives @@ {"CommonCompoundNames", "AllotropeNames", 
        "CASNumber", "Color", "ElectronShellConfiguration", 
        "ElectronConfigurationString", "LatticeAngles", 
        "LatticeConstants", "NeutronCrossSection", 
        "NeutronMassAbsorption", "SpaceGroupName", "SpaceGroupNumber", 
        "QuantumNumbers"}];
    Table[Association[Map[# -> ElementData[i, #] &, allProperties]], {i, 
      118}] >> "elementassociation";

# Wolfram structure
Package consists of communication/inititialization/shutdown commands and two types of features: displays and stories.  Displays are the periodic properties and stories are routines that perform a number of tricks.


