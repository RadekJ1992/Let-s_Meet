//
//  createEventViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapPin.h"

@interface createEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *coordinatesField;

@property (weak, nonatomic) MapPin *pin;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@end
