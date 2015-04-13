# tonal-soundfield

## Description

This repository contains code for the sound generation part of the SigMusic 2015 project, [Tonal Starfield](http://sigmusic.github.io/tonal-starfield/). These files are written in ChucK, a strongly-timed audio programming language.

The audio synthesis is in three parts: the low abyss tones (abyss.ck), the midrange chords (chords.ck, which can use osctest.ck to provide OSC input), and the high-end melodies (melody.ck, which can use sample OSC input from osctestmelody.ck). Multiple ChucK files can be run at once, so you can run the sonification script and the OSC test from the same terminal window.

## Setup

  - Download [ChucK](http://chuck.cs.princeton.edu/)
  - Download [node.js](https://nodejs.org/)
  - Fork / clone repository
  - `npm install`
 
## Run

  - Start JACK (if on a Unix system)
  - Run `node websocket2osc.js` and `chuck chords.ck chordProgression.ck [abyss.ck]`
  - For use with [tonal-starfield](http://sigmusic.github.io/tonal-starfield/), connect the simulation to the audio code via WebSockets, and send a melody using the client.
