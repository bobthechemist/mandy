import sys
import os
from mathlink import *
from time import sleep
from base import *

def qanda():
  "Performs one In/Out cycle"
  sendexpression(raw_input())
  getresult()
  return;

def sendexpression(str):
  "Sends str to the Mathematica kernel"
  k.newpacket()
  k.putfunction("EvaluatePacket",1)
  k.putfunction("ToString",1)
  k.putfunction("ToExpression",1)
  k.putstring(str)
  k.endpacket()
  return

def getresult():
  "To be called after sendexpression to get the result"
  if k.nextpacket() == 3:
    result =  k.getstring()
  else:
    result = "I don't know what to tell you"
    geterror()
  return result

def gettoken():
  "Returns the current token type"
  t = tokendictionary[k.getnext()]
  #print t
  return t;

 
# possible way to address errors.  If there is an error, then a series
# of gettoken/k.getXXX can generate the result until the string "$Failed"
# is passed.  One should not try to get a token after this string, as the
# link will hang.
def geterror():
  "Returns the error, I hope"
  myerror = None
  curval = None
  while curval != "$Failed":
    curval = returnresult(gettoken())
    print curval
  return;

def returnresult(token):
  val = None
  if token == "MLTKSYM":
    val = k.getsymbol()
  elif token == "MLTKSTR":
    val = k.getstring() 
  elif token == "MLTKFUNC":
    val = k.getfunction() 
  else:
    val = token
  return val

def main():
  while True:
    try:
      qanda()
    except KeyboardInterrupt:
      print "Done"
      break

def wlstart():
  global k 
  k = env().openargv(['','-linkname','wolfram -mathlink','-linkmode','launch'])
  k.connect()
  while k.ready()!=1:
    sleep(0.5)
  k.nextpacket()
  k.getstring()
  print "*** Wolfram link established."
  # Now initiate Arduino communication
  sendexpression("<</home/pi/mandy/wl/mandystart.wl")
  getresult() 
  print "*** Arduino link established."

if __name__ == "__main__":
  main()

# MANDY commands

def atomicweight():
  sendexpression("display[2]")
  getresult()
  return "Displaying\natomic weight.\n\nRed=high Purple=low"

def atomicradius():
  sendexpression("display[3]")
  getresult()
  return "Displaying\natomic radius.\nRed=large\nPurple=small"

def boilingpoint():
  sendexpression("display[4]")
  getresult()
  return "Displaying\nboiling point.\n\nRed=high Purple=low"

def density():
  sendexpression("display[5]")
  getresult()
  return "Displaying\ndensity.\n\nRed=high Purple=low"

def electronegativity():
  sendexpression("display[6]")
  getresult()
  return "Displaying\nelectronegativity.\n\nRed=high Purple=low"

def ionizationenergy():
  sendexpression("display[7]")
  getresult()
  return "Displaying\nionization energy.\n\nRed=high Purple=low"

def meltingpoint():
  sendexpression("display[8]")
  getresult()
  return "Displaying\nmelting point.\n\nRed=high Purple=low"

def molarvolume():
  sendexpression("display[9]")
  getresult()
  return "Displaying\nmolar volume.\n\nRed=high Purple=low"

def phase():
  sendexpression("display[10]")
  getresult()
  return "Displaying phase.\nPurple=solid\nGreen=liquid\nRed=gas"

def discoveryyear():
  sendexpression("display[11]")
  getresult()
  return "Displaying\ndiscovery year.\n\nPurple=old Red=new"

def block():
  sendexpression("display[12]")
  getresult()
  return "Displaying blocks.\n\nPurple=s Blue=p\nYellow=d Red=f"

def stableisotopes():
  sendexpression("display[13]")
  getresult()
  return "Displaying # of\nstable isotopes.\n\nRed=1 Purple=10"

def humanabundance():
  sendexpression("display[14]")
  getresult()
  return "Displaying elements\nin your body.\n\nRed=high Purple=low"

def electronaffinity():
  sendexpression("display[15]")
  getresult()
  return "Displaying\nelectron affinity.\n\nRed=high Purple=low"

def thermalconductivity():
  sendexpression("display[16]")
  getresult()
  return "Displaying\nthermal\nconductivity.\nRed=high Purple=low"

def electricalconductivity():
  sendexpression("display[17]")
  getresult()
  return "Displaying\nelectrical\nconductivity.\nRed=high Purple=low"

def hardness():
  sendexpression("display[18]")
  getresult()
  return "Displaying\nhardness.\n\nRed=high Purple=low"

def blank():
  sendexpression("blankScreen[]")
  getresult()
  return "Going dark\nfor a while."

def shutdown():
  sendexpression("blankScreen[]")
  os.system('sudo shutdown -h now')
  return "Shutting down."

def restart():
  sendexpression("blankScreen[]")
  os.system("sudo shutdown -r now")
  return "Restarting..."

def hello():
  sendexpression("blankScreen[]")
  getresult()
  sendexpression("sendCommand[167,0,2,10]")
  getresult()
  sendexpression("blankscreen[]")
  getresult()
  return ""


def story():
  s = tts.lcdspeak
  sendexpression("blankScreen[]")
  getresult()
  s("We learn that the\n metallic character\n of elements\n increases towards", 0.0, 1.0, 1.0)
  sleep(5)
  s("Francium.\n\nBut is this true?", 0.0, 1.0, 1.0)
  sendexpression("sendCommand[121,87,3,20]")
  getresult()
  sleep(5)
  s("We also learn that\n metals have\n several\n properties.", 0.0, 1.0, 1.0)
  sleep(5)
  s("They have high\n thermal conduc-\n tivity, and silver\n has the highest.", 0.0, 1.0, 1.0)
  sendexpression("display[16]")
  getresult()
  sleep(5)
  s("They conduct\n electricity well\n too, and silver\n wins again.", 0.0, 1.0, 1.0)
  sendexpression("display[17]")
  getresult()
  sleep(5)
  s("Metals typically\n have high boiling\n points, like the\n 3rd row d-block.", 0.0, 1.0, 1.0)
  sendexpression("display[4]")
  getresult()
  sleep(5)
  s("The heavy trans-\n ition metals are\n also the densest.", 0.0, 1.0, 1.0)
  sendexpression("display[5]")
  getresult()
  sleep(5)
  s("If we put all of\n that information\n together, we get a\n new trend...", 0.0, 1.0, 1.0)
  sendexpression("story[1]")
  getresult()
  sleep(5)
  s("...and observe\n that the noble\n metals are the\n most metallic.", 0.0, 1.0, 1.0)
  sleep(5)
  return "The End"

