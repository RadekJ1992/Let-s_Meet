#import <UIKit/UIKit.h>
#import "DBManager.h"
/**
 ViewController pokazujący listę dostępnych wydarzeń. Implementuje protokoły UITableViewDelegate i UITableViewDataSource w celu obsługi tabeli wydarzeń
 */
@interface eventsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
/**
 tabela z wydarzeniami
 */
@property (weak, nonatomic) IBOutlet UITableView *eventTable;
/**
 tablica z nazwami wydarzeń pobrana z bazy danych
 */
@property (strong, nonatomic) NSMutableArray *eventNames;
/**
 wybrane wydarzenie
 */
@property (strong, nonatomic) Event* event;

@end
