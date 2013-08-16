//
//  Stats.m
//  OSL
//
//  Created by James Dailey on 3/27/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Stats.h"
#import "cocos2d.h"

@implementation Stats
@synthesize w2,w3,w4,w2w,w3w,w4w,su,st,sa,he,tut,tg,mi,sux;

- (id) init: (int) w2X w3X:(int)w3X w4X:(int)w4X w2wX:(int)w2wX w3wX:(int)w3wX w4wX:(int)w4wX suX:(int)suX stX:(int)stX saX:(int)saX heX:(int)heX tutX:(int)tutX tgX:(int)tgX miX:(int)miX suxX:(int) suxX;
{
	CCLOG(@"--------------Stats init");
	self =  [super init];
	if (self != nil) {
		w2 = w2X;
		w3 = w3X;
		w4 = w4X;
		w2w = w2wX;
		w3w = w3wX;
		w4w = w4wX;
		su = suX;
		st = stX;
		sa = saX;
		he = heX;
		tut = tutX;
		tg = tgX;
		mi = miX;
		sux = suxX;
		//CCLOG (@"w2:%i,w3:%i,w4:%i,w2w:%i,w3w:%i,w4w:%i,su:%i,st:%i,he:%i,tut:%i,tg:%i,mi:%i,sux:%i",w2,w3,w4,w2w,w3w,w4w,su,st,he,tut,tg,mi,sux);
	}
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:w2 forKey:@"w2"];
    [encoder encodeInt:w3 forKey:@"w3"];
    [encoder encodeInt:w4 forKey:@"w4"];
    [encoder encodeInt:w2w forKey:@"w2w"];
    [encoder encodeInt:w3w forKey:@"w3w"];
    [encoder encodeInt:w4w forKey:@"w4w"];
	[encoder encodeInt:su forKey:@"su"];
	[encoder encodeInt:st forKey:@"st"];
	[encoder encodeInt:sa forKey:@"sa"];
	[encoder encodeInt:he forKey:@"he"];
	[encoder encodeInt:tut forKey:@"tut"];
	[encoder encodeInt:tg forKey:@"tg"];
	[encoder encodeInt:mi forKey:@"mi"];
	[encoder encodeInt:sux forKey:@"sux"];
}

- (id)initWithCoder:(NSCoder *)decoder {		
	return [self init: [decoder decodeIntForKey:@"w2"] w3X:[decoder decodeIntForKey:@"w3"] w4X:[decoder decodeIntForKey:@"w4"] w2wX:[decoder decodeIntForKey:@"w2w"] w3wX:[decoder decodeIntForKey:@"w3w"] w4wX:[decoder decodeIntForKey:@"w4w"] suX:[decoder decodeIntForKey:@"su"] stX:[decoder decodeIntForKey:@"st"] saX:[decoder decodeIntForKey:@"sa"] heX:[decoder decodeIntForKey:@"he"] tutX:[decoder decodeIntForKey:@"tut"] tgX:[decoder decodeIntForKey:@"tg"] miX:[decoder decodeIntForKey:@"mi"] suxX:[decoder decodeIntForKey:@"sux"]];
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Stats");
	[super dealloc];
}
@end