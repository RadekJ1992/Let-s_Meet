#import <UIKit/UIKit.h>
#import "DBManager.h"

@interface eventsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *eventTable;
@property (strong, nonatomic) NSMutableArray *eventNames;
@property (strong, nonatomic) Event* event;

@end
