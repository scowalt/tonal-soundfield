OscRecv recv;
6449 => recv.port;
recv.listen();
recv.event( "/key/root/type, i i i" ) @=> OscEvent @ oe;
recv.event( "/note/timbre, i f" ) @=> OscEvent @ om;

// key is an integer MIDI note value (e.g., C is 0, C# is 1, etc.)
// root is an integer MIDI note value (e.g., C is 0, C# is 1, etc.)
// type is an integer (0 = major, 1 = minor, 2=dim, 3=aug, 4=sus4, 5=dom7)


0 => int key;
0 => int root;
0 => int type;
600 => int portamento;
3 => int detune;
4 => int numSynths;
0 => int activeSynth;
0 => int lfoTime;
30 => int noteDistance;
4 => int numMelSynths;
float timbre;
[ [ [0, 2, 4, 7, 12],
	[1, 5, 8, 13],
	[0, 2, 4, 9, 12, 14],
	[3, 7, 10, 15],
	[2, 4, 8, 9, 11, 16],
	[0, 5, 7, 9, 12, 14],
	[4, 6, 10, 13],
	[2, 7, 9, 11, 14],
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
	[-1, 6, 9, 11, 14] ],
  [ [0] ],
  [ [0] ],
  [ [0, 2, 5, 7, 9, 12],
	[1, 5, 8, 13],
	[2, 4, 6, 9, 12, 14],
	[3, 7, 10, 15],
	[2, 4, 8, 9, 11, 16],
	[0, 5, 7, 9, 12, 14],
	[4, 6, 10, 13],
	[2, 7, 9, 11, 14],
	[0, 3, 8, 12, 15],
	[4, 7, 9, 13, 14, 16],
	[2, 5, 9, 10, 12, 14],
	[-1, 6, 11, 15] ],
  [ [0, 4, 7, 10, 12],
	[1, 5, 8, 13],
	[2, 4, 6, 9, 12, 14],
	[3, 7, 10, 15],
	[2, 4, 8, 9, 11, 16],
	[0, 5, 7, 9, 12, 14],
	[4, 6, 10, 13],
	[2, 5, 7, 11, 12, 14],
	[0, 3, 8, 12, 15],
	[4, 7, 9, 13, 14, 16],
	[2, 5, 9, 10, 12, 14],
	[-1, 6, 11, 15] ] ] @=> int chordNotes[][][];

SawOsc bassTone => NRev bassRev => LPF bassLp => dac;
0.1 => bassTone.gain;
400 => bassLp.freq;
0.2 => bassRev.mix;
6 => bassLp.Q;

TriOsc fifthTone => NRev fifthRev => LPF fifthLp => dac;
0.07 => fifthTone.gain;
600 => fifthLp.freq;
0.15 => fifthRev.mix;
3 => fifthLp.Q;

TriOsc octTone => NRev octRev => LPF octLp => dac;
0.07 => octTone.gain;
800 => octLp.freq;
0.15 => octRev.mix;
3 => octLp.Q;

PRCRev lrev;
LPF lmasterLP;
0.6 => lrev.mix;
2000 => lmasterLP.freq;
1 => lmasterLP.Q;
lrev => lmasterLP => dac.left;

PRCRev rrev;
LPF rmasterLP;
0.6 => rrev.mix;
2000 => rmasterLP.freq;
1 => rmasterLP.Q;
rrev => rmasterLP => dac.right;

NRev lmelrev => dac.left;
0.08 => lmelrev.mix;
NRev rmelrev => dac.right;
0.08 => rmelrev.mix;

SawOsc osc[numSynths];
ADSR env[numSynths];
LPF lp[numSynths];
Pan2 oscPan[numSynths];
float lfoSpeed[numSynths];
float lfoDepth[numSynths];
SqrOsc s[numMelSynths];
ADSR e[numMelSynths];
Pan2 p[numMelSynths];
LPF lpm[numMelSynths];
float fifthNote;

fun void oscGetChord(){
	while(true){
		oe => now;
		while(oe.nextMsg()){
			<<<"osc recieved">>>;
			oe.getInt() % 12 => key;
			oe.getInt() % 12 => root;
			oe.getInt() => type;
			bassTone.freq() => float currentFreq;
			(root + key) % 12 + 48 => Std.mtof => float destFreq;
			for(0 => int x; x < portamento; x++){
				currentFreq + ((destFreq - currentFreq) * x / portamento) => bassTone.freq;
				bassTone.freq() * 2 - 3 => octTone.freq;
				bassTone.freq() => Std.ftom => fifthNote;
				fifthNote + 7 => Std.mtof => fifthTone.freq;
				1::ms => now;
			}
		}
	}
}

fun void oscGetMelody(){
	0 => int x;
	while(true){
		om => now;
		while(om.nextMsg()){
			<<<"reiceved osc">>>;
			84 + (om.getInt() + key) % 12 => Std.mtof => s[x % numSynths].freq;
			om.getFloat() => timbre;
			<<<timbre>>>;
			timbre * 5000 + 1600 => lpm[x % numSynths].freq;
			Math.sin(timbre * 16931) => p[x % numSynths].pan;
			((Math.sin(timbre * 13063) + 1.5) * 400)::ms => e[x % numSynths].decayTime;
			e[x % numSynths].keyOn();
			1 +=> x;
			e[x % numSynths].keyOff();
		}
	}
}

fun void chordLfo(){
	while(true){
		for(0 => int i; i < numSynths; i++){
			(lfoDepth[i] * Math.sin(lfoTime / lfoSpeed[i])) + 800 => lp[i].freq;
		}
		lfoTime++;
		10::ms => now;
	}
}

for(0 => int i; i < numSynths; i++){
	osc[i] => env[i] => lp[i] => oscPan[i];
	0.03 => osc[i].gain;
	oscPan[i].left => lrev;
	oscPan[i].right => rrev;
	0.75 - 1.5 * (i $ float / (numSynths - 1)) => oscPan[i].pan;
	<<<oscPan[i].pan()>>>;
	400::ms => env[i].attackTime;
	60::ms => env[i].decayTime;
	0.8 => env[i].sustainLevel;
	1000::ms => env[i].releaseTime;
	800 => lp[i].freq;
	3 => lp[i].Q;
	Math.random2f(200, 500) => lfoDepth[i];
	Math.random2f(80, 200) => lfoSpeed[i];
}

for(0 => int x; x < numMelSynths; x++){
    s[x] => e[x] => lpm[x] => p[x];
    p[x].left => lmelrev;
    p[x].right => rmelrev;
    0.05 => s[x].gain;
    3::ms => e[x].attackTime;
    60::ms => e[x].decayTime;
    0.2 => e[x].sustainLevel;
    100::ms => e[x].releaseTime;
    2 => lpm[x].Q;
}

spork ~ chordLfo();
spork ~ oscGetChord();
spork ~ oscGetMelody();
int sameNote;
float synthNote;

0.2 => dac.gain;

while(true){
	if(Math.randomf() > 0.4){
		1 => int sameNote;
		0 => int c;
		while(sameNote > 0 && c < 40){
			60 + key + chordNotes[type][root][Math.random2(0, chordNotes[type][root].cap() - 1)] => Std.mtof => synthNote;
			<<<"Tried to make note: ", synthNote>>>;
			0 => sameNote;
			c++;
			for(0 => int x; x < numSynths; x++){
				if(synthNote < osc[x].freq() + noteDistance && synthNote > osc[x].freq() - noteDistance){
					sameNote++;
				}
			}
		}
		synthNote + Math.random2f(-1 * detune, detune) => osc[activeSynth].freq;
		env[activeSynth].keyOn(1);
		<<<"Made note: ", osc[activeSynth].freq()>>>;
		activeSynth++;
		if(activeSynth == numSynths){
			0 => activeSynth;
		}
		env[activeSynth].keyOff(1);
	}
	Math.random2(1500, 2000)::ms => now;
}