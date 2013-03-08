//
//  Mission1.h
//  OSL
//
//  Created by James Dailey on 3/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "GameScene.h"
#import "EnemyM3.h"
#import "Armored.h"

@interface Mission1 : GameScene {

}
@end

@interface Mission1Layer : BackgroundLayer {
	int currentPackage,timedCount;
	NSArray *packages;
	EnemyM3 *s1,*s2,*a1,*a2,*a3;
	Armored *c1,*c2;
}
//-(void) dropPackage:(int) t;
-(void) dropPackage: (Enemy*) e;
-(void) doBomb:(CGPoint)c;
-(void) shootLeader;
-(void) doLose;
-(void) setup;
@end

@interface MissionControlLayer : ControlLayer {
	int shot, maxShot,targetsLeft;
	NSMutableArray *bullets;
}
-(void) fireButtonPressed: (id)sender;
-(void) delayLose;
-(void) delayWin;
-(void) updateTargets;
@end


