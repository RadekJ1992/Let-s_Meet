#import "createEventViewController.h"
#import "contactsSelectViewController.h"
#import "locationSelectViewController.h"
#import "eventslistViewController.h"

@interface createEventViewController () {
    NSString* oldName;
}

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [eventNameField setDelegate:self];
    self.contactsTable.dataSource = self;
    if (event) {
        oldName = event.eventName;
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
    event.eventName = textField.text;
    [textField resignFirstResponder];
    return YES;
}

-(void)addEventToDatabase {
    BOOL success = NO;
    NSString *alertString = @"Data Insertion failed";
    if (event.eventDate && event.eventName && event.pin) {
        [[DBManager getSharedInstance] deleteEventForEventName:oldName];
        success = [[DBManager getSharedInstance]addEvent:event.eventName onDate:event.eventDate inLocation:event.pin withGuests:event.contacts];
        if (success == NO) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                                  alertString message:nil
                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else{
        alertString = @"Enter all fields";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              alertString message:nil
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)doneButtonClicked:(id)sender {
    [self addEventToDatabase];
}

- (IBAction)sendButtonClicked:(id)sender {
    if (![[DBManager getSharedInstance] getEventForEventName: [event eventName]]) [self addEventToDatabase];
    [event setEventID:[[DBManager getSharedInstance] getEventIDforEventName:[event eventName]]];
    if ([[event eventID] intValue] != 0) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            NSMutableArray* contactsPhoneNumbers = [[NSMutableArray alloc] init];
            for (id value in event.contacts.allValues) {
                [contactsPhoneNumbers addObject:value];
            }
        
            controller.body = [NSString stringWithFormat:@"meetApp://%@", event.eventID];
            controller.recipients = contactsPhoneNumbers;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    } else {
        [[TCPManager getSharedInstance] registerEvent:event];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Nie wysłano SMS" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;}
		case MessageComposeResultSent:
            
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(id)initWithEventName:(NSString *)eventName {
    self = [super init];
    if (self) {
        event = [[DBManager getSharedInstance] getEventForEventName:eventName];
    }
    return self;

}
@end
