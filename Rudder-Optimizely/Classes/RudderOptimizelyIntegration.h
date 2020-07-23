//
//  RudderOptimizelyIntegration.h
//  Pods-Rudder-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderOptimizelyIntegration : NSObject<RudderIntegration>

@property (nonatomic) BOOL sendEvents;

@property (nonatomic, strong, nonnull) NSDictionary *config;
@property (nonatomic, strong, nonnull) OPTLYManager *manager;
@property (nonatomic, strong, nonnull) RudderClient *client;
@property (nonatomic, strong) dispatch_queue_t _Nullable backgroundQueue;
@property (nonatomic, nullable) id observer;
@property (nonatomic, nullable) NSString *userId;
@property (nonatomic, nullable) NSDictionary *userTraits;
@property (nonatomic, strong) NSMutableArray *_Nullable queue;
@property (nonatomic, strong) NSTimer *_Nullable flushTimer;


- (instancetype) initWithConfig:(NSDictionary *)config andOptimizelyManager:(OPTLYManager  *)manager withAnalytics:(nonnull RudderClient *)client  withRudderConfig:(nonnull RudderConfig *)rudderConfig;

@end

NS_ASSUME_NONNULL_END
