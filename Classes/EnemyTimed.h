//
//  EnemyTimed.h
//  OSL
//
//  Created by James Dailey on 5/15/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "CustomPoint.h"
#import "Enemy.h"

@interface EnemyTimed : Enemy {
	int doNothing;
}
-(void) nextMove;
@end
