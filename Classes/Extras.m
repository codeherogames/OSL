//
//  Extras.m
//  OSL
//
//  Created by James Dailey on 3/10/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Extras.h"


@implementation Extras
@synthesize x,d,c,p,n,u,img;

- (id) initWithFile: (NSString*) sX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX pX:(int)pX uX:(int)uX
{
	CCLOG(@"--------------Extras init");
	self =  [super initWithFile:[NSString stringWithFormat:@"%@", sX]];
	if (self != nil) {
		self.img = sX;
		self.n = nX;
		self.d = dX;
		self.x = xX;
		self.c = cX;
		self.p = pX;
		self.u = uX;
	}
	
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:img forKey:@"img"];
    [encoder encodeObject:d forKey:@"d"];
    [encoder encodeInt:x forKey:@"x"];
    [encoder encodeInt:c forKey:@"c"];
    [encoder encodeInt:p forKey:@"p"];
    [encoder encodeInt:u forKey:@"u"];
    [encoder encodeObject:n forKey:@"n"];
}

- (id)initWithCoder:(NSCoder *)decoder {	
	return [self initWithFile: [decoder decodeObjectForKey:@"img"] nX:[decoder decodeObjectForKey:@"n"] dX:[decoder decodeObjectForKey:@"d"] xX:[decoder decodeIntForKey:@"x"] cX:[decoder decodeIntForKey:@"c"] pX:[decoder decodeIntForKey:@"p"] uX:[decoder decodeIntForKey:@"u"]];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Extras");
	//[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end