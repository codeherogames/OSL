//
//  Extras.h
//  OSL
//
//  Created by James Dailey on 3/10/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Extras : CCSprite <NSCoding> {
	NSString *img,*n,*d;
	int x,c,p,u;
}
@property (readwrite, nonatomic) int x,c,p,u;
@property (nonatomic, retain) NSString *n,*d,*img;

- (id) initWithFile: (NSString*) sX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX pX:(int)aX uX:(int)uX;

@end
