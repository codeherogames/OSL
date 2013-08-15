//
//  Armored.m
//  PixelSnipe
//
//  Created by James Dailey on 1/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Armored.h"


@implementation Armored
@synthesize passengerCount,tire1, tire2;
- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a

{
	CCLOG(@"--------------Armored init");
	self =  [super initWithFile:s l:l a:a];
	if (self != nil) {
		self.type = ARMOR;
        if ([[AppDelegate get] perkEnabled:40])
            self.passengerCount = 1;
        else
            self.passengerCount = 2;
		//self.tire1 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		//self.tire2 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		self.tire1 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		self.tire2 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		float posY = self.contentSize.height/4-2;
		[tire1 setPosition:ccp(self.contentSize.width/5+7,posY)];
		tire1.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire1 z:self.zOrder+1];
		[tire2 setPosition:ccp(self.contentSize.width-self.contentSize.width/5+5.3,posY)];
		tire2.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire2 z:self.zOrder+1];
	}
    return self;
}

- (void) move:(ccTime) dt
{
  if (self.currentState != PAUSE) {
	elapsed += dt;
	if (elapsed >= duration)
	{
		elapsed = 0;
		// In case there were too many frame drops and enemy got ahead
		//self.position = ccp(nextPosition.x,nextPosition.y);
		
		
		CCLOG(@"Count:%i",self.pointCount);
		if (self.pointCount == [self.points count]-1) {
			[self unschedule: @selector(move:)];
			[self stopAllActions];
			[self dead];
            return;
		}
		lastX = c.point.x;
		pointCount++;
		c = [self.points objectAtIndex:pointCount];		
		
		// Get current state
		self.currentState = c.currentState;
		
		CCLOG(@"%@",c.name);
		// Pause to drop
		if (currentState == PAUSE) {
			CCLOG(@"DropOff");
			[self stopAllActions];
			[self schedule: @selector(dropOff) interval: 1];
		}
		else {
			// Get next position
			nextPosition= c.point;
		}
		
		duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
						(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / VEHICLE2RATE;
		duration = duration * 0.8;
		if ([[AppDelegate get] perkEnabled:23]) {
			duration*=.8;
		}
		CCLOG(@"rate: %f duration: %f", VEHICLE2RATE, duration);
		CGPoint velocity = ccpSub( nextPosition, self.position );
		speedVector = ccp(velocity.x/duration,velocity.y/duration);
	}
	else
	{
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
		if (self.flipX == TRUE) {
			self.tire1.rotation+=20;
			self.tire2.rotation+=20;
		}
		else {
			self.tire1.rotation-=20;
			self.tire2.rotation-=20;
		}
	}
  }// Pause
}

- (void) dropOff
{
	Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self.layerPointer h:@"hat1.png"];
	enemy.color = ccRED;
	enemy.type = 3;
	[enemy startMoving:ccp(self.position.x,self.position.y)];
	passengerCount--;
	if (passengerCount == 0) {
		[self unschedule: @selector(dropOff)];
		self.currentState = DRIVE;
	}
}

- (void) dead
{
	[super dead];
}

- (void) dealloc 
{
	[super dealloc];
}
@end
