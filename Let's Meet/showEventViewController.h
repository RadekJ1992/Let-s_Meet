#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "MapPin.h"
/**
 ViewController obsługujący wyświetlenie mapki z pinami pokazującymi pozycje ludzi zapisanych na wydarzenie
 */
@interface showEventViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Event* event;


@end
