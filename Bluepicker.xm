//
//  Bluepicker.xm
//  Bluepicker
//	Activator listener for Bluepicker selection sheet. Also hears notifications from outside parties.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import "Bluepicker.h"

@interface Bluepicker ()

@property (retain, nonatomic) NSArray *devices;

@property (readwrite, nonatomic) BOOL waitingForToggle;

@property (retain, nonatomic) UIWindow *keyWindow, *bluepickerSheetWindow;

@property (retain, nonatomic) UIActionSheet *bluepickerSheet;

@end

@implementation Bluepicker

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.insanj.Bluepicker"];
	[pool release];
}

- (id)init {
	self = [super init];
	if (self) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerChooseNotificationReceived:) name:@"Bluepicker.Choose" object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerStartNotificationReceived:) name:@"Bluepicker.Start" object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerAlertNotificationReceived:) name:@"Bluepicker.Alert" object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerDismissNotificationReceived:) name:@"Bluepicker.Dismiss" object:nil];

		[[NSNotificationCenter defaultCenter] addObserverForName:@"BluetoothPowerChangedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			if (_waitingForToggle) {
				NSLog(@"[Bluepicker] Heard Bluetooth toggle notification, looks like we're prompting again...");
				_waitingForToggle = NO;
				[self bluepickerStartNotificationReceived:nil];
			}
		}];
	}

	return self;
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[self dismiss];
	if (event) {
		[event setHandled:YES];
	}

	_devices = [[[BluetoothManager sharedInstance] pairedDevices] retain];
	NSLog(@"[Bluepicker] Received Activator event, notifying to list paired devices: %@", _devices);

	NSMutableArray *titles = [NSMutableArray arrayWithCapacity:_devices.count];			

	for (BluetoothDevice *device in _devices) {
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


	[self bluepickerAlertNotificationReceived:titles];
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
	if (_devices) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Bluepicker.Dismiss" object:nil];
		return YES;
	}

	return NO;
}

- (void)bluepickerStartNotificationReceived:(NSNotification *)notification {
	NSLog(@"[Bluepicker] Received external notification (possibly from Control Center), prompting Action...");
	[self activator:nil receiveEvent:nil];
}

- (void)bluepickerChooseNotificationReceived:(NSNotification *)notification {
	NSInteger indexChosen = [notification.userInfo[@"index"] integerValue];

	// Cancel
	if (indexChosen < 0 || indexChosen == _devices.count - 2) {
		NSLog(@"[Bluepicker] Dismissing action sheet after cancel button press");
	}

	// Turn On/Off Bluetooth
	else if (indexChosen == _devices.count - 1) {
		if ([[BluetoothManager sharedInstance] enabled]) {
			NSLog(@"[Bluepicker] Turning off Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:NO];
		}

		else {
			NSLog(@"[Bluepicker] Turning on Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:YES];
			_waitingForToggle = YES;
		}
	}

	else {
		BluetoothDevice *selectedDevice = _devices[indexChosen];

		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:selectedDevice]) {
			NSLog(@"[Bluepicker] Trying to disconnected from: %@", selectedDevice);
			[selectedDevice disconnect];
		}

		else {
			NSLog(@"[Bluepicker] Trying to connect to: %@", selectedDevice);
			[[BluetoothManager sharedInstance] connectDevice:selectedDevice];
		}
	}

	_devices = nil;
}

- (void)bluepickerAlertNotificationReceived:(id)sender {
	NSLog(@"[Bluepicker] Notification received, presenting action sheet (%@) from view: %@", _bluepickerSheet, self);
	NSArray *titles = [sender isKindOfClass:[NSArray class]] ? (NSArray *)sender : ((NSNotification *)sender).userInfo[@"titles"];

	_bluepickerSheet = [[[UIActionSheet alloc] initWithTitle:@"Bluepicker\nPaired Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];

	for (int i = 0; i < titles.count; i++) {
		[_bluepickerSheet addButtonWithTitle:titles[i]];
	}

	[_bluepickerSheet setDestructiveButtonIndex:_bluepickerSheet.numberOfButtons-1];
	[_bluepickerSheet addButtonWithTitle:@"Cancel"];
	[_bluepickerSheet setCancelButtonIndex:_bluepickerSheet.numberOfButtons-1];

	_keyWindow = [UIApplication sharedApplication].keyWindow;

	_bluepickerSheetWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_bluepickerSheetWindow.backgroundColor = [UIColor clearColor];
	[_bluepickerSheetWindow makeKeyAndVisible];

	[_bluepickerSheet showInView:_bluepickerSheetWindow];
}

- (void)bluepickerDismissNotificationReceived:(NSNotification *)notification {
	[_bluepickerSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

// Method to connect to BluetoothManager device (clicked valid button
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"[Bluepicker] Detected action sheet selection at index %i (cancel index: %i)", (int)buttonIndex, (int)[actionSheet cancelButtonIndex]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Bluepicker.Choose" object:nil userInfo:@{@"index" : @(buttonIndex)}];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[_keyWindow makeKeyAndVisible];

	_bluepickerSheetWindow.hidden = YES;
	[_bluepickerSheetWindow release];
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[_devices release];
	[super dealloc];
}

@end
