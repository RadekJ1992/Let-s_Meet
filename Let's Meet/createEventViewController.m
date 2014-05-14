//
//  createEventViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "createEventViewController.h"
#import "contactsSelectViewController.h"
#import "locationSelectViewController.h"

@interface createEventViewController ()

-(void)addEventToDatabase;

@end

@implementation createEventViewController

@synthesize event;
@synthesize contacts;
@synthesize contactsNames;
@synthesize contactsTable;
@synthesize datePicker;
@synthesize eventNameField;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contacts"]) {
        if (event) {
            contactsSelectViewController *cSVC = [segue destinationViewController];
            cSVC.event = event;
        }
    }
    if ([segue.identifier isEqualToString:@"chooseLocationSegue"]) {
        if (event) {
            locationSelectViewController *lSVC = [segue destinationViewController];
            lSVC.event = event;
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
    [eventNameField setDelegate:self];
    self.contactsTable.dataSource = self;
    if (event) {
        [datePicker setDate:event.eventDate];
        eventNameField.text = event.eventName;
        NSString *text = [NSString stringWithFormat:@"%f,%f", event.pin.coordinate.latitude, event.pin.coordinate.longitude];
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:event.pin.coordinate.latitude longitude:event.pin.coordinate.longitude] completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 [self coordinatesField].text = [placemarks[0] description];
             } else [self coordinatesField].text = text;
             
         }];
        
        for (id key in event.contacts) {
            if (!contactsNames) contactsNames = [[NSMutableArray alloc] init];
            [contactsNames addObject:key];
        }
    }
    CGAffineTransform rotate = CGAffineTransformMakeRotation(0/*-1.57*/);
    rotate = CGAffineTransformScale(rotate, /*.46, 2.25*/ 0.85, .85);
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(/*3, 22.5*/0,0);
    datePicker.transform = CGAffineTransformConcat(rotate,t0);
    [self.view addSubview:datePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.event.contacts allKeys] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *unifiedID = @"aCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unifiedID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:unifiedID];
        
    }
    
    cell.textLabel.text = [self.contactsNames objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text  = [self.event.contacts objectForKey:[self.contactsNames objectAtIndex:[indexPath row]]];
    return cell;
    
}

- (IBAction)dateChanged:(id)sender {
    NSDate* sourceDate = [datePicker date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    event.eventDate = destinationDate;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (!event) event = [[Event alloc] init];
    NSString* oldName = event.eventName;
    event.eventName = textField.text;
    if ([oldName isEqualToString:@""]) [[DBManager getSharedInstance ] deleteEventForEventName:oldName];
    [textField resignFirstResponder];
    return YES;
}

-(void)addEventToDatabase {
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    if (event.eventDate && event.eventName && event.pin) {
        //[[DBManager getSharedInstance] forceCloseDatabase];
        [[DBManager getSharedInstance] deleteEventForEventName:event.eventName];
        success = [[DBManager getSharedInstance]addEvent:event.eventName onDate:event.eventDate inLocation:event.pin withGuests:event.contacts];
    }
    else{
        alertString = @"Enter all fields";
    }
    if (success == NO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
        alertString message:nil
        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)doneButtonClicked:(id)sender {
    [self addEventToDatabase];
}

-(id)initWithEventName:(NSString *)eventName {
    self = [super init];
    if (self) {
        event = [[DBManager getSharedInstance] getEventForEventName:eventName];
    }
    return self;

}
@end
