4 => int numSynths;
float timbre;

SqrOsc s[numSynths];
ADSR e[numSynths];
Pan2 p[numSynths];
LPF lp[numSynths];
NRev lrev;
NRev rrev;

lrev => dac.left;
0.08 => lrev.mix;
rrev => dac.right;
0.08 => rrev.mix;

for(0 => int x; x < numSynths; x++){
    s[x] => e[x] => lp[x] => p[x];
    p[x].left => lrev;
    p[x].right => rrev;
    0.06 => s[x].gain;
    3::ms => e[x].attackTime;
    60::ms => e[x].decayTime;
    0.2 => e[x].sustainLevel;
    100::ms => e[x].releaseTime;
    5 => lp[x].Q;
}

OscRecv recv;
6449 => recv.port;
recv.listen();

recv.event( "/note/timbre, i f" ) @=> OscEvent @ oe;
0 => int x;
while(true){
    oe => now;
    while(oe.nextMsg()){
        oe.getInt() => Std.mtof => s[x % numSynths].freq;
        oe.getFloat() => timbre;
        <<<timbre>>>;
        timbre * 5000 + 1600 => lp[x % numSynths].freq;
        Math.sin(timbre * 16931) => p[x % numSynths].pan;
        ((Math.sin(timbre * 13063) + 1.5) * 400)::ms => e[x % numSynths].decayTime;
        e[x % numSynths].keyOn();
        1 +=> x;
        e[x % numSynths].keyOff();
    }
}