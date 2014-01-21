// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import "Bluepicker.h"

@interface SBControlCenterButton : UIButton {
        NSString *_identifier;
        NSNumber *_sortKey;
}

@property(copy, nonatomic) NSString *identifier;
@property(copy, nonatomic) NSNumber *sortKey;
-(void)dealloc;
@end

@interface SBCCButtonLayoutView{
        NSMutableArray *_buttons;
        float _interButtonPadding;
        UIEdgeInsets _contentEdgeInsets;
}

@property(assign, nonatomic) UIEdgeInsets contentEdgeInsets;
@property(assign, nonatomic) float interButtonPadding;
-(id)initWithFrame:(CGRect)frame;
-(void)addButton:(SBControlCenterButton *)button;
-(NSMutableArray *)buttons;
-(void)dealloc;
-(void)layoutSubviews;
-(void)removeButton:(SBControlCenterButton *)button;
@end

%hook SBCCButtonLayoutView
-(void)addButton:(SBControlCenterButton *)button{
	if([button.identifier isEqualToString:@"bluetooth"]){			
		UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bluepicker_callActivatorAction:)];
		[button addGestureRecognizer:press];
		[press release];
	}

	%orig();
}

%new -(void)bluepicker_callActivatorAction:(UILongPressGestureRecognizer *)sender{
	if(sender.state == UIGestureRecognizerStateBegan){
		NSLog(@"[Bluepicker] Recognized long press on Bluetooth toggle, calling for a picker show");
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"BPShowPicker" object:nil];
	}
}
%end