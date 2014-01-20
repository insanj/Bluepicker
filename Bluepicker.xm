// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>
#import <BluetoothManager/BluetoothManager.h>

@interface Bluepicker : NSObject <LAListener, UIActionSheetDelegate> {
@private
	UIActionSheet *bluepickerSheet;
	NSArray *devices;
}
@end

@implementation Bluepicker

// Called when the user-defined action is recognized, shows sheet
-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event{
	if(![self dismiss]){
		devices = [[BluetoothManager sharedInstance] pairedDevices];
		bluepickerSheet = [[UIActionSheet alloc] initWithTitle:@"Bluepicker" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		
		// Note: other methods of interest: 	//- (void)setDeviceScanningEnabled:(BOOL)arg1;
												//- (id)connectedDevices;

		for(BluetoothDevice *device in devices)
	        [bluepickerSheet addButtonWithTitle:[device name]];
	
		[bluepickerSheet addButtonWithTitle:@"Cancel"];
		[bluepickerSheet setCancelButtonIndex:devices.count];
		[bluepickerSheet showInView:[[UIApplication sharedApplication] keyWindow]];
		
		[event setHandled:YES];
	}
}

-(void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event{
	[self dismiss];
}

-(void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event{
	[self dismiss];
}

-(void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event{
	if([self dismiss])
		[event setHandled:YES];
}

// Called when manual dismiss of action sheet is required (eg from double event calls)
-(BOOL)dismiss{
	if(bluepickerSheet){
		[bluepickerSheet dismissWithClickedButtonIndex:[bluepickerSheet cancelButtonIndex] animated:YES];
		[bluepickerSheet release];
		bluepickerSheet = nil;
		return YES;
	}

	return NO;
}

// Method to connect to BluetoothManager device (clicked valid button)
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([actionSheet cancelButtonIndex] != buttonIndex){
		NSLog(@"[Bluepicker] Detected device selection, trying to connect to: %@", [devices objectAtIndex:buttonIndex]);
		[[BluetoothManager sharedInstance] connectDevice:[devices objectAtIndex:buttonIndex]];
	}

	[bluepickerSheet release];
	bluepickerSheet = nil;
}

-(void)dealloc{
	[bluepickerSheet release];
	[devices release];
	[super dealloc];
}

+(void)load{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.Bluepicker"];
	[pool release];
}

@end 