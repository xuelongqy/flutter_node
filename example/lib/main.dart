import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_node/flutter_node.dart';
import 'package:flutter_node/node_bindings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Pointer<Pointer<Utf8>> argv = allocate<Pointer<Utf8>>(count: 3);
    List<String> arguments = [
      'node',
      '-e',
      '''
var http = require('http');
var versions_server = http.createServer( (request, response) => { 
  response.end('Versions: ' + JSON.stringify(process.versions)); 
}); 
versions_server.listen(3000);
      ''',
    ];
    Map<String, int> argumentsMap = {};
    int argumentsSize = 0;
    for (var arg in arguments) {
      int size = utf8.encode(arg).length + 1;
      argumentsMap[arg] = utf8.encode(arg).length + 1;
      argumentsSize += size;
    }
    Pointer<Utf8> argumentsPointer;
    final Pointer<Uint8> result = allocate<Uint8>(count: argumentsSize);
    final Uint8List nativeString = result.asTypedList(argumentsSize);
    int argumentsPos = 0;
    for (var arg in arguments) {
      var units = utf8.encode(arg);
      nativeString.setAll(argumentsPos, units);
      nativeString[units.length] = 0;
      int size = units.length + 1;
      argumentsSize += size;
    }
    int pointPos = 0;
    argumentsPointer = result.cast();
    for (int i = 0; i < arguments.length; i++) {
      var arg = arguments[i];
      argv[0] = Pointer.fromAddress(pointPos + argumentsPointer.address);
      pointPos += (utf8.encode(arg).length + 1);
    }
    nodeStart(3, argv);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterNode.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
