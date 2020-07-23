//
//  RudderOptimizelyFactory.h
//  Pods-Rudder-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import <Foundation/Foundation.h>
#import <Rudder/RudderIntegrationFactory.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderOptimizelyFactory : NSObject<RudderIntegrationFactory>

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)optimizely;

@property OPTLYManager *manager;

@end

NS_ASSUME_NONNULL_END
