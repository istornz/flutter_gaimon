#import "GaimonPlugin.h"
#if __has_include(<gaimon/gaimon-Swift.h>)
#import <gaimon/gaimon-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "gaimon-Swift.h"
#endif

@implementation GaimonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGaimonPlugin registerWithRegistrar:registrar];
}
@end
