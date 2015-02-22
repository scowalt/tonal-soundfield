class Chord
{
    0=>static int mode;
    0=>int style;
    Chord @ next[];
    int notes[];
    int root;                         //the root key
    int type;                         //major,minor,etc
    float probabilities[][];              //probability for each next state
    Chord @ modulationSequence[][];
    Chord @ modulationChord[];
    int modulationTarget[];
    fun void init(int root, int type, Chord next[], float probabilities[][])
    {
        setRoot(root);
        setType(type);
        setNext(next);
        setProbabilities(probabilities);
        setNotes();
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
        return getNextChord(mode);
    }
    fun Chord getNextChord(int i)
    {
        Std.rand2f(0, 1)=>float rand;
        0=>float c;
        getProbabilities(i)@=>float p[];
        for (0=>int i; i<p.cap()-1;i++)
        {
            p[i]+=>c;
            if (rand<=c)
                return next[i];
        }
        return next[next.cap()-1];
    }
    fun float[] getProbabilities(int i)
    {
        return probabilities[i];
    }
    fun string toString()
    {
        [["I","i","Idim","Iaug","Isus4","I7"],
         ["bII","bii"],
         ["II","ii"],
         ["bIII","biii"],
         ["III","iii"],
         ["IV","vi"],
         ["bV","bv"],
         ["V","v","Vdim","Vaug","Vsus4","V7"],
         ["bVI","bvi"],
         ["VI","vi","VIdim","VIaug","VIsus4"],
         ["bVII","bvii"],
         ["VII","vii"]]@=>string s[][];
        return s[root][type];
    }
    fun void setNotes()
    {
        if (type==0)
        {
            [root,root+4,root+7]@=>notes;
        }
        if (type==1)
        {
            [root,root+3,root+7]@=>notes;
        }
        if (type==2)
        {
            [root,root+3,root+6]@=>notes;
        }
        if (type==3)
        {
            [root,root+4,root+8]@=>notes;
        }
        if (type==4)
        {
            [root,root+5,root+7]@=>notes;
        }
        if (type==5)
        {
            [root,root+4,root+7,root+10]@=>notes;
        }

    }
    fun int[] getNotesWithin()
    {
        return notes;
    }
    fun void setModulation(Chord modulation[][], int target[], Chord chord[])
    {
        modulation@=>modulationSequence;
        target@=>modulationTarget;
        chord@=>modulationChord;
    }
    fun Chord[][] getModulationSequence()
    {
        return modulationSequence;
    }
    fun int[] getModulationTarget()
    {
        return modulationTarget;
    }
    fun Chord[] getModulationChord()
    {
        return modulationChord;
    }
}


//runing code starts here
OscSend send;
"localhost" => string hostname;
6449 => int port;
send.setHost(hostname,port);
Chord current;
Chord I;
Chord I7;
Chord ii;
Chord II;
Chord iii;
Chord III;
Chord IV;
Chord V;
Chord V7;
Chord vi;
Chord VI;
Chord Isus4;
Chord VIsus4;
I.init(0,0,[I,ii,III,IV,V,vi],[[0.1,0.1,0.1,0.3,0.3,0.1],[0.1,0.1,0.1,0.1,0.1,0.5]]);
I7.init(0,5,[I7],[[1.0],[1.0]]);
ii.init(2,1,[I,iii,III,V,vi],[[0.1,0.1,0.3,0.4,0.1],[0.1,0.4,0.3,0.1,0.1]]);
II.init(2,0,[II],[[1.0],[1.0]]);
iii.init(4,1,[V,IV,vi],[[0.4,0.4,0.2],[0.2,0.3,0.5]]);
III.init(4,0,[IV,vi],[[0.6,0.4],[0.3,0.7]]);
IV.init(5,0,[I,V,III],[[0.3,0.6,0.1],[0.2,0.5,0.3]]);
V.init(7,0,[I,vi,ii,iii,Isus4,V7],[[0.2,0.2,0.1,0.2,0.1,0.2],[0.2,0.1,0.1,0.2,0.2,0.2]]);
V7.init(7,5,[I,vi],[[0.8,0.2],[0.4,0.6]]);
vi.init(9,1,[I,ii,iii,IV,V,vi],[[0.1,0.3,0.1,0.3,0.1,0.1],[0.1,0.2,0.2,0.2,0.2,0.1]]);
Isus4.init(0,4,[I],[[1.0],[1.0]]);
VIsus4.init(9,4,[vi],[[1.0],[1.0]]);
VI.init(9,0,[VI],[[1.0],[1.0]]);
III.setModulation([[VIsus4,VI]],[-3],[I]);
I.setModulation([[VI,II],[I7,IV]],[2,5],[I,I]);
I @=> current;
Rhodey  instruments[4];
for (0=>int i; i < instruments.cap(); i++)
{
    instruments[i]=>dac;
}
0=>int key;
while (true)
{
    <<< "Chord Name: ", current.toString() >>>;
    current.root=>int root;
    current.type=>int type;
    key => send.addInt;
    root => send.addInt;
    type => send.addInt;
    <<< "Sent key: ", key, "root: ", root, ", type: ", type >>>;
    current.getNotesWithin()@=>int notes[];
    for (0=>int j;j<4;j++)
    {
        0.5::second=>now;
        for (0=>int i; i < instruments.cap(); i++)
        {
            Std.mtof(48+(key+notes[i%notes.cap()])%12)=>instruments[i].freq;
            if (j==0)
                0.2=>instruments[i].noteOn;
            else if (Math.random2f(0,1)<0.7)
                0.1=>instruments[i].noteOn;
        }
    }
    if (current.getModulationTarget()!=null&&Math.random2f(0,1)<0.9)
    {

        current.getModulationSequence()@=>Chord sq[][];
        current.getModulationTarget()@=>int keys[];
        current.getModulationChord()@=>Chord chords[];
        Math.random2f(0,sq.cap())  $ int  =>int choice;
        sq[choice]@=>Chord chordSq[];
        keys[choice]=>int keyChange;
        chords[choice]@=>Chord modChord;
        for (0=>int i; i <chordSq.cap();i++)
        {
            chordSq[i]@=>current;
                <<< "Chord Name: ", current.toString() >>>;
            current.root=>int root;
            current.type=>int type;
            key => send.addInt;
            root => send.addInt;
            type => send.addInt;
            <<< "Sent key: ", key, "root: ", root, ", type: ", type >>>;
            current.getNotesWithin()@=>int notes[];
            for (0=>int j;j<4;j++)
            {
                0.5::second=>now;
                for (0=>int i; i < instruments.cap(); i++)
                {
                    Std.mtof(48+(key+notes[i%notes.cap()])%12)=>instruments[i].freq;
                    if (j==0)
                        0.2=>instruments[i].noteOn;
                    else if (Math.random2f(0,1)<0.7)
                        0.1=>instruments[i].noteOn;
                }
            }
        }
        modChord.getNextChord()@=>current;
        (key+keyChange+12)%12=>key;
    }
    else
    {
        current.getNextChord()@=>current;
    }
}


