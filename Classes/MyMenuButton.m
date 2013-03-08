//
//  myMenuButton.m
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MyMenuButton.h"
#import "AppDelegate.h"
#import "ChildMenuButton.h"

@implementation MyMenuButton
@synthesize disabledColor,enabledColor,pressedColor,type,status,rect,money,selected,childButtons;
- (id) initWithName: s t:(int) t val:(int) val
{
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	self = [[super initWithFile:[NSString stringWithFormat:@"%@.png",s]] autorelease];
	if (self != nil) {
		self.status = 1;
		self.type = t;
		self.disabledColor=[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@disabled.png",s]];
		self.enabledColor=[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",s]];
		self.pressedColor=[CCSprite spriteWithFile:[NSString stringWithFormat:@"%@pressed.png",s]];
		self.money = val;
		self.selected = 0;
		childButtons = [[NSMutableArray alloc] init];
	}
	[[AppDelegate get].actionButtons addObject:self];
	return self;
}

-(void) reset {
	self.status = 0;
	self.selected = 0;
	self.texture=self.disabledColor.texture;
	for (ChildMenuButton *c in childButtons) {
		[c enable];
	}
	[self unschedule: @selector(moneyProgress)];
	[self schedule: @selector(moneyProgress) interval: 0.1];
}

-(void) moneyProgress {
	if ([AppDelegate get].money >= self.money) {
		if ([AppDelegate get].lastActionButton == self.tag) {
			self.texture=self.pressedColor.texture;
		}
		else {
			status = 1;
			self.texture=self.enabledColor.texture;
		}
		//[self setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
	}
	else {
		status = 0;
		//[self setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
		self.texture=self.disabledColor.texture;
	}
}

-(void) blink {
	self.texture=self.pressedColor.texture;
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
		//enabled
		//CCLOG(@"status:%d",status);
		if (status == 1) {
			[[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
			//not selected yet
			//CCLOG(@"selected:%d",selected);
			if ([AppDelegate get].lastActionButton != self.tag) {
				//CCLOG(@"last:%d, tag:%d",[AppDelegate get].lastActionButton,self.tag);
				[[AppDelegate get].glassSlider addButtons:self.childButtons];
				
				selected = 1;
				//save button as last
				[AppDelegate get].lastActionButton = self.tag;
				//[self setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
				[self blink];
				//open submenu
				//CCLOG(@"slider status:%d",[AppDelegate get].glassSlider.status);
				if ([AppDelegate get].glassSlider.status == 0) {
					[[AppDelegate get].soundEngine playSound:3 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
					[[AppDelegate get].glassSlider slideOut];
				}
			}
			else { // already selected
				selected = 0;
				//no button selected
				
				//[self setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
				//close submenu
				//CCLOG(@"last:%d, tag:%d",[AppDelegate get].lastActionButton,self.tag);
				//CCLOG(@"slider status:%d",[AppDelegate get].glassSlider.status);
				if ([AppDelegate get].glassSlider.status == 1) {
					[AppDelegate get].lastActionButton = -1;
					[[AppDelegate get].soundEngine playSound:4 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
					[[AppDelegate get].glassSlider slideIn];
				}
			}
			//[[AppDelegate get].bgLayer menuAttack:self.type];
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
	CCLOG(@"Deallocing myMenuButton");
	[super dealloc];
}
@end
