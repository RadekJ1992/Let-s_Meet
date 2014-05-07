//
//  createEventViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapPin.h"
#import "DBManager.h"

@interface createEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *coordinatesField;

@property (weak, nonatomic) MapPin *pin;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@property (strong, nonatomic) NSMutableArray *contactsNames;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)dateChanged:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end
