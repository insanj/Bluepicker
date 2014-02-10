// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#import <BluetoothManager/BluetoothManager.h>

static NSString *kBluechooserConnectedEventName = @"com.insanj.bluepicker.connected";
static NSString *kBluechooserDisconnectedEventName = @"com.insanj.bluepicker.disconnected";

__attribute__((always_inline))
static inline LAEvent *LASendEventWithName(NSString *eventName) {
	LAEvent *event = [[[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]] autorelease];
	[LASharedActivator sendEventToListener:event];
	return event;
}

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface Bluechooser : NSObject <LAEventDataSource>
+(id)sharedInstance;
@end