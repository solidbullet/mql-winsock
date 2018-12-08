var net = require('net');
const redis = require('redis')
var HOST = '127.0.0.1';
var PORT = 8080;

// 创建一个TCP服务器实例，调用listen函数开始监听指定端口
// 传入net.createServer()的回调函数将作为”connection“事件的处理函数
// 在每一个“connection”事件中，该回调函数接收到的socket对象是唯一的

net.createServer(function(sock) {
	const client = redis.createClient(6379, 'hiiboy.com')
	client.auth('password',function(err, reply) {
	 console.log("redis connect ok");
	});
    // 我们获得一个连接 - 该连接自动关联一个socket对象
    console.log('CONNECTED: ' +
        sock.remoteAddress + ':' + sock.remotePort);

    // 为这个socket实例添加一个"data"事件处理函数
    sock.on('data', function(data) {
        console.log('DATA ' + sock.remoteAddress + ': ' + data);
		var accountid = String(data).substr(0, String(data).length - 1);
        // 回发该数据，客户端将收到来自服务端的数据
		client.hgetall("user", function (err, obj) {
			if(JSON.stringify(obj).indexOf(accountid) >0 )sock.write("1");
			else sock.write("-1");
		});	
        //sock.write('i"' + data + '"100000000');
    });

    // 为这个socket实例添加一个"close"事件处理函数
    sock.on('close', function(data) {
        console.log('CLOSED: ' +
            sock.remoteAddress + ' ' + sock.remotePort);
    });

}).listen(PORT, HOST);

console.log('Server listening on ' + HOST +':'+ PORT);