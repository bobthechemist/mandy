#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

// Use pin 6 for communication to neopixels
#define PIN 6
// Number of elements (will eventually be 118)
#define ELEMENTS 118
// Map the atomic number to the correct pixel

static int zpmap[] = {-1, 77, 0, 78, 89, 1, 2, 3, 4, 5, 6, 79, 88, 7, 8, 9, 10, 11, 12, 80, \
87, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 13, 14, 15, 16, 17, 18, \
81, 86, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57, 19, 20, 21, 22, 23, \
24, 82, 85, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, \
106, 105, 104, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 25, 26, 27, \
28, 29, 30, 83, 84, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, \
102, 103, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 31, 32, 33, 34, 35, \
36};
  
Adafruit_NeoPixel table = Adafruit_NeoPixel(ELEMENTS, PIN, NEO_GRB + NEO_KHZ800);


// Serial setup
#define INPUT_SIZE 15 // 4 - 3 digit values, comma delimited, no spaces
char input[INPUT_SIZE + 1];
boolean stringComplete = false;
int inputPos = 0;
boolean inputError = false; // Not used presently


void setup() {
  // Initialize serial
  Serial.begin(9600);
  // Initialize table
  table.begin();
  table.show(); // Initialize all pixels to 'off'
}

void loop() {
  if (stringComplete) {
    // inspired by http://arduino.stackexchange.com/a/1033/8481
    char *pch;

    pch = strtok (input, ",");
    int colors[5];
    int ci = 0;
    while (pch != NULL)
    {
      colors[ci++] = atoi(pch);
      pch = strtok (NULL, ",");
    }
    // clear the string:
    inputPos = 0;
    stringComplete = false;
    // Rudimentary error checking
    for(int i = 0; i<4; i++) {
      if (colors[i] <0 || colors[i] > 255) colors[i] = 0;
    }
    // Should be OK to display colors
    if (colors[0]==255) {
      quickColor(table.Color(colors[1],colors[2],colors[3]));
    }
    else if (colors[0]==254){
      rainbowCycle(20); 
    }
    // Color wipe in atomic number order
    else if (colors[0]==253) {
      colorWipe(table.Color(colors[1],colors[2],colors[3]),20);
    }
    else if (colors[0]<=118) {
      table.setPixelColor(zpmap[colors[0]],table.Color(colors[1],colors[2],colors[3]));
    }
    table.show();
  }

}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    if (inputPos < INPUT_SIZE) {
      // add it to the inputString, will be ignored if buffer is full
      input[inputPos++] = inChar;
    }
    if (inChar == '\n') {
      input[inputPos++] = 0;
      stringComplete = true;
    }
  }

}

// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t wait) {
  for(uint16_t z=1; z<=118; z++) {
    table.setPixelColor(zpmap[z], c);
    table.show();
    delay(wait);
  }
}



// Quick fill
void quickColor(uint32_t c) {
  for(uint16_t i=0; i<table.numPixels(); i++) {
    table.setPixelColor(i,c);
  }
  table.show();
}


// Keep for "screen saver"
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256*5; j++) { // 5 cycles of all colors on wheel
    for(i=0; i< table.numPixels(); i++) {
      table.setPixelColor(i, Wheel(((i * 256 / table.numPixels()) + j) & 255));
    }
    table.show();
    delay(wait);
  }
}





// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if(WheelPos < 85) {
    return table.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if(WheelPos < 170) {
    WheelPos -= 85;
    return table.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return table.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}
