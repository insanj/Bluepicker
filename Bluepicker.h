//
//  Bluepicker.h
//  Bluepicker
//	Activator listener for Bluepicker selection sheet. Also hears notifications from outside parties.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>
#import <BluetoothManager/BluetoothManager.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIActionSheet+Private.h>
#import "substrate.h"
#import <objc/runtime.h>

@interface Bluepicker : NSObject <LAListener, UIActionSheetDelegate> {
@private
	UIActionSheet *bluepickerSheet;
	NSArray *devices;
	BOOL waitingForToggle;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event;
- (BOOL)dismiss;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)dealloc;
+ (void)load;

@end
