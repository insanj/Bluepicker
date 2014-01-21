// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>
#import <BluetoothManager/BluetoothManager.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface Bluepicker : NSObject <LAListener, UIActionSheetDelegate>{
@private
	UIActionSheet *bluepickerSheet;
	NSArray *devices;
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
-(void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;
-(void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event;
-(void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event;
-(BOOL)dismiss;
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
-(void)dealloc;
+(void)load;
@end