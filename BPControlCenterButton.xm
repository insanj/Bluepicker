//
//	BPControlCenterButton.xm
//	Bluepicker
//	Injects a tap-and-hold listener to the Bluetooth button in Control Center.
//	
//	Created by Julian Weiss on 1/20/14.
//	Copyright (c) 2014, insanj. All rights reserved.
//

#import "BPControlCenterButton.h"

%hook SBControlCenterButton

// static char * bluepickerHoldRecognizerKey;

- (void)setIdentifier:(NSString *)identifier {
	/*

	// Un-needed methods to intelligently replace/remove previous recognizers
	NSArray *gestureRecognizers = [NSArray arrayWithArray:self.gestureRecognizers];
	for (int i = 0; i < gestureRecognizers.count; i++) {
		UIGestureRecognizer *recognizer = (UIGestureRecognizer *)gestureRecognizers[i];
		NSArray *targets = MSHookIvar<NSArray *>(recognizer, "_targets");
		SEL action = MSHookIvar<SEL>(targets[0], "_action");
		if (action == @selector(bluepicker_callActivatorAction:)) {
			NSLog(@"[Bluepicker] Heard -setIdentifier: with action on %@, removing due to duplicate %@.", identifier, recognizer);
			[self removeGestureRecognizer:recognizer];
		}
	}

	if (bluepickerHoldRecognizer && ![((SBControlCenterButton *)bluepickerHoldRecognizer.view).identifier isEqualToString:@"bluetooth"]) {
		[bluepickerHoldRecognizer.view removeGestureRecognizer:bluepickerHoldRecognizer];
		bluepickerHoldRecognizer = nil;
	}

	*/

	BOOL isBluetoothButton = [identifier isEqualToString:@"bluetooth"];
	// UILongPressGestureRecognizer *bluepickerHoldRecognizer = (UILongPressGestureRecognizer *)objc_getAssociatedObject(self, &bluepickerHoldRecognizerKey);

	if (isBluetoothButton) {
		NSArray *gestureRecognizers = [NSArray arrayWithArray:self.gestureRecognizers];
		for (UIGestureRecognizer *recognizer in gestureRecognizers) {
			[self removeGestureRecognizer:recognizer];
		}

		UILongPressGestureRecognizer *bluepickerHoldRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bluepicker_callActivatorAction:)];
		bluepickerHoldRecognizer.minimumPressDuration = 0.25;
		[self addGestureRecognizer:bluepickerHoldRecognizer];

		// objc_setAssociatedObject(self, &bluepickerHoldRecognizerKey, bluepickerHoldRecognizer, OBJC_ASSOCIATION_ASSIGN);
		[bluepickerHoldRecognizer release];
	}

	%orig(identifier);
}

%new - (void)bluepicker_callActivatorAction:(UILongPressGestureRecognizer *)sender {
	NSLog(@"---- called %@", sender);

    if (sender.state == UIGestureRecognizerStateBegan) {
	    NSLog(@"[Bluepicker] Recognized hold on Bluetooth toggle, calling for a picker show.");
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"BPShowPicker" object:nil];
    }
}
/*
- (void)dealloc {
	UILongPressGestureRecognizer *bluepickerHoldRecognizer = (UILongPressGestureRecognizer *)objc_getAssociatedObject(self, &bluepickerHoldRecognizerKey);
	if (bluepickerHoldRecognizer) {
		[self removeGestureRecognizer:bluepickerHoldRecognizer];
	}

	%orig();
}*/

%end