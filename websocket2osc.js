var osc = require('node-osc');
var crypto = require('crypto');
var WebSocketServer = require('ws').Server;
var wsport = 7447;
var outport = 6450;
var wss = new WebSocketServer({port: wsport});
var client = new osc.Client('localhost', outport); 

wss.on('connection', function connection(ws){
  ws.on('message', function incoming(message){
    console.log(message);
    message = JSON.parse(message);
    if(message.event == 'comet' && message.melody){
      crypto.randomBytes(18, function(ex, buf){
        var id = buf.toString('hex');
        var timbre = (message.color.r + message.color.g + message.color.b) % 1;
        args = [id,  timbre, message.lifespan];
        for(var x = 0; x < 8; x++){
          args = args.concat(parseInt(message.melody[x]) + 72);
        }
        for(var x = 0; x < 200; x++){
          setTimeout(function(){
            client.send('/id/timbre/lifetime/n1/n2/n3/n4/n5/n6/n7/n8', args);
          }, 10);
        }
      });
    }
  });
});