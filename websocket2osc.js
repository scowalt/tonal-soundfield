var osc = require('node-osc');
var WebSocketServer = require('ws').Server;
var wsport = 3000;
var outport = 6449;
var wss = new WebSocketServer({port: wsport});
var client = new osc.Client('localhost', outport); 

wss.on('connection', function connection(ws){
  ws.on('message', function incoming(message){
    client.send('/note/timbre', [parseInt(message.split(' ')[0]), parseFloat(message.split(' ')[1])]);
  });
});