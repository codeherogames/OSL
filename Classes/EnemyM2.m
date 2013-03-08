//
//  EnemyM2.m
//  OSL
//
//  Created by James Dailey on 5/18/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "EnemyM2.h"


@implementation EnemyM2
/*- (id) initWithFile: (NSString*) s l:(CCNode*)l h:(NSString*)h
{

	self =  [super initWithFile:s];

}	*/
-(void) kidnap {
	CCLOG(@"kidnap");
	if (c.name == @"shootLeft")
		self.flipX = TRUE;
	else 
		self.flipX = FALSE;
	hat.flipX = self.flipX;
	self.kidnapper=1;
	[self stopAllActions];
	self.texture = self.shooting.texture;
	self.textureRect = self.shooting.textureRect;
	CCSprite *g = [CCSprite spriteWithFile:@"gun.png"];
	[self addChild:g z:-1 tag:123];
	g.flipX=self.flipX;
	if (self.flipX == TRUE) {
		[g setPosition:ccp(self.contentSize.width-4,self.contentSize.height/2+2)];
	}
	else {
		[g setPosition:ccp(4,self.contentSize.height/2+2)];
	}
	[[AppDelegate get].bgLayer shootLeader];
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
			
			
			//CCLOG(@"Count:%i",[c getCount]);
			if ([c getCount] == 0) {
				
				if ([[AppDelegate get].bgLayer hasSecurity:(self.position.x > PREZX ? 2 : 1)] && self.currentState != FIGHT) {
					CCLOG(@"start fight");
					if ([[AppDelegate get] perkEnabled:22]) {
						self.currentState = FIGHT;
						[self schedule: @selector(fighting) interval: 0.5];
					}
					else {
						self.currentState = FIGHT;
						[self schedule: @selector(fighting) interval: 3];
					}
				}
				else {
					[self kidnap];
				}
				[self unschedule: @selector(move:)];
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
				
				//CCLOG(@"%@",c.name);
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
					/*if (c.zOrder != ZNONE) {
						[self.parent reorderChild:self z:c.zOrder];
					}*/
					
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
						if ((currentState == CLIMB || currentState == RAPPEL) && [[AppDelegate get] perkEnabled:22]) //strongarm
							duration-=durationChange;
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
			[self changeZ:10000-self.position.y];
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

@end
