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
    //wczytanie ustawień z SettingsBundle
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    phoneNumber = [standardUserDefaults valueForKey:@"phoneNumber"];
    
    //utworzenie Socketa
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) ip, [port intValue], &readStream, &writeStream);
    
    //konwersja CFStreamów do NSStreamów używanych w obj-C
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:sharedInstance];
    [outputStream setDelegate:sharedInstance];
    
    //uruchomienie pętli obsługujacych strumienie
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    [sharedInstance sendHello];
    
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
            
        //zdarzenie informujące o przyjściu danych
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
                            
                            // podzielenie tekstu który przyszedł na tablicę NSStringów względem znaku '|'
                            NSArray* splitArray = [output componentsSeparatedByString:@"|"];
                            
                            //gdy odsyłane jest potwierdzenie pomyślnego utworzenia nowego wydarzenia na serwerze razem z przypisanym mu ID
                            if ([splitArray[0] isEqual: @"EVENT_OK"]) {
                                if ([splitArray count] == 3) {
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    //stringByReplacingOccurrencesOfString:@"\n" withString:@""
                                    //metoda używana bo obj-C nie lubi znaków nowej linii przy konwersji z NSString na coś innego
                                    NSNumber* eventID = [f numberFromString:[splitArray[2] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                                    NSString* eventName = [splitArray[1] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                    [[DBManager getSharedInstance] updateEventID:eventID forEventName:eventName];
                                }
                            }
                            
                            //gdy pomyślnie zarejestrowano użytkownika do wydarzenia; odsyłane są szczegóły dotyczące wydarzenia
                            if ([splitArray[0] isEqual:@"REG_OK"]) {
                                if ([splitArray count] == 6) {
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    NSNumber* eventID = [f numberFromString:splitArray[1]];
                                    //konwersja daty wydarzenia z NSString na NSDate
                                    NSString* eventDateString = [splitArray[5] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    NSDate* eventDate = [dateFormat dateFromString:eventDateString];
                                    //przypisanie lokalizacji
                                    MapPin* pin = [[MapPin alloc] init];
                                    [pin setCoordinate:CLLocationCoordinate2DMake([splitArray[3] doubleValue], [splitArray[4] doubleValue])];
                                    //wrzucenie do bazy danych
                                    [[DBManager getSharedInstance] updateEventDetailsForEventID:eventID
                                                                                  withEventName:splitArray[2]
                                                                                         onDate:eventDate
                                                                                     inLocation:pin];
                                }
                                
                            }
                            //gdy wysłana zostanie lokalizacja innego użytkownika
                            if ([splitArray[0] isEqual:@"USR_LOC"]) {
                                if ([splitArray count] == 5) {
                                    
                                    //jeśli nie ma takiego numeru w tabeli gości - dodaj go
                                    if (![[[DBManager getSharedInstance] getAllGuestPhones] containsObject:splitArray[1]]) {
                                        [[DBManager getSharedInstance] addGuestWithName:splitArray[1] andPhone:splitArray[1]];
                                    }
                                    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                    NSNumber* eventID = [f numberFromString:splitArray[2]];
                                    
                                    //gdy ten numer telefonu nie jest przypięty do tego wydarzenia - przypnij go
                                    if (![[[[DBManager getSharedInstance] getEventGuestsWithPhoneNumbersForEventName:
                                            [[DBManager getSharedInstance] getEventNameForEventID:eventID]]
                                           allValues] containsObject:splitArray[1]]) {
                                        [[DBManager getSharedInstance] addGuestToEventWithEventID:eventID
                                                                                  withPhoneNumber:splitArray[1]];
                                    }
                                    //zaktualizuj informację w bazie
                                    [[DBManager getSharedInstance] updateGuestPositionForGuestWithPhoneNumber:splitArray[1]
                                                                                              withCoordinates:CLLocationCoordinate2DMake([splitArray[3] doubleValue], [[splitArray[4] stringByReplacingOccurrencesOfString:@"\n" withString:@""]doubleValue] )];
                                    //wyślij potwierdzenie na serwer
                                    [sharedInstance sendPacketWithMessage:@"USR_LOC_OK\n"];
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
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"LOC|%@|%f|%f\n",
                                           phoneNumber,
                                           latitude,
                                           longitude]];
}

-(void) registerEvent:(Event*) event{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[event eventDate]];
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"EVENT|%@|%@|%f|%f|%@\n",
                                           phoneNumber,
                                           [event eventName],
                                           (double)[[event pin] coordinate].latitude,
                                           (double)[[event pin] coordinate].longitude,
                                           dateString]];
}

-(void) registerToEventwithEventName:(NSNumber*) eventID{
    [sharedInstance sendPacketWithMessage:[NSString stringWithFormat: @"REG|%@|%d\n",
                                           phoneNumber,
                                           [eventID intValue]]];
}


@end
