//
//  showEventViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 15.06.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "showEventViewController.h"
#import "createEventViewController.h"
#import "DBManager.h"

@interface showEventViewController ()
@end

@implementation showEventViewController
@synthesize event;
@synthesize mapView;

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
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[event pin] coordinate], 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;
    
    NSMutableDictionary *guestsDictionary = [[DBManager getSharedInstance] getEventGuestsWithLocationsForEventName: [event eventName]];
    
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
