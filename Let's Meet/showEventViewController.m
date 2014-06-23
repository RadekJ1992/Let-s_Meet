#import "showEventViewController.h"
#import "createEventViewController.h"
#import "DBManager.h"

@interface showEventViewController ()
@end

@implementation showEventViewController
@synthesize event;
@synthesize mapView;
/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedEvent"]) {
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
    
    //wyświetlenie mapy
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[event pin] coordinate], 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;
    
    //wyświetlenie pinezki w miejcu wydarzenia
    MapPin *eventPin = [[MapPin alloc] init];
    [eventPin setTitle:[event eventName]];
    [eventPin setCoordinate:[[event pin] coordinate]];
    [mapView addAnnotation:eventPin];
    
    //pobranie lokalizacji gości z bazy
    NSMutableDictionary *guestsDictionary = [[DBManager getSharedInstance] getEventGuestsWithLocationsForEventName: [event eventName]];
    
    //dodanie pinezki dla każego gościa
    for (NSString *name in [guestsDictionary allKeys]) {
        MapPin *pin = [[MapPin alloc] init];
        [pin setTitle: name];
        [pin setCoordinate: [(CLLocation*) [guestsDictionary objectForKey: name] coordinate]];
        [mapView addAnnotation:pin];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
