//
//  Event.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 08.05.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapPin.h"

@interface Event : NSObject

@property(strong, nonatomic) MapPin* pin;
@property(strong, nonatomic) NSMutableDictionary* contacts;
@property(strong, nonatomic) NSString* eventName;
@property(strong, nonatomic) NSDate* eventDate;

@end
