#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "Event.h"
#import "DBManager.h"
/**
 ViewController obsługujący wybór kontaktów z listy
 */
@interface contactsSelectViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate> {
}
@property (strong, nonatomic) Event* event;
@property (strong, nonatomic) NSMutableDictionary *contacts;
@end
