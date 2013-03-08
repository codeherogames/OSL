//
//  Rifle.m
//  OSL
//
//  Created by James Dailey on 2/16/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Rifle.h"


@implementation Rifle
@synthesize x,d,c,r,n,u,img;

- (id) initWithFile: (NSString*) sX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX rX:(int)rX uX:(int)uX
{
	CCLOG(@"--------------Rifle init");
	self =  [super initWithFile:sX];
		if (self != nil) {
			self.img = sX;
			self.n = nX;
			self.d = dX;
			self.x = xX;
			self.c = cX;
			self.r = rX;
			self.u = uX;
		}

    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:img forKey:@"img"];
    [encoder encodeObject:d forKey:@"d"];
    [encoder encodeInt:x forKey:@"x"];
    [encoder encodeInt:c forKey:@"c"];
    [encoder encodeInt:r forKey:@"r"];
    [encoder encodeInt:u forKey:@"u"];
    [encoder encodeObject:n forKey:@"n"];
}

- (id)initWithCoder:(NSCoder *)decoder {		
	return [self initWithFile: [decoder decodeObjectForKey:@"img"] nX:[decoder decodeObjectForKey:@"n"] dX:[decoder decodeObjectForKey:@"d"] xX:[decoder decodeIntForKey:@"x"] cX:[decoder decodeIntForKey:@"c"] rX:[decoder decodeIntForKey:@"r"] uX:[decoder decodeIntForKey:@"u"]];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Rifle");
	//[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end
