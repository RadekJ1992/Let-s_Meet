//
//  showEventViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 15.06.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "MapPin.h"

@interface showEventViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Event* event;


@end
