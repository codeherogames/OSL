//
//  Truck.h
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

@interface Truck : Vehicle {
	int driverDied;
	CCSprite *tire1, *tire2;
}
@property (nonatomic, retain) CCSprite *tire1, *tire2;
- (void) addPassengers;
- (void) startTow: (CGPoint) endPoint;
@end

