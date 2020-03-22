import 'dart:ffi';

import 'cnode_ffi.dart';

final Pointer Function(Pointer loop) getEnvironmentEventLoop = cNodeLib
    .lookup<NativeFunction<Pointer Function(Pointer)>>('getEnvironmentEventLoop')
    .asFunction();