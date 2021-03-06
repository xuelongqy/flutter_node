import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_node/node_bindings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  // Node环境
  static Pointer _env = nullptr;

  // Node程序启动前(通常做初始化)
  static InitNodeDart _initNodeFunc;
  static void _initNode(Pointer env) {
    _env = env;
    if (_initNodeFunc != null) {
      _initNodeFunc(env);
    }
  }

  // 输入控制器
  TextEditingController _scriptInputController;
  TextEditingController _urlInputController;

  // 按钮动画控制器
  AnimationController _iconController;
  // 按钮动画控制器
  bool _isRunning = false;
  set _running(bool value) {
    _isRunning = value;
    if (_isRunning) {
      _iconController.reverse();
    } else {
      _iconController.forward();
    }
  }
  
  // 返回结果
  String _result;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..drive(Tween(begin: 0.0, end: 1.0));
    _iconController.animateTo(1.0);
    _urlInputController = TextEditingController(text: 'http://127.0.0.1:3000');
    _scriptInputController =
        TextEditingController(text: '''var http = require('http');
var versions_server = http.createServer( (request, response) => { 
  response.end('Versions: ' + JSON.stringify(process.versions)); 
}); 
versions_server.listen(3000);''');
    _initNodeFunc = _initNodeInner;
  }
  
  @override
  void dispose() {
    super.dispose();
    _iconController.dispose();
  }

  void _initNodeInner(Pointer env) {
    setState(() {
      _running = true;
    });
  }

  void _startNode(String script) async {
    if (_env != nullptr) return;
    List<String> arguments = [
      'node',
      '-e',
      script,
    ];
    Pointer<Pointer<Utf8>> argv = allocate<Pointer<Utf8>>(count: 3);
    int argumentsSize = 0;
    for (var arg in arguments) {
      int size = utf8.encode(arg).length + 1;
      argumentsSize += size;
    }
    Pointer<Utf8> argumentsPointer;
    final Pointer<Uint8> result = allocate<Uint8>(count: argumentsSize);
    final Uint8List nativeString = result.asTypedList(argumentsSize);
    argumentsPointer = result.cast();
    int argumentsPos = 0;
    for (int i = 0; i < arguments.length; i++) {
      var arg = arguments[i];
      var units = utf8.encode(arg);
      nativeString.setAll(argumentsPos, units);
      nativeString[argumentsPos + units.length] = 0;
      argv[i] = Pointer.fromAddress(argumentsPos + argumentsPointer.address);
      argumentsPos += units.length + 1;
    }
    // 启动Node程序
    //nodeStart(3, argv, Pointer.fromFunction(_initNode));
    nodeStartThread(3, argv, nullptr);
//    final receivePort = ReceivePort();
//    Isolate.spawn<SendPort>(_nodeIsolate, receivePort.sendPort);
//    final sendPort = await receivePort.first as SendPort;
//    final answer = ReceivePort();
//    sendPort.send([
//      {
//        'argc': 3,
//        'argv': argv.address,
//      },
//      answer.sendPort
//    ]);
//    return await answer.first;
  }

  void _stopNode() {
    _running = false;
    if (_env != nullptr) {
      _env = nullptr;
      print(nodeStop(_env));
    }
  }

//  static void _nodeIsolate(SendPort sendPort) {
//    final receivePort = ReceivePort();
//    //绑定
//    sendPort.send(receivePort.sendPort);
//    //监听
//    receivePort.listen((message) {
//      //获取数据并解析
//      final data = message[0] as Map;
//      final send = message[1] as SendPort;
//      //返回结果
//      send.send(nodeStart(data['argc'], Pointer.fromAddress(data['argv']), Pointer.fromFunction(_initNode)));
//    });
//  }

  void _requestUrl() {
    HttpClient().getUrl(Uri.parse(_urlInputController.text)).then((request) {
      request.close().then((response) {
        response.transform(utf8.decoder).join().then((value) {
          setState(() {
            _result = value;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Node.js for Flutter'),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 10.0),
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text('Node.js:'),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1.0, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.all(new Radius.circular(5.0)),
              ),
              child: TextField(
                controller: _scriptInputController,
                maxLines: 30,
                style: TextStyle(
                  fontSize: 12.0,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _urlInputController,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: RaisedButton(
                      child: Text('Request'),
                      onPressed: _requestUrl,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(_result ?? ''),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isRunning ? () {
            _stopNode();
          } : () {
            _startNode(_scriptInputController.text);
          },
          child: AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            progress: _iconController,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}
