#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

static UIActionSheet *bluepickerSheet;

@interface FBWindow : UIWindow
@end

@interface SBWindow : FBWindow
- (id)initWithFrame:(CGRect)frame;
@end

@interface SBAppWindow : SBWindow
@end

@interface SBAppWindow (Bluepicker) <UIActionSheetDelegate>

- (void)bluepickerAlertNotificationReceived:(NSNotification *)notification;
- (void)bluepickerDismissNotificationReceived:(NSNotification *)notification;

@end

%hook SBAppWindow

- (id)initWithFrame:(CGRect)frame {
	SBAppWindow *appWindow = %orig();

	NSLog(@"[Bluepicker] Added notification listeners to window: %@", appWindow);

	[[NSDistributedNotificationCenter defaultCenter] addObserver:appWindow selector:@selector(bluepickerAlertNotificationReceived:) name:@"Bluepicker.Alert" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:appWindow selector:@selector(bluepickerDismissNotificationReceived:) name:@"Bluepicker.Dismiss" object:nil];

	return appWindow;
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"Bluepicker.Alert" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"Bluepicker.Dismiss" object:nil];

	%orig();
}

%new 
- (void)bluepickerAlertNotificationReceived:(NSNotification *)notification {
	NSArray *titles = (NSArray *)notification.userInfo[@"titles"];

	bluepickerSheet = [[UIActionSheet alloc] initWithTitle:@"Bluepicker\nPaired Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	for (int i = 0; i < titles.count; i++) {
		[bluepickerSheet addButtonWithTitle:titles[i]];
	}

	[bluepickerSheet setDestructiveButtonIndex:bluepickerSheet.numberOfButtons-1];
	[bluepickerSheet addButtonWithTitle:@"Cancel"];
	[bluepickerSheet setCancelButtonIndex:bluepickerSheet.numberOfButtons-1];
	[bluepickerSheet showInView:self];

	NSLog(@"[Bluepicker] Notification received, presenting action sheet (%@) from view: %@", bluepickerSheet, self);
}

%new
- (void)bluepickerDismissNotificationReceived:(NSNotification *)notification {
	[bluepickerSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

// Method to connect to BluetoothManager device (clicked valid button
%new
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"[Bluepicker] Detected action sheet selection at index %i (cancel index: %i)", (int)buttonIndex, (int)[actionSheet cancelButtonIndex]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Bluepicker.Choose" object:nil userInfo:@{@"index" : @(buttonIndex)}];
}

%new
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[bluepickerSheet release];
	bluepickerSheet = nil;
}

%end
