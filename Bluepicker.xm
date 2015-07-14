//
//  Bluepicker.xm
//  Bluepicker
//	Activator listener for Bluepicker selection sheet. Also hears notifications from outside parties.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import "Bluepicker.h"

@implementation Bluepicker

- (id)init {
	self = [super init];
	if (self) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerChooseNotificationReceived:) name:@"Bluepicker.Choose" object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerStartNotificationReceived:) name:@"Bluepicker.Start" object:nil];

		[[NSNotificationCenter defaultCenter] addObserverForName:@"BluetoothPowerChangedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			if (waitingForToggle) {
				NSLog(@"[Bluepicker] Heard Bluetooth toggle notification, looks like we're prompting again...");
				waitingForToggle = NO;
				[self bluepickerStartNotificationReceived:nil];
			}
		}];
	}

	return self;
}

- (void)bluepickerStartNotificationReceived:(NSNotification *)notification {
	NSLog(@"[Bluepicker] Received external notification (possibly from Control Center), prompting Action...");
	[self activator:nil receiveEvent:nil];
}

- (void)bluepickerChooseNotificationReceived:(NSNotification *)notification {
	NSInteger indexChosen = [notification.userInfo[@"index"] integerValue];

	// Cancel
	if (indexChosen < 0 || indexChosen == devices.count - 2) {
		NSLog(@"[Bluepicker] Dismissing action sheet after cancel button press");
	}

	// Turn On/Off Bluetooth
	else if (indexChosen == devices.count - 1) {
		if ([[BluetoothManager sharedInstance] enabled]) {
			NSLog(@"[Bluepicker] Turning off Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:NO];
		}

		else {
			NSLog(@"[Bluepicker] Turning on Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:YES];
			waitingForToggle = YES;
		}
	}

	else {
		BluetoothDevice *selectedDevice = devices[indexChosen];

		// attempted fix for issue #8
		/* if (![[selectedDevice name] isEqualToString:clickedButtonTitle]) {
			for (BluetoothDevice *device in devices) {
				if ([[device name] isEqualToString:clickedButtonTitle]) {
					selectedDevice = device;
					break;
				} 
			}	
		}*/

		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:selectedDevice]) {
			NSLog(@"[Bluepicker] Trying to disconnected from: %@", selectedDevice);
			[selectedDevice disconnect];
		}

		else {
			NSLog(@"[Bluepicker] Trying to connect to: %@", selectedDevice);
			[[BluetoothManager sharedInstance] connectDevice:selectedDevice];
		}
	}

	devices = nil;
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[self dismiss];
	if (event) {
		[event setHandled:YES];
	}

	devices = [[[BluetoothManager sharedInstance] pairedDevices] retain];
	NSLog(@"[Bluepicker] Received Activator event, notifying to list paired devices: %@", devices);

	NSMutableArray *titles = [NSMutableArray arrayWithCapacity:devices.count];			

	for (BluetoothDevice *device in devices) {
		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:device]) {
        	[titles addObject:[@"●  " stringByAppendingString:[device name]]];
		}

        else {
        	[titles addObject:[device name]];
		}
	}

	if ([[BluetoothManager sharedInstance] enabled]) {
		[titles addObject:@"Turn Off Bluetooth"];
	}

	else {
		[titles addObject:@"Turn On Bluetooth"];
	}


	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Bluepicker.Alert" object:nil userInfo:@{@"titles" : titles}];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	[self dismiss];
	[event setHandled:YES];
}

// Restricts action to only be paired with other non-modal-ui actions
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
	return @[@"modal-ui"];
}

// Called when manual dismiss of action sheet is required (eg from double event calls)
- (BOOL)dismiss {
	if (devices) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Bluepicker.Dismiss" object:nil];
		return YES;
	}

	return NO;
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[devices release];
	[super dealloc];
}

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.insanj.Bluepicker"];
	[pool release];
}

@end
