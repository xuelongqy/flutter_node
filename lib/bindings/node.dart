import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'cnode_ffi.dart';

/// Before the node program starts
/// [env] Node Environment
typedef InitNode = Void Function(Pointer env);
typedef InitNodeDart = void Function(Pointer env);

/// Start the node program
/// [argc] Argument count
/// [argv] Arguments
/// [initNode] Before the node program starts, initialization operation
/// [@return] exit code
final int Function(
        int argc,
        Pointer<Pointer<Utf8>> argv,
        Pointer<NativeFunction<InitNode>> initNode,) nodeStart =
    cNodeLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Int32, Pointer, Pointer)>>('nodeStart')
        .asFunction();

/// Start the node program in a thread
/// [argc] Argument count
/// [argv] Arguments
/// [initNode] Before the node program starts, initialization operation
/// [@return] exit code (Temporarily useless)
final int Function(
    int argc,
    Pointer<Pointer<Utf8>> argv,
    Pointer<NativeFunction<InitNode>> initNode,) nodeStartThread =
cNodeLib
    .lookup<
    NativeFunction<
        Int32 Function(
            Int32, Pointer, Pointer)>>('nodeStartThread')
    .asFunction();

/// Stop node program
/// [env] Node Environment
/// [@return] exit code (Temporarily useless)
final int Function(Pointer env) nodeStop = cNodeLib
    .lookup<NativeFunction<Int32 Function(Pointer)>>('nodeStop')
    .asFunction();
