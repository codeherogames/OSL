//
//  Loadout.m
//  OSL
//
//  Created by James Dailey on 3/13/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Loadout.h"
#import "Rifle.h"
#import "Scope.h"
#import "Ammo.h"
#import "Extras.h"
#import "AppDelegate.h"

@implementation Loadout
@synthesize r,s,a,b,e,g,po,ac,re,s1,s2,s3,version;

- (id) init: (int)rX sX:(int)sX aX:(int)aX bX:(int)bX eX:(int)eX gX:(int)gX s1X:(int)s1X s2X:(int)s2X s3X:(int)s3X vX:(int)vX
{
	CCLOG(@"--------------Loadout init");
	self =  [super init];
	if (self != nil) {
		r = rX;
		s = sX;
		a = aX;
		b = bX;
		e = eX;
		g = gX;
		po = 0;
		ac = 0;
		re = 5;
		s1 = s1X;
		s2 = s2X;
		s3 = s3X;
		version = vX;
		[self updateStats];
	}
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:r forKey:@"r"];
    [encoder encodeInt:s forKey:@"s"];
    [encoder encodeInt:a forKey:@"a"];
    [encoder encodeInt:b forKey:@"b"];
    [encoder encodeInt:e forKey:@"e"];
    [encoder encodeInt:g forKey:@"g"];
	[encoder encodeInt:s1 forKey:@"s1"];
	[encoder encodeInt:s2 forKey:@"s2"];
	[encoder encodeInt:s3 forKey:@"s3"];
	[encoder encodeInt:version forKey:@"version"];
}

- (id)initWithCoder:(NSCoder *)decoder {		
	return [self init: [decoder decodeIntForKey:@"r"] sX:[decoder decodeIntForKey:@"s"] aX:[decoder decodeIntForKey:@"a"] bX:[decoder decodeIntForKey:@"b"] eX:[decoder decodeIntForKey:@"e"] gX:[decoder decodeIntForKey:@"g"] s1X:[decoder decodeIntForKey:@"s1"] s2X:[decoder decodeIntForKey:@"s2"] s3X:[decoder decodeIntForKey:@"s3"] vX:[decoder decodeIntForKey:@"version"]];
}

-(void) updateStats 
{
	Rifle *rifle = [[AppDelegate get].rifles objectAtIndex:r];
	Ammo *ammo = [[AppDelegate get].ammo objectAtIndex:a];
	Extras *extra = [[AppDelegate get].extras objectAtIndex:e];
	Scope *scope = [[AppDelegate get].scopes objectAtIndex:s];
	po = ammo.p;
	ac = scope.a;
	if (e > 0)
		ac += extra.p;
	
	if (b == 1) {
		re = 0;
		ac +=1;
	}
	else {
		re = rifle.r;
	}
	CCLOG (@"r:%i,s:%i,a:%i,b:%i,e:%i,g:%i,po:%i,ac:%i,re:%i,s1:%i,s2:%i,s3:%i,version:%i",r,s,a,b,e,g,po,ac,re,s1,s2,s3,version);
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Loadout");
	[super dealloc];
}
@end