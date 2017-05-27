# Mandy - the periodic table you can talk to

## Introduction
Mandy is an interactive periodic table that takes voice commands to display various
trends in the elements.  A (teaser) trailer can be found [here](https://youtu.be/eI-IgJ3n_RU).

## Components
Mandy can be broken down into three components:

- Simplified Command and Control (SCAC) a [minimalist speech recognition package](https://github.com/bobthechemist/scac) that I've designed which uses pocketsphinx
- An Arduino which accepts serial commands to light RGB LEDs (aka [Neopixels](https://learn.adafruit.com/adafruit-neopixel-uberguide/overview)
- Wolfram Mathematica scripts for crunching color codes, organizing the periodic-table data and communicating between SCAC and the Arduino, which relies on [python-mathlink](https://github.com/bobthechemist/python-mathlink)

### scac - Simplified command and control
to be written

### PTPixels - Wolfram code for pixel data and communication
to be written

### python-mathlink - Communication between python and Mathematica
Cloned from [here](https://github.com/bobthechemist/python-mathlink) with the following changes:
- `sudo apt-get install python-dev libuuid-dev`
- Using version 11.0 of *Mathematica* 
- Still need to copy the libML32i3.so library to /usr/local/lib

## Directory Structure
- **arduino** has the arduino sketch(es) needed to control the neopixels.
- **assets** are items used by SCAC for speech recognition and language model generation
- **base** contains core files used by SCAC, such as the text-to-speech engine, which in Mandy's case is the LCD display.
- **design** holds files relevant to the physical structure (OpenSCAD scripts, graphics and Mathematica code).
- **library** stores the functions to be run when a speech command is recognized.
- **systemd** contains copies of Unit files used to make Mandy, speech recognition and some power switches work as services.
- **wl** contains wolfram scripts and python mathlink code.  

