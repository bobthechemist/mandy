import sys
import os
from mathlink import *
from time import sleep

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
  return "Displaying atomic\nweight.\nRed=low\nPurple=High"

def atomicradius():
  sendexpression("display[3]")
  getresult()
  return "Displaying atomic\nradius.\nRed=small\nPurple=large"

def boilingpoint():
  sendexpression("display[4]")
  getresult()
  return "Displaying boiling\npoint.\nRed=low\nPurple=High"

def density():
  sendexpression("display[5]")
  getresult()
  return "Displaying\ndensity\nRed=low\nPurple=High"

def electronegativity():
  sendexpression("display[6]")
  getresult()
  return "Displaying\nelectronegativity\nRed=low\nPurple=High"

def ionizationenergy():
  sendexpression("display[7]")
  getresult()
  return "Displaying\nionization energy\nRed=low\nPurple=High"

def meltingpoint():
  sendexpression("display[8]")
  getresult()
  return "Displaying melting\npoint.\nRed=low\nPurple=High"

def molarvolume():
  sendexpression("display[9]")
  getresult()
  return "Displaying molar\nvolume.\nRed=low\nPurple=High"

def phase():
  sendexpression("display[10]")
  getresult()
  return "Displaying phase\nsolid=?\nliquid=\ngas=?"

def discoveryyear():
  sendexpression("display[11]")
  getresult()
  return "Displaying discovery\nyear.\nRed=early\nPurple=late"

def block():
  sendexpression("display[12]")
  getresult()
  return "Displaying blocks\n\ns=red p=blue\nd=green f=purple"

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
