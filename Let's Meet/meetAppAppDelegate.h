#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TCPManager.h"

/**
 Delegat całej aplikacji
 */
@interface meetAppAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) UIBackgroundTaskIdentifier *bgTask;


- (void)registerDefaultsFromSettingsBundle;
@end
