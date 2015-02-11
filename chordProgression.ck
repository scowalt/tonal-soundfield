/* As you can see, this is a very raw Markov chain for chord progressions
 * It would be great if melodies can be generated according to this state machine
 * I use classes only because a ton of "else if" looks really messy, though the object-oriented of this language is really bad
 * The blank funcion is intended for future data receiving
 * It sends basic information of a chord
 * I hope melody can be generated according to the chord
 */
 
//the very basic chord base
class Chord
{
    0=>int style;
    string name;                      //how you call it         
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
        Std.rand2f(0, 1)=>float rand;
        0=>float c;
        getPrabablities()@=>float p[];
        for (0=>int i; i<p.cap();i++)
        {
            p[i]+=>c;
            if (rand<=c)
                return next[i];
        }
        return this;
    } 
    fun float[] getPrabablities()
    {
        if (style==0)
            return probabilities[0];
    }
    fun void setStyle(){}           //may be used to change probabilities
}


//runing code starts here
OscSend send;
"localhost" => string hostname;
6449 => int port;
send.setHost(hostname,port);
Chord current;
Chord I;
Chord ii;
Chord iii;
Chord III;
Chord IV;
Chord V;
Chord vi;
I.init(0,0,[I,ii,III,IV,V],[[0.1,0.1,0.1,0.4,0.3]]);
ii.init(2,1,[I,iii,III,V,vi],[[0.1,0.1,0.3,0.4,0.1]]);
iii.init(4,1,[V,IV,vi],[[0.2,0.4,0.4]]);
III.init(4,0,[IV,vi],[[0.4,0.6]]);
IV.init(5,0,[I,V,III],[[0.3,0.6,0.1]]);
V.init(7,0,[I,vi,ii],[[0.6,0.3,0.1]]);
vi.init(9,1,[I,ii,iii,IV,V,vi],[[0.1,0.3,0.1,0.3,0.1,0.1]]);
I @=> current;
while (true)
{
    <<< "Chord Name: ", current.name >>>;
    0=>int key;
    current.root=>int root;
    current.type=>int type;
    key => send.addInt;
    root => send.addInt;
    type => send.addInt;
    <<< "Sent key: ", key, "root: ", root, ", type: ", type >>>;
    current.getNextChord()@=>current;
    6::second=>now;
}

















