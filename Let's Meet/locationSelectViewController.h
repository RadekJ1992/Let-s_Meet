#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "Event.h"
#import <CoreLocation/CoreLocation.h>
/**
 ViewController obsługujący wybór lokalizacji wydarzenia
 */
@interface locationSelectViewController : UIViewController <UISearchBarDelegate> {
    MKMapView *mapView;
}
//okienko z mapą
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
//pasek wyszukiwania
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//obiekt reprezentujący wydarzenie
@property (strong, nonatomic) Event* event;
//metoda ustawiająca lokalizację
-(IBAction)setLocation:(id)sender;

@end
