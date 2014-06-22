#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "Event.h"
#import "DBManager.h"

@interface contactsSelectViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate> {
}
@property (strong, nonatomic) Event* event;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@end
