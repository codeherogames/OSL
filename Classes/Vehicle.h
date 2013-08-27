//
//  Vehicle.h
//  PixelSnipe
//
//  Created by James Dailey on 1/8/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "LinearPoint.h"
#import "Enemy.h"

@interface Vehicle : CCSprite {
	int currentState,lastState;
	float elapsed,duration,lastX;
	CGPoint nextPosition,speedVector;
	int type; //0:truck 1:armored 2:plane 3:helicopter
	LinearPoint *c;
	id LayerPointer;
	NSMutableArray *passengers;
	int pointCount;
	NSArray *points;
	CCSprite *armor;
    int passengerCount;
}

@property (readwrite, nonatomic) int currentState,lastState,type,pointCount;
@property (readwrite, nonatomic) float elapsed, duration,lastX;
@property (nonatomic, retain) id c,layerPointer;
@property (nonatomic,readwrite) CGPoint nextPosition,speedVector;
@property (nonatomic, retain) NSMutableArray *passengers;
@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) CCSprite *armor;
@property (readwrite, nonatomic) int passengerCount;

- (id) initWithFile: (NSString*) s l:(CCLayer*)l a:(NSArray*)a;
- (void) startMoving: (CGPoint) startPoint;
- (void) dead;
- (void) passengerDied: (int) i;
- (void) addPassengers;
-(void) kill;
- (void) stopMoving;
@end

