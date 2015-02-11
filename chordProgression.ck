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
    string name;                      //how you call it
    string nextChord[];               //next states
    int root;                         //the root key
    int type;                         //major,minor,etc
    float probability[];              //probability for each next state
    fun string getNextChordName()     //randomly choose the next chord
    {
        Std.rand2f(0, 1)=>float rand;
        0=>float c;
        for (0=>int i; i<probability.cap();i++)
        {
            probability[i]+=>c;
            if (rand<=c)
                return nextChord[i];
        }
        return this.name;
    }
    fun void setStyle(){}            //may be used to change probabilities
}

class ChordMajor extends Chord
{
    0=>type;
}

class ChordMinor extends Chord
{
    1=>type;
}

class ChordI extends ChordMajor
{
    "I"=>name;
    0=>root;
    ["I", "ii","III","IV","V"]@=>nextChord;
    [0.1,0.1,0.1,0.4,0.3]@=>probability;
}
class Chordii extends ChordMinor
{
    "ii"=>name;
    2=>root;
    ["I","iii","III","V","vi"]@=>nextChord;
    [0.1,0.1,0.3,0.4,0.1]@=>probability;
}
class Chordiii extends ChordMinor
{
    "iii"=>name;
    4=>root;
    ["V","IV","vi"]@=>nextChord;
    [0.2,0.4,0.4]@=>probability;
}
class ChordIII extends ChordMajor
{
    "III"=>name;
    4=>root;
    ["IV","vi"]@=>nextChord;
    [0.4,0.6]@=>probability;
}
class ChordIV extends ChordMajor
{
    "IV"=>name;
    5=>root;
    ["I","V","III"]@=>nextChord;
    [0.3,0.6,0.1]@=>probability;
}
class ChordV extends ChordMajor
{
    "V"=>name;
    7=>root;
    ["I","vi","ii"]@=>nextChord;
    [0.6,0.3,0.1]@=>probability;
}class Chordvi extends ChordMinor
{
    "vi"=>name;
    9=>root;
    ["I","ii","iii","IV","V","vi"]@=>nextChord;
    [0.1,0.3,0.1,0.3,0.1,0.1]@=>probability;
}

//runing code starts here
OscSend send;
"localhost" => string hostname;
6449 => int port;
send.setHost(hostname,port);
Chord current;
ChordI I;
Chordii ii;
Chordiii iii;
ChordIII III;
ChordIV IV;
ChordV V;
Chordvi vi;
fun Chord getChord(string s)
{
    if (s=="I")
        return I;
    if (s=="ii")
        return ii;
    if (s=="iii")
        return iii;
    if (s=="III")
        return III;
    if (s=="IV")
        return IV;
    if (s=="V")
        return V;
    if (s=="vi")
        return vi;
    return null;
}
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
    getChord(current.getNextChordName())@=>current;
    6::second=>now;
}

















