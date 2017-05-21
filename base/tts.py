import os
import Adafruit_CharLCD as LCD 
from helper import *

# lcd configuration
lcd_rs = 27
lcd_en = 22
lcd_d4 = 25
lcd_d5 = 24
lcd_d6 = 23
lcd_d7 = 18
lcd_red = 4
lcd_green = 17
lcd_blue = 7
lcd_columns = 20
lcd_rows = 4
global lcd

# Converting arguments to variable length, so that tts styles that require
# multiple arguments can use the same structure.

def textonly(*var):
  print col.PURPLE + var[0] + col.NONE

def espeak(*var):
  os.system('espeak -ven-us+f2 "{0}" 2>/dev/null'.format(var[0]))

def lcdinit():
  global lcd
  lcd = LCD.Adafruit_RGBCharLCD(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, 
    lcd_d7, lcd_columns, lcd_rows, lcd_red, lcd_green, lcd_blue)
  lcd.clear()
  lcd.set_color(1.0, 0.0, 1.0)
  lcd.message("Hi! I'm Mandy,\n the bright\nperiodic table.\nSpeak to me.")

def lcdspeak(*var):
  global lcd
  lcd.clear()
  lcd.set_color(var[1], var[2], var[3])
  lcd.message(var[0])

