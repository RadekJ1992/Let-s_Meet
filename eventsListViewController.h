//
//  eventsListViewController.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 27.04.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

@interface eventsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *eventTable;
@property (strong, nonatomic) NSMutableArray *eventNames;
@property (strong, nonatomic) Event* event;

@end
