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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contact"]) {
        if (contacts) {
            createEventViewController *cEVC = [segue destinationViewController];
            cEVC.contacts = contacts;
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
    if (!contacts) {
        contacts = [[NSMutableDictionary alloc]init];
        
    }
    ABPeoplePickerNavigationController * peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    // Display only a person's phone and address
    NSArray * displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonAddressProperty],
                                [NSNumber numberWithInt:kABPersonPhoneProperty],
                                nil];
    
    peoplePicker.displayedProperties = displayedItems;
    /*
    peoplePicker.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
    */
    [self.view addSubview:peoplePicker.view];
    [self addChildViewController:peoplePicker];
    [peoplePicker didMoveToParentViewController:self];
    //[self presentModalViewController:peoplePicker animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
    
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString *name=[NSString stringWithFormat:@"%@|%@",firstName,lastName];
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef mul;
        mul=(__bridge ABMultiValueRef)((__bridge NSString *) ABRecordCopyValue(person, kABPersonPhoneProperty));
        NSString *phone=(__bridge NSString *) ABMultiValueCopyValueAtIndex(mul,0);
        [contacts setObject:phone forKey:name];
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    //UIViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"createEventViewController"];
    //[self.navigationController pushViewController: myController animated:YES];
    [self performSegueWithIdentifier: @"contact" sender: nil];
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}
/*
-(IBAction)addPerson:(id)sender{
    ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
  //  view.newPersonViewDelegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:view];
   [self.peoplePicker presentModalViewController:nc animated:YES];
}*/

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
