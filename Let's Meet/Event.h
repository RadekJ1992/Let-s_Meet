#import <Foundation/Foundation.h>
#import "MapPin.h"
/**
 obiekt reprezentujący wydarzenie
 */
@interface Event : NSObject

@property(strong, nonatomic) MapPin* pin;
@property(strong, nonatomic) NSMutableDictionary* contacts;
@property(strong, nonatomic) NSString* eventName;
@property(strong, nonatomic) NSDate* eventDate;
@property(strong, nonatomic) NSNumber* eventID;

@end

