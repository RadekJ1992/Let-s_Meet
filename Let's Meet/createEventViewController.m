//
//  createEventViewController.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "createEventViewController.h"
#import "contactsSelectViewController.h"

@interface createEventViewController ()

@end

@implementation createEventViewController

@synthesize pin;
@synthesize contacts;
@synthesize contactsNames;
@synthesize contactsTable;
@synthesize datePicker;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contacts"]) {
        if (contacts) {
            contactsSelectViewController *cEVC = [segue destinationViewController];
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
    self.contactsTable.dataSource = self;
    if (pin) {
        NSString *text = [NSString stringWithFormat:@"%f,%f", pin.coordinate.latitude, pin.coordinate.longitude];
        [self coordinatesField].text = text;
    }
    CGAffineTransform rotate = CGAffineTransformMakeRotation(0/*-1.57*/);
    rotate = CGAffineTransformScale(rotate, /*.46, 2.25*/ 0.85, .85);
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(/*3, 22.5*/0,0);
    datePicker.transform = CGAffineTransformConcat(rotate,t0);
    [self.view addSubview:datePicker];

    if (contacts) {
        for (id key in self.contacts) {
            if (!contactsNames) contactsNames = [[NSMutableArray alloc] init];
            [contactsNames addObject:key];
        }
    }
        // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.contacts allKeys] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *unifiedID = @"aCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unifiedID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:unifiedID];
        
    }
    
    cell.textLabel.text = [self.contactsNames objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text  = [self.contacts objectForKey:[self.contactsNames objectAtIndex:[indexPath row]]];
    return cell;
    
}

- (IBAction)dateChanged:(id)sender {
    NSDate* sourceDate = [datePicker date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    NSLog(@"%@",[destinationDate description]);
}

- (IBAction)doneButtonClicked:(id)sender {
    
    
}
@end
