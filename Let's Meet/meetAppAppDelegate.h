//
//  meetAppAppDelegate.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface meetAppAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) UIBackgroundTaskIdentifier *bgTask;

- (void)registerDefaultsFromSettingsBundle;
@end
