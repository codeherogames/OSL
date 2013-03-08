//
//  TowTruck.m
//  PixelSnipe
//
//  Created by James Dailey on 1/18/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "TowTruck.h"


@implementation TowTruck
@synthesize tire1, tire2;
@synthesize v,currentState,lastState,elapsed,duration,nextPosition,speedVector,type,lastX;
@synthesize c,layerPointer,points,pointCount,offsetY;
- (id) initWithFile: (NSString*) s l:(CCLayer*)l v:(Vehicle*)veh

{
	CCLOG(@"--------------Tow Truck init");
	self =  [super initWithFile:s];
	if (self != nil) {
		self.type = TRUCK;
		self.v = veh;
		self.points =  [[NSMutableArray alloc] init];
		self.currentState=0;
		self.lastState=-1;
		self.duration=0.0f;
		self.type = 0;
		self.position = ccp(2000,10);
		self.lastX=-6000.0f;	
		self.layerPointer = l;
		//[self.layerPointer addChild:self z:8];
		self.pointCount = 0;
		self.flipX=TRUE;
		self.offsetY = 12;
		
		//self.tire1 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		//self.tire2 = [[CCSprite spriteWithFile:@"tire.png"] retain];
		self.tire1 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		self.tire2 = [[CCSprite spriteWithFile:@"hubcap.png"] retain];
		float posY = self.contentSize.height/4-8;
		[tire1 setPosition:ccp(self.contentSize.width/4+2,posY)];
		tire1.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire1 z:self.zOrder+1];
		[tire2 setPosition:ccp(self.contentSize.width-self.contentSize.width/5+2,posY)];
		tire2.anchorPoint=ccp(0.5,0.5);
		[self addChild:tire2 z:self.zOrder+1];
		//[l.vehicles addObject:self];
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
		if (self.pointCount == [self.points count]) {
			[self unschedule: @selector(move:)];
			[self stopAllActions];
		}
		lastX = c.point.x;
		pointCount++;
		c = [self.points objectAtIndex:pointCount];
		
		CCLOG(@"%@",c.name);
			
		// Get current state
		self.currentState = c.currentState;
		
		CCLOG(@"%@",c.name);
		
		// Get next position
		nextPosition= c.point;
		
		if (self.currentState == LEAVE) {
			[self.v startTow: ccp(MAXX+self.contentSize.width,STREET)];
			self.currentState = DRIVE;
		}	
		duration = sqrt((self.position.x - nextPosition.x) *  (self.position.x - nextPosition.x) + 
						(self.position.y - nextPosition.y) *  (self.position.y - nextPosition.y)) / c.duration;
		CCLOG(@"rate: %f duration: %f", c.duration, duration);
		CGPoint velocity = ccpSub( nextPosition, self.position );
		speedVector = ccp(velocity.x/duration,velocity.y/duration);
	}
	else
	{
		self.position = ccp(self.position.x + (speedVector.x * dt),self.position.y + (speedVector.y * dt));
		
		if (self.position.x > lastX) {
			self.tire1.rotation+=20;
			self.tire2.rotation+=20;
		}
		else {
			self.tire1.rotation-=20;
			self.tire2.rotation-=20;
		}
	}
}

- (void) startMoving: (CGPoint) startPoint
{
	LinearPoint *start =  [[[LinearPoint alloc] initWithData:INSTANTRATE p:ccp(MAXX,STREET+10+offsetY) s:DRIVE z:ZOUT n:@"Begin Tow"] retain];
	LinearPoint *tow =  [[[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(v.position.x+self.v.contentSize.width-8,self.v.position.y+offsetY) s:DRIVE z:ZOUT n:@"Tow"] retain];
	LinearPoint *leave =  [[[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(MAXX+self.contentSize.width,STREET+10+offsetY) s:LEAVE z:ZOUT n:@"Remove"] retain];
	NSMutableArray *towPoints =  [[NSMutableArray alloc] init];
	[towPoints addObject:start];
	[towPoints addObject:tow];
	[towPoints addObject:leave];
	self.points = towPoints;
	
	self.c = [self.points objectAtIndex:0];
	self.position = c.point;
	[self schedule: @selector(move:)];
}

-(void) kill 
{
	CCLOG(@"kill towtruck");
	self.layerPointer=nil;
	[self removeAllChildrenWithCleanup:YES];
	[self unscheduleAllSelectors];
	[self stopAllActions];
	[self.parent removeChild:self cleanup:YES];
}

- (void) dealloc 
{
	[super dealloc];
}
@end
