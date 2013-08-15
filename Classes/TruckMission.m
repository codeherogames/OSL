//
//  TruckMission.m
//  OSL
//
//  Created by James Dailey on 5/16/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "TruckMission.h"


@implementation TruckMission
- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a
{
	CCLOG(@"--------------Vehicle init");
	self =  [super initWithFile:s];
	if (self != nil) {
		//[self.texture setAliasTexParameters];
		self.currentState=0;
		self.lastState=-1;
		self.duration=0.0f;
		self.type = 0;
		self.position = ccp(2000,10);
		self.lastX=-6000.0f;
		self.layerPointer = l;
		passengers =  [[NSMutableArray alloc] init];
		self.pointCount = 0;
		self.tire1 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		self.tire2 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		float posY = self.contentSize.height/4-2;
		[tire1 setPosition:ccp(self.contentSize.width/5,posY)];
		tire1.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire1 z:self.zOrder+1];
		[tire2 setPosition:ccp(self.contentSize.width-self.contentSize.width/5,posY)];
		tire2.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire2 z:self.zOrder+1];
		
		if (a != nil) {
			self.points = a;
			self.flipX = FALSE;
		}
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
			
			CCLOG(@"Count:%i",self.pointCount);
			if (self.pointCount == [self.points count]-1) {
				[[AppDelegate get].soundEngine playSound:0 sourceGroupId:0 pitch:0.6f pan:0.0f gain:DEFGAIN loop:NO];
				[self unschedule: @selector(move:)];
				[self stopAllActions];
				[self killPassenger];
				[self.layerPointer doLose];
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

- (void) addPassengers
{
	CCLOG(@"addPassengers");
	Enemy *enemy1 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CANDIDATEHAT]];
	enemy1.color = ccRED;
	//enemy1.head.color = ccBLUE;
	enemy1.type = FROMVEHICLE;
	[enemy1 setPosition:ccp(self.contentSize.width-enemy1.contentSize.width-10,self.contentSize.height/2+enemy1.contentSize.height/2.5)];
	[self reorderChild:enemy1 z:-2];
	
	
	Enemy *enemy3 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];
	enemy3.hat.color=ccBLACK;
	enemy3.color = ccRED;
	//enemy3.head.color = ccBLUE;
	enemy3.type = FROMVEHICLE;
	[enemy3 setPosition:ccp(self.contentSize.width/2-10,self.contentSize.height/2+enemy3.contentSize.height/3-6)];
	[self reorderChild:enemy3 z:-2];
	enemy3.anchorPoint=ccp(0.5,0.5);
	enemy3.customTag = 99;
	//[passengerList addObject:enemy3];
	[passengers addObject:enemy1];
	enemy1.customTag = 0;
	
	if (self.flipX == TRUE) {
		CCLOG(@"Passengers Flipx");
		enemy1.flipX = TRUE;
		enemy1.hat.flipX = TRUE;
		enemy3.flipX = TRUE;
		enemy3.hat.flipX = TRUE;
	}
}

-(void) killPassenger {
	Enemy *e = (Enemy *) [passengers lastObject];	
	[e addBlood];
	[e dead];
}

- (void) startMoving: (CGPoint) startPoint
{
	self.c = [self.points objectAtIndex:0];
	self.position = c.point;
	[self addPassengers];
	[self schedule: @selector(move:)];
}

- (void) passengerDied: (int) i
{

}

@end
