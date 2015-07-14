//
//  BluepickerEvent.h
//  Bluepicker
//	Activator event for Bluetooth connections and disconnections.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import <Foundation/NSDistributedNotificationCenter.h>
#import <libactivator/libactivator.h>
#import <BluetoothManager/BluetoothManager.h>

static NSString *kBluepickerEventConnectedEventName = @"com.insanj.bluepicker.connected";
static NSString *kBluepickerEventDisconnectedEventName = @"com.insanj.bluepicker.disconnected";
static BOOL kBluepickerEventDidSucceed = NO;

__attribute__((always_inline))
static inline LAEvent *LASendEventWithName(NSString *eventName) {
	LAEvent *event = [[[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]] autorelease];
	[LASharedActivator sendEventToListener:event];
	return event;
}

@interface BluepickerEvent : NSObject <LAEventDataSource>

+ (id)sharedInstance;

@end
