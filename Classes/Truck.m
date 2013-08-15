//
//  Truck.m
//  PixelSnipe
//
//  Created by James Dailey on 1/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Truck.h"

@implementation Truck
@synthesize tire1, tire2;
- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a
{
	CCLOG(@"--------------Truck init");
	self =  [super initWithFile:s l:l a:a];
	if (self != nil) {
		self.type = TRUCK;
		driverDied = 0;
        self.pointCount = 0;
		//self.tire1 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		//self.tire2 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		self.tire1 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		self.tire2 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		float posY = self.contentSize.height/4-2;
		[tire1 setPosition:ccp(self.contentSize.width/5,posY)];
		tire1.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire1 z:self.zOrder+1];
		[tire2 setPosition:ccp(self.contentSize.width-self.contentSize.width/5,posY)];
		tire2.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire2 z:self.zOrder+1];
		
		if ([[AppDelegate get] perkEnabled:1]) {
			self.armor = [[CCSprite spriteWithFile:@"armorall.png"] retain];
			armor.anchorPoint=ccp(0.5,0.5);
			[armor setPosition:ccp(self.contentSize.width/2,self.contentSize.height/2)];
			[self addChild:armor z:self.zOrder+20];
			armor.visible = NO;
		}
        
        for (int i=0;i<self.points.count;i++) {
            CustomPoint *p = [self.points objectAtIndex:i];
            CCLOG(@"point%i:%f,%f",i,p.point.x,p.point.y);
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
			
			CCLOG(@"Count:%i",pointCount);
            CCLOG(@"PointsCount:%i",[self.points count]);
			if (pointCount == [self.points count]-1) {
				[self unschedule: @selector(move:)];
				[self stopAllActions];
				if (driverDied == 0)
					[self.layerPointer launchTruck];
				[self dead];
                return;
			}
			lastX = c.point.x;
			pointCount++;
            //CCLOG(@"point%i:%f,%f",i,p.point.x,p.point.y);
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

- (void) startTow: (CGPoint) endPoint
{

	nextPosition=endPoint;
	self.currentState = DRIVE;
	duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
					(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / VEHICLE2RATE;

	CGPoint velocity = ccpSub( nextPosition, self.position );
	speedVector = ccp(velocity.x/duration,velocity.y/duration);
	elapsed = 0;
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

	}
	else
	{
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
		self.tire1.rotation+=20;
		self.tire2.rotation+=20;
	}
}

- (void) addPassengers
{
	Enemy *enemy1 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];
	enemy1.color = ccRED;
	enemy1.type = FROMVEHICLE;
	[enemy1 setPosition:ccp(self.contentSize.width-enemy1.contentSize.width-10,self.contentSize.height/2+enemy1.contentSize.height/2.5)];
	[self reorderChild:enemy1 z:-2];

	Enemy *enemy2 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];
	enemy2.color = ccRED;
	enemy2.type = FROMVEHICLE;
	[enemy2 setPosition:ccp(self.contentSize.width-(enemy2.contentSize.width-10*2),self.contentSize.height/2+enemy2.contentSize.height/2.5)];
	[self reorderChild:enemy2 z:-2];

	Enemy *enemy3 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];
	enemy3.color = ccRED;
	enemy3.type = FROMVEHICLE;
	[enemy3 setPosition:ccp(self.contentSize.width/2-10,self.contentSize.height/2+enemy3.contentSize.height/3-6)];
	[self reorderChild:enemy3 z:-2];
	enemy3.anchorPoint=ccp(0.5,0.5);
	enemy3.customTag = 99;
	//[passengerList addObject:enemy3];
	[passengers addObject:enemy1];
	enemy1.customTag = 0;
	[passengers addObject:enemy2];
	enemy2.customTag = 1;
	
	if (self.flipX == TRUE) {
		CCLOG(@"Passengers Flipx");
		enemy1.flipX = TRUE;
		enemy1.hat.flipX = TRUE;
		enemy2.flipX = TRUE;
		enemy2.hat.flipX = TRUE;
		enemy3.flipX = TRUE;
		enemy3.hat.flipX = TRUE;
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
		if (driverDied == 1)
			[self.layerPointer towTruck:self];
	}
	else {
		Enemy *e = (Enemy *) [passengers lastObject];
		[self removeChild:e cleanup:YES];
		[passengers removeLastObject];
		
		if (e.currentState != DEAD) {
			[[AppDelegate get].bgLayer addChild:e];
			e.type = FROMVEHICLE;
			e.customTag = -1;
			[e startMoving:ccp(self.position.x,self.position.y)];
			
		}	
	}
}

- (void) passengerDied: (int) i
{
	CCLOG(@"Passenger Died %i", i);
	
	if (i == 99) {
		CCLOG(@"Driver Shot");
		self.currentState = PAUSE;
		driverDied = 1;
		[self unschedule: @selector(move:)];
		[self stopAllActions];
		[self unscheduleAllSelectors];
		if ([passengers count] > 0)
			[self schedule: @selector(dropOff) interval: 1];
		else {
			[self.layerPointer towTruck:self];
		}
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
