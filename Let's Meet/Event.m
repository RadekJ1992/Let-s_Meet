//
//  Event.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 08.05.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize pin;
@synthesize contacts;
@synthesize eventName;
@synthesize eventDate;

-(id) init {
    self = [super init];
    if (self) {
        pin = [[MapPin alloc]init];
        contacts = [[NSMutableDictionary alloc] init];
        eventName = [[NSString alloc] init];
        eventDate = [[NSDate alloc] init];
    }
    return self;
}

@end
