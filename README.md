# tonal-soundfield
This repository contains code for the sound generation part of the SigMusic 2015 project, [Tonal Starfield](http://sigmusic.github.io/tonal-starfield/). These files are written in ChucK, a strongly-timed audio programming language.

To use these files, first download ChucK from either the ChucK website (http://chuck.cs.princeton.edu/) or from your OS repositories. Then, to run a ChucK file, start JACK, and then type in "chuck <filename>.ck" at the terminal.

The audio synthesis is in three parts: the low abyss tones (abyss.ck), the midrange chords (chords.ck, which can use osctest.ck to provide OSC input), and the high-end melodies (melody.ck, which can use sample OSC input from osctestmelody.ck). Multiple ChucK files can be run at once, so you can run the sonification script and the OSC test from the same terminal window.
