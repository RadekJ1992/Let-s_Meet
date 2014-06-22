#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TCPManager.h"


@interface meetAppAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) UIBackgroundTaskIdentifier *bgTask;


- (void)registerDefaultsFromSettingsBundle;
@end
