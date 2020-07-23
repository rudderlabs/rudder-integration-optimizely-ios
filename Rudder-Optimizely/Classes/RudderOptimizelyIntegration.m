//
//  RudderOptimizelyIntegration.m
//  Pods-Rudder-Optimizely_Example
//
//  Created by Ruchira Moitra on 22/07/20.
//

#import "RudderOptimizelyIntegration.h"


@implementation RudderOptimizelyIntegration

#pragma mark - Initialization

- (instancetype) initWithConfig:(NSDictionary *)config andOptimizelyManager:(OPTLYManager *)manager withAnalytics:(nonnull RudderClient *)client  withRudderConfig:(nonnull RudderConfig *)rudderConfig {
    self = [super init];
    if(self){
        self.config = config;
        self.manager = manager;
        self.client = client;
        self.backgroundQueue = dispatch_queue_create("Rudder Optimizely Background Queue ", NULL);
        
        if ([(NSNumber *)[self.config objectForKey:@"listen"] boolValue]) {
            self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"Notification for optimizely"
                                                                              object:nil
                                                                               queue:nil
                                                                          usingBlock:^(NSNotification *_Nonnull note) {
                [self experimentDidGetViewed:note];
            }];
        }
        
        
    }
    
    return self;
    
}

- (void) dump:(RudderMessage *)message {
    @try {
        if (message != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processRudderEvent:message];
            });
        }
    } @catch (NSException *ex) {
        [RudderLogger logError:[[NSString alloc] initWithFormat:@"%@", ex]];
    }
    
}

- (void) processRudderEvent: (nonnull RudderMessage *) message {
    NSDictionary *properties = message.context.traits;
    properties = [self filterProperties:properties];
    NSString *type = message.type;
    
    if ([type isEqualToString:@"identify"]) {
        if (message.userId) {
            self.userId = message.userId;
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder is assigning your user id %@", self.userId]];
        }
        
        if (properties) {
            self.userTraits = properties;
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder is assigning your user traits/attributes %@", self.userTraits]];
        }
        
    }
    
    else if([type isEqualToString:@"track"]){
        if ([self.manager getOptimizely] == nil) {
            [self enqueueAction:message];
            return;
        }
        
        [self trackEvent:message];
        
        
    }
}

- (void)reset {
    if ([self.manager getOptimizely] == nil) {
        return;
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"[NSNotificationCenter defaultCenter] removeObserver:%@", self.observer]];
    }
}

- (void)trackEvent:(RudderMessage *)message
{
    OPTLYClient *client = [self.manager getOptimizely];
    
    
    BOOL trackKnownUsers = [[self.config objectForKey:@"trackKnownUsers"] boolValue];
    if (trackKnownUsers && [self.userId length] == 0) {
        return;
    }
    
    // Attributes must not be nil, so Segment will trigger track without attributes if self.userTraits is empty
    if (trackKnownUsers) {
        if (self.userTraits.count > 0) {
            [client track:message.event userId:self.userId attributes:self.userTraits eventTags:message.properties];
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder Optimizely track:%@, userId:%@, attributes:%@, eventTags:%@", message.event,self.userId,self.userTraits,message.properties]];
        } else {
            [client track:message.event userId:self.userId eventTags:message.properties];
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder Optimizely track:%@, userId:%@, eventTags:%@", message.event,self.userId,message.properties]];
        }
        
        
        if (!trackKnownUsers && self.userTraits.count > 0) {
            [client track:message.event userId:message.anonymousId attributes:self.userTraits eventTags:message.properties];
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder Optimizely track:%@, userId:%@, attributes:%@, eventTags:%@", message.event,message.anonymousId,self.userTraits,message.properties]];
        } else {
            [client track:message.event userId:message.anonymousId eventTags:message.properties];
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Rudder Optimizely track:%@, userId:%@, eventTags:%@", message.event,message.anonymousId,message.properties]];
            
        }
    }
}

#pragma mark experiment viewed

- (void)experimentDidGetViewed:(NSNotification *)notification
{
    OPTLYExperiment *experiment = notification.userInfo[OptimizelyNotificationsUserDictionaryExperimentKey];
    OPTLYVariation *variation = notification.userInfo[OptimizelyNotificationsUserDictionaryVariationKey];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[@"experimentId"] = [experiment experimentId];
    properties[@"experimentName"] = [experiment experimentKey];
    properties[@"variationId"] = [variation variationId];
    properties[@"variationName"] = [variation variationKey];
    
    if ([(NSNumber *)[self.config objectForKey:@"nonInteraction"] boolValue]) {
        properties[@"nonInteraction"] = @1;
    }
    
    // Trigger event as per our spec
    // NSDictionary *integrations = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", @"OptimizelyFullStack", nil];
    [self.client track:@"Experiment Viewed" properties:properties]; //need to add options
}


#pragma mark queueing

- (void)enqueueAction:(RudderMessage *)message
{
    [self dispatchBackground:^{
        @try {
            if (self.queue.count > 100) {
                // Remove the oldest element.
                [self.queue removeObjectAtIndex:0];
            }
            [self setupTimer];
            [self.queue addObject:message];
            
        }
        @catch (NSException *exception) {
            
        }
    }];
}

- (void)dispatchBackground:(void (^)(void))block
{
    dispatch_async(_backgroundQueue, block);
    
}

- (NSMutableArray *)queue
{
    if (!_queue) {
        _queue = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _queue;
}

- (void)setupTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_flushTimer == nil) {
            _flushTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(isOptimizelyInitialized) userInfo:nil repeats:YES];
        }
    });
}
- (void)isOptimizelyInitialized
{
    [self dispatchBackground:^{
        
        if ([self.manager getOptimizely] == nil) {
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Optimizely is not initialized!"]];
        } else {
            [self.flushTimer invalidate];
            self.flushTimer = nil;
            [self flushQueue];
            
        }
        
    }];
}

- (void)flushQueue
{
    for (RudderMessage *message in self.queue) {
        [self trackEvent:message];
    }
    
    [self.queue removeAllObjects];
}
- (NSDictionary*) filterProperties: (NSDictionary*) properties {
    if (properties != nil) {
        NSMutableDictionary *filteredProperties = [[NSMutableDictionary alloc] init];
        for (NSString *key in properties.allKeys) {
            id val = properties[key];
            if ([val isKindOfClass:[NSString class]] || [val isKindOfClass:[NSNumber class]]) {
                filteredProperties[key] = val;
            }
        }
        return filteredProperties;
    } else {
        return nil;
    }
}






@end
