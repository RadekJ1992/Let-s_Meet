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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contact"]) {
        if (contact) {
            createEventViewController *cEVC = [segue destinationViewController];
            cEVC.contacts = contact;
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
    ABPeoplePickerNavigationController * peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    // Display only a person's phone and address
    NSArray * displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonAddressProperty],
                                [NSNumber numberWithInt:kABPersonPhoneProperty],
                                nil];
    
    peoplePicker.displayedProperties = displayedItems;
    
    [self.view addSubview:peoplePicker.view];
    [self addChildViewController:peoplePicker];
    [peoplePicker didMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    contact = [[NSMutableDictionary alloc]
               initWithObjects:@[@"", @"", @""]
               forKeys:@[@"firstName", @"lastName", @"mobileNumber"]];
    
    CFTypeRef generalCFObject;
    generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (generalCFObject) {
        [contact setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contact setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    //generalCFObject = ABRecordCopyValue(person, kABPersonPhoneProperty);
    //if (property == kABPersonPhoneProperty) {
        //if (generalCFObject) {
        ABMultiValueRef mul;
        mul=(__bridge ABMultiValueRef)((__bridge NSString *) ABRecordCopyValue(person, kABPersonPhoneProperty));
        //int count= ABMultiValueGetCount(mul);
        NSString *name=(__bridge NSString *) ABMultiValueCopyValueAtIndex(mul,0);
        [contact setObject:name forKey:@"mobileNumber"];
        CFRelease(generalCFObject);
        //}
    //}
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;

    //return YES;
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
//    contact = [[NSMutableDictionary alloc]
//     initWithObjects:@[@"", @"", @""]
//     forKeys:@[@"firstName", @"lastName", @"mobileNumber"]];
//    
//    CFTypeRef generalCFObject;
//    generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
//    if (generalCFObject) {
//        [contact setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
//        CFRelease(generalCFObject);
//    }
//    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
//    if (generalCFObject) {
//        [contact setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
//        CFRelease(generalCFObject);
//    }
//    //generalCFObject = ABRecordCopyValue(person, kABPersonPhoneProperty);
//    if (property == kABPersonPhoneProperty) {
//        //if (generalCFObject) {
//            ABMultiValueRef mul;
//            mul=(__bridge ABMultiValueRef)((__bridge NSString *) ABRecordCopyValue(person, kABPersonPhoneProperty));
//            //int count= ABMultiValueGetCount(mul);
//            NSString *name=(__bridge NSString *) ABMultiValueCopyValueAtIndex(mul,0);
//            [contact setObject:name forKey:@"mobileNumber"];
//            CFRelease(generalCFObject);
//        //}
//    }
//    
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
