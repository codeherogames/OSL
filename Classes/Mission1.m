//
//  Mission1.m
//  OSL
//
//  Created by James Dailey on 3/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Mission1.h"
#import "MissionScene.h"
#import "PopupLayer.h"
#import "TruckMission.h"
#import "BombTruck.h"
#import "LinearPoint.h"
#import "WinScene.h"
#import "LoseScene.h"
#import "Sniper.h"
#import "EnemyM2.h"
#import "Radio.h"
#import "EnemyParatrooper.h"

enum {
	kBackgroundLayer = 5000,
	kMidgroundLayer = 5001,
	kForegroundLayer = 5002,	
	kScopeLayer = 5003,
	kControlLayer = 5004,
	kBackdropLayer = 5005,
	kPauseLayer = 5006,
	kButtonMenu = 6000,
};

@implementation Mission1
- (id) init {
    self = [super init];
    if (self != nil) {
		//[AppDelegate get].scale = 1.0f;
		//[AppDelegate get].reload = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		//[AppDelegate get].currentMission = 8;
    }
    return self;
}

-(void) addLayers {
	[self addChild:[MissionControlLayer node] z:5 tag:kControlLayer];
	[self addChild:[Mission1Layer node] z:1 tag:kBackgroundLayer];
	[self addChild:[ScopeLayer node] z:4 tag:kScopeLayer];
	[AppDelegate get].bgLayer = (Mission1Layer*) [self getChildByTag:kBackgroundLayer];
	
}

@end

@implementation Mission1Layer
- (id) init {
    self = [super init];
    if (self != nil) {
		//CGSize s = [[CCDirector sharedDirector] winSize];
		[self setScale:[AppDelegate get].scale];
	}
    return self;
}	

-(void) setup {
	CGSize s = [[CCDirector sharedDirector] winSize];
	if ([AppDelegate get].lowRes == 1)
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	CCSprite *building = [CCSprite spriteWithFile:@"adminbuilding.png"];
	[building setPosition:ccp(s.width/2,s.height/2)];	
	[self addChild:building z:1];
	if ([AppDelegate get].lowRes == 1)
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	CCSprite *sky = [CCSprite spriteWithFile:@"w1px.png"];
	[sky setPosition:ccp(building.position.x,building.position.y+400)];	
	[sky setScaleY:900];
	[sky setScaleX:self.contentSize.width*6];
	sky.color= ccc3(184,230,248);
	[self addChild:sky z:0];
	
	CCSprite *grass = [CCSprite spriteWithFile:@"w1px.png"];
	[grass setPosition:ccp(building.position.x,building.position.y-160)];	
	[grass setScaleY:300];
	[grass setScaleX:self.contentSize.width*6];
	grass.color= ccc3(89,133,39);
	[self addChild:grass z:0];
	
	CCSprite *grass2 = [CCSprite spriteWithFile:@"w1px.png"];
	[grass2 setPosition:ccp(building.position.x,building.position.y-700)];	
	[grass2 setScaleY:300];
	[grass2 setScaleX:self.contentSize.width*6];
	grass2.color= ccc3(89,133,39);
	[self addChild:grass2 z:0];
	
	int startX = -1000;
	for (int i=0; i<16;i++) {
		CCSprite *tree = [CCSprite spriteWithFile:@"tree.png"];
		tree.scale = 2;
		float randX = startX + i * (tree.contentSize.width*2);
		float randY = arc4random() % 100;
		[tree setPosition:ccp(randX,building.position.y-100+randY)];	
		[self addChild:tree z:0];
	}
	
	CCSprite *street = [CCSprite spriteWithFile:@"w1px.png"];
	[street setPosition:ccp(building.position.x,building.position.y-building.contentSize.height/2-180)];	
	[street setScaleY:300];
	[street setScaleX:self.contentSize.width*6];
	street.color= ccc3(79,79,79);
	[self addChild:street z:0];
	
	CCSprite *sidewalkEdge = [CCSprite spriteWithFile:@"w1px.png"];
	[sidewalkEdge setPosition:ccp(building.position.x,building.position.y-building.contentSize.height/2-28)];	
	[sidewalkEdge setScaleY:16];
	[sidewalkEdge setScaleX:self.contentSize.width*6];
	sidewalkEdge.color= ccc3(154,154,154);
	[self addChild:sidewalkEdge z:0];
	
	CCSprite *sidewalk = [CCSprite spriteWithFile:@"w1px.png"];
	[sidewalk setPosition:ccp(building.position.x,building.position.y-building.contentSize.height/2-12)];	
	[sidewalk setScaleY:26];
	[sidewalk setScaleX:self.contentSize.width*6];
	sidewalk.color= ccc3(193,193,193);
	[self addChild:sidewalk z:0];
	
	CCSprite *sidewalk2 = [CCSprite spriteWithFile:@"w1px.png"];
	[sidewalk2 setPosition:ccp(building.position.x,building.position.y-building.contentSize.height/2-310)];	
	[sidewalk2 setScaleY:36];
	[sidewalk2 setScaleX:self.contentSize.width*6];
	sidewalk2.color= ccc3(193,193,193);
	[self addChild:sidewalk2 z:0];
	
	CCLOG(@"Current mission: %i",[AppDelegate get].currentMission);
	
	float winX[] = {-114,-44,30,370,446,520};
	float winY[] = {72,-19};
	if ([AppDelegate get].currentMission == 1) {
		NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2+self.contentSize.width*3,STREET) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(-600,STREET) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
		TruckMission *truck1 = [[TruckMission alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
		[self addChild:truck1 z:8];
		[vehicles addObject:truck1];
		[truck1 startMoving:ccp(0,0)];
		
		int sniperIndex = (uint) arc4random() % 12;
		int counter = 0;
		for (int x=0;x<6;x++) {
			for (int y=0;y<2;y++) {
				CCLOG(@"counter:%i sniperIndex:%i",counter,sniperIndex);
				if (counter == sniperIndex) {
					//Sniper
					sniper = [[Sniper alloc] initWithFile: @"sniper.png"];	 
					[sniper setPosition:ccp(winX[x],winY[y])];
					sniper.color=ccRED;
					sniper.type = TARGET;
					[self addChild:sniper z:4];
					
					CCSprite *sniperRifle = [CCSprite spriteWithFile:@"sniperrifle.png"];
					sniperRifle.anchorPoint=ccp(0.5,0.5);
					[sniperRifle setPosition:ccp(0,18)];
					sniperRifle.rotation=-5;
					[sniper addChild:sniperRifle z:-1];
					
					CCSprite *hat = [CCSprite spriteWithFile:@"hat1.png"];
					hat.anchorPoint=ccp(0.5,0.5);
					[hat setPosition:ccp(sniper.contentSize.width/2,sniper.contentSize.height-hat.contentSize.height/2)];
					[sniper addChild:hat z:sniper.zOrder+1];
					
					sniper.visible = FALSE;
					for (CCSprite *c in sniper.children)
						c.visible=FALSE;
				}
				else {
					//Randoms
					Enemy *guy = [[Enemy alloc] initWithFile: @"windowguy.png" l:self h:nil];
					[guy setPosition:ccp(winX[x],winY[y])];
					[guy setType:CITIZEN];
					guy.color = ccRED;
					guy.visible = FALSE;
				}
				counter++;
			}
		}
		startX = -400; //800
		for (int j=0; j<3;j++) {
			for (int i=0; i<20;i++) {
				int img = (uint) arc4random() % 3;
				int xPlus = (uint) arc4random() % 60;
				Enemy *enemy;
				if (img == 2)
					enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:nil];
				else if (img == 1)
					enemy = [[Enemy alloc] initWithFile: @"parachuteguy.png" l:self h:nil];
				else
					enemy = [[Enemy alloc] initWithFile: @"stand.png" l:self h:nil];

				[enemy setType:CITIZEN];
				enemy.color = ccRED;
				enemy.position = ccp(startX+(i*60)+xPlus,building.position.y-building.contentSize.height/2+(j*3));
				//enemy.zOrder=enemy.zOrder+j;
			}
		}
		//CCLOG(@"enemies:%i",[[AppDelegate get].enemies count]);
		[self schedule: @selector(randomShow) interval: 2];
		self.position = ccp(-420,180);
	}
	if ([AppDelegate get].currentMission == 6) {
		NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2+self.contentSize.width*3,STREET) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(-600,STREET) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
		TruckMission *truck1 = [[TruckMission alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
		[self addChild:truck1 z:8];
		[vehicles addObject:truck1];
		[truck1 startMoving:ccp(0,0)];
		
		int sniperIndex = (uint) arc4random() % 12;
		
		int sniperIndex1 = (uint) arc4random() % 12;
		while (sniperIndex1 == sniperIndex)
			sniperIndex1 = (uint) arc4random() % 12;
		
		int sniperIndex2 = (uint) arc4random() % 12;
		while (sniperIndex2 == sniperIndex || sniperIndex2 == sniperIndex1)
			sniperIndex2 = (uint) arc4random() % 12;
		
		int sniperIndex3 = (uint) arc4random() % 12;
		while (sniperIndex3 == sniperIndex || sniperIndex3 == sniperIndex1 ||sniperIndex3 == sniperIndex2)
			sniperIndex3 = (uint) arc4random() % 12;
		
		int counter = 0;
		for (int x=0;x<6;x++) {
			for (int y=0;y<2;y++) {
				CCLOG(@"counter:%i sniperIndex:%i",counter,sniperIndex);
				if (counter == sniperIndex || counter == sniperIndex1 || counter == sniperIndex2 || counter == sniperIndex3) {
					//Sniper
					sniper = [[Sniper alloc] initWithFile: @"sniper.png"];	 
					[sniper setPosition:ccp(winX[x],winY[y])];
					sniper.color=ccRED;
					sniper.type = TARGET;
					[self addChild:sniper z:4];
					
					CCSprite *sniperRifle = [CCSprite spriteWithFile:@"sniperrifle.png"];
					sniperRifle.anchorPoint=ccp(0.5,0.5);
					[sniperRifle setPosition:ccp(0,18)];
					sniperRifle.rotation=-5;
					[sniper addChild:sniperRifle z:-1];
					
					CCSprite *hat = [CCSprite spriteWithFile:@"hat1.png"];
					hat.anchorPoint=ccp(0.5,0.5);
					[hat setPosition:ccp(sniper.contentSize.width/2,sniper.contentSize.height-hat.contentSize.height/2)];
					[sniper addChild:hat z:sniper.zOrder+1];
					
					sniper.visible = FALSE;
					for (CCSprite *c in sniper.children)
						c.visible=FALSE;
				}
				else {
					//Randoms
					Enemy *guy = [[Enemy alloc] initWithFile: @"windowguy.png" l:self h:nil];
					[guy setPosition:ccp(winX[x],winY[y])];
					[guy setType:CITIZEN];
					guy.color = ccRED;
					guy.visible = FALSE;
				}
				counter++;
			}
		}
		startX = -400; //800
		for (int j=0; j<3;j++) {
			for (int i=0; i<20;i++) {
				int img = (uint) arc4random() % 3;
				int xPlus = (uint) arc4random() % 60;
				Enemy *enemy;
				if (img == 2)
					enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:nil];
				else if (img == 1)
					enemy = [[Enemy alloc] initWithFile: @"parachuteguy.png" l:self h:nil];
				else
					enemy = [[Enemy alloc] initWithFile: @"stand.png" l:self h:nil];
				
				[enemy setType:CITIZEN];
				enemy.color = ccRED;
				enemy.position = ccp(startX+(i*60)+xPlus,building.position.y-building.contentSize.height/2+(j*3));
				//enemy.zOrder=enemy.zOrder+j;
			}
		}
		//CCLOG(@"enemies:%i",[[AppDelegate get].enemies count]);
		[self schedule: @selector(randomShow) interval: 2];
		self.position = ccp(-420,180);
	}
	else if ([AppDelegate get].currentMission == 2 || [AppDelegate get].currentMission == 7) {
		Enemy *candidate = [[Enemy alloc] initWithFile: @"stand.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CANDIDATEHAT]];
		[candidate setPosition:ccp(200,-10)];
		[candidate setType:CITIZEN];
		candidate.color = ccRED;

		for (int x=0;x<6;x++) {
			for (int y=0;y<2;y++) {
				//Randoms
				Enemy *guy = [[Enemy alloc] initWithFile: @"windowguy.png" l:self h:nil];
				[guy setPosition:ccp(winX[x],winY[y])];
				[guy setType:CITIZEN];
				guy.color = ccRED;
			}
		}
		startX = -100; //800
		for (int j=0; j<8;j++) {
			for (int i=0; i<20;i++) {
				int img = (uint) arc4random() % 3;
				int xPlus = (uint) arc4random() % 30;
				Enemy *enemy;
				if (img == 2)
					enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:nil];
				else if (img == 1)
					enemy = [[Enemy alloc] initWithFile: @"parachuteguy.png" l:self h:nil];
				else
					enemy = [[Enemy alloc] initWithFile: @"stand.png" l:self h:nil];
				  
				[enemy setType:CITIZEN];
				enemy.color = ccRED;
				enemy.position = ccp(startX+(i*30)+xPlus,building.position.y-building.contentSize.height/2-(j*40));
				[enemy changeZ:10000-enemy.position.y];
			  }
		  }
		CustomPoint *shootLeft =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(candidate.position.x-60,candidate.position.y-40) s:WALK z:ZOUT n:@"shootLeft"];
		CustomPoint *shootRight =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(candidate.position.x+60,candidate.position.y-40) s:WALK z:ZOUT n:@"shootRight"];
		
		CustomPoint *CRandomRight =  [[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(41,-352) s:WALK z:ZOUT n:@"CRandomRight"];
		CustomPoint *CRandomLeft =  [[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(241,-352) s:WALK z:ZOUT n:@"CRandomLeft"];
		CustomPoint *CRandomThree =  [[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(441,-352) s:WALK z:ZOUT n:@"CRandomLeft"];
		
		[CRandomRight.nextPoints addObject:shootLeft];
		[CRandomRight.nextPoints addObject:shootRight];
		[CRandomLeft.nextPoints addObject:shootLeft];
		[CRandomLeft.nextPoints addObject:shootRight];
		[CRandomThree.nextPoints addObject:shootLeft];
		[CRandomThree.nextPoints addObject:shootRight];
		
		if ([AppDelegate get].currentMission == 2) {
			NSArray *points =  [[NSMutableArray alloc] initWithObjects:CRandomLeft,CRandomRight,nil];
			Enemy *target = [[EnemyM2 alloc] initWithFile: @"walk1.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CONSTRUCTIONHAT]];
			//[target setPosition:ccp(141,352)];
			[target setType:TARGET];
			target.color = ccRED;			
			[target startMovingWithPoints:points];
		}
		else {
			NSArray *points1 =  [[NSMutableArray alloc] initWithObjects:CRandomRight,nil];
			Enemy *target1 = [[EnemyM2 alloc] initWithFile: @"walk1.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CONSTRUCTIONHAT]];
			//[target setPosition:ccp(141,352)];
			[target1 setType:TARGET];
			target1.color = ccRED;			
			[target1 startMovingWithPoints:points1];	
			
			NSArray *points2 =  [[NSMutableArray alloc] initWithObjects:CRandomLeft,nil];
			Enemy *target2 = [[EnemyM2 alloc] initWithFile: @"walk1.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CONSTRUCTIONHAT]];
			//[target setPosition:ccp(141,352)];
			[target2 setType:TARGET];
			target2.color = ccRED;			
			[target2 startMovingWithPoints:points2];	
			
			NSArray *points3 =  [[NSMutableArray alloc] initWithObjects:CRandomThree,nil];
			Enemy *target3 = [[EnemyM2 alloc] initWithFile: @"walk1.png" l:self h:[NSString stringWithFormat: @"hat%i.png", CONSTRUCTIONHAT]];
			//[target setPosition:ccp(141,352)];
			[target3 setType:TARGET];
			target3.color = ccRED;			
			[target3 startMovingWithPoints:points3];
		}
	}
	else if ([AppDelegate get].currentMission == 3 || [AppDelegate get].currentMission == 8) {
		
		CGPoint carLeftPoint = ccp(700,-80);
		CGPoint carRightPoint = ccp(-300,-80);
		LinearPoint *streetParkLeft =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:carLeftPoint s:DRIVE z:ZOUT n:@"streetParkLeft"];
		LinearPoint *streetParkRight =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:carRightPoint s:DRIVE z:ZOUT n:@"streetParkRight"];
		LinearPoint *streetLeft =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(-10000,carRightPoint.y) s:DRIVE z:ZOUT n:@"streetLeft"];
		
		NSArray *c1p =  [[NSMutableArray alloc] initWithObjects:streetParkLeft,streetLeft,nil];
		NSArray *c2p =  [[NSMutableArray alloc] initWithObjects:streetParkRight,streetLeft,nil];
		c1 = [[Armored alloc] initWithFile: @"hummer.png" l:self a:c1p];
		c1.position=carLeftPoint;
		[self addChild:c1 z:8];
		[vehicles addObject:c1];
					   
	    c2 = [[Armored alloc] initWithFile: @"hummer.png" l:self a:c2p];
	    c2.position=carRightPoint;
	    [self addChild:c2 z:8];
	    [vehicles addObject:c2];
									  
		CustomPoint *packageLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(150,-100) s:WALK z:ZOUT n:@"packageLeft"];
		CustomPoint *carLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:carLeftPoint s:WALK z:ZOUT n:@"carLeft"];
		CustomPoint *shootLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(150,-50) s:NOTHING z:ZOUT n:@"shootLeft"];
		
		CustomPoint *packageRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(206,-40) s:WALK z:ZOUT n:@"packageRight"];
		CustomPoint *packageKneel =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(200,-40) s:KNEEL z:ZOUT n:@"packageKneel"];
		
		CustomPoint *carRight =  [[CustomPoint alloc] initWithData:WALKRATE p:carRightPoint s:WALK z:ZOUT n:@"carRight"];
		CustomPoint *shootRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(250,-50) s:NOTHING z:ZOUT n:@"shootRight"];
		
		CustomPoint *walkRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(carRightPoint.x+300,carRightPoint.y+20) s:WALK z:ZOUT n:@"walkRight"];
		CustomPoint *packageKneelRight =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(carRightPoint.x+300,carRightPoint.y+20) s:KNEEL z:ZOUT n:@"packageKneelRight"];
		
		CustomPoint *walkLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(carLeftPoint.x-300,carLeftPoint.y+20) s:WALK z:ZOUT n:@"walkLeft"];
		CustomPoint *packageKneelLeft =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(carLeftPoint.x-300,carLeftPoint.y+20) s:KNEEL z:ZOUT n:@"packageKneelLeft"];
		
		if ([AppDelegate get].currentMission == 8) {
			[packageKneelRight.nextPoints addObject:carRight];
			[walkRight.nextPoints addObject:packageKneelRight];
			[packageKneel.nextPoints addObject:walkRight];
		}
		else {
			[packageKneel.nextPoints addObject:carRight];
		}
		[packageRight.nextPoints addObject:packageKneel];
		[shootRight.nextPoints addObject:packageRight];
		
		if ([AppDelegate get].currentMission == 8) {
			[packageKneelLeft.nextPoints addObject:carLeft];
			[walkLeft.nextPoints addObject:packageKneelLeft];
			[packageLeft.nextPoints addObject:walkLeft];
			//[shootLeft.nextPoints addObject:walkLeft];
		}
		else {
			[packageLeft.nextPoints addObject:carLeft];
			//[shootLeft.nextPoints addObject:carLeft];
		}
		
		[shootLeft.nextPoints addObject:packageLeft];
		NSArray *s1p =  [[NSMutableArray alloc] initWithObjects:shootLeft,nil];
		s1 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:[NSString stringWithFormat: @"hat%i.png", SECURITYHAT]];
		[s1 setType:TARGET];
		s1.color=ccBLUE;
		s1.head.color=ccBLUE;
		s1.position=ccp(150,-50);
		s1.flipX=TRUE;
		s1.hat.flipX=TRUE;
		[s1 startMovingWithPoints:s1p];
		
		NSArray *s2p =  [[NSMutableArray alloc] initWithObjects:shootRight,nil];
		s2 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:[NSString stringWithFormat: @"hat%i.png", SECURITYHAT]];
		[s2 setType:TARGET];
		s2.color=ccBLUE;
		s2.head.color=ccBLUE;
		s2.position=ccp(250,-50);
		[s2 startMovingWithPoints:s2p];
		
		currentPackage = 0;
		timedCount = 0;
		packages = [[NSMutableArray alloc] initWithObjects:@"gift.png",@"flowers.png",@"fruitbasket.png",nil];
		
		CustomPoint *package =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(170,-60) s:WALK z:ZOUT n:@"package"];
		CustomPoint *packageKneel1 =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(170,-60) s:KNEEL z:ZOUT n:@"packageKneel"];
		CustomPoint *crowd =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(610,-80) s:WALK z:ZOUT n:@"crowd"];
		CustomPoint *crowd2 =  [[CustomPoint alloc] initWithData:WALKRATE p:crowd.point s:WALK z:ZOUT n:@"crowd2"];
		
		[packageKneel1.nextPoints addObject:crowd2];
		[package.nextPoints addObject:packageKneel1];
		[crowd.nextPoints addObject:package];
		NSArray *points =  [[NSMutableArray alloc] initWithObjects:crowd,nil];
		
		
		EnemyM3 *b2 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[b2 setType:CITIZEN];
		b2.color=ccRED;
		b2.position=ccp(crowd.point.x-10,crowd.point.y+10);
		
		a1 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[a1 setType:CITIZEN];
		a1.color=ccRED;
		a1.position=crowd.point;
		[a1 startMovingWithPoints:points];
		[a1 forceMove];
		
		EnemyM3 *b1 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[b1 setType:CITIZEN];
		b1.color=ccRED;
		b1.position=ccp(crowd.point.x-20,crowd.point.y-10);
		
		EnemyM3 *b4 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[b4 setType:CITIZEN];
		b4.color=ccRED;
		b4.position=ccp(-410,-60);
		
		a2 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[a2 setType:CITIZEN];
		a2.color=ccRED;
		a2.position=ccp(-400,-70);
		
		EnemyM3 *b3 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[b3 setType:CITIZEN];
		b3.color=ccRED;
		b3.position=ccp(a2.position.x-20,a2.position.y-10);
		
		a3 = [[EnemyM3 alloc] initWithFile: @"stand.png" l:self h:nil];
		[a3 setType:CITIZEN];
		a3.color=ccRED;
		a3.position=ccp(600,-70);
		
		
		[self schedule: @selector(timedMove) interval: 12];
		//[self schedule: @selector(timedMove) interval: 2];
	}
	else if ([AppDelegate get].currentMission == 4 || [AppDelegate get].currentMission == 9) {
		timedCount = 0;
		int side = (uint) arc4random() % 2;
		int randY = (uint) arc4random() % 80;
		if (side == 0) {
			NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2-self.contentSize.width*3,STREET-40+randY) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(200,STREET+40) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
			BombTruck *vehicle = [[BombTruck alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
			[self addChild:vehicle z:100-randY];
			[vehicles addObject:vehicle];
			[vehicle startMoving:ccp(MINX,0)];
		}
		else {
			NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2+self.contentSize.width*3,STREET-40+randY) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(200,STREET+40) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
			BombTruck *vehicle = [[BombTruck alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
			[self addChild:vehicle z:100-randY];
			[vehicles addObject:vehicle];
			[vehicle startMoving:ccp(0,0)];
		}
		if ([AppDelegate get].currentMission == 9)
			[self schedule: @selector(truckLaunch) interval: 5];
		else 
			[self schedule: @selector(truckLaunch) interval: 10];
	}
	else if ([AppDelegate get].currentMission == 5 || [AppDelegate get].currentMission == 10) {
		timedCount = 0;
		currentPackage = 5;
		if ([AppDelegate get].currentMission == 10)
			currentPackage = 15;
		CCSprite *c = [CCSprite spriteWithFile:@"b1px.png"];
		//c.color=ccc3(43,69,127);
		[c setScaleY:self.contentSize.width*6];
		[c setScaleX:self.contentSize.width*6];
		[c setPosition:ccp(240, 160)];
		c.opacity = 100;
		[self addChild:c z:500];
		
		EnemyParatrooper *enemy = [[EnemyParatrooper alloc] initWithFile: @"parachuteguy.png" l:self h:@"hat1.png"];
		[enemy setType:TARGET];
		enemy.color = ccRED;
		int start = arc4random() % ([[AppDelegate get].planeStartPoint count]-1) + 1;
		LinearPoint *p = [[AppDelegate get].planeStartPoint objectAtIndex:start];
		[enemy startMoving:p.point];
		
		if ([AppDelegate get].currentMission == 10)
			[self schedule: @selector(timedPlane) interval: 3];
		else 
			[self schedule: @selector(timedPlane) interval: 5];
	}
}

-(void) timedPlane {
	if (timedCount < currentPackage) {
		EnemyParatrooper *enemy = [[EnemyParatrooper alloc] initWithFile: @"parachuteguy.png" l:self h:@"hat1.png"];
		[enemy setType:TARGET];
		enemy.color = ccRED;
		int start = arc4random() % ([[AppDelegate get].planeStartPoint count]-1) + 1;
		LinearPoint *p = [[AppDelegate get].planeStartPoint objectAtIndex:start];
		[enemy startMoving:p.point];
	}
	else {
		[self unschedule: @selector(timedPlane:)];
	}
	timedCount++;
}

-(void) truckLaunch {
	CGSize s = [[CCDirector sharedDirector] winSize];
	int side = (uint) arc4random() % 2;
	int randY = (uint) arc4random() % 80;
	if (side == 0) {
		NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2-self.contentSize.width*3,STREET-40+randY) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(200,STREET+40) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
		BombTruck *vehicle = [[BombTruck alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
		[self addChild:vehicle z:100-randY];
		[vehicles addObject:vehicle];
		[vehicle startMoving:ccp(MINX,0)];
	}
	else {
		NSArray *truckRoute =  [[NSMutableArray alloc] initWithObjects:[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(s.width/2+self.contentSize.width*3,STREET-40+randY) s:DRIVE z:ZOUT n:@"streetRight"],[[LinearPoint alloc] initWithData:VEHICLE1RATE p:ccp(200,STREET+40) s:DRIVE z:ZOUT n:@"streetLeft"],nil];
		BombTruck *vehicle = [[BombTruck alloc] initWithFile: @"truck1.png" l:self a:truckRoute];
		[self addChild:vehicle z:100-randY];
		[vehicles addObject:vehicle];
		[vehicle startMoving:ccp(0,0)];
	}
	timedCount++;
}

-(void) timedMove {
	if (timedCount == 0) {
		CustomPoint *package =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(190,-50) s:WALK z:ZOUT n:@"package"];
		CustomPoint *packageKneel =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(190,-50) s:KNEEL z:ZOUT n:@"packageKneel"];
		CustomPoint *crowd =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(-400,-70) s:WALK z:ZOUT n:@"crowd"];
		CustomPoint *crowd2 =  [[CustomPoint alloc] initWithData:WALKRATE p:crowd.point s:WALK z:ZOUT n:@"crowd2"];
		
		[packageKneel.nextPoints addObject:crowd2];
		[package.nextPoints addObject:packageKneel];
		[crowd.nextPoints addObject:package];
		NSArray *points =  [[NSMutableArray alloc] initWithObjects:crowd,nil];
		[a2 startMovingWithPoints:points];
		[a2 forceMove];
	}
	else if (timedCount == 1) {
		CustomPoint *package =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(210,-50) s:WALK z:ZOUT n:@"package"];
		CustomPoint *packageKneel =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(210,-50) s:KNEEL z:ZOUT n:@"packageKneel"];
		CustomPoint *crowd =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(600,-70) s:WALK z:ZOUT n:@"crowd"];
		CustomPoint *crowd2 =  [[CustomPoint alloc] initWithData:WALKRATE p:crowd.point s:WALK z:ZOUT n:@"crowd2"];
		
		[packageKneel.nextPoints addObject:crowd2];
		[package.nextPoints addObject:packageKneel];
		[crowd.nextPoints addObject:package];
		NSArray *points =  [[NSMutableArray alloc] initWithObjects:crowd,nil];
		[a3 startMovingWithPoints:points];
		[a3 forceMove];
	}
	else if (timedCount == 2) {
		//[s1 forceMove];
		//[s2 forceMove];
		//[self schedule: @selector(timedMove) interval: 10];
		//[self schedule: @selector(bombTimer) interval: 15];
	}
	timedCount++;
}
			  
-(void) sendVehicles {
	[c1 startMoving:ccp(0,0)];
	[c2 startMoving:ccp(0,0)];
	[self schedule: @selector(doLose) interval: 3];
}	

-(void) doBomb:(CGPoint)c {
	CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"bigExplosion.plist"];
	emitter.autoRemoveOnFinish = YES;
	emitter.position = c;
	[self addChild: emitter z:100];
	[[AppDelegate get].soundEngine playSound:10 sourceGroupId:0 pitch:1.0f pan:0.0f gain:1.0f loop:NO];
	[self doLose];
}				

-(void) dropPackage: (Enemy*) e {
	if (e.type == TARGET) {
		Radio *enemy = [[Radio alloc] initWithFile: @"briefcase.png" l:self];	
		[enemy setType:TARGET];
		enemy.position = e.position; //ccp(200,-50);
		[enemy release];
		[(MissionControlLayer*) [self.parent getChildByTag:kControlLayer] updateTargets];
	}
	else {
		Radio *enemy = [[Radio alloc] initWithFile: [packages objectAtIndex:currentPackage] l:self];		
		[enemy setType:CITIZEN];
		enemy.position = ccp(170+(currentPackage*20),-70);
		[enemy release];
		if (currentPackage == 2) {
			[s1 forceMove];
			[s2 forceMove];
		}
	}
	currentPackage++;
}

-(void) randomShow {
	for (int i = 2; i<14;i++) {
		Enemy *e = [[AppDelegate get].enemies objectAtIndex:i];
		if (e.type != FROMVEHICLE) {
			int show = (uint) arc4random() % 2;
			if (show == 1) {
				e.visible = TRUE;
				if (e.type == TARGET) {
					for (CCSprite *c in e.children)
						c.visible=TRUE;
				}
			}
			else {
				e.visible = FALSE;
				if (e.type == TARGET) {
					for (CCSprite *c in e.children)
						c.visible=FALSE;
				}
			}
		}
	}
}

-(void) shootLeader {
	[[AppDelegate get].soundEngine playSound:0 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	Enemy *e = [[AppDelegate get].enemies objectAtIndex:0];
	[e addBlood];
	[e dead];
	[self unscheduleAllSelectors];
	[(MissionControlLayer*) [self.parent getChildByTag:kControlLayer] delayLose];
}

-(void) doLose {
	[self unscheduleAllSelectors];
	[(MissionControlLayer*) [self.parent getChildByTag:kControlLayer] delayLose];	
}

- (int) shotFired {
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	CCLOG(@"shot position: %f,%f",240-location.x,160-location.y);
	int gotHim = -1;
	int headshot = 0;
	//CCLOG(@"enemies count %i",[[AppDelegate get].enemies count]);
	for (int i = 0; i < (int) [[AppDelegate get].enemies count]; i++) {
		Enemy *enemy = [[AppDelegate get].enemies objectAtIndex:i];
		int wasShot = [enemy checkIfShot];
		//CCLOG(@"wasShot=%i",wasShot);
		
		if (wasShot > 0) {
			// Missions
			if (enemy.type != TARGET ) {
				return -2;
			}
			else if (([AppDelegate get].currentMission == 3 || [AppDelegate get].currentMission == 8) && currentPackage < 4) {
				return -2;
			}
			if (wasShot > 1 && enemy.type == TARGET) {
				headshot=1;
				//CCLOG(@"heashotStreakBefore=%i",[AppDelegate get].headshotStreak);
				[AppDelegate get].headshotStreak++;
				[self doHeadshot:enemy.position i:wasShot];
				//CCLOG(@"heashotStreakAfter=%i",[AppDelegate get].headshotStreak);
			}
			/*else if (enemy.type == TARGET && packages) {
				
			}*/
			gotHim = i;
			if (dirtKills > 0) {
				dirtKills--;
				if (dirtKills == 0)
					[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] blurryOff];
				
			}
			if (invertKills > 0)
				invertKills--;
			break;
		}
		else if (wasShot == -3) {
			if (currentPackage < 4)
				return -2;
			else 
				return -1;
		}
	}
	
	CCLOG(@"heashot=%i",headshot);
	if (headshot == 0)
		[AppDelegate get].headshotStreak=0;
	
	if (gotHim > -1) {
		if ([AppDelegate get].loadout.s == 2 || [AppDelegate get].loadout.s == 3) {
			[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] resetScope];
		}
		[[AppDelegate get].enemies removeObjectAtIndex:gotHim];
		return [[AppDelegate get].enemies count];
	}
	else {
		[AppDelegate get].headshotStreak=0;
		return gotHim;
	}
}

- (void) moveBGPostion:(float) x y:(float) y {
	//CCLOG(@"moveBGPostion x:%f y:%f",x,y);
	// Adjust x,y
	
	x = x/(([AppDelegate get].sensitivity+1) * 5);
	y = y/(([AppDelegate get].sensitivity+1) * 5);
	
	CGSize s = CGSizeMake(960,512);
	
	// Screen Bounds Values
	/*float yMax = s.height;
	float yMin = -s.height;
	float xMax = s.width;
	float xMin = -s.width;*/
	// Screen Bounds Values
	float yMax = s.height*[AppDelegate get].scale;
	float yMin = -s.height*[AppDelegate get].scale;
	float xMax = s.width*[AppDelegate get].scale;
	float xMin = -s.width*[AppDelegate get].scale;

	x = self.position.x + x;
	y = self.position.y + y;
	
	if (x <= xMin) {
		x = xMin; //self.position.x;
	}
	if (x >= xMax) {
		x = xMax; //self.position.x;
	}
	if (y <= yMin) {
		y = yMin; //self.position.y;
	}
	if (y >= yMax) {
		y = yMax; //self.position.y;
	}

	self.position = ccp(x,y);
}

-(void)towTruck: (Vehicle*) v {

}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MissionScene node]];
}

@end

@implementation MissionControlLayer
- (id) init {
	CCLOG(@"ControlLayer");
    self = [super init];
    if (self != nil) {		

	}
	return self;
}

-(void) setup {
	levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
											  @"Mission %2i", [AppDelegate get].currentMission] fontName:[AppDelegate get].clearFont fontSize:14];
	levelLabel.anchorPoint=ccp(0,0);
	[levelLabel setPosition:ccp(10, 300)];
	[self addChild:levelLabel];
	
	CCSprite *objective1 = [CCSprite spriteWithFile: @"squareborder.png"];
	objective1.position = ccp(46,220);
	[self addChild:objective1 z:12];
	CCLabelTTF *objective1Text = [CCLabelTTF labelWithString:@"Protect" fontName:[AppDelegate get].clearFont fontSize:12];
	objective1Text.position = ccp(objective1.position.x,objective1.position.y+objective1.contentSize.height/2+8);
	[self addChild:objective1Text z:3];
	CCSprite *objective2 = [CCSprite spriteWithFile: @"squareborder.png"];
	objective2.position = ccp(46,110);
	[self addChild:objective2 z:12];
	CCLabelTTF *objective2Text = [CCLabelTTF labelWithString:@"Destroy" fontName:[AppDelegate get].clearFont fontSize:12];
	objective2Text.position = ccp(objective2.position.x,objective2.position.y+objective2.contentSize.height/2+8);
	[self addChild:objective2Text z:3];
	
	if ([AppDelegate get].currentMission == 1 || [AppDelegate get].currentMission == 6) {
		CCSprite *pres = [CCSprite spriteWithFile:@"walk1.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		pres.color = ccRED;
		[self addChild:pres z:13];
		
		CCSprite *hat = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png",CANDIDATEHAT]];
		hat.anchorPoint=ccp(0.5,0.0);
		[hat setPosition:ccp(pres.contentSize.width/2,pres.contentSize.height-hat.contentSize.height/2)];
		[pres addChild:hat z:pres.zOrder+1];
		
		CCSprite *enemy = [CCSprite spriteWithFile:@"shooting2.png"];
		[enemy setPosition:ccp(objective2.position.x,objective2.position.y)];
		enemy.color=ccRED;
		[self addChild:enemy z:13];
		CCSprite *glasses = [CCSprite spriteWithFile:@"hat1.png"];
		glasses.anchorPoint=ccp(0.5,0.5);
		//[glasses setPosition:ccp(enemy.contentSize.width/2,32)];
		[glasses setPosition:ccp(self.contentSize.width/2,self.contentSize.height-hat.contentSize.height/2)];
		[enemy addChild:glasses z:enemy.zOrder+1];
		CCSprite *g = [CCSprite spriteWithFile:@"gun.png"];
		[enemy addChild:g z:-1];
		[g setPosition:ccp(4,enemy.contentSize.height/2+2)];
	}
	else if ([AppDelegate get].currentMission == 2 || [AppDelegate get].currentMission == 7) {
		CCSprite *pres = [CCSprite spriteWithFile:@"walk1.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		pres.color = ccRED;
		[self addChild:pres z:13];
		
		CCSprite *hat = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png",CANDIDATEHAT]];
		hat.anchorPoint=ccp(0.5,0.0);
		[hat setPosition:ccp(pres.contentSize.width/2,pres.contentSize.height-hat.contentSize.height/2)];
		[pres addChild:hat z:pres.zOrder+1];
		
		CCSprite *enemy = [CCSprite spriteWithFile:@"shooting2.png"];
		[enemy setPosition:ccp(objective2.position.x,objective2.position.y)];
		enemy.color=ccRED;
		[self addChild:enemy z:13];
		CCSprite *glasses = [CCSprite spriteWithFile:@"hat1.png"];
		glasses.anchorPoint=ccp(0.5,0.5);
		//[glasses setPosition:ccp(enemy.contentSize.width/2,32)];
		[glasses setPosition:ccp(self.contentSize.width/2,self.contentSize.height-hat.contentSize.height/2)];
		[enemy addChild:glasses z:enemy.zOrder+1];
		CCSprite *g = [CCSprite spriteWithFile:@"gun.png"];
		[enemy addChild:g z:-1];
		[g setPosition:ccp(4,enemy.contentSize.height/2+2)];
	}
	else if ([AppDelegate get].currentMission == 3 || [AppDelegate get].currentMission == 8) {
		CCSprite *pres = [CCSprite spriteWithFile:@"adminbuildingMini.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		[self addChild:pres z:13];
		
		CCSprite *enemy = [CCSprite spriteWithFile:@"briefcase.png"];
		[enemy setPosition:ccp(objective2.position.x,objective2.position.y)];
		enemy.color=ccRED;
		[self addChild:enemy z:13];
	}
	else if ([AppDelegate get].currentMission == 4 || [AppDelegate get].currentMission == 9) {
		CCSprite *pres = [CCSprite spriteWithFile:@"adminbuildingMini.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		[self addChild:pres z:13];
		
		CCLabelTTF *q2 = [CCLabelTTF labelWithString:@"?" fontName:[AppDelegate get].clearFont fontSize:32];
		q2.color=ccBLUE;
		q2.position=ccp(objective2.position.x, objective2.position.y);
		[self addChild:q2 z:13];
	}
	else if ([AppDelegate get].currentMission == 5 || [AppDelegate get].currentMission == 10) {
		CCSprite *pres = [CCSprite spriteWithFile:@"adminbuildingMini.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		[self addChild:pres z:13];
		
		CCLabelTTF *q2 = [CCLabelTTF labelWithString:@"?" fontName:[AppDelegate get].clearFont fontSize:32];
		q2.color=ccBLUE;
		q2.position=ccp(objective2.position.x, objective2.position.y);
		[self addChild:q2 z:13];		
	}
	else {
		CCSprite *pres = [CCSprite spriteWithFile:@"adminbuildingMini.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		[self addChild:pres z:13];
		
		CCLabelTTF *q2 = [CCLabelTTF labelWithString:@"?" fontName:[AppDelegate get].clearFont fontSize:32];
		q2.color=ccBLUE;
		q2.position=ccp(objective2.position.x, objective2.position.y);
		[self addChild:q2 z:13];
	}

	shot = 0;
	maxShot = 1;
	if ([AppDelegate get].currentMission < 3) {
		maxShot = 1;
		targetsLeft = 1;
	}
	else if ([AppDelegate get].currentMission == 3) {
		maxShot = 7;
		targetsLeft = 2;
	}
	else if ([AppDelegate get].currentMission == 4) {
		maxShot = 10;
		targetsLeft = 5;
	}
	else if ([AppDelegate get].currentMission == 5) {
		maxShot = 12;
		targetsLeft = 6;
	}
	else if ([AppDelegate get].currentMission == 6) {
		maxShot = 4;
		targetsLeft = 4;
	}
	else if ([AppDelegate get].currentMission == 7) {
		maxShot = 3;
		targetsLeft = 3;
	}
	else if ([AppDelegate get].currentMission == 8) {
		maxShot = 7;
		targetsLeft = 2;
	}
	else if ([AppDelegate get].currentMission == 9) {
		maxShot = 15;
		targetsLeft = 10;
	}
	else if ([AppDelegate get].currentMission == 10) {
		maxShot = 20;
		targetsLeft = 15;
	}
	else {
		maxShot = 10;
		targetsLeft = 3;
	}
	CCLOG(@"maxShot:%i,targetsLeft:%i",maxShot,targetsLeft);
	float bulletX = 440;
	float bulletY = 280;
	bullets = [[NSMutableArray alloc] init];
	for (int i = 0; i<maxShot;i++) {
		if (i > 11)
			bulletX = 800;
		CCSprite *b = [CCSprite spriteWithFile:@"ammo0.png"];
		b.scale=0.6;
		[b setPosition:ccp(bulletX, bulletY-(i*(b.contentSize.height*b.scale))-4)];
		[self addChild:b z:13 tag:i+1000];
		//[bullets addObject:b];
		//[b release];
	}
	
}

-(void) fireButtonPressed: (id)sender {
	CCLOG(@"Fire Button Pressed");
	if ([AppDelegate get].reload == 0 && shot < maxShot) {
		shot++;
		//CCSprite *b = [bullets objectAtIndex:[bullets count]-1];
		[self removeChildByTag:maxShot-shot+1000 cleanup:YES];

		//bulletCount--;
		//if (bulletCount > 0) {
		//CCLOG(@"Fire Button Pressed");
		[[AppDelegate get].soundEngine playSound:0 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		/*			
		 CCSprite *s = (CCSprite*)[self getChildByTag:1000+bulletCount-1];
		 s.visible = NO;
		 if ([AppDelegate get].gameType != 2) // Sandbox
		 bulletCount--;
		 */
		int shotResult = ([(Mission1Layer*) [self.parent getChildByTag:kBackgroundLayer] shotFired]);
		
		if (shotResult > -1) {
			targetsLeft--;
			if (targetsLeft == 0)
				[self delayWin];
		}
		else if (shotResult == -2 || shot == maxShot) {
			[self delayLose];
		}
		
		/*NSString *k = [NSString stringWithFormat:@"%2i",[[AppDelegate get].enemies count]];
		 [enemyLabel setString:k];*/
		
		[AppDelegate get].reload = 1;
		if ([AppDelegate get].loadout.b != 1) {
			[(Mission1Layer*) [self.parent getChildByTag:kBackgroundLayer] moveBGPostion:-distance y:-distance];
			elapsed = 0;
			[self schedule: @selector(doRecoil) interval: ([AppDelegate get].loadout.re)*.01];
		}
		[self schedule: @selector(doReloadSound) interval: .2];
		
		if ([AppDelegate get].loadout.r == 1)
			[self schedule: @selector(doReload) interval: .3];
		else if ([AppDelegate get].loadout.r == 0)
			[self schedule: @selector(doReload) interval: .6];
		else
			[self schedule: @selector(doReload) interval: 1];
			
	}
}

-(void) updateTargets {
	targetsLeft++;
}
  
-(void) delayWin {
	[self schedule: @selector(doWin) interval: 2];
}

-(void) doWin {
	[self unschedule: @selector(doWin)];
	[[CCDirector sharedDirector] replaceScene:[WinScene node]];
}

-(void) delayLose {
	[self schedule: @selector(doLose) interval: 2];
}

-(void) doLose {
	[self unschedule: @selector(doLose)];
	[[CCDirector sharedDirector] replaceScene:[LoseScene node]];
}

@end
