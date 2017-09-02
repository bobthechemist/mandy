from base import *
from base.helper import *
# Here we need to explicitly state which modules in the library are being used
from library.mandy import *
import os
import signal
# Needed for random display
import time
import random

# Handle SIGINT and SIGTERM gracefully
def sig_handler(signum, frame):
  print "*** Shutting down"
  say("Terminating...",0.0,0.0,0.0)
  spipe.close()
  exit(0)

signal.signal(signal.SIGINT, sig_handler)
signal.signal(signal.SIGTERM, sig_handler)

# Start wolfram link
wlstart()

# base name of the corpus (don't include .info suffix)
corpus = "mandy"

# Define the TTS engine
say = tts.lcdspeak
tts.lcdinit()


# Connect functions to commands
print "*** Creating command function dictionary" 
fdict = {}
with open("assets/"+corpus+".info") as raw:
  for line in raw:
    if line[0] != '#':
      cmd, func = line.partition(",")[::2]
      fdict[cmd.rstrip()]=func.strip()

# Checking if there exists a function for each command, remove command if not
# Cannot modify a dictionary while iterating, so make a copy
print "*** Checking dictionary"
for k,v in fdict.copy().iteritems():
  if v in locals().keys():
    print " - found", k, "which calls", v
  else:
    if v=='keyphrase':
      print " - found keyphrase"
      keyphrase = k
    else:
      print col.RED + " - no function found for", k,"(",v,")", \
        "deleting" + col.NONE
      del fdict[k]


# Should be able to do this in previous loop.
keyphrase = "None found!"
for cmd, func in fdict.iteritems():
  if func=='keyphrase':
    keyphrase = cmd

# Print some information
print "*** The keyphrase is:", keyphrase
print "*** Simplified command and control, loaded."
print "*** Mandy is listening..."

# Open the speech pipe; should have default config file with this filename
#   since it is also needed to start pocketsphinx
spipe = open('/tmp/speech')

# Create sublist of display functions
displayopts = fdict.keys()
for i in ['SHUTDOWN', 'RESTART', 'NOTHING', 'HELLO MANDY']:
  displayopts.remove(i)

# Set a latency variable 
latent = time.time()

# TEST AREA
#say(story(), 1.0, 1.0, 0.0)
#time.sleep(2)
#os._exit(1)

hello()

# Main loop 
while True:
  waiting = True

# - Read a line from the speech pipe, looking for the keyphrase
  while waiting:
    # Display random trend
    if time.time() - latent > 180:
      latent = time.time()
      say("I'm bored", 0.0, 0.0, 0.0)
      say(locals()[fdict[random.choice(displayopts)]](), 0.0, 1.0, 0.0)

    # Read a line from the speechpipe
    # This command is blocking and script will halt here in a silent room.
    line = spipe.readline().rstrip()
    # Check to see if the line was the keyphrase
    if line == keyphrase: 
      waiting = False
      # Reset latency timer
      latent = time.time()
      say("   What would you\n    like to see?", 0.0, 1.0, 1.0)

# - When keyphrase is found start looking for a command
  line = spipe.readline().rstrip()
# - When valid command is found, execute function associated with command
  try:
    say(locals()[fdict[line]](), 0.0, 1.0, 0.0)
  except KeyError:
    say("Sorry,\nI did not hear you.", 1.0, 0.0, 0.0)
    print line
  except TypeError:
    say("Sorry,\nI wasn't paying\nattention.", 1.0, 0.0, 0.0)




