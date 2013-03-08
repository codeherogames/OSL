//
//  Dial.m
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MyDial.h"


@implementation MyDial
@synthesize rect;
/*- (id) initWithFile: (NSString*) s l:(CCNode*)l
{
	CCLOG(@"--------------Enemy init");
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	self =  [super initWithFile:s];
	return self;
}*/

- (void)onEnter
{
	CCLOG(@"onEnter adding myButtontouchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	CGSize s = [self contentSize];
	rect = CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
	[super onEnter];
}

- (void)onExit
{
	CCLOG(@"onExit removing myButton touchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	[super onExit];
}	

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( [self containsTouchLocation:touch] ) {
		[[AppDelegate get].soundEngine playSound:6 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		CCLOG(@"sens:%i",[AppDelegate get].sensitivity);
		if ([AppDelegate get].sensitivity == 1) {
			[AppDelegate get].sensitivity = 2;
			self.rotation=90;
		}
		else if ([AppDelegate get].sensitivity == 3) {
			[AppDelegate get].sensitivity = 1;
			self.rotation=0;
		}
		else {
			[AppDelegate get].sensitivity = 3;
			self.rotation=180;
		}
		CCLOG(@"sens:%i",[AppDelegate get].sensitivity);
		return YES;
	}
	else {
		return NO;
	}
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

- (void) dealloc {
	CCLOG(@"Deallocing myDial");
	[super dealloc];
}
@end