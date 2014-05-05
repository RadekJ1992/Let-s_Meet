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
    rotate = CGAffineTransformScale(rotate, /*.46, 2.25*/ 1, .85);
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(/*3, 22.5*/0,0);
    datePicker.transform = CGAffineTransformConcat(rotate,t0);
    [self.view addSubview:datePicker];

    if (contacts) {
        
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
    
    for (id key in self.contacts) {
        NSLog(@"key: %@, value: %@", key, [self.contacts objectForKey:key]);
        cell.textLabel.text  = key;
        cell.detailTextLabel.text  = [self.contacts objectForKey:key];
    }
    
    //NSString *nameString = [self.contacts objectForKey:@"name"];
    //NSString *phoneString = [self.contacts objectForKey:@"phone"];
    //cell.textLabel.text  = nameString;
   // cell.detailTextLabel.text  = phoneString;
    
    
    return cell;
    
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

- (IBAction)dateChanged:(id)sender {
}
@end
