#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MapPin.h"
#import "Event.h"

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;

-(BOOL)createDB;
-(BOOL)addEvent:(NSString*)eventName onDate:(NSDate*)date inLocation:(MapPin*)pin withGuests:(NSMutableDictionary*)contacts;
-(BOOL)addGuestWithName:(NSString*) guestName andPhone:(NSString*) guestPhone;
-(NSMutableArray*) getAllEventsNames;
-(NSMutableArray*) getAllGuestNames;
-(NSMutableArray*) getAllGuestPhones;
-(NSMutableDictionary*) getEventGuestsWithPhoneNumbersForEventName:(NSString*) eventName;
-(NSMutableDictionary*) getEventGuestsWithLocationsForEventName:(NSString*) eventName;
-(MapPin*)getEventLocationForEventName: (NSString*) eventName;
-(NSDate*)getEventDateForEventName: (NSString*) eventName;
-(Event*)getEventForEventName:(NSString*) eventName;
-(NSString*)getEventNameForEventID:(NSNumber*) eventID;
-(NSNumber*)getEventIDforEventName:(NSString*) eventName;
-(NSString*)getGuestNameforGuestPhoneNumber:(NSString*) guestPhone;
-(BOOL) insertUserLocation:(CLLocationCoordinate2D) coordinates;

-(BOOL) updateEventID: (NSNumber*) eventID forEventName:(NSString*) eventName;
-(BOOL) updateEventDetailsForEventID:(NSNumber*) eventID withEventName: (NSString*) eventName onDate:(NSDate*) date inLocation:(MapPin*)pin;
-(BOOL) addGuestToEventWithEventID:(NSNumber*) eventID withPhoneNumber:(NSString*) phoneNumber;
-(BOOL) updateGuestPositionForGuestWithPhoneNumber:(NSString*) phoneNumber withCoordinates:(CLLocationCoordinate2D) coordinates;

-(BOOL) deleteEventForEventName:(NSString*) eventName;
-(BOOL) deleteGuestForGuestName:(NSString*) guestName;
-(BOOL) deleteConnectionForGuest:(NSString*) guestName andEventName:(NSString*) eventName;

-(void) forceCloseDatabase;

@end
