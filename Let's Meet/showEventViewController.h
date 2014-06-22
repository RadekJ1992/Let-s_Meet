#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "MapPin.h"

@interface showEventViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Event* event;


@end
