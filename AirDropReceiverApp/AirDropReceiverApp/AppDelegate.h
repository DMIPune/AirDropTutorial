//
//  AppDelegate.h
//  AirDropReceiverApp
//
//  Created by Pranay on 3/25/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLProfile.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *saveReceivedWindow;

- (APLProfile *)dequeueProfile;

@end
