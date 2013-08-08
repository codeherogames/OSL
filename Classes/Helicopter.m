//
//  Helicopter.m
//  PixelSnipe
//
//  Created by James Dailey on 1/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Helicopter.h"

@implementation Helicopter
@synthesize myAnimation,myAction;
- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a
{
	CCLOG(@"--------------Helicopter init");
	self =  [super initWithFile:s l:l a:a];
	if (self != nil) {
		self.type = HELIC;
		driverDied = 0;
		myAnimation = [CCAnimation animation];
		for( int i=1;i<3;i++) {
			[myAnimation addFrameWithFilename: [NSString stringWithFormat:@"chopper%i.png", i]];
		}
		self.myAction = [CCAnimate actionWithDuration:0.5 animation:myAnimation restoreOriginalFrame:NO];
		[self runAction: [CCRepeatForever actionWithAction:self.myAction]];
		if ([[AppDelegate get] perkEnabled:1]) {
			self.armor = [[CCSprite spriteWithFile:@"armorall.png"] retain];
			armor.anchorPoint=ccp(0.5,0.5);
			[armor setPosition:ccp(self.contentSize.width/2,self.contentSize.height/2)];
			[self addChild:armor z:self.zOrder+20];
			armor.visible = NO;
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
			if (self.pointCount == [self.points count]) {
				[self unschedule: @selector(move:)];
				[self stopAllActions];
				if (driverDied == 0)
					[self.layerPointer launchHelicopter];
				[self dead];
			}
			lastX = c.point.x;
			pointCount++;
			c = [self.points objectAtIndex:pointCount];
			
			// Get current state
			//if (self.currentState == PAUSE && c.currentState != PAUSE)
				//[self runAction: [CCRepeatForever actionWithAction:self.myAction]];
			self.currentState = c.currentState;
			
			CCLOG(@"%@",c.name);
			
			// Pause to drop
			if (currentState == PAUSE) {
				CCLOG(@"DropOff");
				//[self stopAllActions];
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
		}
	}// Pause
}

- (void) startTow: (CGPoint) endPoint
{
	
	nextPosition=endPoint;
	self.currentState = DRIVE;
	duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
					(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / VEHICLE2RATE;
	
	CGPoint velocity = ccpSub( nextPosition, self.position );
	speedVector = ccp(velocity.x/duration,velocity.y/duration);
	elapsed = 0;
	//[emitter stopSystem];
	[self schedule: @selector(tow:)];
}

- (void) tow:(ccTime) dt
{
	elapsed += dt;
	if (elapsed >= duration)
	{
		CCLOG(@"Tow complete");
		[self unschedule: @selector(move:)];
		[self stopAllActions];
		[self dead];
		[[AppDelegate get].bgLayer menuAttack:CODESCRAPMETAL];
	}
	else
	{
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
	}
}


- (void) addPassengers
{
	Enemy *enemy1 = [[Enemy alloc] initWithFile: @"headOnly.png" l:self h:@"hat1.png"];
	enemy1.color = ccRED;
	enemy1.type = FROMHELICOPTER;
	[enemy1 setPosition:ccp(self.contentSize.width/2,self.contentSize.height/3)];
	[self reorderChild:enemy1 z:-2];
    [passengers addObject:enemy1];
	enemy1.customTag = 0;
    
    if (![[AppDelegate get] perkEnabled:40]) {
        Enemy *enemy2 = [[Enemy alloc] initWithFile: @"headOnly.png" l:self h:@"hat1.png"];
        enemy2.color = ccRED;
        enemy2.type = FROMHELICOPTER;
        enemy2.currentState = DRIVE;
        if (self.flipX == TRUE)
            [enemy2 setPosition:ccp(self.contentSize.width-(self.contentSize.width/2-24),self.contentSize.height/3)];
        else 
            [enemy2 setPosition:ccp(self.contentSize.width/2-24,self.contentSize.height/3)];
        [self reorderChild:enemy2 z:-2];
        [passengers addObject:enemy2];
        enemy2.customTag = 1;
	}
	Enemy *enemy3 = [[Enemy alloc] initWithFile: @"headOnly.png" l:self h:@"hat1.png"];
	enemy3.color = ccRED;
	enemy3.type = FROMHELICOPTER;
	enemy3.currentState = DRIVE;
	if (self.flipX == TRUE)
		[enemy3 setPosition:ccp(self.contentSize.width-58,self.contentSize.height/3+2)];
	else 
		[enemy3 setPosition:ccp(58,self.contentSize.height/3+2)];
	[self reorderChild:enemy3 z:-2];
	enemy3.anchorPoint=ccp(0.5,0.5);
	enemy3.customTag = 99;

	if (self.flipX == TRUE) {
		CCLOG(@"Passengers Flipx");
        for (Enemy *e in passengers) {
            e.flipX = TRUE;
            e.hat.flipX = TRUE;
        }
	}
	if ([[AppDelegate get] perkEnabled:1])
		[armor setPosition:enemy3.position];
}

- (void) dropOff
{
	CCLOG(@"Passenger Count %i", [passengers count]);
	if ([passengers count] == 0) {
		[self unschedule: @selector(dropOff)];
		self.currentState = DRIVE;
	}
	else {
		Enemy *e = (Enemy *) [passengers lastObject];
		[self removeChild:e cleanup:YES];
		[passengers removeLastObject];
		if (e.currentState != DEAD) {
			[[AppDelegate get].bgLayer addChild:e];
			e.customTag = -1;
			e.type = FROMHELICOPTER;
			[e startMoving:ccp(self.position.x,ROOF)];
		}	
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

- (void) passengerDied: (int) i
{
	CCLOG(@"Passenger Died %i", i);
	
	if (i == 99) {
		CCLOG(@"Driver Shot");
        // TRIFECTA or BOUNTBONUS check
        if ([AppDelegate get].gameType != SURVIVAL) {
            if ([[AppDelegate get] perkEnabled:44] && [passengers count] == 0) {
                    [AppDelegate get].money += 500;
                    [[AppDelegate get].bgLayer sendMyIntel:@"5000 Bonus"];
                    [[AppDelegate get].bgLayer sendMyIntel:@"Trifecta"];
            }
            if ([[AppDelegate get] perkEnabled:28]) {
                [AppDelegate get].money += 80;
                [[AppDelegate get].bgLayer sendMyIntel:@"800 Bonus"];
                [[AppDelegate get].bgLayer sendMyIntel:@"Bounty Bonus"];
            }
        }
		self.currentState = PAUSE;
		driverDied = 1;
		[self unschedule: @selector(move:)];
		//[self stopAllActions];
		//[self unscheduleAllSelectors];
		while ([passengers count] > 0) {
			Enemy *e = (Enemy *) [passengers lastObject];
			[self removeChild:e cleanup:YES];
			[passengers removeLastObject];
			if (e.currentState != DEAD) {
				[self launchParachute];
			}
			//[self schedule: @selector(dropOff) interval: 1];
		}
		[self fall:STREET];
	}
}

- (void) fall:(float) where
{
	[self unschedule: @selector(move:)];
	self.anchorPoint = ccp(0.5,0.5);
	[self setRotation:-20];
	c =  [[CustomPoint alloc] initWithData:FALLRATE p:ccp(self.position.x-self.contentSize.width,where) s:FALL z:ZOUT n:@"Falling"];
	CCLOG(@"%@",c.name);
	nextPosition= c.point;
	duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
					(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / c.duration;
	duration = duration * 0.5;
	//CCLOG(@"rate: %f duration: %f", c.duration, duration);
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
		//[self stopAllActions];
		[self unschedule: @selector(falling:)];
		[self stopAllActions];
		[self setRotation:0];
		/*emitter = [CCParticleSystemQuad particleWithFile:@"smoke.plist"];
		emitter.autoRemoveOnFinish = YES;
		emitter.position = ccp(self.contentSize.width*0.7,self.contentSize.height/3);
		if (self.flipX == FALSE) {
			emitter.rotation = -(emitter.rotation);
		}
		[self addChild: emitter z:-1];*/
		self.currentState = DRIVE;
		[self.layerPointer towTruck:self];
	}
	else
	{
		/*if ((int)self.position.y % 40 == 0) {
			if (self.flipX == TRUE)
				self.flipX = FALSE;
			else
				self.flipX = TRUE;
		}*/
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
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

