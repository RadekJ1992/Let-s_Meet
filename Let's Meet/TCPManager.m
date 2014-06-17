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
                        
                        if (nil != output) {
                            NSLog(@"%@", output);
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

- (BOOL)sendPacketWithMessage: (NSString*) msg {
	NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    return YES;
}


@end
