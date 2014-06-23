#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MapPin.h"
#import "Event.h"
/**
 Singleton obsługujący połączenie z bazą danych
 W bazie danych są cztery tabele - tabela wydarzeń, gości, łącząca poprzednie dwie i ostatnia,
 przechowująca historię lokalizacji użytkownika
 
 @code
 |---------|       |--------------|      |---------|
 |         |       |              |      |         |
 | events  |>------|  eventGuest  |-----<| guests  |
 |         |       |              |      |         |
 |---------|       |--------------|      |---------|
 
 */
@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;

//utworzenie bazy danych
-(BOOL)createDB;

//dodanie nowego wydarzenia
-(BOOL)addEvent:(NSString*)eventName onDate:(NSDate*)date inLocation:(MapPin*)pin withGuests:(NSMutableDictionary*)contacts;

//dodanie nowego kontaktu
-(BOOL)addGuestWithName:(NSString*) guestName andPhone:(NSString*) guestPhone;

//pobranie wszystkich nazw wydarzeń
-(NSMutableArray*) getAllEventsNames;

//pobranie wszystkich nazw gości
-(NSMutableArray*) getAllGuestNames;

//pobranie wszystkich numerów telefonów gości
-(NSMutableArray*) getAllGuestPhones;

//pobranie gości wydarzenia razem z ich numerami telefonów
-(NSMutableDictionary*) getEventGuestsWithPhoneNumbersForEventName:(NSString*) eventName;

//pobranie gości wydarzenia razem z ich lokalizacjami
-(NSMutableDictionary*) getEventGuestsWithLocationsForEventName:(NSString*) eventName;

//pobranie lokalizacji wydarzenia
-(MapPin*)getEventLocationForEventName: (NSString*) eventName;

//pobranie daty wydarzenia
-(NSDate*)getEventDateForEventName: (NSString*) eventName;

//pobranie całego wydarzenia
-(Event*)getEventForEventName:(NSString*) eventName;

//pobranie nazwy wydarzenia przypisanego do określonego ID
-(NSString*)getEventNameForEventID:(NSNumber*) eventID;

//pobranie ID wydarzenia przypisanego do danej nazwy wydarzenia
-(NSNumber*)getEventIDforEventName:(NSString*) eventName;

//pobranie nazwy gościa posiadającego dany numer telefonu
-(NSString*)getGuestNameforGuestPhoneNumber:(NSString*) guestPhone;

//wprowadzenie lokalizacji użytkownika do bazy
-(BOOL) insertUserLocation:(CLLocationCoordinate2D) coordinates;

//zmiana ID wydarzenia o danej nazwie
-(BOOL) updateEventID: (NSNumber*) eventID forEventName:(NSString*) eventName;

//aktualizacja całego wydarzenia
-(BOOL) updateEventDetailsForEventID:(NSNumber*) eventID withEventName: (NSString*) eventName onDate:(NSDate*) date inLocation:(MapPin*)pin;

//dodanie gościa o danym numerze do wydarzenia
-(BOOL) addGuestToEventWithEventID:(NSNumber*) eventID withPhoneNumber:(NSString*) phoneNumber;

//zaktualizowanie lokalizacji gościa o danym numerze
-(BOOL) updateGuestPositionForGuestWithPhoneNumber:(NSString*) phoneNumber withCoordinates:(CLLocationCoordinate2D) coordinates;

//usunięcie wydarzenia o danej nazwie
-(BOOL) deleteEventForEventName:(NSString*) eventName;

//usunięcie gościa o danej nazwie
-(BOOL) deleteGuestForGuestName:(NSString*) guestName;

//usunięcie wpisu łączącego danego gościa z danym wydarzeniem
-(BOOL) deleteConnectionForGuest:(NSString*) guestName andEventName:(NSString*) eventName;

//wymuszenie zamknięcia połączenia (jakby coś się popsuło)
-(void) forceCloseDatabase;

@end
