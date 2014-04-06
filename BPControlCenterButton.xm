// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import "BPControlCenterButton.h"

%hook SBCCButtonLayoutView

// Sometimes this method isn't loaded into memory, and thus crashes, apparently...
%new - (void)bluepicker_callActivatorAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[Bluepicker] Recognized long press on Bluetooth toggle, calling for a picker show");
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"BPShowPicker" object:nil];
    }
}

- (void)addButton:(SBControlCenterButton *)button {
	if ([button.identifier isEqualToString:@"bluetooth"]) {
		UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bluepicker_callActivatorAction:)];
		[button addGestureRecognizer:press];
		[press release];
	}

	%orig();
}

%end
