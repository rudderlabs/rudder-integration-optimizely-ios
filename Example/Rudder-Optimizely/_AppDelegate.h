//
//  _AppDelegate.h
//  RS-Optimizely
//
//  Created by moitra.ruchira.26@gmail.com on 07/22/2020.
//  Copyright (c) 2020 moitra.ruchira.26@gmail.com. All rights reserved.
//

@import UIKit;
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import <OptimizelySDKiOS/OPTLYManager.h>

@interface _AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property OPTLYManager *optlyManager;

@end
