#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "Firebase/Firebase.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* sendResetPasswordEmail = [FlutterMethodChannel
                                            methodChannelWithName:@"rsproule.pocketphds/sendResetPasswordEmail"
                                            binaryMessenger:controller];
    
    [sendResetPasswordEmail setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // TODO
        NSString *email = call.arguments[@"email"];
        [[FIRAuth auth] sendPasswordResetWithEmail:email completion:^(NSError *_Nullable error) {
            // ...
            if(error != nil) {
                result(@(false));
            }else{
                result(@(true));
            }
          
            
        }];
    }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
