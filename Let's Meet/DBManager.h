//
//  DBManager.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 06.05.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

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
-(NSMutableDictionary*) getEventGuestsForEventName:(NSString*) eventName;
-(MapPin*)getEventLocationForEventName: (NSString*) eventName;
-(NSDate*)getEventDateForEventName: (NSString*) eventName;
-(Event*)getEventForEventName:(NSString*) eventName;

-(BOOL) deleteEventForEventName:(NSString*) eventName;
-(BOOL) deleteGuestForGuestName:(NSString*) guestName;
-(BOOL) deleteConnectionForGuest:(NSString*) guestName andEventName:(NSString*) eventName;

-(void) forceCloseDatabase;

@end
