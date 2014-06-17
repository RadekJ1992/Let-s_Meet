//
//  DBManager.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 06.05.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"letsMeet.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg0;
            const char *sql_pragma_stmt = "PRAGMA foreign_keys=ON";
            if (sqlite3_exec(database, sql_pragma_stmt, NULL, NULL, &errMsg0)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to execute pragma query, %s", errMsg0);
            }
            
            char *errMsg1;
            const char *sql_stmt_events =
            "create table if not exists eventsTable (eventName text primary key, eventLocationLatitude real, eventLocationLongitude real, eventDate text, eventID integer)";
            if (sqlite3_exec(database, sql_stmt_events, NULL, NULL, &errMsg1)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create events table, %s", errMsg1);
            }
            char *errMsg2;
            const char *sql_stmt_guests =
            "create table if not exists guestsTable (guestName text primary key, guestPhone text, guestLocationLatitude real, guestLocationLongitude real)";
            if (sqlite3_exec(database, sql_stmt_guests, NULL, NULL, &errMsg2)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create guests table, %s", errMsg2);
            }
            char *errMsg3;
            const char *sql_stmt_event_guest =
            "create table if not exists eventGuestTable (id integer primary key autoincrement, eventName text, guestName text, foreign key (eventName) references eventsTable(eventName) on update cascade , foreign key (guestName) references guestsTable(guestName) on update cascade)";
            if (sqlite3_exec(database, sql_stmt_event_guest, NULL, NULL, &errMsg3)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create guest-event table, %s", errMsg3);
            }
            char *errMsg4;
            const char *sql_stmt_usrloc =
            "create table if not exists userLocationsTable (id integer primary key autoincrement, userLocationLatitude real, userLocationLongitude real, updateDate text";
            if (sqlite3_exec(database, sql_stmt_usrloc, NULL, NULL, &errMsg4)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create events table, %s", errMsg4);
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(BOOL)addGuestWithName:(NSString*) guestName andPhone:(NSString*) guestPhone {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert or replace into guestsTable values (\"%@\",\"%@\",52.2296756,21.0122287)", guestName, guestPhone];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        
        sqlite3_close(database);

    }
    return NO;
}

-(BOOL)addEvent:(NSString*)eventName onDate:(NSDate*)date
     inLocation:(MapPin*)pin withGuests:(NSMutableDictionary*)contacts {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *dateString = [dateFormat stringFromDate:date];
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into eventsTable values (\"%@\",\"%f\",\"%f\",\"%@\", 0)", eventName, pin.coordinate.latitude, pin.coordinate.longitude, dateString];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i == SQLITE_DONE)
        {
            sqlite3_reset(statement);
            for (NSString *key in contacts.allKeys) {
                const char *dbpath = [databasePath UTF8String];
                int i = sqlite3_open(dbpath, &database);
                if ( i == SQLITE_OK)
                {
                    NSString *insertEventGuestSQL = [NSString stringWithFormat:@"insert or replace into eventGuestTable (eventName, guestName) values (\"%@\", \"%@\")",eventName, key];
                    const char *insert_stmt = [insertEventGuestSQL UTF8String];
                    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
                    if (sqlite3_step(statement) != SQLITE_DONE)
                    {
                        NSLog(@"Failed to connect guest %@ with event %@", key, eventName);
                        return NO;
                    }
                    sqlite3_reset(statement);
                }
            }
            sqlite3_reset(statement);
            return YES;
        }
        else {
            NSLog(@"Failed to create event");
            return NO;
        }
        sqlite3_reset(statement);
    
        sqlite3_close(database);

    }
    return NO;
}

-(NSMutableArray*) getAllEventsNames {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select eventName from eventsTable"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
            }
            return resultArray;
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);

    }
    return nil;
}

-(NSMutableArray*) getAllGuestNames {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select guestName from guestsTable"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
            }
            return resultArray;
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);
        
    }
    return nil;
}

-(NSMutableArray*) getAllGuestPhones {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select guestPhone from guestsTable"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
            }
            return resultArray;
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);
        
    }
    return nil;
}

-(NSMutableDictionary*) getEventGuestsWithPhoneNumbersForEventName:(NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select guestName from eventGuestTable where eventName = \"%@\"", eventName];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *guestNameArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [guestNameArray addObject:name];
            }
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
            
            NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
            
            for (NSString* name in guestNameArray) {
                NSString *guestQuerySQL = [NSString stringWithFormat: @"select guestPhone from guestsTable where guestName = \"%@\"", name];
                const char *guest_query_stmt = [guestQuerySQL UTF8String];
                if (sqlite3_prepare_v2(database,guest_query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        NSString *phone = [[NSString alloc] initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                        [resultDictionary setObject:phone forKey:name];
                    }
                    //sqlite3_finalize(statement);
                    sqlite3_reset(statement);
                }
            }
            sqlite3_close(database);
            return resultDictionary;
        }
        
        
        sqlite3_close(database);

    }
    return nil;
}

-(NSMutableDictionary*) getEventGuestsWithLocationsForEventName:(NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select guestName from eventGuestTable where eventName = \"%@\"", eventName];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *guestNameArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [guestNameArray addObject:name];
            }
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
            
            NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
            
            for (NSString* name in guestNameArray) {
                NSNumber *latitude;
                NSNumber *longitude;
                NSString *guestlatQuerySQL = [NSString stringWithFormat: @"select guestLocationLatitude from guestsTable where guestName = \"%@\"", name];
                const char *guest_lat_query_stmt = [guestlatQuerySQL UTF8String];
                if (sqlite3_prepare_v2(database,guest_lat_query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        latitude = [NSNumber numberWithFloat:(float) sqlite3_column_double(statement, 0)];
                    }
                    sqlite3_reset(statement);
                }
                NSString *guestlngQuerySQL = [NSString stringWithFormat: @"select guestLocationLongitude from guestsTable where guestName = \"%@\"", name];
                const char *guest_lng_query_stmt = [guestlngQuerySQL UTF8String];
                if (sqlite3_prepare_v2(database,guest_lng_query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                    {
                        longitude = [NSNumber numberWithFloat:(float) sqlite3_column_double(statement, 0)];
                    }
                    sqlite3_reset(statement);
                }
                [resultDictionary setObject: [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude: [longitude doubleValue]] forKey:name];
            }
            sqlite3_close(database);
            return resultDictionary;
        }
        
        
        sqlite3_close(database);
        
    }
    return nil;
}

-(MapPin*)getEventLocationForEventName: (NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select eventLocationLatitude, eventLocationLongitude from eventsTable where eventName=\"%@\"",eventName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumber *lat = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 0)];
                NSNumber *lng = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 1)];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
                MapPin* pin = [[MapPin alloc] init];
                pin.coordinate = coord;
                sqlite3_reset(statement);
                sqlite3_close(database);
                return pin;
            }
            else{
                NSLog(@"Event not found");
                return nil;
            }
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
        }
    
        sqlite3_close(database);
    
    }
    return nil;
}

-(NSDate*) getEventDateForEventName: (NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select eventDate from eventsTable where eventName=\"%@\"",eventName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *dateString = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate* date = [dateFormatter dateFromString:dateString];
                sqlite3_reset(statement);
                sqlite3_close(database);
                return date;
            }
            else{
                NSLog(@"Event not found");
                return nil;
            }
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
        }
    
        sqlite3_close(database);

    }
    return nil;
}

-(BOOL) deleteEventForEventName:(NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        NSString *querySQL = [NSString stringWithFormat:@"delete from eventsTable where eventName=\"%@\"",eventName];
        const char *sql_stmt = [querySQL UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)!= SQLITE_OK)
        {
            NSLog(@"Failed to delete event, %s", errMsg);
            return NO;
        }
        else return YES;
    
        sqlite3_close(database);

    }
    return NO;
}

-(Event*) getEventForEventName:(NSString *)eventName {
    Event* result = [[Event alloc] init];
    result.eventName = eventName;
    result.pin = [self getEventLocationForEventName:eventName];
    result.eventDate = [self getEventDateForEventName:eventName];
    result.contacts = [self getEventGuestsWithPhoneNumbersForEventName:eventName];
    return result;
}

-(NSString*)getEventNameForEventID:(NSNumber*) eventID {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select eventName from eventsTable where eventID=\"%d\"",[eventID intValue]];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *eventName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                sqlite3_reset(statement);
                sqlite3_close(database);
                return eventName;
            }
            else{
                NSLog(@"Event not found");
                return nil;
            }
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);
        
    }
    return nil;

}

-(BOOL) deleteGuestForGuestName:(NSString*) guestName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        NSString *querySQL = [NSString stringWithFormat:@"delete from guestsTable where guestName=\"%@\"",guestName];
        const char *sql_stmt = [querySQL UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            return NO;
            NSLog(@"Failed to delete guest");
        }
        else return YES;
    
        sqlite3_close(database);

    }
    return NO;
}

-(BOOL) deleteConnectionForGuest:(NSString*) guestName andEventName:(NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        NSString *querySQL = [NSString stringWithFormat:@"delete from eventGuestTable where guestName=\"%@\" and eventName=\"%@\"",guestName, eventName];
        const char *sql_stmt = [querySQL UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            return NO;
            NSLog(@"Failed to delete guest and event connection");
        }
        else return YES;
    
        sqlite3_close(database);

    }
    return NO;
}

-(BOOL) insertUserLocation:(CLLocationCoordinate2D)coordinates {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into userLocationsTable values (%f,%f,\"%@\"", coordinates.latitude, coordinates.longitude, dateString];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        
        sqlite3_close(database);
        
    }
    return NO;

}

-(BOOL) updateEventID:(NSNumber*) eventID forEventName:(NSString*) eventName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"update eventsTable set eventID = %d where eventName like ('%@')", [eventID intValue], eventName];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return NO;
}

-(BOOL) updateEventDetailsForEventID:(NSNumber*) eventID withEventName: (NSString*) eventName onDate:(NSDate*) date inLocation:(MapPin*)pin {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:date];
        NSString *insertSQL = [NSString stringWithFormat:@"update eventsTable set eventName = '%@', eventLocationLatitude = %f, eventLocationLongitude = %f, eventDate = %@ where eventID = %d",
                               eventName,
                               (double)[pin coordinate].latitude,
                               (double)[pin coordinate].longitude,
                               dateString,
                               [eventID intValue] ];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return NO;
}

-(BOOL) addGuestToEventWithEventID:(NSNumber*) eventID withPhoneNumber:(NSString*) phoneNumber {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"instert into eventGuestsTable (eventName, guestName) values (select eventName from eventsTable where eventID = %d, select guestName from guestsTable where guestPhone like ('%@'))",
                               [eventID intValue],
                               phoneNumber];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return NO;
}

-(BOOL) updateGuestPositionForGuestWithPhoneNumber:(NSString*) phoneNumber withCoordinates:(CLLocationCoordinate2D) coordinates {
    
    if (![[sharedInstance getAllGuestPhones] containsObject:phoneNumber]) {
        sqlite3_reset(statement);
        sqlite3_close(database);
        [sharedInstance addGuestWithName:phoneNumber andPhone:phoneNumber];
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"update guestsTable set guestLocationLatitude = %f, guestLocationLongitude =%f where guestPhone like ('%@')",
                               coordinates.latitude,
                               coordinates.longitude,
                               phoneNumber];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return NO;
}


-(void) forceCloseDatabase {
    sqlite3_close(database);
};

@end
