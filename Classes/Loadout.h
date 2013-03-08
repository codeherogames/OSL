//
//  Loadout.h
//  OSL
//
//  Created by James Dailey on 3/13/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Loadout : NSObject <NSCoding> {
	int r,s,a,b,e,g,po,ac,re,s1,s2,s3,version;
}
@property (readwrite, nonatomic) int r,s,a,b,e,g,po,ac,re,s1,s2,s3,version;

- (id) init: (int)rX sX:(int)sX aX:(int)aX bX:(int)bX eX:(int)eX gX:(int)gX s1X:(int)s1X s2X:(int)s2X s3X:(int)s3X vX:(int)vX;
-(void) updateStats;
@end