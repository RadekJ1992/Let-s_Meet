//
//  TCPManager.m
//  Let's Meet
//
//  Created by Radosław Jarzynka on 17.06.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "TCPManager.h"

@implementation TCPManager

static TCPManager *sharedInstance = nil;
static NSInputStream *inputStream;
static NSOutputStream *outputStream;
static bool isConnected;
static NSMutableArray *receivedMessages;
static NSString *phoneNumber;

+(TCPManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:NULL];
        [sharedInstance startNetworkCommunication];
    }
    return sharedInstance;
}

-(void)startNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    phoneNumber = [standardUserDefaults valueForKey:@"phoneNumber"];
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) ip, [port intValue], &readStream, &writeStream);
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:sharedInstance];
    [outputStream setDelegate:sharedInstance];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    isConnected = true;
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
            
        case NSStreamEventNone:
            NSLog(@"Stream None Event");
            break;
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
			if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = (int) [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        //wygram konkurs na najbardziej nieczytelny kod!
                        
                        if (nil != output) {
                            NSLog(@"%@", output);
                            NSArray* splitArray = [[NSArray alloc] init];
                            splitArray = [output componentsSeparatedByString:@"|"];
                            if ([splitArray[0] isEqual: @"EVENT_OK"]) {
                                if ([splitArray count] == 3) {
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    NSNumber* eventID = [f numberFromString:splitArray[2]];
                                    [[DBManager getSharedInstance] updateEventID:eventID forEventName:splitArray[1]];
                                }
                            }
                            if ([splitArray[0] isEqual:@"REG_OK"]) {
                                if ([splitArray count] == 6) {
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    NSNumber* eventID = [f numberFromString:splitArray[1]];
                                    MapPin* pin = [[MapPin alloc] init];
                                    [pin setCoordinate:CLLocationCoordinate2DMake([splitArray[3] doubleValue], [splitArray[4] doubleValue])];
                                    [[DBManager getSharedInstance] updateEventDetailsForEventID:eventID
                                                                                  withEventName:splitArray[2]
                                                                                         onDate:splitArray[5]
                                                                                     inLocation:pin];
                                }
                                
                            }
                            if ([splitArray[0] isEqual:@"USR_LOC"]) {
                                if ([splitArray count] == 4) {
                                    if (![[[DBManager getSharedInstance] getAllGuestPhones] containsObject:splitArray[1]]) {
                                        [[DBManager getSharedInstance] addGuestWithName:splitArray[1] andPhone:splitArray[1]];
                                    }
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    NSNumber* eventID = [f numberFromString:splitArray[2]];
                                    if (![[[[DBManager getSharedInstance] getEventGuestsWithPhoneNumbersForEventName:
                                            [[DBManager getSharedInstance] getEventNameForEventID:eventID]]
                                           allValues] containsObject:splitArray[1]]) {
                                        [[DBManager getSharedInstance] addGuestToEventWithEventID:eventID
                                                                                  withPhoneNumber:splitArray[1]];
                                    }
                                    [[DBManager getSharedInstance] updateGuestPositionForGuestWithPhoneNumber:splitArray[1]
                                                                                              withCoordinates:CLLocationCoordinate2DMake([splitArray[3] doubleValue], [splitArray[4] doubleValue] )];
                                }
                            }
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream Has Space Available Event");
            break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"Stream End Encountered Event");
			break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)sendPacketWithMessage: (NSString*) msg {
	NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

-(void) sendHello {
    [sharedInstance sendPacketWithMessage: [NSString stringWithFormat: @"HELLO|%@\n",
                                            phoneNumber]];
}

-(void) sendLocationWithLatitude: (double) latitude andLongitude:(double) longitude {
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"LOC|%@|%f|%f",
                                           phoneNumber,
                                           latitude,
                                           longitude]];
}

-(void) registerEvent:(Event*) event{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[event eventDate]];
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"EVENT|%@|%@|%f|%f|%@",
                                           phoneNumber,
                                           [event eventName],
                                           (double)[[event pin] coordinate].latitude,
                                           (double)[[event pin] coordinate].longitude,
                                           dateString]];
}

-(void) registerToEventwithEventName:(NSNumber*) eventID{
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"REG|%@|%d",
                                           phoneNumber,
                                           [eventID intValue]]];
}


@end
