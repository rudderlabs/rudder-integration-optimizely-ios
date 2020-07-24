//
//  RSOptimizelyFactory.m
//  Pods-RS-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import "RudderOptimizelyFactory.h"
#import "RudderOptimizelyIntegration.h"


@implementation RudderOptimizelyFactory


+ (instancetype)instanceWithOptimizely:(OPTLYManager *)manager
{
    static dispatch_once_t once;
    static RudderOptimizelyFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithOptimizely:manager];
    });
    return sharedInstance;
}

- (id)initWithOptimizely:(OPTLYManager *)manager
{
    [RSLogger logDebug:@"Initializing Optimizely SDK"];
    if (self = [super init]) {
        self.manager = manager;
    }

    return self;
}

// COMMENT: not required?
+ (instancetype)createWithOptimizelyManager:(NSString *)token optimizelyManager:(OPTLYManager *)manager
{
    return [[self alloc] initWithOptimizely:manager];
}

- (nonnull NSString *)key {
    return @"Optimizely Fullstack";
}

- (nonnull id<RSIntegration>)initiate:(nonnull NSDictionary *)config client:(nonnull RSClient *)client rudderConfig:(nonnull RSConfig *)rudderConfig {
    [RSLogger logDebug:@"Creating RSIntegrationFactory"];

    return [[RudderOptimizelyIntegration alloc] initWithConfig:config andOptimizelyManager:self.manager withAnalytics:client withRSConfig:rudderConfig];
}
@end
