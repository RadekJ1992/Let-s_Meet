//
//  locationSelectViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "locationSelectViewController.h"
#import "createEventViewController.h"

@interface locationSelectViewController ()

@end

@implementation locationSelectViewController

@synthesize mapView;
@synthesize searchBar;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"coordinates"]) {
        if (pin) {
            createEventViewController *cEVC = [segue destinationViewController];
            cEVC.pin = pin;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = 52.2296756;
    region.center.longitude = 21.0122287;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    
    [mapView setRegion:region animated:YES];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [theSearchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        MKCoordinateSpan span;
        double radius = placemark.region.radius / 1000; // convert to km
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        span.latitudeDelta = radius / 112.0;
        
        region.span = span;
        
        [mapView setRegion:region animated:YES];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)setLocation:(id)sender {
    mapView.showsUserLocation = YES;
    MKCoordinateRegion region = MKCoordinateRegionMake([mapView userLocation].coordinate, MKCoordinateSpanMake(0.01f, 0.01f));
    [mapView setRegion:region animated:YES];
    
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    [self.mapView removeAnnotation:pin];
    if (pin == nil) {
        pin = [[MapPin alloc] init];
    }
    // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    // Then all you have to do is create the annotation and add it to the map
    //MapPin *dropPin = [[MapPin alloc] init];
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = locCoord.latitude;
    region.center.longitude = locCoord.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    pin.coordinate = region.center;
    [self.mapView addAnnotation:pin];
}

@end