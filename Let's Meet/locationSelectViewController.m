#import "locationSelectViewController.h"
#import "createEventViewController.h"

@interface locationSelectViewController ()

@end

@implementation locationSelectViewController

@synthesize mapView;
@synthesize searchBar;
@synthesize event;
/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"coordinates"] ||
        [segue.identifier isEqualToString:@"coordinatesBack"]) {
        if (event) {
            createEventViewController *cEVC = [segue destinationViewController];
            cEVC.event = event;
        }
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
    //obsługa wciśnięcia i przytrzymania palca na mapie - wybór lokalizacji
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    if (!event) event = [[Event alloc] init];
    //wyświetlenie domyślnej lokalizacji - centrum Warszawy
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = 52.2296756;
    region.center.longitude = 21.0122287;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [mapView setRegion:region animated:YES];
    
}
//metoda obsługująca wyszukiwanie miejsc na mapie
-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [theSearchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        double radius = [(CLCircularRegion *)placemark.region radius] / 1000; // convert to km
        
        
        MKCoordinateRegion region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(radius / 112.0, radius / 112.0));
        
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        
        [mapView setRegion:region animated:YES];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)setLocation:(id)sender {
    mapView.showsUserLocation = YES;
    MKCoordinateRegion region = MKCoordinateRegionMake([mapView userLocation].coordinate, MKCoordinateSpanMake(0.01f, 0.01f));
    [mapView setRegion:region animated:YES];
    
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    [self.mapView removeAnnotation:event.pin];
    if (event.pin == nil) {
        event.pin = [[MapPin alloc] init];
    }
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = locCoord.latitude;
    region.center.longitude = locCoord.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    event.pin.coordinate = region.center;
    [self.mapView addAnnotation:event.pin];
}

@end
