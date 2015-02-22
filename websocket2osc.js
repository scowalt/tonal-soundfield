var osc = require('node-osc');
var WebSocketServer = require('ws').Server;
var wsport = 7447;
var outport = 6449;
var wss = new WebSocketServer({port: wsport});
var client = new osc.Client('localhost', outport); 

wss.on('connection', function connection(ws){
  ws.on('message', function incoming(message){
    console.log(message);
    message = JSON.parse(message);
    if(message.event == 'comet'){
      client.send('/note/timbre', [Math.floor(50 + message.color.b * 20), message.color.r]);
      console.log(message.color.g);
    }
  });
});