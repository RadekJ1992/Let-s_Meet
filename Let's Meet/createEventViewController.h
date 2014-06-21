//
//  createEventViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MapPin.h"
#import "Event.h"
#import "DBManager.h"
#import "TCPManager.h"

@interface createEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *coordinatesField;

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@property (strong, nonatomic) NSMutableArray *contactsNames;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)dateChanged:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)sendButtonClicked:(id)sender;

-(id) initWithEventName:(NSString*) eventName;

@end
