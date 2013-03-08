//
//  TowTruck.h
//  PixelSnipe
//
//  Created by James Dailey on 1/18/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "Vehicle.h"

@interface TowTruck : CCSprite {
	int currentState,lastState;
	float elapsed,duration,lastX,offsetY;
	CGPoint nextPosition,speedVector;
	int type; //0:truck 1:armored 2:plane 3:helicopter
	LinearPoint *c;
	id LayerPointer;
	int pointCount;
	NSArray *points;
	Vehicle *v;
	CCSprite *tire1, *tire2;
}
@property (nonatomic, retain) CCSprite *tire1, *tire2;
@property (nonatomic, retain) Vehicle *v;
@property (readwrite, nonatomic) int currentState,lastState,type,pointCount;
@property (readwrite, nonatomic) float elapsed, duration,lastX,offsetY;
@property (nonatomic, retain) id c,layerPointer;
@property (nonatomic,readwrite) CGPoint nextPosition,speedVector;
@property (nonatomic, retain) NSArray *points;

- (id) initWithFile: (NSString*) s l:(CCLayer*)l v:(Vehicle*)v;
- (void) startMoving: (CGPoint) startPoint;
-(void) kill;
@end