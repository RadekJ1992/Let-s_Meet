//
//  locationSelectViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"

@interface locationSelectViewController : UIViewController <UISearchBarDelegate> {
    MKMapView *mapView;
    MapPin *pin;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
-(IBAction)setLocation:(id)sender;

@end
