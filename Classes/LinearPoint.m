//
//  LinearPoint.m
//  OSL
//
//  Created by James Dailey on 2/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "LinearPoint.h"


@implementation LinearPoint
@synthesize duration, point,currentState,zOrder,name;

- (id) initWithData: (float) d p:(CGPoint)p s:(int)s z:(int)z n:(NSString*)n
{
    self = [super init];
	self.duration=d;
	self.point=p;
	self.currentState=s;
	self.zOrder=z;
	self.name=n;
    return self;
}

@end
