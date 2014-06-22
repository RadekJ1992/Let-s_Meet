#import "meetAppAppDelegate.h"

@interface meetAppAppDelegate() {
    bool isInBackGround;
}
@end

@implementation meetAppAppDelegate

@synthesize locationManager;
@synthesize bgTask;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    NSString *phoneNumber = (NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNumber"];
    if (!ip || !port || !phoneNumber) {
        [self registerDefaultsFromSettingsBundle];
    }
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 500;
    locationManager.delegate = self;
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    isInBackGround = FALSE;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation];
}




-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"locationUpdate %f, %f" ,[locations[0] coordinate].latitude, [locations[0] coordinate].longitude);
    [[DBManager getSharedInstance] insertUserLocation: [locations[0] coordinate]];
    [[TCPManager getSharedInstance] sendLocationWithLatitude:(double) [locations[0] coordinate].latitude andLongitude:(double)[locations[0] coordinate].longitude];
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    UIAlertView *alertView;
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[DBManager getSharedInstance] addEvent:text onDate:nil inLocation:nil withGuests:nil];
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* eventID = [f numberFromString:text];
    [[DBManager getSharedInstance] updateEventID:eventID forEventName:text];
    [[TCPManager getSharedInstance] registerToEventwithEventName:eventID];
    NSString *msg = [NSString stringWithFormat:@"Zostałeś zaproszony do wydarzenia!"]; //\n%@\n%@\n%@\n%@", text, ip, port,phoneNumber];
    alertView = [[UIAlertView alloc] initWithTitle:[url lastPathComponent] message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
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
