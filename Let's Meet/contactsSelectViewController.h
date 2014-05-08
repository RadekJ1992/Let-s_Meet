//
//  contactsSelectViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "Event.h"
#import "DBManager.h"

@interface contactsSelectViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate> {
}
@property (strong, nonatomic) Event* event;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@end
