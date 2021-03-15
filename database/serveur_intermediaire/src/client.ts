import WebSocket from 'ws';

var sock = new WebSocket("ws://localhost:1234");

sock.onopen = function(){
    sock.onmessage = function (msg: WebSocket.MessageEvent) {
        console.log(msg.data);
    };

    console.log("sending msg");
    sock.send("SELECT * FROM pions");
    console.log("received msg");
}