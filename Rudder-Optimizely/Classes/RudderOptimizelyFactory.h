//
//  RSOptimizelyFactory.h
//  Pods-RS-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSOptimizelyFactory : NSObject<RSIntegrationFactory>

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)optimizely;

@property OPTLYManager *manager;

@end

NS_ASSUME_NONNULL_END
