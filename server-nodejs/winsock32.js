var net = require('net');
const redis = require('redis')
var HOST = '127.0.0.1';
var PORT = 8080;

// ����һ��TCP������ʵ��������listen������ʼ����ָ���˿�
// ����net.createServer()�Ļص���������Ϊ��connection���¼��Ĵ�����
// ��ÿһ����connection���¼��У��ûص��������յ���socket������Ψһ��

net.createServer(function(sock) {
	const client = redis.createClient(6379, 'hiiboy.com')
	client.auth('password',function(err, reply) {
	 console.log("redis connect ok");
	});
    // ���ǻ��һ������ - �������Զ�����һ��socket����
    console.log('CONNECTED: ' +
        sock.remoteAddress + ':' + sock.remotePort);

    // Ϊ���socketʵ�����һ��"data"�¼�������
    sock.on('data', function(data) {
        console.log('DATA ' + sock.remoteAddress + ': ' + data);
		var accountid = String(data).substr(0, String(data).length - 1);
        // �ط������ݣ��ͻ��˽��յ����Է���˵�����
		client.hgetall("user", function (err, obj) {
			if(JSON.stringify(obj).indexOf(accountid) >0 )sock.write("1");
			else sock.write("-1");
		});	
        //sock.write('i"' + data + '"100000000');
    });

    // Ϊ���socketʵ�����һ��"close"�¼�������
    sock.on('close', function(data) {
        console.log('CLOSED: ' +
            sock.remoteAddress + ' ' + sock.remotePort);
    });

}).listen(PORT, HOST);

console.log('Server listening on ' + HOST +':'+ PORT);