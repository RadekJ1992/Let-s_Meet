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
@synthesize inputStream;
@synthesize outputStream;

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
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [locationManager startMonitoringSignificantLocationChanges];
    
    [self initNetworkCommunication];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
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

-(void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) ip, [port intValue], &readStream, &writeStream);
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
}
@end
