# Special functions
- 255: quick fill the specified color
- 254: rainbow cycle; requires a color but is ignored
- 253: color wipe; similar to quick fill but lights pixels one at a time

# Feature organization for v2.0

Mandy can to *tricks* which have the following characteristics
- Associated code (119 to 255)
- are classified as atomic, tabular or global
    - atomic refer to a single element
    - tabular are applied to all 118 elements
    - global set parameters when the communication line is too short to send information

## Example tricks
Is color setting considered an atomic trick?  Perhaps. Colors can be set; turning a pixel off is equivalent to setting its color to black.
### Global
- defaultcolor: sets the color to be used for atomic tricks
### Atomic
- blink: slot 1 contains the element to blink (must be below 119), slot 2 contains the number of blinks (consider number of half blinks so the pixel can be left in a lit state) and slot 3 contains an optional delay in ms.
- fade: similar to blink, but gradually increases color rather than display on/off.  Can take the same options as blink.
- hightlight: modification of fade that takes note of the current pixel color and emphasizes it.

### Tabular
- wash: paint the table with a single color.  Need to decide if trick will accept a color or use global color and allow for blink-like options in slots

## Command structure
Mandy's Arduino recieves commands serially from its Rasbperry Pi, currently at 9600 Baud (although there may not be a good reason for this speed).  Commands are 4 byte sized unsigned integers formatted as a newline terminated, comma delimited string with no spaces.  The maximum length of the command would therefore be 16 characters.  A valid command therefore consists of 4 *slots* numbered 0 .. 3.

## New command ordering
- Save 119 for testing purposes
- 120 to 164 are for atomic tricks
- 165 to 209 are for tabular tricks
- 210 to 255 are for global (non-visual) tricks

### Current tricks
- 120: atBlink
- 210: setDefaultColor
