class Chord
{
    0=>int style;       
    Chord @ next[];
    int root;                         //the root key
    int type;                         //major,minor,etc
    float probabilities[][];              //probability for each next state
    fun void init(int root, int type, Chord next[], float probabilities[][])
    {
        setRoot(root);
        setType(type);
        setNext(next);
        setProbabilities(probabilities);
    }
    fun void setRoot(int i)
    {
        i=>root;
    }
    fun void setType(int i)
    {
        i=>type;
    }
    fun void setNext(Chord c[])
    {
        c@=>next;
    }
    fun void setProbabilities(float f[][])
    {
        f@=>probabilities;
    }
    fun Chord getNextChord()
    {
        return getNextChord(0);
    }
    fun Chord getNextChord(int i)
    {
        Std.rand2f(0, 1)=>float rand;
        0=>float c;
        getProbabilities(i)@=>float p[];
        for (0=>int i; i<p.cap();i++)
        {
            p[i]+=>c;
            if (rand<=c)
                return next[i];
        }
        return this;
    }
    fun float[] getProbabilities(int i)
    {
        return probabilities[i];
    }
    fun string toString()
    {
        [["I","i"],
         ["bII","bii"],
         ["II","ii"],
         ["bIII","biii"],
         ["III","iii"],
         ["IV","vi"],
         ["bV","bv"],
         ["V","v"],
         ["bVI","bvi"],
         ["VI","vi"],
         ["bVII","bvii"],
         ["VII","vii"]]@=>string s[][];
        return s[root][type];
    }
    fun int[] getNotesWithin()
    {
        if (type==0)
        {
            return [root,root+4,root+7];
        }
        if (type==1)
        {
            return [root,root+3,root+7];
        }
        if (type==2)
        {
            return [root,root+3,root+6];
        }
        return null;
    }
}


//runing code starts here
OscSend send;
"localhost" => string hostname;
6449 => int port;
send.setHost(hostname,port);
Chord previous;
Chord current;
Chord I;
Chord ii;
Chord iii;
Chord III;
Chord IV;
Chord V;
Chord V7;
Chord vi;
I.init(0,0,[I,ii,III,IV,V,vi],[[0.1,0.1,0.1,0.3,0.3,0.1],[0.1,0.1,0.1,0.1,0.1,0.5]]);
ii.init(2,1,[I,iii,III,V,vi],[[0.1,0.1,0.3,0.4,0.1],[0.1,0.4,0.3,0.1,0.1]]);
iii.init(4,1,[V,IV,vi],[[0.4,0.4,0.2],[0.2,0.3,0.5]]);
III.init(4,0,[IV,vi],[[0.6,0.4],[0.3,0.7]]);
IV.init(5,0,[I,V,III],[[0.3,0.6,0.1],[0.2,0.5,0.3]]);
V.init(7,0,[I,vi,ii,iii],[[0.5,0.2,0.1,0.2],[0.3,0.4,0.1,0.2]]);
vi.init(9,1,[I,ii,iii,IV,V,vi],[[0.1,0.3,0.1,0.3,0.1,0.1],[0.1,0.2,0.2,0.2,0.2,0.1]]);
I @=> current;
Rhodey  instruments[4];
for (0=>int i; i < instruments.cap(); i++)
{
    instruments[i]=>dac;
}
while (true)
{
    <<< "Chord Name: ", current.toString() >>>;
    0=>int key;
    current.root=>int root;
    current.type=>int type;
    key => send.addInt;
    root => send.addInt;
    type => send.addInt;
    <<< "Sent key: ", key, "root: ", root, ", type: ", type >>>;
    current.getNotesWithin()@=>int notes[];
    for (0=>int j;j<4;j++)
    {  
        0.7::second=>now;
        for (0=>int i; i < instruments.cap(); i++)
        {
            Std.mtof(48+key+(notes[i%notes.cap()])%12)=>instruments[i].freq;
            if (j==0)
                0.2=>instruments[i].noteOn;
            else if (Math.random2f(0,1)<0.7)
                0.1=>instruments[i].noteOn;
        }
    }
    current.getNextChord(1)@=>Chord temp;
    while (temp==previous)
    {
        current.getNextChord(1)@=>temp;
    }
    current @=> previous;
    temp @=> current;
}










