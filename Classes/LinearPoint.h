//
//  LinearPoint.h
//  OSL
//
//  Created by James Dailey on 2/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LinearPoint : NSObject {
	float duration;
	CGPoint point;
	int currentState,zOrder;
	NSString *name;
}
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) int currentState,zOrder;

- (id) initWithData: (float) d p:(CGPoint)p s:(int)s z:(int)z n:(NSString*)n;
@end