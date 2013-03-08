//
//  EnemyParatrooper.m
//  OSL
//
//  Created by James Dailey on 5/20/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "EnemyParatrooper.h"

@implementation EnemyParatrooper
- (void) move:(ccTime) dt
{
	if (self.currentState != PAUSE) {
		elapsed += dt;
		if (elapsed >= duration)
		{
			elapsed = 0;
			// In case there were too many frame drops and enemy got ahead
			//self.position = ccp(nextPosition.x,nextPosition.y);
			
			
			//CCLOG(@"Count:%i",[c getCount]);
			if ([c getCount] == 0) {				
				[self unschedule: @selector(move:)];
				[self stopAllActions];
				if (type == TARGET) {
					//[self hide];
					//[[AppDelegate get].bgLayer doLose];
					[self.layerPointer doBomb:self.position];
				}
			}
			else {
				lastPosition = c.point;
				
				/*if ([AppDelegate get].elite)
				 c = [c getFirst];
				 else */
				c = [c getRandom];
				//CCLOG(@"lastpos.y:%f,c.point.y:%f",lastPosition.y,c.point.y);
				
				//CCLOG(@"lastPosition.x:%f c.point.x:%f",lastPosition.x,c.point.x);
				if (lastPosition.x < c.point.x) {
					self.flipX =TRUE;
					for (CCSprite *e in self.children) {
						e.flipX = self.flipX;
						e.position = ccp(e.position.x,e.position.y);
					}
				}
				else {
					self.flipX =FALSE;
					//hat.flipX=self.flipX;
					for (CCSprite *e in self.children) {
						e.flipX = self.flipX;
						e.position = ccp(self.contentSize.width-e.position.x,e.position.y);
					}
				}

				//if ([AppDelegate get].gameType != MISSIONS) {
					if (c.currentState == PARACHUTE) {
						hat.rotation=-30;
					}
					else if (lastPosition.y < c.point.y) {
						hat.rotation=30;
					}
					else if (lastPosition.y > c.point.y) {
						hat.rotation=-30;
					}
					else {
						hat.rotation=0;
					}
					if (self.flipX)
						hat.rotation=-hat.rotation;
					//CCLOG(@"rotation:%f",head.rotation);
				//}
				
				//CCLOG(@"%@",c.name);
				// Parachute landed.  Remove parachute
				if (currentState == PARACHUTE && c.currentState != PARACHUTE) {
					[self removeChild:parachute cleanup:YES];
				}
				
				// Get current state
				self.currentState = c.currentState;
				
				// If not paused
				if (self.currentState != PAUSE) {
					// Get next position
					nextPosition= c.point;
					
					// Get new z if needed
					if (c.zOrder != ZNONE) {
						[self.parent reorderChild:self z:c.zOrder];
					}
					duration = (sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
									 (self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / c.duration);
					
					//Perk checks
					if (currentState == PARACHUTE) {
						if ([AppDelegate get].currentMission == 10) {
							duration*=.7;
						}	
					}
					
					//CCLOG(@"rate: %f duration: %f", c.duration, duration);
					CGPoint velocity = ccpSub( nextPosition, self.position );
					speedVector = ccp(velocity.x/duration,velocity.y/duration);
					
				}
				else {
					//// TODO: Add stand still image and duration
					nextPosition = self.position;
				}
			}
		}
		else
		{
			self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
		}

		// Handle animations
		//CCLOG(@"Current State: %i Last State: %i", currentState, lastState);
		if (lastState != currentState) {
			[self stopAllActions];
			if (currentState == CLIMB) {
				self.flipX =FALSE;
				hat.flipX=self.flipX;
				[self runAction: [CCRepeatForever actionWithAction:self.actionClimb]];
			}
			else if (currentState == WALK) {
				[self runAction: [CCRepeatForever actionWithAction:[CCSequence actions: self.actionWalk,[self.actionWalk reverse],nil]]];			
			}
			else if (currentState == FIGHT) {
				[self runAction: [CCRepeatForever actionWithAction:self.actionFight1]];	
			}
			lastState = currentState;
		}
		
	}// Pause
}

- (void) startMoving: (CGPoint) startPoint
{
	//CCLOG(@"Parachuter");
	// Add Parachute
	self.parachute = [CCSprite spriteWithFile:@"parachute.png"];
	//self.parachute.opacity = 255;
	self.parachute.color = ccBLUE;
	[self addChild:self.parachute z:-1];
	[self.parachute setPosition:ccp(self.contentSize.width/2,self.contentSize.height+self.contentSize.height/3)];
	CustomPoint *landingNext;
	int idx = (uint) arc4random() % 3;
	if (idx == 0)
		landingNext= [[CustomPoint alloc] initWithData:WALKRATE p:ccp(200,-20) s:WALK z:ZOUT n:@"Enter Building"];
	else if (idx == 1)
		landingNext= [[CustomPoint alloc] initWithData:WALKRATE p:ccp(400,-34) s:WALK z:ZOUT n:@"Enter Building"];
	else
		landingNext= [[CustomPoint alloc] initWithData:WALKRATE p:ccp(0,-34) s:WALK z:ZOUT n:@"Enter Building"];
	
	CustomPoint *landing =  [[CustomPoint alloc] initWithData:PARACHUTE1RATE p:ccp((ELEVATOR-200) + ((rand() / 4294967296.0) * 1000),SIDEWALK+30) s:PARACHUTE z:ZOUT n:@"Parachute Landing"];
	[landing.nextPoints addObject:landingNext];
	if (startPoint.y == 0) {
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(PARACHUTE1X + ((rand() / 4294967296.0) * 400),PARACHUTE1Y) s:PARACHUTE z:ZOUT n:@"Parachuting"] retain];
	}
	else {
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:PARACHUTE z:ZOUT n:@"Parachuting"] retain];
	}
	[c.nextPoints addObject:landing];
	self.position = c.point;
	//CCLOG(@"%f,%f",self.position.x,self.position.y);
	[self schedule: @selector(move:)];
}

@end
