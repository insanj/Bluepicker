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

@property (retain, nonatomic) NSMutableArray *titles;

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

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[event setHandled:YES];

	NSLog(@"[Bluepicker] Listener received call to (activator:receiveEvent:)");
	[self bluepickerStartNotificationReceived:nil];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	NSLog(@"[Bluepicker] Listener received call to (activator:abortEvent:)");
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	NSLog(@"[Bluepicker] Listener received call to (activator:otherListenerDidHandleEvent:)");
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	NSLog(@"[Bluepicker] Listener received call to (activator:receiveDeactivateEvent:)");
	[self dismiss];
}

// Restricts action to only be paired with other non-modal-ui actions
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
	return @[@"modal-ui"];
}

- (void)bluepickerStartNotificationReceived:(NSNotification *)notification {	
	if (_bluepickerSheet) {
		NSLog(@"[Bluepicker] Already presenting an action sheet, so we'll ignore this subsequent call");
		return;
	}

	_devices = [[[BluetoothManager sharedInstance] pairedDevices] retain];
	_titles = [[NSMutableArray alloc] initWithCapacity:_devices.count+1];

	_bluepickerSheet = [[UIActionSheet alloc] initWithTitle:@"Bluepicker\nPaired Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	for (int i = 0; i < _devices.count; i++) {
		BluetoothDevice *device = _devices[i];

		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:device]) {
        	[_titles addObject:[@"●  " stringByAppendingString:[device name]]];
		}

        else {
        	[_titles addObject:[device name]];
		}

		[_bluepickerSheet addButtonWithTitle:_titles[i]];
	}

	NSString *destructiveButtonTitle = [NSString stringWithFormat:@"Turn %@ Bluetooth", [[BluetoothManager sharedInstance] enabled] ? @"Off" : @"On"];
	[_titles addObject:destructiveButtonTitle];

    _bluepickerSheet.destructiveButtonIndex = [_bluepickerSheet addButtonWithTitle:destructiveButtonTitle];
    _bluepickerSheet.cancelButtonIndex = [_bluepickerSheet addButtonWithTitle:@"Cancel"];

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

- (void)dismiss {
	if (_bluepickerSheet) {
		[_bluepickerSheet dismissWithClickedButtonIndex:_bluepickerSheet.cancelButtonIndex animated:YES];
	}

	else {
		NSLog(@"[Bluepicker] Cannot dismiss non-existent action sheet");
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	NSLog(@"[Bluepicker] actionSheet:<%@>clickedButtonAtIndex:<%i>, buttonTitle:%@", actionSheet, (int)buttonIndex, buttonTitle);

	if (buttonIndex < 0 || [buttonTitle isEqualToString:@"Cancel"]) { // Cancel
		NSLog(@"[Bluepicker] Dismissing action sheet after cancel button press");
	}

	else if ([buttonTitle isEqualToString:[_titles lastObject]]) { // Turn On/Off Bluetooth
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
		BluetoothDevice *selectedDevice = _devices[[_titles indexOfObject:buttonTitle]];

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
	[_titles release];
	[_bluepickerSheet release];
	[_bluepickerSheetWindow release];

	[super dealloc];
}

@end
