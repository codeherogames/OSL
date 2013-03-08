//
//  Helicopter.h
//  PixelSnipe
//
//  Created by James Dailey on 1/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "CustomPoint.h"
#import "Enemy.h"
#import "Vehicle.h"

@interface Helicopter : Vehicle {
	int driverDied;
	CCAnimation *myAnimation;
	id myAction;
	//CCParticleSystemQuad *emitter;
}
@property (nonatomic, retain) CCAnimation *myAnimation;
@property (nonatomic, retain) id myAction;

- (void) addPassengers;
- (void) startTow: (CGPoint) endPoint;
- (void) launchParachute;
- (void) fall:(float) where;
@end

