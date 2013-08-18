//
//  Plane.m
//  PixelSnipe
//
//  Created by James Dailey on 1/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Plane.h"


@implementation Plane
@synthesize passengerCount;
- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a
{
	CCLOG(@"--------------Plane init");
	self =  [super initWithFile:s l:l a:a];
	if (self != nil) {
		self.type = PLANE;
        if ([[AppDelegate get] perkEnabled:40])
            self.passengerCount = 5;
        else
            self.passengerCount = 6;
	}
    return self;
}

- (void) move:(ccTime) dt
{
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
		
		CCLOG(@"%@",c.name);
		// Parachute landed.  Remove parachute
		if (currentState == DROP) {
            if (self.pointCount <= self.passengerCount+1)
                [self launchParachute];
		}
		
		// Get current state
		self.currentState = c.currentState;
		
		// Get next position
		nextPosition= c.point;
		
		duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
						(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / c.duration;
		if ([[AppDelegate get] perkEnabled:23]) {
			duration*=.8;
		}
		CCLOG(@"rate: %f duration: %f", c.duration, duration);
		CGPoint velocity = ccpSub( nextPosition, self.position );
		speedVector = ccp(velocity.x/duration,velocity.y/duration);
	}
	else
	{
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
	}
}

- (void) launchParachute
{
	CCLOG(@"Launch Parachute");
	Enemy *enemy = [[Enemy alloc] initWithFile: @"parachuteguy.png" l:self.layerPointer h:@"hat1.png"];
	[enemy setType:PARACHUTER];
	//enemy.opacity = 255;
	enemy.color = ccRED;
	[enemy startMoving:ccp(self.position.x,self.position.y-self.contentSize.height)];
}

- (void) dead
{
	[super dead];
	// Put code to remove from parent
}

- (void) dealloc 
{
	[super dealloc];
}
@end
