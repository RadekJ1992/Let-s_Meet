#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "Event.h"
#import <CoreLocation/CoreLocation.h>

@interface locationSelectViewController : UIViewController <UISearchBarDelegate> {
    MKMapView *mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) Event* event;

-(IBAction)setLocation:(id)sender;

@end
