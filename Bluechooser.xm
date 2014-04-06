// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import "Bluechooser.h"

@implementation Bluechooser

+ (id)sharedInstance {
	static Bluechooser *shared = nil;
	if (!shared) {
		shared = [[Bluechooser alloc] init];
	}

	return shared;
}

- (id)init {
	if ((self = [super init])) {
		[LASharedActivator registerEventDataSource:self forEventName:kBluechooserConnectedEventName];
		[LASharedActivator registerEventDataSource:self forEventName:kBluechooserDisconnectedEventName];
	}

    return self;
}

- (void)dealloc{
	if (LASharedActivator.runningInsideSpringBoard) {
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluechooserConnectedEventName];
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluechooserDisconnectedEventName];
	}

    [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:kBluechooserConnectedEventName]) {
        return @"Connected";
	}

    return @"Disconnected";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
    return @"Bluepicker";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:kBluechooserConnectedEventName]) {
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
		if(kBluechooserDidSucceed) {
			NSLog(@"[Bluepicker] Received bluetooth device connection notification, performing action...");
			kBluechooserDidSucceed = NO; // Notification is always sent twice
			LASendEventWithName(kBluechooserConnectedEventName);
		}

		else {
			NSLog(@"[Bluepicker] Received phony bluetooth device connection notification, waiting to perform action...");
			kBluechooserDidSucceed = YES;
		}
	}

	else if ([arg1 isEqualToString:@"BluetoothDeviceDisconnectSuccessNotification"]) {
		NSLog(@"[Bluepicker] Received bluetooth device disconnection notification...");
		LASendEventWithName(kBluechooserDisconnectedEventName);
	}
}

%end

%ctor {
	[Bluechooser sharedInstance];
}
