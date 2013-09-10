//
//  Enemy.h
//  Sniper
//
//  Created by James Dailey on 11/14/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "CustomPoint.h"

@interface Enemy : CCSprite {
	int currentState,lastState,customTag,kidnapper,hits;
	float elapsed,duration;
	CGPoint nextPosition,lastPosition,speedVector;
	int type; //0:regular 1:parachuter 2:citizen 3:truck 4:plane 100:sniper
	CCAnimation *animateClimb, *animateWalk,*animateFight1;
	id actionClimb, actionWalk,actionFight1;
	CustomPoint *c;
	id LayerPointer;
	CCSprite *shooting,*hat,*parachute,*zipping,*elite,*armor,*head;
	NSString *owner;
    int dodgeLevel;
    BOOL fullAccessSet;
}

@property (readwrite, nonatomic) int currentState,lastState,type,customTag,kidnapper,hits;
@property (readwrite, nonatomic) float elapsed, duration;
@property (nonatomic, retain) CCAnimation *animateClimb, *animateWalk,*animateFight1;
@property (nonatomic, retain) id actionClimb,actionWalk,actionFight1;
@property (nonatomic, retain) id c,layerPointer;
@property (nonatomic,readwrite) CGPoint nextPosition,speedVector;
@property (nonatomic, retain) CCSprite *shooting,*parachute,*zipping,*zipPost,*elite,*armor,*head,*targetHead;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) CCSprite *hat;
@property (readwrite, nonatomic) int dodgeLevel;
@property (nonatomic, assign) BOOL fullAccessSet;

- (id) initWithFile: (NSString*) s l:(CCNode*)l h:(NSString*)h;
- (void) startMoving: (CGPoint) startPoint;
- (void) startMovingWithPoints: (NSArray*) points;
- (void) addBlood;
- (void) dead;
- (void) pause:(int)p;
- (int) checkIfShot;
- (BOOL) dodged;
- (int) checkIfSighted;
- (void) fall:(float) where;
-(void) kill;
-(void) kidnap;
-(void) startFight;
-(void) hide;
-(void) changeZ:(int)i;
@end
