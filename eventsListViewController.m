#import "eventsListViewController.h"
#import "meetAppAppDelegate.h"
#import "createEventViewController.h"
#import "showEventViewController.h"

@interface eventsListViewController ()

@end

@implementation eventsListViewController

@synthesize eventTable;
@synthesize eventNames;
@synthesize event;
/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"eventToShow"]) {
        if (event) {
            showEventViewController *sEVC = [segue destinationViewController];
            sEVC.event = event;
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
    //załaduj dane z bazy
    self.eventTable.dataSource = self;
    self.eventTable.delegate = self;
    self.eventTable.allowsMultipleSelectionDuringEditing = NO;
    eventNames = [[DBManager getSharedInstance] getAllEventsNames];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [eventNames count];
}

//utworzenie komórki w tabeli
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *unifiedID = @"aCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unifiedID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:unifiedID];
        
    }
    
    cell.textLabel.text = [eventNames objectAtIndex:[indexPath row]];
    return cell;
    
}
//zaznaczenie komórki w tabelu i wywołanie jej viewControllera
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    UITableViewCell* cell = (UITableViewCell *)[[self eventTable] cellForRowAtIndexPath:indexPath];
    NSString* eventName = cell.textLabel.text;
    event = [[DBManager getSharedInstance] getEventForEventName:eventName];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"eventToShow" sender: nil];   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
//usunięcie eventu z bazy danych przez przesunięcie jego komórki w tabeli w lewo i zaznaczenie "usuń"
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell* cell = (UITableViewCell *)[[self eventTable] cellForRowAtIndexPath:indexPath];
        NSString* eventName = cell.textLabel.text;
        [[DBManager getSharedInstance] deleteEventForEventName:eventName];
        dispatch_async(dispatch_get_main_queue(), ^{
            eventNames = [[DBManager getSharedInstance] getAllEventsNames];
            [eventTable reloadData];
        });
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
