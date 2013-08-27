//
//  Vehicle.m
//  Sniper
//
//  Created by James Dailey on 11/14/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle
@synthesize currentState,lastState,elapsed,duration,nextPosition,speedVector,type,lastX,passengers;
@synthesize c,layerPointer,points,pointCount,armor,passengerCount;

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
		self.armor = nil;
		
		if (a != nil) {
			int tmp = arc4random() % 2;
			if (tmp == 0 || [AppDelegate get].gameType == MISSIONS || [AppDelegate get].gameType == TUTORIAL) {
				self.points = a;
				self.flipX = FALSE;
			}
			else {
				self.points = [[a reverseObjectEnumerator] allObjects];
				self.flipX = TRUE;
			}
		}
	}
	
    return self;
}

- (void) move:(ccTime) dt
{

}

- (void) addPassengers {
	
}

- (void) startMoving: (CGPoint) startPoint
{
	self.c = [self.points objectAtIndex:0];
	self.position = c.point;
	[self addPassengers];
	if (self.position.x == MINX) {
		self.flipX = TRUE;
		for (Enemy *e in self.children) {
			e.flipX = TRUE;
			e.position = ccp(self.contentSize.width-e.position.x,e.position.y);
		}
	}
	[self schedule: @selector(move:)];
}

- (void) stopMoving {
	[self unschedule: @selector(move:)];
}

- (void) passengerDied: (int) i
{
	CCLOG(@"Passenger Died %i, count:%i", i,[passengers count]);
    // TRIFECTA or BOUNTBONUS check
    int trifectaBonus = 0;
    if ([AppDelegate get].gameType != SURVIVAL) {
        if ([[AppDelegate get] myPerk:44]) { //Trifecta
            if (passengerCount == 0) {
                if ([[AppDelegate get] perkEnabled:40]) { //Seat Taken
                    [AppDelegate get].money += 200;
                    trifectaBonus = 2000;
                    [[AppDelegate get].bgLayer showBonus:@"2000" withPerk:44];
                }
                else {
                    [AppDelegate get].money += 300;
                    trifectaBonus = 3000;
                    [[AppDelegate get].bgLayer showBonus:@"3000" withPerk:44];
                }
            }
            
        }
        if ([[AppDelegate get] myPerk:28]) { //Bounty
            [AppDelegate get].money += 80;
            [[AppDelegate get].bgLayer showBonus:[NSString stringWithFormat:@"%i",800+trifectaBonus] withPerk:28];
            
        }
    }
}

- (void) dead
{
	// Stop Moving
	[self unschedule: @selector(move:)];
	[self stopAllActions];
	[self unscheduleAllSelectors];
	[self removeAllChildrenWithCleanup:YES];
	[self.layerPointer removeChild:self cleanup:YES];
	// Put code to remove from parent
}

-(void) kill 
{
	CCLOG(@"kill vehicle");
	[self unscheduleAllSelectors];
	[self stopAllActions];
	self.layerPointer=nil;
	[self removeAllChildrenWithCleanup:YES];
	[self.parent removeChild:self cleanup:YES];
}

- (void) dealloc 
{
	//CCLOG(@"dealloc Vehicle, retain: %i",c.name, [layerPointer retainCount]);
	//CCLOG(@"dealloc Vehicle, retain2: %i",c.name, [layerPointer retainCount]);
	[super dealloc];
}
@end
