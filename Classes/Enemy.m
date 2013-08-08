//
//  Enemy.m
//  Sniper
//
//  Created by James Dailey on 11/14/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "Enemy.h"
#import "Vehicle.h"
#import "GameScene.h"

@implementation Enemy
@synthesize currentState,lastState,elapsed,duration,nextPosition,speedVector,type,customTag,kidnapper,hat,head;
@synthesize c,layerPointer,shooting,parachute,zipping,zipPost,owner,hits;
@synthesize actionClimb,animateClimb,actionFight1,animateFight1,actionWalk,animateWalk,elite,armor,dodgeLevel,wasInside,fullAccessSet;
//@synthesize emitter;
- (id) initWithFile: (NSString*) s l:(CCNode*)l h:(NSString*)h
{
	//CCLOG(@"--------------Enemy init");
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	self =  [super initWithFile:s];
	//self = [[[super alloc] initWithFile:@"stickman.png"] autorelease];
	if (self != nil) {
		self.layerPointer = l;
		//[self.texture setAliasTexParameters];
		self.currentState=-1;
		self.lastState=-1;
		self.duration=0.0f;
		self.type = 0;
		self.kidnapper = 0;
		self.hits = 0;
        self.dodgeLevel = 60;
		
		self.position = ccp(2000,10);
		lastPosition=self.position;
		self.customTag = -1;
		self.shooting = [[CCSprite spriteWithFile:@"shooting2.png"] retain];
		self.zipping = [[CCSprite spriteWithFile:@"climb2.png"] retain];
		self.elite = nil;
		self.wasInside = NO;
        self.fullAccessSet = NO;
        
		if ([[AppDelegate get] perkEnabled:5]) {
			self.elite = [[CCSprite spriteWithFile:@"eliteagents.png"] retain];
			elite.anchorPoint=ccp(0.5,0);
			[elite setPosition:ccp(self.contentSize.width/2,60)];
			[self addChild:elite z:self.zOrder+20];
			elite.visible = NO;
		}
		self.armor = nil;
		if ([[AppDelegate get] perkEnabled:1]) {
			self.armor = [[CCSprite spriteWithFile:@"armorall.png"] retain];
			armor.anchorPoint=ccp(0.5,0.5);
			[armor setPosition:ccp(self.contentSize.width/2,self.contentSize.height/2)];
			[self addChild:armor z:self.zOrder+20];
			armor.visible = NO;
		}	
		
		//Create climb animation
		animateClimb = [CCAnimation animation];
		for( int i=1;i<4;i++) {
			[animateClimb addFrameWithFilename: [NSString stringWithFormat:@"climb%i.png", i]];
		}
		[animateClimb addFrameWithFilename: @"climb2.png"];
		self.actionClimb = [CCAnimate actionWithDuration:1 animation:animateClimb restoreOriginalFrame:NO];

		//Create walk animation
		animateWalk = [CCAnimation animation];
		for( int i=1;i<6;i++) {
			[animateWalk addFrameWithFilename: [NSString stringWithFormat:@"walk%i.png", i]];
		}
		//[animateWalk addFrameWithFilename:@"walk2.png"];
		//id walk1 = [[CCAnimate actionWithDuration:0.8 animation:animateWalk restoreOriginalFrame:NO] retain];
		//id walk2 = [[walk1 reverse] retain];
		self.actionWalk = [CCAnimate actionWithDuration:0.8 animation:animateWalk restoreOriginalFrame:NO];	
		
		animateFight1 = [CCAnimation animation];
		for( int i=1;i<4;i++) {
			int x = i;
			if (x == 3)
				x = 1;
			[animateFight1 addFrameWithFilename: [NSString stringWithFormat:@"punch%i.png", x]];
		}
		self.actionFight1 = [CCAnimate actionWithDuration:0.6 animation:animateFight1 restoreOriginalFrame:NO];
		
		[AppDelegate get].tagCounter++;
		[self.layerPointer addChild:self z:1 tag: [AppDelegate get].tagCounter];
		[[AppDelegate get].enemies addObject:self];
		
		head = [[CCSprite spriteWithFile:@"head.png"] retain];
		head.anchorPoint=ccp(0.5,0.5);
		head.color=ccRED;
		[head setPosition:ccp(self.contentSize.width/2,self.contentSize.height-head.contentSize.height/2+2)];
		[self addChild:head z:self.zOrder+1];
		
		if (h == nil) {
			hat = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png", (arc4random() % 17)+2]];
		}
		else {
			hat = [CCSprite spriteWithFile:h];
		}
		
		if ([[AppDelegate get] perkEnabled:6] && h == @"hat1.png") { // Predator
			self.opacity=20;
			hat.color=ccBLACK;
			head.opacity=self.opacity;
		}

		if (h == @"hat1.png")
			hat.anchorPoint=ccp(0.5,0.5);
		else 
			hat.anchorPoint=ccp(0.5,0.0);
		[hat setPosition:ccp(self.contentSize.width/2,self.contentSize.height-hat.contentSize.height/2)];
		//[hat setPosition:ccp(self.contentSize.width/2,self.contentSize.height)];
		[self addChild:hat z:self.zOrder+1];
		
		/*hat.anchorPoint=ccp(0.5,0.5);
		[hat setPosition:ccp(head.contentSize.width/2,head.contentSize.height-hat.contentSize.height/2)];
		[head addChild:hat z:head.zOrder+1];*/
	}
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
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
		

		//CCLOG(@"Count:%i",[c getCount]);
		if ([c getCount] == 0) {

			if ([(BackgroundLayer*) [AppDelegate get].bgLayer hasSecurity:(self.position.x > PREZX ? 2 : 1)] && self.currentState != FIGHT) {
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
            
			// All Access
            if ([[AppDelegate get] perkEnabled:30] && self.type == CITIZEN && !fullAccessSet) {
                if ([c.description isEqualToString:@"Cbuilding1F2Elevator"] || [c.description isEqualToString:@"Cbuilding1F4Elevator"]) {
                    fullAccessSet = YES;

                    // 3rd Floor
                    CustomPoint *Cbuilding1F3Elevator = [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR4Y) s:WALK z:ZIN n:@"Cbuilding1F3Elevator"];	
                    
                    CustomPoint *nextFloor;
                    if ([c.description isEqualToString:@"Cbuilding1F4Elevator"])
                        nextFloor = [c getLast];
                    else
                        nextFloor = [c getFirst];
                    
                    [nextFloor.nextPoints addObject:Cbuilding1F3Elevator];
                     
                    CustomPoint *Cbuilding1F3Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGECITIZEN,FLOOR3Y) s:WALK z:ZIN n:@"Cbuilding1F3Right"];	
                    [Cbuilding1F3Elevator.nextPoints addObject:Cbuilding1F3Right];
                    [Cbuilding1F3Right.nextPoints addObject:Cbuilding1F3Elevator];
                    [Cbuilding1F3Elevator.nextPoints addObject:nextFloor];
                    
                    [c.nextPoints addObject:Cbuilding1F3Elevator];
                }
            }
            // Sleeper Cell Perk
            if ([[AppDelegate get] perkEnabled:34] && self.type == CITIZEN && lastPosition.y > SIDEWALK && [c.description isEqualToString:@"building1F1Door"]) {
                wasInside = YES;
            }
            // Sleeper Cell Perk
            if ([[AppDelegate get] perkEnabled:34] && self.type == CITIZEN && wasInside) {
                self.type = AGENT;
                hat = [CCSprite spriteWithFile:@"hat1.png"];
                
                if ([[AppDelegate get] perkEnabled:6]) { // Predator
                    self.opacity=20;
                    hat.color=ccBLACK;
                    head.opacity=self.opacity;
                }
                
                hat.anchorPoint=ccp(0.5,0.5);
                [hat setPosition:ccp(self.contentSize.width/2,self.contentSize.height-hat.contentSize.height/2)];
                
                c = [[[AppDelegate get].walkStartPoint objectAtIndex:0] getRandom];
            }
            else {
                c = [c getRandom];  
            }
            
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
			
			if (self.currentState == RAPPEL) {
				//Remove Line
				//[[AppDelegate get].bgLayer hideZipline];
				self.rotation=0;
			}
			// Get current state
			self.currentState = c.currentState;

			if (self.currentState == RAPPEL) {
				//Draw line
				[(BackgroundLayer*) [AppDelegate get].bgLayer showZipline];
				self.texture = self.zipping.texture;
				self.rotation=20;
			}
			if (self.currentState == CLIMB) {
				[(BackgroundLayer*) [AppDelegate get].bgLayer showRope];
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
					if ([[AppDelegate get] perkEnabled:17] || ([AppDelegate get].gameType == SURVIVAL && [AppDelegate get].currentLevel > 14)) {
						duration*=.7;
					}	
				}
				else if ([AppDelegate get].gameType == SURVIVAL) {
					if ([AppDelegate get].survivalMode == 1) {
						float durationChange = duration*.2;
						if ([[AppDelegate get] perkEnabled:2]) // Power Walker
							duration-=durationChange;
						if ((currentState == CLIMB || currentState == RAPPEL) && [[AppDelegate get] perkEnabled:22]) //strongarm
							duration-=durationChange;
					}
					if ([AppDelegate get].currentLevel > 9) {
						float newDur = [AppDelegate get].currentLevel / 10 * 0.2;
						duration -= newDur;
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

- (int) checkIfSighted {
	if (self.position.x > (ELEVATORX-20) && self.position.x < (ELEVATORX+20)) {
		return 0;
	}
	CGPoint headLoc = [head convertToWorldSpace:CGPointZero];
	CGPoint point = ccp(240,160);
	
	if(CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y, head.contentSize.width*[AppDelegate get].scale,head.contentSize.height*[AppDelegate get].scale), point))
	{
		return 2;
	}
	else if (CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y+head.contentSize.height*[AppDelegate get].scale, head.contentSize.width*[AppDelegate get].scale,-self.contentSize.height*[AppDelegate get].scale), point))
	{
		return 1;
	}
	return 0;
}

- (void) startMoving: (CGPoint) startPoint
{
	// Put Enemy at initial position
	if (self.type == PARACHUTER) {
		//CCLOG(@"Parachuter");
		// Add Parachute
		self.parachute = [CCSprite spriteWithFile:@"parachute.png"];
		//self.parachute.opacity = 255;
		self.parachute.color = ccBLUE;
		[self addChild:self.parachute z:-1];
		[self.parachute setPosition:ccp(self.contentSize.width/2,self.contentSize.height+self.contentSize.height/3)];
		CustomPoint *landingNext = [[[AppDelegate get].walkStartPoint objectAtIndex:0] getRandom];
		CustomPoint *landing =  [[CustomPoint alloc] initWithData:PARACHUTE1RATE p:ccp(ELEVATOR + ((rand() / 4294967296.0) * 800),SIDEWALK) s:PARACHUTE z:ZOUT n:@"Parachute Landing"];
		[landing.nextPoints addObject:landingNext];
		if (startPoint.y == 0) {
			self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(PARACHUTE1X + ((rand() / 4294967296.0) * 400),PARACHUTE1Y) s:PARACHUTE z:ZOUT n:@"Parachuting"] retain];
		}
		else {
			self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:PARACHUTE z:ZOUT n:@"Parachuting"] retain];
		}
		[c.nextPoints addObject:landing];
	}
	// Put Enemy at initial position
	else if (self.type == FROMVEHICLE) {
		//CCLOG(@"From Vehicle");
		CustomPoint *nextPoint = [[[AppDelegate get].walkStartPoint objectAtIndex:0] getRandom];
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:WALK z:ZOUT n:@"Exit Vehicle"] retain];
		[c.nextPoints addObject:nextPoint];
	}
	else if (self.type == FROMHELICOPTER) {
		//CCLOG(@"From Helicopter");
		/*CustomPoint *nextPoint = [[[AppDelegate get].roofStartPoint objectAtIndex:0] getRandom];
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:WALK z:ZOUT n:@"Exit Helicopter"] retain];
		[c.nextPoints addObject:nextPoint];*/
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:WALK z:ZOUT n:@"Exit Vehicle"] retain];
		CustomPoint *nextPoint = [[[AppDelegate get].roofStartPoint objectAtIndex:(arc4random() % 2)] retain];
		[c.nextPoints addObject:nextPoint];
	}
	else if (self.type == CITIZEN) {
		self.opacity=255;
		if (startPoint.x == 0 && startPoint.y == 0)
			self.c = [[[AppDelegate get].citizenStartPoint objectAtIndex:(arc4random() % 2)] retain];
		else
			self.c =  [AppDelegate get].Cbuilding1F4Elevator;
	}
	else if (self.type == JUMPER) {
		self.c = [[[AppDelegate get].jumperStartPoint objectAtIndex:0] retain];
	}
	else if (startPoint.y != 0 && startPoint.x != 0) {
		self.c =  [[[CustomPoint alloc] initWithData:INSTANTRATE p:startPoint s:WALK z:ZOUT n:@"Start at Point"] retain];
		CustomPoint *nextPoint = [[[AppDelegate get].walkStartPoint objectAtIndex:0] getRandom];
		[c.nextPoints addObject:nextPoint];
	}
	else {
		self.c = [[[AppDelegate get].walkStartPoint objectAtIndex:(arc4random() % 2)] retain];
	}
	
	//CCLOG(@"%@",c.name);
	self.position = c.point;
	//CCLOG(@"%f,%f",self.position.x,self.position.y);
	[self schedule: @selector(move:)];
}

- (void) startMovingWithPoints: (NSArray*) points
{
	self.c = [[points objectAtIndex:(arc4random() % [points count])] retain];
	//CCLOG(@"%@",c.name);
	self.position = c.point;
	//CCLOG(@"%f,%f",self.position.x,self.position.y);
	[self schedule: @selector(move:)];
}


- (void) dead
{
	[self unschedule: @selector(checkIfSighted)];
	elite.visible = FALSE;
	armor.visible = FALSE;
	//CCLOG(@"Dead: current state:%i", self.currentState);
	if (self.kidnapper==1)
		[(BackgroundLayer*) [AppDelegate get].bgLayer menuAttack:KIDNAPPERDEAD];

	// Stop Moving
	[self unschedule: @selector(move:)];
	[self stopAllActions];
	if (self.type == JUMPER)
		[(BackgroundLayer*) [AppDelegate get].bgLayer hideZipline];
	
	if (self.type == CITIZEN) {
		[(BackgroundLayer*) [AppDelegate get].bgLayer menuAttack:CODEINNOCENT];
	}
	//[self removeAllChildrenWithCleanup:YES];
	if (currentState == CLIMB) {
		[self fall:FLOOR1Y];
	}
	else if (currentState == PARACHUTE) {
		[self removeChild:parachute cleanup:YES];
		[self fall:SIDEWALK];
	}
	else if (currentState == RAPPEL) {
		[self fall:SIDEWALK];
		//Remove Line
		[(BackgroundLayer*) [AppDelegate get].bgLayer hideZipline];
	}
	//else if (currentState == DRIVE) {
		//[self fall:STREET];
	//}	
	else {
		if (customTag == -1) {
			
			if (currentState == WALK || currentState == PAUSE || currentState == FIGHT || currentState == STATIONARY) {
				if (self.flipX ==TRUE) {
					self.anchorPoint = ccp(1,0);
					//[self setRotation:-90];
					[self runAction: [CCRotateTo actionWithDuration:0.3 angle:-90]];
				}
				else {
					self.anchorPoint = ccp(0,0);
					//[self setRotation:90];
					[self runAction: [CCRotateTo actionWithDuration:0.3 angle:90]];
				}
			}
			currentState = DEAD;
			[self runAction: [CCFadeOut actionWithDuration:2]];
			for (CCSprite *p in self.children) {
				[p runAction: [CCFadeOut actionWithDuration:2]];
			}
			[self schedule: @selector(removing) interval: 2];
		}
		else {
			currentState = DEAD;
			[self runAction: [CCFadeOut actionWithDuration:0.3]];
			for (CCSprite *p in self.children) {
				[p runAction: [CCFadeOut actionWithDuration:0.3]];
			}
			[(Vehicle*) self.layerPointer passengerDied:self.customTag];
		}
	}
	
}

- (void) pause:(int) p
{
	[self stopAllActions];
	self.currentState = PAUSE;
	[self schedule: @selector(pausing) interval: p];
}

- (void) pausing
{
    [self unschedule: @selector(pausing)];
	if (currentState != DEAD && [c getCount] > 0) {
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
}

-(void) startFight {
	CCLOG(@"start fight");
	[self removeChildByTag:123 cleanup:YES];
	self.kidnapper=0;
	[AppDelegate get].kidnappers--;
	self.currentState = FIGHT;
	[(BackgroundLayer*) [AppDelegate get].bgLayer hasSecurity:(self.position.x > PREZX ? 2 : 1)];
	[self runAction: [CCRepeatForever actionWithAction:self.actionFight1]];
	if ([[AppDelegate get] perkEnabled:22]) {
		self.currentState = FIGHT;
		[self schedule: @selector(fighting) interval: 0.3];
	}
	else {
		[self schedule: @selector(fighting) interval: 3];
	}
}

- (void) fighting
{
	CCLOG(@"fighting");
	[self unschedule: @selector(fighting)];
	if (currentState != DEAD) {
		if ([(BackgroundLayer*) [AppDelegate get].bgLayer stopFight:(self.position.x > PREZX ? 2 : 1)]) {
			[self kidnap];
		}
		else {
			[self dead];
		}
	}
	else {
		[(BackgroundLayer*) [AppDelegate get].bgLayer stopFight:90+(self.position.x > PREZX ? 2 : 1)];
	}
}

-(void) kidnap {
	CCLOG(@"kidnap");
	if (currentState != DEAD) {
		self.kidnapper=1;
		[(BackgroundLayer*) [AppDelegate get].bgLayer menuAttack:SNIPERFOUND];
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
	}
}

- (void) removing
{
	self.position = ccp(-10000,-10000);
    [self unschedule: @selector(removing)];
	//[self.layerPointer removeChild:self cleanup:YES];
	//[self dealloc];
}

- (void) removingOLD
{
	if (customTag != -1) {
		[(Vehicle*) self.layerPointer passengerDied:self.customTag];
		//[self.parent passengerDied:self.customTag];
	}
    [self unschedule: @selector(removing)];
	//[self.layerPointer removeChild:self cleanup:YES];
	//[self dealloc];
}

-(void) addBlood {
	// Blood
	CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"blood.plist"];
	emitter.autoRemoveOnFinish = YES;
	emitter.position = ccp(self.position.x,self.position.y+self.contentSize.height/3);
	[self.layerPointer addChild: emitter z:self.zOrder+2];
	/*CCSprite *blood = [CCSprite spriteWithFile:@"blood.png"];
	[blood setPosition:ccp(self.contentSize.width/2,self.contentSize.height-(self.contentSize.height/4))];
	[self addChild:blood z:self.zOrder+1];*/
}

- (int) checkIfShot {
	CGPoint headLoc = [head convertToWorldSpace:CGPointZero];
	if (self.position.x > (ELEVATORX-20) && self.position.x < (ELEVATORX+20)) {
		return 0;
	}
	CGPoint point = ccp(240,160);
	if(CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y, head.contentSize.width*[AppDelegate get].scale,head.contentSize.height*[AppDelegate get].scale), point))
	{
		if (self.type != CITIZEN && [self dodged]) {
			[self pause:0.7];
			elite.visible = YES;
			[elite runAction: [CCFadeOut actionWithDuration:0.8]];
			return 0;
		}
		// Driver, armor, no BMG, 
		else if (customTag == 99 && [[AppDelegate get] perkEnabled:1] && [AppDelegate get].loadout.a != 2) {
			Vehicle *v = (Vehicle*) self.parent;
			if (v.currentState == PAUSE) {
				[self addBlood];
				[self dead];
				return 2;
			}
			else {
				v.armor.visible = YES;
				[v.armor runAction: [CCFadeOut actionWithDuration:0.8]];
				return 0;
			}
		}
		else {
			[self addBlood];
			[self dead];
			return 2;	
		}
	}
	else if (CGRectContainsPoint(CGRectMake(headLoc.x,headLoc.y+head.contentSize.height*[AppDelegate get].scale, head.contentSize.width*[AppDelegate get].scale,-self.contentSize.height*[AppDelegate get].scale), point))
	{
		if (customTag == 99 && [[AppDelegate get] perkEnabled:1] && [AppDelegate get].loadout.a != 2) {
			Vehicle *v = (Vehicle*) self.parent;
			if (v.currentState == PAUSE) {
				[self addBlood];
				[self dead];
				return 3;
			}
			else {
				v.armor.visible = YES;
				[v.armor runAction: [CCFadeOut actionWithDuration:0.8]];
				return 0;
			}
		}
		else if ([AppDelegate get].loadout.a == 2 || ([AppDelegate get].loadout.a == 1 && ![[AppDelegate get] perkEnabled:1])) { // Heavy Ammo or cheytac and no perk
			/*if ([self dodged]) {
				[self pause:0.7];
				elite.visible = YES;
				[elite runAction: [CCFadeOut actionWithDuration:0.8]];
				return 0;
			}
			else {*/
				[self addBlood];
				[self dead];
				return 3;	
			//}	
		}
		else {
			if ([[AppDelegate get] perkEnabled:1]) { // Armor
				armor.visible = YES;
				[armor runAction: [CCFadeOut actionWithDuration:0.8]];
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
			}
			return 0;
		}
	}
	else { //Missed
		return 0;
	}
}

-(BOOL) dodged {
    //1.7
	if (![[AppDelegate get] perkEnabled:5])
		return NO;
    dodgeLevel+=10;
    //return ((arc4random() % 100) > 69);
	return ((arc4random() % 100) > dodgeLevel);
}

- (void) fall:(float) where
{
	self.currentState = FALL;
	[self unschedule: @selector(move:)];
	self.anchorPoint = ccp(0,0);
	[self setRotation:90];
	c =  [[CustomPoint alloc] initWithData:FALLRATE p:ccp(self.position.x+(self.position.y-where)/10,where) s:FALL z:ZOUT n:@"Falling"];
	CCLOG(@"%@",c.name);
	nextPosition= c.point;
	duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
					(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / c.duration;
	CCLOG(@"rate: %f duration: %f", c.duration, duration);
	duration = duration * 0.5;
	CCLOG(@"rate: %f duration: %f", c.duration, duration);
	CGPoint velocity = ccpSub( nextPosition, self.position );
	speedVector = ccp(velocity.x/duration,velocity.y/duration);

	elapsed = 0;
	[self schedule: @selector(falling:)];
}


- (void) falling:(ccTime) dt
{
	elapsed += dt;
	if (elapsed >= duration)
	{
		[self stopAllActions];
		[self unschedule: @selector(falling:)];
		self.currentState = DEAD;
		//[self addBlood];
		[self dead];
	}
	else
	{
		self.rotation+=0.5;
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
	}
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


-(void) hide {
	self.position=ccp(-10000,-10000);
}

-(void) changeZ:(int)i {
	[self.parent reorderChild:self z:i];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Enemy: %i", self.tag);
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end
