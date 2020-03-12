import 'dart:ffi';
import 'dart:io';

final DynamicLibrary cNodeLib = Platform.isAndroid
    ? DynamicLibrary.open("libcnode.so")
    : Platform.isIOS || Platform.isMacOS
    ? DynamicLibrary.open("cnode.framework/cnode")
    : null;