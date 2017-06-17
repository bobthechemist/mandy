#!/bin/sh

BASE=/home/pi/mandy/assets
PIPENAME=/tmp/speech
FTEELOC=$BASE/ftee
ADCDEV=plughw:1,0
CORPUS=3271
#LOG=/tmp/speech.log
LOG=/tmp/speech.log

# If pipe does not exist, create it
if [ ! -p $PIPENAME ]
  then
    mkfifo $PIPENAME
fi
# Check to see if the pipe was actually created
if [ ! -p $PIPENAME ]
  then
    echo "$PIPENAME either does not exist or is not a named pipe."
    echo "Make the pipe on your own with the command mkfifo $PIPENAME."
    echo "Exiting..."
    exit
fi

# The sed filter is only appropriate for pocketsphinx 0.8-5.  Later versions have different output formats.  
pocketsphinx_continuous -adcdev $ADCDEV -logfn /dev/null -lm $BASE/$CORPUS.lm -dict $BASE/$CORPUS.dic 2>/dev/null | sed --unbuffered -n 's/^[0-9: ]\{11\}\(.*\)/\1/p' | $FTEELOC $PIPENAME > $LOG & 
