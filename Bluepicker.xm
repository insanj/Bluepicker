// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import "Bluepicker.h"

@implementation Bluepicker

- (id)init {
	self = [super init];
	if (self) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(showPicker) name:@"BPShowPicker" object:nil];
	}

	return self;
}

- (void)showPicker {
	NSLog(@"[Bluepicker] Received external notification (possibly from Control Center), prompting Action...");
	[self activator:nil receiveEvent:nil];
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (![self dismiss]) {
		if (event) {
			[event setHandled:YES];
		}

		devices = [[[BluetoothManager sharedInstance] pairedDevices] retain];
		NSLog(@"[Bluepicker] Received Activator event, listing paired devices: %@", devices);

		bluepickerSheet = [[UIActionSheet alloc] initWithTitle:@"Bluepicker\nPaired Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		bluepickerSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

		// Note: possible method of interest: -(void)setDeviceScanningEnabled:(BOOL)arg1;
		for(BluetoothDevice *device in devices){
			if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:device]) {
	        	[bluepickerSheet addButtonWithTitle:[@"●  " stringByAppendingString:[device name]]];
			}

	        else {
	        	[bluepickerSheet addButtonWithTitle:[device name]];
			}
		}

		if ([[BluetoothManager sharedInstance] enabled]) {
			[bluepickerSheet addButtonWithTitle:@"Turn Off Bluetooth"];
		}

		else {
			[bluepickerSheet addButtonWithTitle:@"Turn On Bluetooth"];
		}

		[bluepickerSheet setDestructiveButtonIndex:bluepickerSheet.numberOfButtons-1];

		[bluepickerSheet addButtonWithTitle:@"Cancel"];
		[bluepickerSheet setCancelButtonIndex:devices.count+1];
		[bluepickerSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	}

	else {
		NSLog(@"[Bluepicker] Received negating Activator event, dismissing action sheet");
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	if ([self dismiss]) {
		[event setHandled:YES];
	}
}

// Restricts action to only be paired with other non-modal-ui actions
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
	return @[@"modal-ui"];
}

// Called when manual dismiss of action sheet is required (eg from double event calls)
- (BOOL)dismiss {
	if (bluepickerSheet) {
		[bluepickerSheet dismissWithClickedButtonIndex:[bluepickerSheet cancelButtonIndex] animated:YES];
		return YES;
	}

	return NO;
}

// Method to connect to BluetoothManager device (clicked valid button)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"[Bluepicker] Detected action sheet selection at index %i (cancel index: %i)", (int)buttonIndex, (int)[actionSheet cancelButtonIndex]);

	if ([actionSheet destructiveButtonIndex] == buttonIndex) {
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Turn Off Bluetooth"]) {
			NSLog(@"[Bluepicker] Turning off Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:NO];
		}

		else {
			NSLog(@"[Bluepicker] Turning on Bluetooth as per user action");
			[[BluetoothManager sharedInstance] setEnabled:YES];
		}
	}

	else if ([actionSheet cancelButtonIndex] != buttonIndex) {
		BluetoothDevice *selected = [devices objectAtIndex:buttonIndex];
		if ([[[BluetoothManager sharedInstance] connectedDevices] containsObject:selected]) {
			NSLog(@"[Bluepicker] Trying to disconnected from: %@", selected);
			[selected disconnect];
		}

		else {
			NSLog(@"[Bluepicker] Trying to connect to: %@", selected);
			[[BluetoothManager sharedInstance] connectDevice:selected];
		}
	}

	else {
		NSLog(@"[Bluepicker] Dismissing action sheet after cancel button press");
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[bluepickerSheet release];
	bluepickerSheet = nil;
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[bluepickerSheet release];
	[devices release];
	[super dealloc];
}

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.Bluepicker"];
	[pool release];
}

@end
