//
//  Perk.h
//  OSL
//
//  Created by James Dailey on 3/15/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface Perk : CCSprite <NSCoding,CCTargetedTouchDelegate> {
	NSString *img,*n,*d;
	int x,c,s,m;
	CGRect rect;
	//CCSprite *highlight;
}
@property (readwrite, nonatomic) int x,c,s,m;
@property (nonatomic, retain) NSString *n,*d,*img;
@property(nonatomic, readonly) CGRect rect;

-(void) reset;
-(void) showHighlight;
- (id) initWithFile: (NSString*) iX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX sX:(int)sX mX:(int)mX;
@end
