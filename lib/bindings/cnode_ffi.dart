import 'dart:ffi';
import 'dart:io';

final DynamicLibrary cNodeLib = Platform.isAndroid
    ? DynamicLibrary.open("libnode.so")
    : Platform.isIOS
        ? DynamicLibrary.open("NodeMobile.framework/NodeMobile")
        : Platform.isMacOS ? DynamicLibrary.open("node.framework/node") : null;