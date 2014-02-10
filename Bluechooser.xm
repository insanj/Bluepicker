// Bluepicker by Julian (insanj) Weiss
// (CC) 2014 Julian Weiss, see full license in README.md

#import "Bluechooser.h"

@implementation Bluechooser

+(id)sharedInstance{
	static Bluechooser *shared = nil;
	if(!shared)
		shared = [[Bluechooser alloc] init];

	return shared;
}

-(id)init{
	if((self = [super init])){
		[LASharedActivator registerEventDataSource:self forEventName:kBluechooserConnectedEventName];
		[LASharedActivator registerEventDataSource:self forEventName:kBluechooserDisconnectedEventName];
	}

    return self;
}
 
-(void)dealloc{
	if(LASharedActivator.runningInsideSpringBoard){
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluechooserConnectedEventName];
		[LASharedActivator unregisterEventDataSourceWithEventName:kBluechooserDisconnectedEventName];
	}

    [super dealloc];
}
 
-(NSString *)localizedTitleForEventName:(NSString *)eventName{
	if([eventName isEqualToString:kBluechooserConnectedEventName])
        return @"Connected";
    return @"Disconnected";
}
 
-(NSString *)localizedGroupForEventName:(NSString *)eventName{
        return @"Bluepicker";
}
 
-(NSString *)localizedDescriptionForEventName:(NSString *)eventName{
	if([eventName isEqualToString:kBluechooserConnectedEventName])
		return @"Bluetooth Device connected.";
	return @"Bluetooth Device disconnected.";
}
 
-(BOOL)eventWithNameIsHidden:(NSString *)eventName{
	return NO;
}
 
-(BOOL)eventWithNameRequiresAssignment:(NSString *)eventName{
	return NO;
}
 
-(BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode{
	return YES;
}
 
-(BOOL)eventWithNameSupportsUnlockingDeviceToSend:(NSString *)eventName{
	return NO;
}
 
@end

%group Bluechooser

%hook BluetoothManager

-(void)connectDevice:(id)arg1{
	%orig();
	LASendEventWithName(kBluechooserConnectedEventName);
}

%end

%hook BluetoothDevice

-(void)disconnect{
	%orig();
	LASendEventWithName(kBluechooserDisconnectedEventName);
}

%end

%end //%group

%ctor{
	%init(Bluechooser)
	[Bluechooser sharedInstance];
}
