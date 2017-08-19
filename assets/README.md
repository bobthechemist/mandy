# Notes

On 8/18/2017, I noticed that the lmtools website was not functioning properly and it was not possible to use makemodel.sh to create a new language model and dictionary.

To solve this problem, I needed to do some manual model making.  I obtained a copy of `quick_lm.pl`

    wget www.speech.cs.cmu.edu/tools/download/quick_lm.pl

and fixed the first line to point to the correct location of perl (which may need to be installed with `sudo apt-get install perl`.  I then tweaked mandy.info using:

    awk -F, '/^[^#]/{print "<s> ", $1, "</s>"}' mandy.info > mandy.cmd

which could then be processed with the quick_lm tool.

    perl quick_lm.pl -s mandy.cmd
    mv mandy.cmd.arpabo manual.lm

To make the corresponding dictionary file, I still used the [online Lexicon tool](www.speech.cs.cmu.edu/tools/lextool.html) which seems to function properly right now.  I had to use a text editor to place each word on its own line and delete duplicates.  

Fortunately, this process works.  I'm hoping to obtain an offline version of the lexicon tool so that Mandy can be completely independent of the web.


