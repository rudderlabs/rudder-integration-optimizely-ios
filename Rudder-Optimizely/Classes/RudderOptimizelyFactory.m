//
//  RudderOptimizelyFactory.m
//  Pods-Rudder-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import "RudderOptimizelyFactory.h"
#import "RudderOptimizelyIntegration.h"
#import "RudderLogger.h"

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
    [RudderLogger logDebug:@"Initializing Optimizely SDK"];
    if (self = [super init]) {
        self.manager = manager;
    }
    
    return self;
}

+ (instancetype)createWithOptimizelyManager:(NSString *)token optimizelyManager:(OPTLYManager *)manager
{
    return [[self alloc] initWithOptimizely:manager];
}

- (nonnull NSString *)key {
    return @"Optimizely Fullstack";
}

- (nonnull id<RudderIntegration>)initiate:(nonnull NSDictionary *)config client:(nonnull RudderClient *)client rudderConfig:(nonnull RudderConfig *)rudderConfig {
    [RudderLogger logDebug:@"Creating RudderIntegrationFactory"];
    
    return [[RudderOptimizelyIntegration alloc] initWithConfig:config andOptimizelyManager:self.manager withAnalytics:client withRudderConfig:rudderConfig];
}
@end
