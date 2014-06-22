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
    self.eventTable.dataSource = self;
    self.eventTable.delegate = self;
    self.eventTable.allowsMultipleSelectionDuringEditing = NO;
    eventNames = [[DBManager getSharedInstance] getAllEventsNames];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [eventNames count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *unifiedID = @"aCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unifiedID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:unifiedID];
        
    }
    
    cell.textLabel.text = [eventNames objectAtIndex:[indexPath row]];
    return cell;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    UITableViewCell* cell = (UITableViewCell *)[[self eventTable] cellForRowAtIndexPath:indexPath];
    NSString* eventName = cell.textLabel.text;
    event = [[DBManager getSharedInstance] getEventForEventName:eventName];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"eventToShow" sender: nil];   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

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
    // Dispose of any resources that can be recreated.
}

@end
