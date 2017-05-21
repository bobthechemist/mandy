#!/bin/sh

# Check to see if file name is passed to script
if [ $# -ne 1 ]
  then
    echo "Usage: makemodel.sh <textfile>"
    exit
fi

# Check to see if first argument is the name of a file
if [ -s $1 ] 
  then
    echo "Found file $1"
  else
    echo "$1 not found. Exiting"
    exit
fi

# Location of CMU's lmtool
URL=http://www.speech.cs.cmu.edu/cgi-bin/tools/lmtool/run
# Will create a temporary file containing the webcrawling output
TEMPFILE=`date +%s`.tmp
# A 'proper' file contains comma-separated commands and associated functions
#   The functions are not needed at this point.
echo "*** Stripping comments and functions from command list"
awk -F, '/^[^#]/{print $1}' $1 > $1.cmd

# Post the textfile to lmtool and save the resulting webpage
echo "*** Posting file to lmtool..."
curl -sSL --form formtype=simple --form corpus=@$1.cmd $URL > $TEMPFILE
# Use sed to find the name of the tarball created by lmtool and then get the file
echo "*** Fetching the resulting tarball..."
wget -q $(sed --unbuffered -n 's/^.*"\(http.*\)".*$/\1/p' $TEMPFILE) 
#sed --unbuffered -n 's/^.*"\(http.*\)".*$/\1/p' $TEMPFILE | xargs wget 

# Find the name of the tarball and the 4-digit identifier
TARBALLBASE=$(sed -n 's/^.*"http.*\(T.*\)\.tgz".*$/\1/p' $TEMPFILE)
TARBALLNUM=$(echo $TARBALLBASE | sed 's/TAR\([0-9]*\)/\1/')

# Extract the two files we need from the tarball
echo "*** Extracting files..."
tar -xzf $TARBALLBASE.tgz $TARBALLNUM.lm $TARBALLNUM.dic

# Clean up
echo "*** Cleaning up..."
rm $TEMPFILE
rm $1.cmd
# Conclusion
echo "Files created today have the prefix $TARBALLNUM."
