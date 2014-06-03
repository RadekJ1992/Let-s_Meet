//
//  meetAppAppDelegate.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "meetAppAppDelegate.h"

@implementation meetAppAppDelegate

@synthesize locationManager;
@synthesize bgTask;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    if (!ip || !port) {
        [self registerDefaultsFromSettingsBundle];
    }
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 500;
    locationManager.delegate = self;
    //[locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];

    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    CLLocation* location = [locationManager location];
    NSLog(@"2%f, %f" ,[location coordinate].latitude, [location coordinate].longitude);
    /*if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    [locationManager startMonitoringSignificantLocationChanges];
    */
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

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // Send the new location to your server in a background task
        // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
        *bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
            [[UIApplication sharedApplication] endBackgroundTask:*bgTask];
            CLLocation* location = [locationManager location];
            NSLog(@"zbgTask%f, %f" ,[location coordinate].latitude, [location coordinate].longitude);

        }];
                      
        // Make a SYNCHRONOUS call to send the new location to our server
        CLLocation* location = [locationManager location];
        NSLog(@"zsynchronouscall%f, %f" ,[location coordinate].latitude, [location coordinate].longitude);

        // Close the task
        if (*bgTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:*bgTask];
             *bgTask = UIBackgroundTaskInvalid;
             }
        } else {
            CLLocation* location = [locationManager location];
            NSLog(@"zelse%f, %f" ,[location coordinate].latitude, [location coordinate].longitude);
            NSLog(@"he z else");// Handle location updates in the normal way
        }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"zzwyklegoupdate'a%f, %f" ,[locations[0] coordinate].latitude, [locations[0] coordinate].longitude);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    UIAlertView *alertView;
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // tylko dla debugu
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *ip = (NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"serverIP"];
    NSString *port = (NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"serverPort"];
    
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n%@", text, ip, port];
    alertView = [[UIAlertView alloc] initWithTitle:[url lastPathComponent] message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    //END tylko dla debugu
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];

}
@end
