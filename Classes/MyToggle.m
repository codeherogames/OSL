//
//  myToggle.m
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MyToggle.h"

@implementation MyToggle
@synthesize rect,t,tOrig;

- (id) initWithFile: (NSString*) s
 {
 //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	 self =  [super initWithFile:[NSString stringWithFormat:@"%@.png", s]];
	 if (self != nil) {
		 CCSprite *tNew = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@1.png", s]];
		 self.tOrig = self.texture;
		 self.t = tNew.texture;
	 }
	return self;
 }

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
		[[AppDelegate get].bgLayer zoomButtonPressed];
		if ([AppDelegate get].scale == [AppDelegate get].maxZoom) {
			self.texture = t;
		}
		else {
			self.texture = tOrig;
		}
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
	CCLOG(@"Deallocing myToggle");
	[super dealloc];
}
@end