import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'cnode_ffi.dart';

/// Start node.js program
/// [argc] Argument count
/// [argv] Arguments
final void Function(int argc, Pointer<Pointer<Utf8>> argv) nodeStart = cNodeLib
    .lookup<NativeFunction<Void Function(Int32, Pointer)>>('nodeStart')
    .asFunction();
