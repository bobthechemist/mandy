#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

// Use pin 6 for communication to neopixels
#define PIN 6
// Number of elements 
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
// Map the period and group to atomic number
static int pgtoz[10][18]={
  {1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 2}, {3, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 5, 6, 7, 8, 9, 
  10}, {11, 12, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 13, 14, 15, 
  16, 17, 18}, {19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36}, {37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54}, {55, 56, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 80, 81, 82, 83, 84, 85, 86}, {87, 88, 103, 104, 105, 106, 
  107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
  118}, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, \
-1, -1, -1}, {-1, -1, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, -1, -1}, {-1, -1, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 
  99, 100, 101, 102, -1, -1}};


  
// Create table and set some global tricks  
Adafruit_NeoPixel table = Adafruit_NeoPixel(ELEMENTS, PIN, NEO_GRB + NEO_KHZ800);
uint32_t defaultColor = table.Color(0,255,0);

// Serial setup
#define INPUT_SIZE 15 // 4 - 3 digit values, comma delimited, no spaces
char input[INPUT_SIZE + 1];
boolean stringComplete = false;
int inputPos = 0;

// Will only perform an update if flag is set
boolean update = true;

// Tricks will be assigned in setup() to make loop() cleaner
void (*trick[256]) ( uint8_t s1, uint8_t s2, uint8_t s3 ) = {NULL};

// function declarations
// - tricks prefixed with at (atomic), tb (tabular) or gl (global)
// - functions that are not tricks do not have a prefix
void rainbowCycle(uint8_t);
void highlight(uint8_t);
uint32_t Wheel(byte);
void whatColor(int);
int pgtop(int p, int g); // Traverse pg and ztop maps 

// v2.0 function declarations
void atBlink(uint8_t z, uint8_t numBlinks, uint8_t wait);
void atFade(uint8_t z, uint8_t numFades, uint8_t wait);
void tbWash(uint8_t r, uint8_t g, uint8_t b);
void tbWave(uint8_t unused, uint8_t numLoops, uint8_t wait);
void tbPaint(uint8_t unused, uint8_t unused2, uint8_t wait);
void glDefaultColor(uint8_t r, uint8_t g, uint8_t b);
void glSetUpdateFlag(uint8_t value, uint8_t show, uint8_t unused2);

/* *** TEST AREA *** */
void test(uint8_t s1, uint8_t s2, uint8_t s3) {
}

/* *** END TEST AREA *** */

// get pixel number from period and group

void setup() {
  // Initialize serial
  Serial.begin(115200);

  // Initialize tricks

  trick[120] = atBlink;
  trick[121] = atFade;
  trick[165] = tbWash;
  trick[166] = tbPaint;
  trick[167] = tbWave;
  trick[210] = glDefaultColor;
  trick[211] = glSetUpdateFlag;
  trick[255] = tbWash; //Backwards compatible with wolfram blankScreen[]

  // Initialize table
  table.begin();
  table.show(); // Initialize all pixels to 'off'

}

void loop() {
  if (stringComplete) {
    // inspired by http://arduino.stackexchange.com/a/1033/8481
    char *pch;

    pch = strtok (input, ",");
    int slots[5];
    int si = 0;
    while (pch != NULL)
    {
      slots[si++] = atoi(pch);
      pch = strtok (NULL, ",");
    }
    // clear the string:
    inputPos = 0;
    stringComplete = false;
    
    // Perform requested trick
    if(slots[0] <= 118) {
      table.setPixelColor(zpmap[slots[0]],table.Color(slots[1],slots[2],slots[3]));
      if (update) table.show();
    }
    else {
      // Assumes these tricks will show the table
      (*trick[slots[0]])(slots[1], slots[2], slots[3]);
    }
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



// Highlight
// Perform a rainbowCycle on a single element called using pgtoz
void highlight(uint8_t z) {
  uint16_t i;

  for(i=0; i<128; i++) {
    table.setPixelColor(zpmap[z],table.Color(i,0,0));
    table.show();
    delay(1);
  }
  for(i=0; i<256; i++) {
    table.setPixelColor(zpmap[z],Wheel(i));
    table.show();
    delay(1);
  }
  for(i=128; i>0; i--) {
      table.setPixelColor(zpmap[z],table.Color(i,0,0));
      table.show();
      delay(1);
  }  
  table.setPixelColor(zpmap[z],table.Color(0,0,0));
  table.show();
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

//print pixel information to serial
void whatColor(int z) {
  Serial.println(table.getPixelColor(zpmap[z]));
}

int pgtop(int p, int g) {
  int temp = -1;
  if (p <= 10 && g <= 18){
    temp = pgtoz[p-1][g-1];
  }
  if (temp != -1 ) {
    return zpmap[temp];
  }
  else {
    return -1;
  }
}

// *** ATOMIC TRICKS ***

// atBlink blinks a single element
void atBlink(uint8_t z, uint8_t numBlinks, uint8_t wait) {
  uint8_t i;

  if(z <= ELEMENTS) {
    for (i = 0; i < numBlinks; i++) {
      if(i%2) {
        table.setPixelColor(zpmap[z],table.Color(0,0,0));
      }
      else {
        table.setPixelColor(zpmap[z],defaultColor);
      }
      table.show();
      // Multiply wait to allow for a 1 s delay (using wait = 200)
      delay(5*wait);
    }
  }
}

// atFade fades a single element
void atFade(uint8_t z, uint8_t numFades, uint8_t wait) {
  int i;
  float j;


  table.setPixelColor(zpmap[z],defaultColor);
  for(i=0; i<numFades; i++){
    for(j=1; j>=0; j-=0.1) {
      table.setPixelColor(zpmap[z],table.Color((uint8_t)(j*255),0,0));
      table.show();
      delay(5*wait);
    }
    for(j=0; j<=1; j+=0.1) {
      table.setPixelColor(zpmap[z],table.Color((uint8_t)(j*255),0,0));
      table.show();
      delay(5*wait);
    }
  }
}

// *** TABULAR TRICKS ***
void tbWash(uint8_t r, uint8_t g, uint8_t b){
  for(uint8_t i=0; i<table.numPixels(); i++) {
    table.setPixelColor(i,table.Color(r,g,b));
  }
  table.show();

}

// Create a sine wave that moves across the periodic table
void tbWave(uint8_t unused, uint8_t numLoops, uint8_t wait) {
  int i, p, g;

  for (i=1; i<numLoops*128; i++) {
    for (p=1; p<=10; p++){
      for(g=1; g<=18;g++){
        //table.setPixelColor(zpmap[pgtoz[p-1][g-1]],Wheel((g*10+p*10-2*i)%255));
        table.setPixelColor(pgtop(p,g),Wheel((g*10+p*10-2*i)%255));
      }
    }
    table.show();
    delay(wait);
  }
}

// Paints the table the default color, one element at a time
void tbPaint(uint8_t unused, uint8_t unused2, uint8_t wait) {
  for(uint8_t z=1; z<=118; z++) {
    table.setPixelColor(zpmap[z], defaultColor);
    table.show();
    delay(wait);
  }
}
// *** GLOBAL TRICKS ***
void glDefaultColor(uint8_t r, uint8_t g, uint8_t b) {
  defaultColor = table.Color(r,g,b);
}

void glSetUpdateFlag(uint8_t value, uint8_t show, uint8_t unused2) {
  if (value == 0) {
    update = false;
  }
  else {
    update = true;
    if (show) table.show();
  }
}

