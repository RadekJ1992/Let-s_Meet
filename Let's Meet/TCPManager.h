//
//  TCPManager.h
//  Let's Meet
//
//  Created by Radosław Jarzynka on 17.06.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPManager : NSObject <NSStreamDelegate> 

+(TCPManager*)getSharedInstance;

- (void)startNetworkCommunication;
- (BOOL)sendPacketWithMessage: (NSString*) msg;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;


@end
