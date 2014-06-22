#import "Event.h"


@implementation Event

@synthesize pin;
@synthesize contacts;
@synthesize eventName;
@synthesize eventDate;
@synthesize eventID;

-(id) init {
    self = [super init];
    if (self) {
        pin = [[MapPin alloc]init];
        contacts = [[NSMutableDictionary alloc] init];
        eventName = [[NSString alloc] init];
        eventDate = [[NSDate alloc] init];
        eventID = [[NSNumber alloc] initWithInt:1];
    }
    return self;
}

@end
