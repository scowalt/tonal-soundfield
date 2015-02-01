OscRecv recv;
6449 => recv.port;
recv.listen();
recv.event( "/root/type, i i" ) @=> OscEvent @ oe;

// root is an integer MIDI note value (e.g., C is 0, C# is 1, etc.)
// type is an integer (0 = major, 1 = minor)

0 => int key;
0 => int root;
0 => int type;
300 => int portamento;
3 => int detune;
4 => int numSynths;
0 => int activeSynth;
0 => int lfoTime;
[ [ [0, 2, 4, 5, 7, 9, 11, 12],
    [1, 5, 8, 13],
    [0, 2, 4, 6, 9, 12, 14],
    [3, 7, 10, 15],
    [2, 4, 8, 9, 11, 16],
    [0, 5, 7, 9, 12, 14],
    [4, 6, 10, 13],
    [2, 6, 7, 9, 11, 12, 14],
    [0, 3, 8, 12, 15],
    [4, 7, 9, 13, 14, 16],
    [2, 5, 9, 10, 12, 14],
    [-1, 6, 11, 15] ],
  [ [0, 2, 3, 5, 7, 10, 12, 15],
    [1, 4, 8, 13],
    [0, 2, 4, 5, 9, 12, 14],
    [3, 5, 6, 10, 15],
    [2, 4, 7, 9, 11, 14, 16],
    [0, 5, 7, 8, 12, 14],
    [4, 6, 9, 13],
    [2, 6, 7, 9, 10, 12, 14],
    [0, 3, 8, 11, 15],
    [4, 7, 9, 11, 12, 14, 16],
    [5, 9, 10, 12, 13],
    [-1, 6, 9, 11, 14] ] ] @=> int chordNotes[][][];

TriOsc bassTone => NRev bassRev => LPF bassLp => dac;
0.1 => bassTone.gain;
500 => bassLp.freq;
0.2 => bassRev.mix;
3 => bassLp.Q;

PRCRev rev;
0.4 => rev.mix;
rev => dac;

SqrOsc osc[numSynths];
ADSR env[numSynths];
LPF lp[numSynths];
Pan2 oscPan[numSynths];
float lfoSpeed[numSynths];
float lfoDepth[numSynths];

fun void oscGetChord(){
	while(true){
		oe => now;
		while(oe.nextMsg()){
			oe.getInt() % 12 => root;
			oe.getInt() => type;
			bassTone.freq() => float currentFreq;
			root + 36 + key => Std.mtof => float destFreq;
			for(0 => int x; x < portamento; x++){
				currentFreq + ((destFreq - currentFreq) * x / portamento) => bassTone.freq;
				1::ms => now;
			}
		}
	}
}

fun void chordLfo(){
	while(true){
		for(0 => int i; i < numSynths; i++){
			lfoDepth[i] * Math.sin(lfoTime / lfoSpeed[i]) + 800 => lp[i].freq;
		}
		lfoTime++;
		1::ms => now;
	}
}

for(0 => int i; i < numSynths; i++){
	osc[i] => oscPan[i] => env[i] => lp[i] => rev;
	0.06 => osc[i].gain;
	1 - 2 * (i / (numSynths - 1)) => oscPan[i].pan;
	400::ms => env[i].attackTime;
	60::ms => env[i].decayTime;
	0.8 => env[i].sustainLevel;
	1000::ms => env[i].releaseTime;
	2 => lp[i].Q;
	Math.random2f(200, 500) => lfoDepth[i];
	Math.random2f(2000, 5000) => lfoSpeed[i];
}

spork ~ chordLfo();
spork ~ oscGetChord();
int sameNote;

0.4 => dac.gain;

while(true){
	if(Math.randomf() > 0.7){
		do{
			60 + key + chordNotes[type][root][Math.random2(0, chordNotes[type][root].cap() - 1)] => Std.mtof => osc[activeSynth].freq;
			0 => int sameNote;
			for(0 => int x; x < numSynths; x++){
				if(osc[x].freq() <= osc[activeSynth].freq() + detune && osc[x].freq() >= osc[activeSynth].freq() - detune){
					sameNote++;
				}
			}
		} while(sameNote > 1);
		osc[activeSynth].freq() + Math.random2f(-1 * detune, detune) => osc[activeSynth].freq;
		env[activeSynth].keyOn(1);
		activeSynth++;
		if(activeSynth == numSynths){
			0 => activeSynth;
		}
		env[activeSynth].keyOff(1);
	}
	Math.random2(400, 600)::ms => now;
}