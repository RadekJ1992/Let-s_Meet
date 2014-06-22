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
