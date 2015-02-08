"localhost" => string hostname;
6449 => int port;
OscSend xmit;
xmit.setHost(hostname, port);

int root;
int type;
0 => int key;

[0, 2, 4, 5, 7, 9, 12] @=> int notes[];
[0, 1, 1, 0, 0, 1, 0] @=> int types[];

while(true){
    xmit.startMsg( "/root/type", "i i" );
    Math.random2(0, notes.cap() - 1) => int i;
    if(Math.randomf() > 0.92){
    	key + 1 => key;
    }
    notes[i] => root;
    types[i] => type;
    key => xmit.addInt;
    root => xmit.addInt;
    type => xmit.addInt;
    <<< "Sent key: ", key, "root: ", root, ", type: ", type >>>;
    6::second => now;
}
