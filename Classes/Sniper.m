//
//  Sniper.m
//  PixelSniper
//
//  Created by James Dailey on 1/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Sniper.h"


@implementation Sniper
- (id) initWithFile: (NSString*) s
{
	CCLOG(@"--------------Sniper init");
	self =  [super initWithFile:s];
	if (self != nil) {
		[[AppDelegate get].enemies addObject:self];
		self.type = 100;
		/*hat = [CCSprite spriteWithFile:@"indyHat.png"];
		[hat setPosition:ccp(self.contentSize.width/2,self.contentSize.height)];
		[self addChild:hat z:self.zOrder+1];
		
		face = [CCSprite spriteWithFile:@"sunglasses.png"];
		 [face setPosition:ccp(self.contentSize.width/2,self.contentSize.height-6)];
		 [self addChild:face z:self.zOrder+1];*/
	}
    return self;
}

- (void) dead
{
	CCLOG(@"Sniper Dead");
	//[self runAction: [CCFadeOut actionWithDuration:1]];
	//[hat runAction: [CCFadeOut actionWithDuration:1]];
	if ([AppDelegate get].gameType != MISSIONS)
		[[AppDelegate get].bgLayer menuAttack:CODELOSE];
	[super dead];
}

- (int) checkIfShot {
	CCLOG(@"checkifSniperShot");
	if (! self.visible)
		return 0;
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	CGPoint point = ccp(240,160);
	
	if (CGRectContainsPoint(CGRectMake(location.x,location.y+self.contentSize.height*[AppDelegate get].scale, self.contentSize.width*[AppDelegate get].scale,-self.contentSize.height*[AppDelegate get].scale), point))
		{
			//[parent.parent addBlood];
			[self addBlood];
			[self dead];
			return 2;
		}
	else {
		return 0;
	}	
}

- (int) checkIfSighted {
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	CGPoint point = ccp(240,160);
	
	if (CGRectContainsPoint(CGRectMake(location.x,location.y+self.contentSize.height*[AppDelegate get].scale, self.contentSize.width*[AppDelegate get].scale,-self.contentSize.height*[AppDelegate get].scale), point))
	{
		return 2;
	}
	return 0;
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Sniper: %i", self.tag);
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end
