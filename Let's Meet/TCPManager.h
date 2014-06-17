//
//  TCPManager.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 17.06.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "Event.h"

@interface TCPManager : NSObject <NSStreamDelegate> 

+(TCPManager*)getSharedInstance;

- (void)startNetworkCommunication;
- (void)sendPacketWithMessage: (NSString*) msg;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;

-(void) sendHello;
-(void) sendLocationWithLatitude: (double) latitude andLongitude:(double) longitude;
-(void) registerEvent:(Event*) event;
-(void) registerToEventwithEventName:(NSNumber*) eventID;

@end
