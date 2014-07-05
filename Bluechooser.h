//
//  Bluechooser.h
//  Bluepicker
//	Activator event for Bluetooth connections and disconnections.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import <Foundation/NSDistributedNotificationCenter.h>
#import <libactivator/libactivator.h>
#import <BluetoothManager/BluetoothManager.h>

static NSString *kBluechooserConnectedEventName = @"com.insanj.bluepicker.connected";
static NSString *kBluechooserDisconnectedEventName = @"com.insanj.bluepicker.disconnected";
static BOOL kBluechooserDidSucceed = NO;

__attribute__((always_inline))
static inline LAEvent *LASendEventWithName(NSString *eventName) {
	LAEvent *event = [[[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]] autorelease];
	[LASharedActivator sendEventToListener:event];
	return event;
}

@interface Bluechooser : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end
