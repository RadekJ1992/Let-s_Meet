//
//  contactsSelectViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "contactsSelectViewController.h"
#import "createEventViewController.h"

@interface contactsSelectViewController ()

@end

@implementation contactsSelectViewController
@synthesize contacts;
@synthesize event;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contact"]) {
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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!event) {
        event = [[Event alloc] init];
    }
    ABPeoplePickerNavigationController * peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    NSArray * displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonAddressProperty],
                                [NSNumber numberWithInt:kABPersonPhoneProperty],
                                nil];
    
    peoplePicker.displayedProperties = displayedItems;
    [self.view addSubview:peoplePicker.view];
    [self addChildViewController:peoplePicker];
    [peoplePicker didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
    
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    if (!firstName) firstName = @" ";
    if (!lastName) lastName = @" ";
    NSString *name=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef mul;
        mul=(__bridge ABMultiValueRef)((__bridge NSString *) ABRecordCopyValue(person, kABPersonPhoneProperty));
        NSString *phone=(__bridge NSString *) ABMultiValueCopyValueAtIndex(mul,0);
        [event.contacts setObject:phone forKey:name];
        [[DBManager getSharedInstance] addGuestWithName:name andPhone:phone];
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"contact" sender: nil];
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
