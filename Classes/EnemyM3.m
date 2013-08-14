//
//  EnemyM3.m
//  OSL
//
//  Created by James Dailey on 5/18/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "EnemyM3.h"
@implementation EnemyM3

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
					[self hide];
					[[AppDelegate get].bgLayer sendVehicles];
				}
				else {
					CCSprite *newguy = [CCSprite spriteWithFile:@"stand.png"];
					self.texture = newguy.texture;
					self.textureRect = newguy.textureRect;
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
				if ([AppDelegate get].gameType != MISSIONS) {
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
				}
				
				CCLOG(@"%@",c.name);
				// Parachute landed.  Remove parachute
				if (currentState == PARACHUTE && c.currentState != PARACHUTE) {
					self.type = AGENT;
					[self removeChild:parachute cleanup:YES];
				}
				
				// Get current state
				self.currentState = c.currentState;
				
				/*if (self.currentState == ELEVATOR) {
				 self.visible = NO;
				 }
				 else {
				 self.visible = YES;
				 }		*/

				if (self.currentState == CLIMB) {
					[[AppDelegate get].bgLayer showRope];
				}
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
						if ([[AppDelegate get] perkEnabled:17]) {
							duration*=.7;
						}	
					}
					else {
						float durationChange = duration*.2;
						if ([[AppDelegate get] perkEnabled:2]) // Power Walker
							duration-=durationChange;
						if ([[AppDelegate get] perkEnabled:20]) // Yield
							duration+=durationChange;
						if (currentState == CLIMB && [[AppDelegate get] perkEnabled:22]) //strongarm
							duration-=durationChange;
					}
					
					if ([AppDelegate get].currentMission == 8)
						duration*=.7;
					
					//CCLOG(@"rate: %f duration: %f", c.duration, duration);
					CGPoint velocity = ccpSub( nextPosition, self.position );
					speedVector = ccp(velocity.x/duration,velocity.y/duration);
					
					if (currentState == KNEEL) {
						CCSprite *newguy = [CCSprite spriteWithFile:@"kneel.png"];
						self.texture = newguy.texture;
						self.textureRect = newguy.textureRect;
						[[AppDelegate get].bgLayer dropPackage:self];
					}
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
			/*else if (currentState == KNEEL) {
				[self.layerPointer dropPackage:self.type];
			}*/
			lastState = currentState;
		}
	}// Pause
}

- (void) startMovingWithPoints: (NSArray*) points
{
	
	self.c = [[points objectAtIndex:(arc4random() % [points count])] retain];
	//CCLOG(@"%@",c.name);
	//self.position = c.point;
	//CCLOG(@"%f,%f",self.position.x,self.position.y);
	
}

- (void) pausing
{
	CCLOG(@"unpausing");
	CCLOG(@"unpausing current state %i",self.currentState);
    [self unschedule: @selector(pausing)];
	if (currentState != DEAD) {
		self.currentState = self.lastState;
		if (currentState == CLIMB) {
			self.flipX =FALSE;
			hat.flipX=self.flipX;
			[self runAction: [CCRepeatForever actionWithAction:self.actionClimb]];
		}
		else if (currentState == WALK) {
			[self runAction: [CCRepeatForever actionWithAction:self.actionWalk]];			
		}
	}
	CCLOG(@"unpausing current state %i",self.currentState);
}

- (int) checkIfShot {
	CGPoint headLoc = [head convertToWorldSpace:CGPointZero];
	if (self.position.x > (ELEVATORX-20) && self.position.x < (ELEVATORX+20)) {
		return 0;
	}
	CGPoint point = ccp([[UIScreen mainScreen] bounds].size.height/2,[[UIScreen mainScreen] bounds].size.width/2);
	if(CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y, head.contentSize.width*[AppDelegate get].scale,head.contentSize.height*[AppDelegate get].scale), point))
	{
		if ([self dodged]) {
			elite.visible = YES;
			[elite runAction: [CCFadeOut actionWithDuration:0.8]];
			return 0;
		}
		else {
			[self addBlood];
			[self dead];
			return 2;	
		}
	}
	else if (CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y+head.contentSize.height*[AppDelegate get].scale, head.contentSize.width*[AppDelegate get].scale,-self.contentSize.height*[AppDelegate get].scale), point))
	{
		if ([AppDelegate get].loadout.a == 2 || ([AppDelegate get].loadout.a == 1 && ![[AppDelegate get] perkEnabled:1])) { // Heavy Ammo or cheytac and no perk
			if ([self dodged]) {
				[self pause:0.7];
				elite.visible = YES;
				[elite runAction: [CCFadeOut actionWithDuration:0.8]];
				return 0;
			}
			else {
				[self addBlood];
				[self dead];
				return 3;	
			}	
		}
		else {
			if ([AppDelegate get].currentMission == 8) { // Armor
			}
			else { //if (self.currentState == WALK || currentState == CLIMB) {
				self.hits++;
				if (self.hits > 2) {
					[self addBlood];
					[self dead];
					return 3;
				}
				CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"blood.plist"];
				emitter.autoRemoveOnFinish = YES;
				emitter.position = ccp(self.position.x,self.position.y-self.contentSize.height/3);
				[self.layerPointer addChild: emitter z:self.zOrder+2 tag:678];
				if (self.currentState != PARACHUTE && self.kidnapper != 1 && self.currentState != FIGHT) {
					if (self.currentState == WALK) {
						CCSprite *newguy = [CCSprite spriteWithFile:@"kneel.png"];
						self.texture = newguy.texture;
						self.textureRect = newguy.textureRect;
					}
					//[self removeChildByTag:123 cleanup:YES];
					[self pause:3];
				}
				if (self.hits > 0) {
					return -3;
				}
			}
			return 0;
		}
	}
	else { //Missed
		return 0;
	}
}

-(void) forceMove {
	[self schedule: @selector(move:)];
}

@end
