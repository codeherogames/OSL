//
//  Radio.m
//  PixelSniper
//
//  Created by James Dailey on 1/29/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Radio.h"


@implementation Radio
@synthesize actionMusic,animateMusic;

- (id) initWithFile: (NSString*) s l:(CCNode*)l
{
	CCLOG(@"--------------Radio init");
	self =  [super initWithFile:s];
	if (self != nil) {
		[self randomPosition];
		[l addChild:self z:3];
		self.layerPointer = l;
		[AppDelegate get].jammers++;
		//[self schedule: @selector(checkIfShot) interval: 0.1];
		[[AppDelegate get].enemies addObject:self];
		if ([AppDelegate get].gameType == MISSIONS && ([AppDelegate get].currentMission == 3 || [AppDelegate get].currentMission == 8)) {
			[self schedule: @selector(blowUp) interval: 8];
		}
	}
return self;
}		

-(void) blowUp {
	if (self.type == TARGET)
		[[AppDelegate get].bgLayer doBomb:self.position];
}

-(void) randomPosition {
	float x = 1.0 * (ELEVATORX + 80) + arc4random() % (BUILDINGDOOR-ELEVATORX-40);
	int yR = arc4random() % 5 + 1;
	float y = FLOOR1Y;
	switch (yR)
    {
	case 1: 
		y = FLOOR1Y;
		break;
	case 2: 
		y = FLOOR2Y;
		break;
	case 3: 
		y = FLOOR4Y;
		break;
	case 4: 
		y = FLOOR4Y;
		break;
	case 5: 
		y = FLOOR5Y;
		break;
	}
	CCLOG(@"Random position=%f,%f",x,y);
	self.position=ccp(x,y);
}

- (int) checkIfShot
{
	CCLOG(@"Check if jammer shot");
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	CGPoint point = ccp([[UIScreen mainScreen] bounds].size.height/2,160);
	//float myScale = 2;
	//CCLOG(@"self position %f,%f, location position %f, %f",self.position.x,self.position.y,location.x,location.y);
	if (CGRectContainsPoint(CGRectMake(location.x, location.y, self.contentSize.width*[AppDelegate get].scale, self.contentSize.height*[AppDelegate get].scale), point)) {		CCLOG(@"Radio Shot!!");
		CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"smallExplosion.plist"];
		emitter.autoRemoveOnFinish = YES;
		emitter.position = ccp(self.position.x,self.position.y);
		[self.layerPointer addChild: emitter z:self.zOrder];
		[AppDelegate get].jammers--;
		if ([AppDelegate get].jammers == 0) {
			[self unschedule:@selector(checkIfShot)];
			[[AppDelegate get].bgLayer stopAnti];
		}
		[self kill];
		return 1;
	}
	return 0;
}

-(void) kill 
{
	CCLOG(@"kill enemy");
	self.layerPointer=nil;
	[self removeAllChildrenWithCleanup:YES];
	[self unscheduleAllSelectors];
	[self stopAllActions];
	[self.parent removeChild:self cleanup:YES];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Enemy: %i", self.tag);
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end
