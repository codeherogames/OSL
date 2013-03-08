//
//  Scope.m
//  OSL
//
//  Created by James Dailey on 2/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Scope.h"


@implementation Scope
@synthesize x,d,c,a,n,u,img;

- (id) initWithFile: (NSString*) sX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX aX:(int)aX uX:(int)uX
{
	CCLOG(@"--------------Scope init");
	self =  [super initWithFile:[NSString stringWithFormat:@"%@", sX]];
	if (self != nil) {
		self.img = sX;
		self.n = nX;
		self.d = dX;
		self.x = xX;
		self.c = cX;
		self.a = aX;
		self.u = uX;
	}
	
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:img forKey:@"img"];
    [encoder encodeObject:d forKey:@"d"];
    [encoder encodeInt:x forKey:@"x"];
    [encoder encodeInt:c forKey:@"c"];
    [encoder encodeInt:a forKey:@"p"];
    [encoder encodeInt:u forKey:@"u"];
    [encoder encodeObject:n forKey:@"n"];
}

- (id)initWithCoder:(NSCoder *)decoder {		
	return [self initWithFile: [decoder decodeObjectForKey:@"img"] nX:[decoder decodeObjectForKey:@"n"] dX:[decoder decodeObjectForKey:@"d"] xX:[decoder decodeIntForKey:@"x"] cX:[decoder decodeIntForKey:@"c"] aX:[decoder decodeIntForKey:@"a"] uX:[decoder decodeIntForKey:@"u"]];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Scope");
	//[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end