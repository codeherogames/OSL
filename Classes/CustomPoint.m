//
//  CustomPoint.m
//  PixelSnipe
//
//  Created by James Dailey on 12/28/10.
//  Copyright 2010 James Dailey. All rights reserved.
//

#import "CustomPoint.h"

@implementation CustomPoint
@synthesize duration, point,currentState,zOrder,name,nextPoints;

- (id) initWithData: (float) d p:(CGPoint)p s:(int)s z:(int)z n:(NSString*)n
{
    self = [super init];
	self.duration=d;
	self.point=p;
	self.currentState=s;
	self.zOrder=z;
	self.name=n;
	self.nextPoints = [[NSMutableArray alloc] init];
	
    return self;
}

- (id) getRandom
{
	if ([self.nextPoints count] == 0)
		return 0;
	int tmp = (uint)(arc4random() % [self.nextPoints count]);
	//CCLOG(@"max:%i tmp:%i",[self.nextPoints count],tmp);
	return [nextPoints objectAtIndex:tmp];
}

- (id) getFirst
{
    return [nextPoints objectAtIndex:0];
}

- (id) getLast
{
	
    return [nextPoints objectAtIndex:[self.nextPoints count]-1];
}

- (int) getCount
{	
    return [self.nextPoints count];
}

- (unsigned int) randomNumberFrom: (unsigned int) minValue to: (unsigned int) maxValue
{
	int tmp = (uint)(arc4random() % maxValue);
	//CCLOG(@"max:%i tmp:%i",maxValue,tmp);
	return tmp;
}

@end
