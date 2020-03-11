#import "FlutterNodePlugin.h"
#if __has_include(<flutter_node/flutter_node-Swift.h>)
#import <flutter_node/flutter_node-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_node-Swift.h"
#endif

@implementation FlutterNodePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNodePlugin registerWithRegistrar:registrar];
}
@end
