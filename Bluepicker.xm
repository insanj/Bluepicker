//
//  Bluepicker.xm
//  Bluepicker
//	Activator listener for Bluepicker selection sheet. Also hears notifications from outside parties.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import "Bluepicker.h"

@interface UIWindow (Private)
- (void)_setSecure:(BOOL)arg1; // thanks again jontelang + http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8
@end

@interface Bluepicker ()

@property (retain, nonatomic) NSArray *devices;

@property (readwrite, nonatomic) BOOL waitingForToggle;

@property (retain, nonatomic) UIWindow *bluepickerSheetWindow;

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
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(bluepickerStartNotificationReceived:) name:@"Bluepicker.Start" object:nil];

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

- (void)bluepickerStartNotificationReceived:(NSNotification *)notification {
	NSLog(@"[Bluepicker] Received external notification (possibly from Control Center), prompting Action...");
	[self activator:nil receiveEvent:nil];
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (event) {
		[event setHandled:YES];
	}

	if (_bluepickerSheet) {
		NSLog(@"[Bluepicker] Already presenting an action sheet, so we'll ignore this subsequent call");
		return;
	}

	_devices = [[[BluetoothManager sharedInstance] pairedDevices] retain];
	NSLog(@"[Bluepicker] Received Activator event, notifying to list paired devices: %@", _devices);

	_bluepickerSheet = [[UIActionSheet alloc] initWithTitle:@"Bluepicker\nPaired Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	for (BluetoothDevice *device in _devices) {
		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:device]) {
        	[_bluepickerSheet addButtonWithTitle:[@"●  " stringByAppendingString:[device name]]];
		}

        else {
        	[_bluepickerSheet addButtonWithTitle:[device name]];
		}
	}

	if ([[BluetoothManager sharedInstance] enabled]) {
		[_bluepickerSheet addButtonWithTitle:@"Turn Off Bluetooth"];
	}

	else {
		[_bluepickerSheet addButtonWithTitle:@"Turn On Bluetooth"];
	}

	[_bluepickerSheet setDestructiveButtonIndex:_bluepickerSheet.numberOfButtons-1];
	[_bluepickerSheet addButtonWithTitle:@"Cancel"];
	[_bluepickerSheet setCancelButtonIndex:_bluepickerSheet.numberOfButtons-1];

	_bluepickerSheetWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_bluepickerSheetWindow.backgroundColor = [UIColor clearColor];
	_bluepickerSheetWindow.windowLevel = UIWindowLevelAlert + 1; // much love, jontelang!

	if ([_bluepickerSheetWindow respondsToSelector:@selector(_setSecure:)]) {
		[_bluepickerSheetWindow _setSecure:YES];
	}

	[_bluepickerSheetWindow makeKeyAndVisible];

	[_bluepickerSheet showInView:_bluepickerSheetWindow];

	NSLog(@"[Bluepicker] Notification received, presented action sheet (%@) from window: %@", _bluepickerSheet, _bluepickerSheetWindow);
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
- (void)dismiss {
	if (_bluepickerSheet) {
		[_bluepickerSheet dismissWithClickedButtonIndex:-1 animated:YES];
	}

	else {
		NSLog(@"[Bluepicker] Cannot dismiss non-existent action sheet");
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet cancelButtonIndex]) {
		NSLog(@"[Bluepicker] Dismissing action sheet after cancel button press");
	}

	else if (_devices.count == 0) { // Turn On/Off Bluetooth
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
		BluetoothDevice *selectedDevice = _devices[buttonIndex];

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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	_bluepickerSheetWindow.hidden = YES;
	_bluepickerSheetWindow = nil;
	_bluepickerSheet = nil;
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[_devices release];
	[_bluepickerSheet release];
	[_bluepickerSheetWindow release];

	[super dealloc];
}

@end
