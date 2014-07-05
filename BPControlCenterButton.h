//
//  BPControlCenterButton.h
//  Bluepicker
//	Injects a tap-and-hold listener to the Bluetooth button in Control Center.
//	
//  Created by Julian Weiss on 1/20/14.
//  Copyright (c) 2014, insanj. All rights reserved.
//

#import "Bluepicker.h"

@interface SBControlCenterButton : UIButton {
	NSString *_identifier;
	NSNumber *_sortKey;
}

@property(copy, nonatomic) NSString *identifier;
@property(copy, nonatomic) NSNumber *sortKey;

- (void)dealloc;
@end

@interface SBControlCenterButton (Bluepicker)
- (void)bluepicker_callActivatorAction:(UILongPressGestureRecognizer *)sender;
@end
