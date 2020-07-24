//
//  _AppDelegate.m
//  RS-Optimizely
//
//  Created by moitra.ruchira.26@gmail.com on 07/22/2020.
//  Copyright (c) 2020 moitra.ruchira.26@gmail.com. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>
#import "RudderOptimizelyFactory.h"

@implementation _AppDelegate
static NSString *DATA_PLANE_URL = @"https://2f7a352d.ngrok.io";
static NSString *CONTROL_PLANE_URL = @"http://api.dev.rudderlabs.com";
static NSString *WRITE_KEY = @"1f5BEV2kneYtZ3HkuwsGjd2JeZ1";
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    OPTLYLoggerDefault *optlyLogger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelError];
    // Initialize an Optimizely manager
    //    self.optlyManager = [OPTLYManager init:^(OPTLYManagerBuilder *_Nullable builder) {
    //        builder.projectId = @"18396880524";
    //        builder.logger = optlyLogger;
    //
    //    }];
    self.optlyManager = [[OPTLYManager alloc] initWithBuilder:[OPTLYManagerBuilder  builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.sdkKey = @"LwrTQEYD9yReHwogKphdt";
        builder.logger = optlyLogger;
    }]];
    //    self.optlyManager =  [OPTLYManager init:^(OPTLYManagerBuilder *_Nullable builder)  {
    //      // Load the datafile from the bundle
    //      NSString *filePath =[[NSBundle bundleForClass:[self class]]
    //                           pathForResource:@"https://cdn.optimizely.com/datafiles/LwrTQEYD9yhdt.json"
    //                           ofType:@"json"];
    //      NSString *fileContents =[NSString stringWithContentsOfFile:filePath
    //                               encoding:NSUTF8StringEncoding
    //                               error:nil];
    //      NSData *jsonData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    //
    //      // Set the datafile in the builder
    //      builder.datafile = jsonData;
    //      builder.logger = optlyLogger;
    //
    //    }];
    //
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
    [builder withControlPlaneUrl:CONTROL_PLANE_URL];
    [builder withFactory:[RSOptimizelyFactory instanceWithOptimizely:self.optlyManager]];

    [builder withLoglevel:RSLogLevelDebug];
    [RSClient getInstance:WRITE_KEY config:[builder build]];
    [[RSClient sharedInstance] track:@"Testing if malformed"];
    [[RSClient sharedInstance] identify:@"test"];
    [[RSClient sharedInstance] track:@"Product Added" properties:@{
        @"revenue": @4000,
    }];




    // Test delayed initialization
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

        // Initialize an Optimizely client by asynchronously downloading the datafile
        [self.optlyManager initializeWithCallback:^(NSError *_Nullable error, OPTLYClient *_Nullable client) {
            // Activate user in an experiment
            OPTLYVariation *variation = [client activate:@"testfeature_test" userId:@"test"];
            [RSLogger logDebug:@"Inside variation"];
            if ([variation.variationKey isEqualToString:@"variation_1"]) {
                [RSLogger logDebug:@"Inside first if"];
                [[RSClient sharedInstance] identify:@"test" traits:@{
                    @"gender" : @"male",
                    @"company" : @"rudder",
                    @"name" : @"ruchira"
                }];
                [[RSClient sharedInstance] track:@"Product Added" properties:@{
                    @"revenue": @8236376,
                }];
                [[RSClient sharedInstance] track:@"Product Removed" properties:@{
                    @"revenue": @2378827,
                }];
            } else if ([variation.variationKey isEqualToString:@"variation_2"]) {
                [RSLogger logDebug:@"Inside second if"];
                [[RSClient sharedInstance] identify:@"test"];
                [[RSClient sharedInstance] track:@"Product Removed" properties:@{
                    @"revenue": @7000,
                }];
            } else {
                [[RSClient sharedInstance] track:@"No variation triggered"properties:@{
                    @"revenue": @6000,
                }];
            }
        }];
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
