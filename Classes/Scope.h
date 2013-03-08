//
//  Scope.h
//  OSL
//
//  Created by James Dailey on 2/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Scope : CCSprite <NSCoding> {
	NSString *img,*n,*d;
	int x,c,a,u;
}
@property (readwrite, nonatomic) int x,c,a,u;
@property (nonatomic, retain) NSString *n,*d,*img;

- (id) initWithFile: (NSString*) sX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX aX:(int)aX uX:(int)uX;
@end