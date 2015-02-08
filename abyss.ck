SinOsc sh[10];
LPF lp1[10];
PRCRev rev[10];
Dyno dn[2];
for(0 => int x; x < 5; x++){
	sh[2 * x] => rev[2 * x] => lp1[2 * x] => dn[0];
	sh[2 * x + 1] => rev[2 * x + 1] => lp1[2 * x + 1] => dn[1];
	0.06 => sh[2 * x].gain;
	0.1 => sh[2 * x + 1].gain;
	40 => lp1[2 * x].freq;
	8 => lp1[2 * x].Q;
	38 => lp1[2 * x + 1].freq;
	8 => lp1[2 * x + 1].Q;
	0.1 => rev[2 * x].mix;
	0.1 => rev[2 * x + 1].mix;
}

for(0 => int x; x < 2; x++){
	0.15 => dn[x].slopeAbove;
	1 => dn[x].slopeBelow;
	0.2 => dn[x].thresh;
}

dn[0] => dac.left;
dn[1] => dac.right;
2 => dac.gain;

SinOsc low => dac;
0.2 => low.gain;
30 => low.freq;

30 => float shn;

while(true){
	for(0 => int x; x < 5; x++){
		shn * Math.pow(2, x) => Std.mtof => sh[2 * x].freq;
		shn * Math.pow(2, x) - 4 => Std.mtof => sh[2 * x + 1].freq;
	}
	shn - Math.random2f(0.0002, 0.002) => shn;
	low.freq() + Math.random2f(-0.03, 0.03) => low.freq;
	if(shn < 15){
		shn * 2 => shn;
	}
	30::ms => now;
}