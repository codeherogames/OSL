//
//  CustomPoint.h
//  PixelSnipe
//
//  Created by James Dailey on 12/28/10.
//  Copyright 2010 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CustomPoint : NSObject {
	float duration;
	CGPoint point;
	int currentState,zOrder;
	NSMutableArray *nextPoints;
	NSString *name;
}

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) int currentState,zOrder;
@property (nonatomic, retain) NSMutableArray *nextPoints;

- (id) initWithData: (float) d p:(CGPoint)p s:(int)s z:(int)z n:(NSString*)n;
- (unsigned int) randomNumberFrom: (unsigned int) minValue to: (unsigned int) maxValue;
- (id) getRandom;
- (id) getFirst;
- (id) getLast;
- (int) getCount;
@end