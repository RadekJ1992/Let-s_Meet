//
//  eventsListViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "eventsListViewController.h"
#import "meetAppAppDelegate.h"
#import "createEventViewController.h"

@interface eventsListViewController ()

@end

@implementation eventsListViewController

@synthesize eventTable;
@synthesize eventNames;
@synthesize event;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedEvent"]) {
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
    self.eventTable.dataSource = self;
    self.eventTable.delegate = self;
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
    [self performSegueWithIdentifier: @"selectedEvent" sender: nil];   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
