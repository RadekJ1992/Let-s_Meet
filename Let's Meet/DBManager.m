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
                NSLog(@"Failed to execute pragma query");
            }
            
            char *errMsg1;
            const char *sql_stmt_events =
            "create table if not exists eventsTable (eventName text primary key, eventLocationLatitude real, eventLocationLongitude real, eventDate text)";
            if (sqlite3_exec(database, sql_stmt_events, NULL, NULL, &errMsg1)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create events table");
            }
            char *errMsg2;
            const char *sql_stmt_guests =
            "create table if not exists guestsTable (guestName text primary key, guestPhone text, guestLocationLatitude real, guestLocationLongitude real)";
            if (sqlite3_exec(database, sql_stmt_guests, NULL, NULL, &errMsg2)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create guests table");
            }
            char *errMsg3;
            const char *sql_stmt_event_guest =
            "create table if not exists eventGuestTable (id integer primary key autoincrement, eventName text, guestName text, foreign key (eventName) references eventsTable(eventName), foreign key (guestName) references guestsTable(guestName)";
            if (sqlite3_exec(database, sql_stmt_event_guest, NULL, NULL, &errMsg3)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create guest-event table");
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
        NSString *insertSQL = [NSString stringWithFormat:@"insert into guestsTable values (\"%@\",\"%@\",0,0)", guestName, guestPhone];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}

-(BOOL)addEvent:(NSString*)eventName onDate:(NSDate*)date
     inLocation:(MapPin*)pin withGuests:(NSMutableDictionary*)contacts {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into eventsTable values (\"%@\",\"%f\",\"%f\",\"%@\")", eventName, pin.coordinate.latitude, pin.coordinate.longitude, [date description]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            for (NSString *key in contacts.allKeys) {
                const char *dbpath = [databasePath UTF8String];
                if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                {
                    NSString *insertEventGuestSQL = [NSString stringWithFormat:@"insert into eventGuestTable (eventName, guestName) values (\"%@\", \"%@\")",eventName, key];
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
            return YES;
        }
        else {
            NSLog(@"Failed to create event");
            return NO;
        }
        sqlite3_reset(statement);
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
    }
    return nil;
}

-(NSMutableDictionary*) getEventGuestsForEventName:(NSString*) eventName {
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
                    return resultDictionary;
                    sqlite3_reset(statement);
                }
            }
        }
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
                return pin;
            }
            else{
                NSLog(@"Event not found");
                return nil;
            }
            sqlite3_reset(statement);
        }
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
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
                NSDate* date = [dateFormatter dateFromString:dateString];
                return date;
            }
            else{
                NSLog(@"Event not found");
                return nil;
            }
            sqlite3_reset(statement);
        }
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
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            return NO;
            NSLog(@"Failed to delete event");
        }
        else return YES;
    }
    return NO;
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
    }
    return NO;
}

@end
