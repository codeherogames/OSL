//
//  ChildMenuButton.m
//  PixelSniper
//
//  Created by James Dailey on 1/26/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "ChildMenuButton.h"
#import "ComputerScene.h"

@implementation ChildMenuButton
@synthesize type,status,rect,disabledColor,enabledColor,selectedColor,des,longDescription;
- (id) initWithFile: (NSString*) s t:(int) t d:(NSString*)d ld:(NSString*)ld
{
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	CCLOG(@"ChildMenuButton init:%@",s);
	self =  [super initWithFile:s];
	if (self != nil) {
		self.type = t;
		self.des = d;
		self.status=1;
		self.disabledColor=ccGRAY;
		self.enabledColor=ccWHITE;
		self.selectedColor=ccGREEN;
		self.longDescription = ld;
	}
	return self;
}

- (void)onEnter
{
	CCLOG(@"onEnter adding ChildMenuButton myButtontouchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	CGSize s = [self contentSize];
	rect = CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
	[super onEnter];
}

- (void)onExit
{
	CCLOG(@"onExit removing ChildMenuButton touchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	[super onExit];
}	

-(void) reset {
	if (self.status == -1)
		self.color=self.disabledColor;
	else {
		//self.opacity=255;
		self.color=self.enabledColor;
	}
}

-(void) enable {
	self.status = 1;
	self.color=self.enabledColor;
}

-(void) disable {
	self.status = -1;
	self.color=self.disabledColor;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self reset];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (self.status == 1) {
		if ( [self containsTouchLocation:touch] ) {
			if (self.type == 14 || self.type == 15) {
				self.status = -1;
				[self reset];
			}
			else {
				self.color=self.selectedColor;
			}
			if ([AppDelegate get].help == 1) {
				[(ComputerScene*)[[CCDirector sharedDirector] runningScene] showDescription:self.longDescription];
			}
			else {
				[[AppDelegate get].bgLayer menuAttack:self.type];
			}
			[AppDelegate get].lastActionButton = -1;
			[[AppDelegate get].glassSlider slideIn];
			return YES;
		}
		else {
			return NO;
		}
		}
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

- (void) dealloc {
	CCLOG(@"Deallocing ChildMenuButton");
	[super dealloc];
}
@end
