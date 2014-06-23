#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MapPin.h"
#import "Event.h"
#import "DBManager.h"
#import "TCPManager.h"
/**
 ViewController obsługujący tworzenie nowego wydarzenia lub edytowanie istniejącego
 Protokół MFMessageComposeViewControllerDelegate służy do obsługi wysyłania SMSów z zaproszeniem
 */
@interface createEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate>
//pole tekstowe z adresem wydarzenia
@property (weak, nonatomic) IBOutlet UITextField *coordinatesField;
//obiekt reprezentujący wydarzenie
@property (strong, nonatomic) Event *event;
//słownik z kontaktami i tablica z nazwami kontaktów
@property (strong, nonatomic) NSMutableDictionary *contacts;
@property (strong, nonatomic) NSMutableArray *contactsNames;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
//pole do wyboru daty i godziny
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)dateChanged:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)sendButtonClicked:(id)sender;

-(id) initWithEventName:(NSString*) eventName;

@end
