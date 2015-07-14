//
//  BluepickerEvent.xm
//  Bluepicker
//	Activator event for Bluetooth connections and disconnections.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import "BluepickerEvent.h"

@implementation BluepickerEvent

+ (id)sharedInstance {
	static BluepickerEvent *shared = nil;
	if (!shared) {
		shared = [[BluepickerEvent alloc] init];
	}

	return shared;
}

- (id)init {
	if ((self = [super init])) {
		[LASharedActivator registerEventDataSource:self forEventName:kBluepickerEventConnectedEventName];
		[LASharedActivator registerEventDataSource:self forEventName:kBluepickerEventDisconnectedEventName];
	}

    return self;
}

- (void)dealloc{
	if (LASharedActivator.runningInsideSpringBoard) {
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluepickerEventConnectedEventName];
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluepickerEventDisconnectedEventName];
	}

    [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:kBluepickerEventConnectedEventName]) {
        return @"Connected";
	}

    return @"Disconnected";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
    return @"Bluepicker";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:kBluepickerEventConnectedEventName]) {
		return @"Bluetooth Device connected.";
	}

	return @"Bluetooth Device disconnected.";
}

- (BOOL)eventWithNameIsHidden:(NSString *)eventName {
	return NO;
}

- (BOOL)eventWithNameRequiresAssignment:(NSString *)eventName {
	return NO;
}

- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
	return YES;
}

- (BOOL)eventWithNameSupportsUnlockingDeviceToSend:(NSString *)eventName {
	return NO;
}

@end

%hook BluetoothManager

- (void)postNotificationName:(id)arg1 object:(id)arg2 {
	%orig();

	if([arg1 isEqualToString:@"BluetoothDeviceConnectSuccessNotification"]) {
		if(kBluepickerEventDidSucceed) {
			NSLog(@"[Bluepicker] Received bluetooth device connection notification, performing action...");
			kBluepickerEventDidSucceed = NO; // Notification is always sent twice
			LASendEventWithName(kBluepickerEventConnectedEventName);
		}

		else {
			NSLog(@"[Bluepicker] Received phony bluetooth device connection notification, waiting to perform action...");
			kBluepickerEventDidSucceed = YES;
		}
	}

	else if ([arg1 isEqualToString:@"BluetoothDeviceDisconnectSuccessNotification"]) {
		NSLog(@"[Bluepicker] Received bluetooth device disconnection notification...");
		LASendEventWithName(kBluepickerEventDisconnectedEventName);
	}
}

%end

%ctor {
	[BluepickerEvent sharedInstance];
}
