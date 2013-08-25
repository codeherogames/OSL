//
//  GameScene.m
//  Sniper
//
//  Created by James Dailey on 10/15/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"
#import "GameKitHelper.h"
#import "MyDial.h"
#import "MyToggle.h"
#import "MyMenuButton.h"
#import "ChildMenuButton.h"
#import "WinScene.h"
#import "LoseScene.h"
#import "Radio.h"
#import "Perk.h"
#import "LinearPoint.h"
#include <sys/time.h>

//#define kFilteringFactor 0.5 // orginal
//#define kAccelMultiple 250.0 // orginal

#define kFilteringFactor 0.9
#define kAccelMultiple 250.0
#define NIGHTSPRITE 90210

enum {
	kBackgroundLayer = 5000,
	kMidgroundLayer = 5001,
	kForegroundLayer = 5002,	
	kScopeLayer = 5003,
	kControlLayer = 5004,
	kSkylineLayer = 5005,
	kPauseLayer = 5006,
	kButtonMenu = 6000,
};

static int GetApproxDistance(CGPoint pt1, CGPoint pt2) {
    
    int dx = (int)pt1.x - (int)pt2.x;
    int dy = (int)pt1.y - (int)pt2.y;
    dx = abs(dx);
    dy = abs(dy);
    if ( dx < dy ) {
        return dx + dy - (dx >> 1);
    } else {
        return dx + dy - (dy >> 1);
    }
}

@implementation GameScene
- (id) init {
	CCLOG(@"GameScene"); 
    self = [super init];
    if (self != nil) {
		[[AppDelegate get].m1 reset];
		[[AppDelegate get].m2 reset];
		[[AppDelegate get].m3 reset];
		[[AppDelegate get].m4 reset];
		[[AppDelegate get].m5 reset];
		/*[[[AppDelegate get].m5.childButtons objectAtIndex:0] enable];
		[[[AppDelegate get].m5.childButtons objectAtIndex:1] enable];
		[[[AppDelegate get].m5.childButtons objectAtIndex:2] enable];*/
		
		[AppDelegate get].scale = 0.5f;
		[AppDelegate get].reload = 0;
		[AppDelegate get].headshotStreak = 0;
		if ([[AppDelegate get] perkEnabled:3])
			[AppDelegate get].money = T5+T2;
		else
			[AppDelegate get].money = T2;
		
		if ([AppDelegate get].gameType == SANDBOX && [AppDelegate get].sandboxMode == 1)
			[AppDelegate get].money = 99999999;
		
        if ([[AppDelegate get] perkEnabled:46])
            [AppDelegate get].sensitivity = 0;
        else
            [AppDelegate get].sensitivity = 1;
		
		if ([[AppDelegate get] perkEnabled:11])
			[AppDelegate get].recon = 1;
		else
			[AppDelegate get].recon = 0;
		[AppDelegate get].anti = 0;
		[AppDelegate get].kidnappers = 0;
		[AppDelegate get].jammers = 0;
		[self addLayers];
		
		if ([[AppDelegate get] perkEnabled:13])
			[self doSnow];
		//[AppDelegate get].gameTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

-(void) addLayers {	
	[self addChild:[SkylineLayer node] z:0 tag:kSkylineLayer];
	[self addChild:[ControlLayer node] z:5 tag:kControlLayer];
	[self addChild:[BackgroundLayer node] z:1 tag:kBackgroundLayer];
	[self addChild:[ForegroundLayer node] z:1 tag:kForegroundLayer];
	[self addChild:[MidgroundLayer node] z:2 tag:kMidgroundLayer];
	[self addChild:[ScopeLayer node] z:4 tag:kScopeLayer];
	[AppDelegate get].bgLayer = (BackgroundLayer*) [self getChildByTag:kBackgroundLayer];
}

-(void) doSnow
{
	CCParticleSystem *emitter = [CCParticleSnow node];
	emitter.position = ccp([[UIScreen mainScreen] bounds].size.height/2,320);
	
	
	//CGPoint p = emitter.position;
	//emitter.position = ccp( p.x, p.y-110);
	emitter.life = 3;
	emitter.lifeVar = 1;
	
	// gravity
	emitter.gravity = ccp(0,-10);
	
	// speed of particles
	emitter.speed = 70; //130;
	emitter.speedVar = 30;
	//1.7;
	//emitter.totalParticles = emitter.totalParticles - (emitter.totalParticles*.2);
	
	
	ccColor4F startColor = emitter.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = emitter.startColorVar;
	startColorVar.b = 0.1f;
	emitter.startColorVar = startColorVar;
	
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"snow.png"];
	[self addChild: emitter z:3];}

-(void) handleDisconnect {
	[AppDelegate get].gameState = NOGAME;
	if ([AppDelegate get].friendInvite == 1) 
		[AppDelegate get].friendInvite = -2;
	[AppDelegate showNotification:@"Opponent disconnected"];
	[[CCDirector sharedDirector] replaceScene:[WinScene node]];
}

- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc GameScene"); 
	[(BackgroundLayer*) [self getChildByTag:kBackgroundLayer] kill];
	[super dealloc];
}
@end

@implementation BackgroundLayer
@synthesize vehicles;
- (id) init {
	CCLOG(@"BackgroundLayer");
    self = [super init];
    if (self != nil) {
		streakName = [[NSArray alloc] initWithObjects: @"Go Get Some",@"Headshot",@"Multikill",@"Killstreak",@"Dominating",@"Massacre",@"Godlike",@"Unstoppable",nil];
		machinegunAvailable = TRUE;
		bombAvailable = TRUE;
		securityAvailable = TRUE;
		security1 = -1;
		security2 = -1;
		if ([AppDelegate get].controls == 0) {
			self.isAccelerometerEnabled = YES;
		}
		[self setScale:[AppDelegate get].scale];
		
		vehicles = [[NSMutableArray alloc] init];
		invertKills=0;
		dirtKills=0;
		atPresident = 0;
		mutinyCount=0;
        lastAttack = 0;
        lastAttackCount = 0;
        shotsFired = 0;
        
		lastAngleX = 0.0f;
		lastAngleY = 0.0f;
		
		[self setup];
		
		headshotLabel = [CCLabelTTF labelWithString:@"Killstreak x 1" dimensions:CGSizeMake(230,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].headshotFont fontSize:40];
		headshotLabel.color=ccc3(0,0,92);
		headshotLabel.position=ccp(50,50);
		headshotLabel.rotation=20;
		headshotLabel.visible=NO;
		[self addChild:headshotLabel z:100];
		
		if ([AppDelegate get].loadout.e == 1 || [AppDelegate get].loadout.e == 2 || [AppDelegate get].loadout.s == 2 || [AppDelegate get].loadout.s == 3) {
			[self schedule: @selector(checkIfSighted) interval: 0.1];
		}
        if ([[AppDelegate get] perkEnabled:48]) {
            [self schedule: @selector(checkProximity) interval: 0.5];
        }
	}
	return self;
}

-(void) setup {
	//Street
	CCSprite *street = [CCSprite spriteWithFile:@"w1px.png"];
	[street setPosition:ccp(240,-300)];	
	[street setScaleY:200];
	[street setScaleX:4096];
	street.color= ccc3(79,79,79);
	[self addChild:street z:0];	
	
	//Street
	CCSprite *street2 = [CCSprite spriteWithFile:@"w1px.png"];
	[street2 setPosition:ccp(450,-80)];	
	[street2 setScaleY:300];
	[street2 setScaleX:1000];
	street2.color= ccc3(79,79,79);
	street2.rotation=-30;
	[self addChild:street2 z:0];	
	
	//Street
	CCSprite *street3 = [CCSprite spriteWithFile:@"w1px.png"];
	[street3 setPosition:ccp(1450,-80)];	
	[street3 setScaleY:200];
	[street3 setScaleX:1000];
	street3.color= ccc3(79,79,79);
	street3.rotation=-30;
	[self addChild:street3 z:0];
	
	//Street
	CCSprite *street4 = [CCSprite spriteWithFile:@"w1px.png"];
	[street4 setPosition:ccp(-700,-80)];	
	[street4 setScaleY:300];
	[street4 setScaleX:1000];
	street4.color= ccc3(79,79,79);
	street4.rotation=-30;
	[self addChild:street4 z:0];
	
	//Street-Water
	CCSprite *dock = [CCSprite spriteWithFile:@"w1px.png"];
	dock.anchorPoint=ccp(0,0);
	[dock setPosition:ccp(-1200,-200)];	
	[dock setScaleY:200];
	[dock setScaleX:3000];
	dock.color= ccc3(79,79,79);
	[self addChild:dock z:0];
	
	// Filler-Low
	CCSprite *filler1 = [CCSprite spriteWithFile:@"w1px.png"];
	filler1.anchorPoint=ccp(0,0);
	[filler1 setPosition:ccp(300,-600)];	
	[filler1 setScaleY:200];
	[filler1 setScaleX:1000];
	filler1.color= ccc3(79,79,79);
	[self addChild:filler1 z:0];	
	
	//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// Water
	CCSprite *water = [CCSprite spriteWithFile:@"w1px.png"];
	water.anchorPoint=ccp(0,0);
	[water setPosition:ccp(-1200,0)];	
	[water setScaleY:200];
	[water setScaleX:3000];
	water.color= ccc3(168,225,255);
	[self addChild:water z:0];	
	
	// Fence
	CCSprite *fence = [CCSprite spriteWithFile:@"fence.png"];
	fence.anchorPoint=ccp(0,0);
	[fence setPosition:ccp(-1000,0)];	
	[self addChild:fence z:0];	
	
	CCSprite *fence2 = [CCSprite spriteWithFile:@"fence.png"];
	fence2.anchorPoint=ccp(0,0);
	[fence2 setPosition:ccp(10,0)];	
	[self addChild:fence2 z:0];	
	
	CCSprite *fence3 = [CCSprite spriteWithFile:@"fence.png"];
	fence3.anchorPoint=ccp(0,0);
	[fence3 setPosition:ccp(1080,0)];	
	[self addChild:fence3 z:0];
	
	float midBuildingY = 100.0f;
	
	CCSprite *building2 = [CCSprite spriteWithFile:@"bldg2.png"];
	[building2 setPosition:ccp(800,midBuildingY)];
	[self addChild:building2 z:1];
	
	// Billboard
	billboard = [CCSprite spriteWithFile:@"billboard.png"];
	[billboard setPosition:ccp(800,ROOF+billboard.contentSize.height/2)];
	[self addChild:billboard z:1];
	
	CCSprite *zipPost = [CCSprite spriteWithFile:@"b1px.png"];
	zipPost.scaleY=50;
	zipPost.scaleX=4;
	[zipPost setPosition:ccp(BUILDING2LEFT-6,ROOF+6)];
	[self addChild:zipPost z:self.zOrder+1];
	
	float sStartX = building2.position.x-(building2.contentSize.width/2)+98;
	float sStartY = midBuildingY-building2.contentSize.height/2+156;
	int sCount=0;
	sniperIndex = (int) arc4random() % 16;
	CCLOG(@"sniperIndex:%d",sniperIndex);
	for (int x=0; x<4;x++) {
		for (int y=0; y<4;y++) {
			if (sCount == sniperIndex) {
				sniperLocation = ccp(sStartX+(126*x),sStartY+(96*y));
				//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
				sniperWindow = [CCSprite spriteWithFile:@"sniperwindow.png"];
				[self addChild:sniperWindow z:2];
				
				sniper = [[Sniper alloc] initWithFile: @"sniper.png"];	 
				[sniper setPosition:ccp(-10000,-10000)];
				sniper.color=ccRED;
				//[sniperWindow addChild:sniper z:3];
				[self addChild:sniper z:sniperWindow.zOrder+1];
				[self hideSniper];
				
				CCSprite *sniperRifle = [CCSprite spriteWithFile:@"sniperrifle.png"];
				sniperRifle.anchorPoint=ccp(0.5,0.5);
				[sniperRifle setPosition:ccp(0,18)];
				sniperRifle.rotation=-5;
				[sniper addChild:sniperRifle z:-1];
				
				CCSprite *hat = [CCSprite spriteWithFile:@"hat1.png"];
				hat.anchorPoint=ccp(0.5,0.5);
				[hat setPosition:ccp(sniper.contentSize.width/2,sniper.contentSize.height-hat.contentSize.height/2)];
				//[hat setPosition:ccp(self.contentSize.width/2,self.contentSize.height)];
				[sniper addChild:hat z:sniper.zOrder+1];
				//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; 
				goto outer;
			}
			sCount++;
		}
	}
outer:;
	//CCLOG(@"sniperlocation:%f",sniperLocation.x);
	
	if ([AppDelegate get].lowRes == 1)
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	CCSprite *bg = [CCSprite spriteWithFile:@"mainbldg1.png"];
	[bg setPosition:ccp(-300.0f,midBuildingY)];
	[self addChild:bg z:4];
	if ([AppDelegate get].lowRes == 1)
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
	CCSprite *flag = [CCSprite spriteWithFile:@"flag.png"];
	[flag setPosition:ccp(BUILDINGEDGE+20,ROOF+20)];
	[self addChild:flag z:bg.zOrder];
	
	/*CCAnimation *animateFlag = [CCAnimation animationWithName:@"animFlag"];
	 [animateFlag addFrameWithFilename:@"flag1.png"];
	 [animateFlag addFrameWithFilename:@"flag.png"];
	 id actionFlag = [CCAnimate actionWithDuration:2 animation:animateFlag restoreOriginalFrame:NO];
	 [flag runAction: [CCRepeatForever actionWithAction:actionFlag]];*/
	
	rope = [CCSprite spriteWithFile:@"b1px.png"];
	rope.visible = NO;
	rope.scaleX=2;
	rope.scaleY=bg.contentSize.height-56;
	[rope setPosition:ccp(BUILDINGEDGE-12,bg.position.y-10)];
	[self addChild:rope z:bg.zOrder];
	
	
	// Escalator 1/2
	CCSprite *escalator1 = [CCSprite spriteWithFile:@"escalator.png"];
	escalator1.flipX=TRUE;
	[escalator1 setPosition:ccp(bg.position.x-26,FLOOR1Y+escalator1.contentSize.height/3-8)];
	[self addChild:escalator1 z:3];
	
	// Escalator 4/5
	CCSprite *escalator2 = [CCSprite spriteWithFile:@"escalator.png"];
	[escalator2 setPosition:ccp(bg.position.x-16,FLOOR4Y+escalator2.contentSize.height/3-8)];
	[self addChild:escalator2 z:3];
	
	float floorstartX = bg.position.x+20;
	
	CCSprite *f5 = [CCSprite spriteWithFile:@"mainbldgfloor.png"];
	[f5 setPosition:ccp(floorstartX,midBuildingY+163.0f)];
	[self addChild:f5 z:1];
	
	CCSprite *f4 = [CCSprite spriteWithFile:@"mainbldgfloor.png"];
	[f4 setPosition:ccp(floorstartX,midBuildingY+66.0f)];
	[self addChild:f4 z:1];
	
	CCSprite *f3 = [CCSprite spriteWithFile:@"mainbldgfloor.png"];
	[f3 setPosition:ccp(floorstartX,midBuildingY-30.0f)];
	[self addChild:f3 z:1];
	
	CCSprite *f2 = [CCSprite spriteWithFile:@"mainbldgfloor.png"];
	[f2 setPosition:ccp(floorstartX,midBuildingY-127.0f)];
	[self addChild:f2 z:1];
	
	CCSprite *f1 = [CCSprite spriteWithFile:@"mainbldgfloor.png"];
	[f1 setPosition:ccp(floorstartX,midBuildingY-222.0f)];
	[self addChild:f1 z:1];
	
	CCSprite *re = [CCSprite spriteWithFile:@"elevatorhalf.png"];
	[re setPosition:ccp(ELEVATORX+9,ROOF+18)];
	[self addChild:re z:bg.zOrder+3];
	
	zipline = [CCSprite spriteWithFile:@"b1px.png"];
	zipline.visible = NO;
	zipline.scaleX=BUILDING2LEFT-BUILDINGEDGE+6;
	zipline.scaleY=2;
	[zipline setRotation:-21];
	[zipline setPosition:ccp(BUILDINGEDGE+(270),FLOOR5Y+25)];
	[self addChild:zipline z:bg.zOrder];
	
	// President
	pres = [CCSprite spriteWithFile:@"stand.png"];
	[pres setPosition:ccp(PREZX, FLOOR3Y-4)];
	pres.color=ccBLACK;
	[self addChild:pres z:3];
	CCSprite *patch = [CCSprite spriteWithFile:@"eyepatch.png"];
	patch.anchorPoint=ccp(0.5,0);
	[patch setPosition:ccp(pres.contentSize.width/2,34)];
	[pres addChild:patch z:pres.zOrder+1];
	
	// President
	presHostage = [CCSprite spriteWithFile:@"parachuteguy.png"];
	[presHostage setPosition:ccp(-10000,-10000)];
	presHostage.color=ccBLACK;
	[self addChild:presHostage z:pres.zOrder];
	
	CCSprite *patch2 = [CCSprite spriteWithFile:@"eyepatch.png"];
	patch2.anchorPoint=ccp(0.5,0);
	[patch2 setPosition:ccp(presHostage.contentSize.width/2,34)];
	[presHostage addChild:patch2 z:presHostage.zOrder+1];
	
	// Desk
	desk = [CCSprite spriteWithFile:@"desk.png"];
	[desk setPosition:ccp(PREZX, FLOOR3Y-desk.contentSize.height/2)];
	[self addChild:desk z:pres.zOrder];
	
	[self makeBuilding:1 y:4 cc:ccc3(186,153,8) cg:ccp(570,-700)];
	[self makeBuilding:1 y:3 cc:ccc3(186,153,8) cg:ccp(520,-690)];
	[self makeBuilding:1 y:5 cc:ccc3(186,153,8) cg:ccp(-680,-710)];
	
	if ([AppDelegate get].multiplayer > 0) {
		/*if ([AppDelegate get].playerWager > 0) {
			[AppDelegate get].playerWager = 20;
			[AppDelegate get].loadout.g -= [AppDelegate get].playerWager;
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
		}*/
		
		CCLabelTTF *opLabel = [CCLabelTTF labelWithString:@"Opponent" fontName:[AppDelegate get].clearFont fontSize:20];
		opLabel.position = ccp(800,billboard.position.y+30);
		opLabel.color = ccBLACK;
		[self addChild:opLabel z:1];
	}
	else {
		[AppDelegate get].currentOpponent = @"Got Perks?";
	}
	
	CCLabelTTF *opponent = [CCLabelTTF labelWithString:[AppDelegate get].currentOpponent fontName:[AppDelegate get].clearFont fontSize:34];
	opponent.position = ccp(800,billboard.position.y);
	opponent.color = ccBLACK;
	//info1.anchorPoint=ccp(0,0);
	[self addChild:opponent z:1];
	
	//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	countDown = -1;

    [self schedule: @selector(checkHostage) interval: 0.1];

	if ([[AppDelegate get] perkEnabled:8]) {
		[self launchGrunt];
		if ([AppDelegate get].multiplayer > 0 && [[AppDelegate get] myPerk:16]) {
			[[AppDelegate get].gkHelper sendAttack:CODEAGENT];
		}
		[self schedule: @selector(doConscription) interval: 20];
	}
	else if ([[AppDelegate get] perkEnabled:24]) {
		[self schedule: @selector(doForcedAction) interval: 20];
	}
	officePartyCount = 0;
	if ([[AppDelegate get] perkEnabled:18]) {
		[self launchOfficeParty];
	}
	if ([[AppDelegate get] perkEnabled:14]) {
		[self launchSecurity];
	}
	
	//timer
	if ([AppDelegate get].multiplayer > 0) {
		gameMins = 1;
		[self schedule: @selector(doMins) interval: 60];
		myBeat = 0;
		theirBeat = 0;
		[self schedule: @selector(beat) interval: 1];
        
	}
	self.position = ccp(-pres.position.x,pres.position.y);
    
}

-(void) beat {
    myBeat++;
    CCLOG(@"MyBeat:%i TheirBeat:%i",myBeat,theirBeat);
    [[AppDelegate get].gkHelper sendAttack:HEARTBEAT];
    if (myBeat - theirBeat > 30) {
        [self onAttackReceived:HEARTBEAT pid:@"me"];
    }
    
}

-(void) doMins {
	if (gameMins > MINMINS) {
		[AppDelegate showNotification:@"Computer Auto-Launch Initiated"];
		[self launchGrunt];
		[self launchParachute];
		[self launchJumper];
	}
	if (gameMins > MINMINS+1) {
		[self launchArmor];
	}
	if (gameMins > MINMINS+2) {
		[self launchHelicopter];
	}
	if (gameMins > MINMINS+3) {
		[self launchTruck];
	}
	if (gameMins > MINMINS+4) {
		[self launchPlane];
	}
	if (gameMins > MINMINS+5) {
		[self launchDirt];
	}
	if (gameMins > MINMINS+6) {
		[self launchInverted];
	}
	gameMins++;
}

-(void) doHeadshot:(CGPoint) p i:(int) i {
	if ([AppDelegate get].headshotStreak > 2) {
		[AppDelegate get].money+=5*[AppDelegate get].headshotStreak;
		if ([[AppDelegate get] perkEnabled:19])
			[AppDelegate get].money+=1.5*[AppDelegate get].headshotStreak;
	}
	
	[headshotLabel stopAllActions];
	int headshotID = 12+([AppDelegate get].headshotStreak % 8);
	if (i == 3 && headshotID % 13 == 0) {
		headshotID = 21;
		[headshotLabel setString:[NSString stringWithFormat:@"Bodyshot\nStreak x %i",[AppDelegate get].headshotStreak]];
	}
	else {
		int x = [AppDelegate get].headshotStreak % 8;
		//if (x < 0)
		//	x = 0;
		//CCLOG(@"index:%i,hss:%i,headshotID:%i",x,[AppDelegate get].headshotStreak,headshotID);
		[headshotLabel setString:[NSString stringWithFormat:@"%@\nStreak x %i",[streakName objectAtIndex:x],[AppDelegate get].headshotStreak]];
	}
	headshotLabel.position = ccp(p.x,p.y+40);
	headshotLabel.visible=YES;
	
	[[AppDelegate get].soundEngine playSound:headshotID sourceGroupId:0 pitch:1.0f pan:0.0f gain:1.0f loop:NO];
	[headshotLabel runAction: [CCFadeOut actionWithDuration:1]]; 
	if ([AppDelegate get].gameType == SURVIVAL && [AppDelegate get].headshotStreak % 16 == 0) {
		if (machinegunAvailable == TRUE) {
			CCLOG(@"unlocked machine gun");
			[self sendMyIntel:@"Machine Gun Ready"];
			[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showMachinegun];
			machinegunAvailable = FALSE;
		}
		else if (bombAvailable == TRUE) {
			CCLOG(@"unlocked armageddon");
			[self sendMyIntel:@"Armaggedon Ready"];
			[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showArmageddon];
			bombAvailable = FALSE;
		}
		else if (securityAvailable == TRUE) {
			CCLOG(@"unlocked security guards");
			[self sendMyIntel:@"Body Guards"];
			[self launchSecurity];
			securityAvailable = FALSE;
		} 
	}
}

- (void) showRope {
	rope.visible=YES;
}

- (void) showZipline {
	zipline.visible=YES;
}
- (void) hideZipline {
	int found = 0;
	for (Enemy *e in [AppDelegate get].enemies) {
		if (e.currentState == RAPPEL) {
			found = 1;
			goto foundit;
		}
	}
foundit:
	if (found == 0)
		zipline.visible=NO;
}

- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B) cc cg:(CGPoint)cg
{
	for (int i=0;i<x;i++) {
		for (int j=0;j<y;j++) {
			CCSprite *part= [CCSprite spriteWithFile:@"cube.png"];
			part.color=cc;
			part.position=ccp(cg.x+i*part.contentSize.width/1.6,cg.y+j*part.contentSize.height/1.7);
			[self addChild:part z:50];
			CCSprite *window= [CCSprite spriteWithFile:@"window.png"];
			window.position=ccp(part.contentSize.width/2,part.contentSize.height/2+window.contentSize.height/7);
			window.anchorPoint=ccp(1,1);
			[part addChild:window];
			CCSprite *windowside= [CCSprite spriteWithFile:@"windowside.png"];
			windowside.position=ccp(part.contentSize.width-windowside.contentSize.width/4,part.contentSize.height/2+windowside.contentSize.height/2.4);
			windowside.anchorPoint=ccp(1,1);
			[part addChild:windowside];
		}
	}
}


/*-(void) updateBillboard: (NSString*) alias {
	//Billboard text
	CCLOG(@"udpate billboard");
	opLabel.visible=TRUE;
	[opponent setString: [NSString stringWithFormat:@"%@",alias]];
}*/

-(CGPoint) getSniperPos {
	return [sniper convertToWorldSpace:ccp(0.5,0.5)];
}

-(void) checkHostage {
	if ([AppDelegate get].kidnappers > 0) {
		//CCLOG(@"checkHostage");
		presHostage.position = ccp(PREZX, FLOOR3Y-4);
		pres.position = ccp(-4000,-4000);
		if ([AppDelegate get].gameType != SURVIVAL) {
			//CCLOG(@"checkHostage:showSniper");
			[self showSniper];
		}
		else if (countDown == COUNTDOWN){
			//CCLOG(@"checkHostage:begin countdown");
			countDown--;
			if ([AppDelegate get].gameType == SURVIVAL && [AppDelegate get].survivalMode == 1)
				[self schedule: @selector(doCountdown) interval: 0.5];
			else
				[self schedule: @selector(doCountdown) interval: 1];
		}
	}
	else if (countDown != -1) {
		CCLOG(@"checkHostage:end countdown");
		countDown = -1;
		[[AppDelegate get].soundEngine stopSound:alertID];
		presHostage.position = ccp(-10000,-10000);
		pres.position = ccp(PREZX, FLOOR3Y-4);
		if ([AppDelegate get].gameType != SURVIVAL) {
			[self hideSniper];
		}
		else {
			[self unschedule: @selector(doCountdown)];
		}
	} else if ([AppDelegate get].kidnappers < 0) {
		[AppDelegate get].kidnappers=0;
	}
}

-(void) doConscription {
	[self launchGrunt];
	if ([AppDelegate get].multiplayer > 0 && [[AppDelegate get] myPerk:16]) {
		[[AppDelegate get].gkHelper sendAttack:CODEAGENT];
	}
}

-(void) doForcedAction {
	CCLOG(@"forcedAction");
    //1.7
	[AppDelegate get].money += 50; //30;
}

-(void) doCountdown {
	CCLOG(@"countdown:%i",countDown);
	if (countDown == 0)
		[[CCDirector sharedDirector] replaceScene:[LoseScene node]];
	else
		countDown--;
}

-(void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	float moveX = (acceleration.x * kFilteringFactor) + (lastAngleX * (1.0 - kFilteringFactor));
    float moveY = (acceleration.y * kFilteringFactor) + (lastAngleY * (1.0 - kFilteringFactor));

	lastAngleY = moveX;
	lastAngleX = moveY;
	
	moveX *= -kAccelMultiple;
	moveY *= kAccelMultiple;
	
	if ([AppDelegate get].reload == 0)
		[self moveBGPostion:moveY y:moveX];
}

-(void) showSniper
{
	sniperWindow.position = sniperLocation;
	//CGPoint x = [sniperWindow convertToWorldSpace:CGPointZero];
	sniper.position=ccp(sniperWindow.position.x-sniperWindow.contentSize.width/2+34,sniperWindow.position.y-sniperWindow.contentSize.height/2+12);
	if ([AppDelegate get].gameType != SURVIVAL)
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] showSniper];
}

-(void) hideSniper
{
	sniperWindow.position = ccp(-10000,-10000);
	sniper.position = ccp(-10000,-10000);	
	if ([AppDelegate get].gameType != SURVIVAL)
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] hideSniper];
}

-(BOOL) leftOfSniper {
	float x = [self convertToWorldSpace:CGPointZero].x;
	//CCLOG(@"bg orig:%f scale:%f",x,[AppDelegate get].scale);
	x = 350 - x;
	if ([AppDelegate get].scale == [AppDelegate get].minZoom)
		x*=2;
	//CCLOG(@"bg:%f sniper:%f",x,sniperLocation.x);
	return (x < sniperLocation.x);
}

-(void) onAttackReceived:(int)attack pid:(NSString*)pid {
	if ([AppDelegate get].multiplayer > 0 && [[AppDelegate get] perkEnabled:24] && attack < CODEPERK2) {
		[self unschedule: @selector(doForcedAction)];
		[self schedule: @selector(doForcedAction) interval: 20];
	}
    
	switch (attack)
    {
        case CODEAGENT: // Agent
			[self launchGrunt];
			if ([[AppDelegate get] perkEnabled:7])
				[self launchGrunt];
			break;
        case CODECITIZEN: // Citizen
			[self launchCitizen];
			if ([[AppDelegate get] perkEnabled:7])
				[self launchCitizen];
			break;
        case CODEPARACHUTE: // Parachute
			[self launchParachute];
			if ([[AppDelegate get] perkEnabled:7])
				[self launchParachute];
			break;
        case CODEJUMPER: // Jumper
			[self launchJumper];
			break;
        case CODEINVERTED: // Inverted Scope
			[self launchInverted];
			break;
        case CODETHUMB: // Dirty Scope
			[self launchDirt];
			break;
        case CODERECON: // Recon
			[self launchRecon];
			break;
        case CODEANTI: // Anti-Recon
			[self launchAnti];
			break;
        case CODEARMOR: // Armor
			[self launchArmor];
			break;
        case CODEPLANE: // Plane
			[self launchPlane];
			break;
        case CODETRUCK: // Truck
			[self launchTruck];
			break;
        case CODECHOPPER: // Helicopter
			[self launchHelicopter];
			break;
        case CODEPERK1: // Armageddon
			[self launchArmageddon];
			break;
		case CODEPERK1TAKEN: //Armageddon Taken
			bombAvailable = FALSE;
			[[[AppDelegate get].m5.childButtons objectAtIndex:0] disable];
			break;
        case CODEPERK2: // Machine Gun
			machinegunAvailable = FALSE;
			[[[AppDelegate get].m5.childButtons objectAtIndex:1] disable];
			break;
        case CODEPERK3: // Security
			securityAvailable = FALSE;
			[[[AppDelegate get].m5.childButtons objectAtIndex:2] disable];
			break;
		case KIDNAPPERDEAD:
			[self launchKidnapperDead];
			break;	
		case SNIPERFOUND: 
			[self launchSniperFound];
			break;		
/*		case CODEPARTY: 
			[self launchOfficeParty];
			break;	*/
		case CODEINNOCENT: // Shot innocent
			[self launchInnocent];
			break;	
		case CODELOSE: // You Lose
			[AppDelegate get].gameState = NOGAME;
			[[CCDirector sharedDirector] replaceScene:[LoseScene node]];
			break;
		case DISCONNECT: // You Win
			//[AppDelegate showNotification:[NSString stringWithFormat:@"Player: %@ disconnected", [AppDelegate get].currentOpponent]];
			[AppDelegate get].gameState = NOGAME;
			if ([AppDelegate get].friendInvite == 1) 
				[AppDelegate get].friendInvite = -2;
			[AppDelegate showNotification:@"Opponent disconnected"];
			[[CCDirector sharedDirector] replaceScene:[WinScene node]];
			break;
		case HEARTBEAT: // heartbeat
			theirBeat++;
			CCLOG(@"Got heartbeat:%i",theirBeat);
			break;
        case CODEOVERDRAFT: // overdraft fee
			[AppDelegate get].money+=10;
            //[self sendMyIntel:@"100 Bonus"];
			//[self sendMyIntel:@"Overdraft"];
            [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"100"];
			break;
        case CODEAMMODEPOT: // ammo depot
			[AppDelegate get].money+=10;
            /*[self sendMyIntel:@"100 Bonus"];
			[self sendMyIntel:@"Ammo Depot"];*/
            [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"100"];
			break;
        case CODESCRAPMETAL: // CODESCRAPMETAL
            if ([[AppDelegate get] myPerk:38]) {
                [AppDelegate get].money+=80;
                //[self sendMyIntel:@"800 Bonus"];
                //[self sendMyIntel:@"Scrap Metal"];
                [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"800"];
            }
			break;
    }
}

-(void) showBonus:(NSString*)bonus {
    [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:bonus];
}

-(void) menuAttack:(int)attack {
	if ([AppDelegate get].gameType == SANDBOX && [[AppDelegate get] perkEnabled:24] && attack < CODEPERK2) {
		[self unschedule: @selector(doForcedAction)];
		[self schedule: @selector(doForcedAction) interval: 20];
	}
	switch (attack)
    {
        case CODEAGENT: // Agent
			if ([AppDelegate get].money-T1 >-1) {
				[AppDelegate get].money-=T1;
				[self sendMyIntel:@"Agent"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					//[self sendMyIntel:@"Mutiny"];
					CCLOG(@"Mutiny");
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0) {
					[[AppDelegate get].gkHelper sendAttack:attack];
				}
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) {
						[self launchGrunt];
				}
				if ([[AppDelegate get] perkEnabled:16]) {
					//[self sendMyIntel:@"CopyCat =^.^="];
					[self launchGrunt];
				}
			}
			break;
        case CODECITIZEN: // Citizen
			if ([AppDelegate get].money-T1 >-1) {
				[AppDelegate get].money-=T1;
				[self sendMyIntel:@"Citizen"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0) {
					[[AppDelegate get].gkHelper sendAttack:attack];
				}
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) {
					[self launchCitizen];
				}
				if ([[AppDelegate get] perkEnabled:16]) {
					//[self sendMyIntel:@"CopyCat =^.^="];
					[self launchCitizen];
				}
			}
			break;
        case CODEPARACHUTE: // Parachute
			if ([AppDelegate get].money-T1 >-1) {
				[AppDelegate get].money-=T1;
				[self sendMyIntel:@"Paratrooper"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0) {
					[[AppDelegate get].gkHelper sendAttack:attack];
				}
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) {
					[self launchParachute];
				}
				if ([[AppDelegate get] perkEnabled:16]) {
					//[self sendMyIntel:@"CopyCat =^.^="];
					[self launchParachute];
				}
			}
			break;
        case CODEJUMPER: // Jumper
			if ([AppDelegate get].money-T2 >-1) {
				[AppDelegate get].money-=T2;
				[self sendMyIntel:@"Zipliner"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchJumper];
				if ([[AppDelegate get] perkEnabled:16]) {
					//[self sendMyIntel:@"CopyCat =^.^="];
					[self launchJumper];
				}
			}
			break;
        case CODEINVERTED: // Inverted Scope
			if ([AppDelegate get].money-T2 >-1) {
				[AppDelegate get].money-=T2;
				[self sendMyIntel:@"Inverted Scope"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchInverted];
			}
			break;
        case CODETHUMB: // Dirty Scope
			if ([AppDelegate get].money-T2 >-1) {
				[AppDelegate get].money-=T2;
				[self sendMyIntel:@"Scope Smudge"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchDirt];
			}
			break;
        case CODERECON: // Recon
			if ([AppDelegate get].money-T3 >-1) {
				[AppDelegate get].money-=T3;
				[self sendMyIntel:@"Recon Enabled"];
				[self launchRecon];
			}
			break;
        case CODEANTI: // Anti-Recon
			if ([AppDelegate get].money-T3 >-1) {
				[AppDelegate get].money-=T3;
				[self sendMyIntel:@"Anti Recon"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchAnti];
			}
			break;
        case CODEARMOR: // Armor
			if ([AppDelegate get].money-T3 >-1) {
				[AppDelegate get].money-=T3;
				[self sendMyIntel:@"Armored Vehicle"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchArmor];
			}
			break;
        case CODEPLANE: // Plane
			if ([AppDelegate get].money-T4 >-1) {
				[AppDelegate get].money-=T4;
				[self sendMyIntel:@"Plane"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchPlane];
			}
			break;
        case CODETRUCK: // Truck
			if ([AppDelegate get].money-T4 >-1) {
				[AppDelegate get].money-=T4;
				[self sendMyIntel:@"Pickup Truck"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchTruck];
			}
			break;
        case CODECHOPPER: // Helicopter
			if ([AppDelegate get].money-T4 >-1) {
				[AppDelegate get].money-=T4;
				[self sendMyIntel:@"Helicopter"];
				if ([[AppDelegate get] perkEnabled:9] && mutinyCount < 5) {
					mutinyCount++;
					CCLOG(@"Mutiny");
					//[self sendMyIntel:@"Mutiny"];
					[self onAttackReceived:attack pid:nil];
					break;
				}
				if ([AppDelegate get].multiplayer > 0)
					[[AppDelegate get].gkHelper sendAttack:attack];
				else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
					[self launchHelicopter];
			}
			break;
        case CODEPERK1: // Armageddon
			if ([AppDelegate get].money-T5 >-1 && bombAvailable) {
				[self sendMyIntel:@"Armageddon Ready"];
				if ([AppDelegate get].multiplayer > 0) {
					[AppDelegate get].money-=T5;
					bombAvailable = FALSE;
					[[AppDelegate get].gkHelper sendAttack:CODEPERK1TAKEN];
				}
				[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showArmageddon];
			}
			break;
        case CODEPERK2: // MachineGun
			if ([AppDelegate get].money-T5 >-1 && machinegunAvailable) {
				[AppDelegate get].money-=T5;
				[self sendMyIntel:@"Machine Gun Ready"];
				if ([AppDelegate get].multiplayer > 0) {
					machinegunAvailable = FALSE;
					[[AppDelegate get].gkHelper sendAttack:attack];
				}
				[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showMachinegun];
			}
			break;
        case CODEPERK3: // Security
			if ([AppDelegate get].money-T5 >-1 && securityAvailable) {
				[AppDelegate get].money-=T5;
				securityAvailable = FALSE;
				[self sendMyIntel:@"Body Guards"];
				if ([AppDelegate get].multiplayer > 0) {
					[[AppDelegate get].gkHelper sendAttack:attack];
				}
				[self launchSecurity];
			}
			break;	
		case KIDNAPPERDEAD: // Kidnapper Dead
			[self sendMyIntel:@"Interrogator Dead"];
			[self sendIntel:@"Interrogator Dead"];
			if ([AppDelegate get].multiplayer > 0)
				[[AppDelegate get].gkHelper sendAttack:attack];
			else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) 
				[self launchKidnapperDead];
			break;
		case SNIPERFOUND: // Sniper Found
			[self sendMyIntel:@"Sniper Located"];
			//[self sendIntel:@"Sniper Located"];
//			[self sniperAlert];
			if ([AppDelegate get].multiplayer > 0) {
                if ([[AppDelegate get] perkEnabled:45])
                    [self schedule: @selector(delaySniperAlert) interval: 3];
                else
                    [[AppDelegate get].gkHelper sendAttack:attack];
            }
			else if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL) {
				if ([[AppDelegate get] perkEnabled:45])
                    [self schedule: @selector(delaySniperAlert) interval: 3];
                else
                    [self launchSniperFound];
            }
			break;
		case CODEINNOCENT: // Shot innocent
			//if (![[AppDelegate get] perkEnabled:19]) {
            //1.7
            [self sendMyIntel:@"Citizen Shot"];
            [self sendMyIntel:@"Planes Incoming"];
            if (([AppDelegate get].multiplayer>0 || ([AppDelegate get].gameType == SANDBOX && [AppDelegate get].sandboxMode != 1)) && ![[AppDelegate get] perkEnabled:36]) {
                [AppDelegate get].money = 0;
                [[AppDelegate get].gkHelper sendAttack:CODEOVERDRAFT];
            }
            if ([[AppDelegate get] perkEnabled:36]) {
                [self sendMyIntel:@"Hush Money Paid"];
            }
            [self launchInnocent];
			//}
			break;		
		case CODELOSE: // You Win
			CCLOG(@"CODELOSE");
			if ([AppDelegate get].multiplayer > 0)
				[[AppDelegate get].gkHelper sendAttack:attack];
			//[self unscheduleAllSelectors];
			[self schedule: @selector(delayWin) interval: 1];
			break;
        case CODESCRAPMETAL: // CODESCRAPMETAL
            if ([AppDelegate get].multiplayer > 0 && [[AppDelegate get] perkEnabled:38]) {
                    [[AppDelegate get].gkHelper sendAttack:attack];
            }
            if ([[AppDelegate get] myPerk:38] && [AppDelegate get].gameType != SURVIVAL) {
                    [AppDelegate get].money+=80;
                    //[self sendMyIntel:@"400 Bonus"];
                    //[self sendMyIntel:@"Scrap Metal"];
                    [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"800"];
            }
            break;
    }
    
    // 3Peat Penalty
    if ([[AppDelegate get] perkEnabled:29]) {
        if (attack < CODEPERK1) {
            if (attack == lastAttack)
                lastAttackCount++;
            else 
                lastAttackCount=0;
            lastAttack = attack;
            if (lastAttackCount>2) {
                lastAttackCount = 0;
                //[self sendMyIntel:@"3Peat Penalty"];
                [self sendMyIntel:@"Plane"];
                [self launchPlane];
            }
        }
    }
    // Overdraft
    if ([AppDelegate get].money<6.5 && [[AppDelegate get] perkEnabled:31]) {
        [[AppDelegate get].gkHelper sendAttack:CODEOVERDRAFT];
        if ([[AppDelegate get] myPerk:38] && [AppDelegate get].gameType == SANDBOX) {
            [AppDelegate get].money+=10;
            [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"100"];
        }
    }
}

-(void) delaySniperAlert {
    [self unschedule: @selector(delaySniperAlert)];
    //if ([AppDelegate get].kidnappers > 0) {
        if ([AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == SURVIVAL)
            [self launchSniperFound];
        else
            [[AppDelegate get].gkHelper sendAttack:SNIPERFOUND];
    //}
}

-(void) delayWin {
	CCLOG(@"Delay Win");
	[AppDelegate get].gameState = NOGAME;
	[self unschedule: @selector(delayWin)];
	[[CCDirector sharedDirector] replaceScene:[WinScene node]];
}

-(void) zoomButtonPressed {
	//CCLOG(@"Fire Button Pressed");
	if ([AppDelegate get].scale == [AppDelegate get].maxZoom) {
		[self setZoom:[AppDelegate get].minZoom];
		[(ForegroundLayer*) [self.parent getChildByTag:kForegroundLayer] setZoom:[AppDelegate get].minZoom];
		[(MidgroundLayer*) [self.parent getChildByTag:kMidgroundLayer] setZoom:[AppDelegate get].minZoom];
		[(SkylineLayer*) [self.parent getChildByTag:kSkylineLayer] setZoom:[AppDelegate get].minZoom];
	}
	else {
		[self setZoom:[AppDelegate get].maxZoom];
		[(ForegroundLayer*) [self.parent getChildByTag:kForegroundLayer] setZoom:[AppDelegate get].maxZoom];
		[(MidgroundLayer*) [self.parent getChildByTag:kMidgroundLayer] setZoom:[AppDelegate get].maxZoom];
		[(SkylineLayer*) [self.parent getChildByTag:kSkylineLayer] setZoom:[AppDelegate get].maxZoom];
	}
}

-(void) sendIntel:(NSString*)s {
	CCLOG(@"Send Intel");
	//if (([AppDelegate get].gameType != SANDBOX && [AppDelegate get].recon == 1))
	if ([AppDelegate get].recon > 0) {
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] updateInfo:s cc:ccRED];
		CCLOG(@"intel sent");
	}
}

-(void) sendMyIntel:(NSString*)s {
/*	if ([[AppDelegate get] perkEnabled:15] && ![[AppDelegate get] perkEnabled:15]) {
		int tauntIndex = (arc4random() % [taunts count]);
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] updateInfo:[taunts objectAtIndex:tauntIndex] cc:ccYELLOW];
	}
	else {*/
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] updateInfo:s cc:ccGREEN];
	//}
}

-(void)launchSniperFound {
	CCLOG(@"Sniper Found");
	[AppDelegate get].kidnappers++;
	if (countDown == -1) {
		alertID = [[AppDelegate get].soundEngine playSound:8 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:YES];
		countDown = COUNTDOWN;
	}
    // Auto-Snipe
    if ([[AppDelegate get] myPerk:47]) {
        int adjustX = floor(sniperIndex / 4) * -126;
        int adjustY = (sniperIndex % 4) * 96;
        float newX = -318 + adjustX;
        newX+=(([[UIScreen mainScreen] bounds].size.height-480)/2);
        float newY = 222 - adjustY;

        [AppDelegate get].scale = [AppDelegate get].minZoom;
        [self zoomButtonPressed];
        self.position = ccp(newX,newY);
        //CCLOG(@"selfposition2:%f,%f",self.position.x,self.position.y);
    }
}

-(void)launchKidnapperDead {
	CCLOG(@"Kidnapper Dead");
	[AppDelegate get].kidnappers--;
}

-(void)launchGrunt {
	CCLOG(@"launchAgent");
	Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
	enemy.color = ccRED;
	[enemy startMoving:ccp(0,0)];
	[self sendIntel:@"Agent"];
}

-(void)launchCitizen {
	CCLOG(@"launchCitizen");
	Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:nil];
	[enemy setType:CITIZEN];
	enemy.color = ccRED;
	[enemy startMoving:ccp(0,0)];
	[self sendIntel:@"Citizen"];
}

-(void)launchOfficeParty {
	CCLOG(@"launchParty");
	officePartyCount++;
	if (officePartyCount == 1)
		[self schedule: @selector(launchOfficeParty) interval: 0.5];
	Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:nil];
	[enemy setType:CITIZEN];
	enemy.color = ccRED;
	[enemy startMoving:ccp(1,1)];
	if (officePartyCount > 9) {
		[self sendMyIntel:@"Office Party!"];
		[self unschedule: @selector(launchOfficeParty)];
	}
}

-(void) launchInnocent {
	//if (![[AppDelegate get] perkEnabled:19]) {
		CCLOG(@"launchInnocent");
		[self launchPlane];
	//}
}

-(void)launchParachute {
	CCLOG(@"launchParachute");
	Enemy *enemy = [[Enemy alloc] initWithFile: @"parachuteguy.png" l:self h:@"hat1.png"];
	[enemy setType:PARACHUTER];
	enemy.color = ccRED;
	int start = arc4random() % ([[AppDelegate get].planeStartPoint count]-1) + 1;
	LinearPoint *p = [[AppDelegate get].planeStartPoint objectAtIndex:start];
	[enemy startMoving:p.point];
	[self sendIntel:@"Paratrooper"];
}

-(void)launchJumper {
	CCLOG(@"launchJumper");
	Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];
	[enemy setType:JUMPER];
	enemy.color = ccRED;
	[enemy startMoving:ccp(0,0)];
	[self sendIntel:@"Zipliner"];
}

-(void)launchInverted {
	CCLOG(@"launchInverted");
	if (![[AppDelegate get] perkEnabled:12]) {
        if ([[AppDelegate get] perkEnabled:26]) //Double Sabotage
            invertKills+=6;
        else
            invertKills+=3;
		[self sendIntel:@"Inverted Scope"];	
	}
}

-(void)launchDirt {
	CCLOG(@"launchDirt");
	if (![[AppDelegate get] perkEnabled:12]) {
        if ([[AppDelegate get] perkEnabled:26]) //Double Sabotage
            dirtKills+=6;
        else
            dirtKills+=3;
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] blurryOn];
		[self sendIntel:@"Scope Smudge"];
	}
}

-(void)launchRecon {
	CCLOG(@"launchRecon");
	//if ([[AppDelegate get] perkEnabled:11])
	[AppDelegate get].recon++;
	[[[AppDelegate get].m3.childButtons objectAtIndex:0] disable];
	//[self sendIntel:@"Recon Enabled"];
}

-(void)launchAnti {
	CCLOG(@"launchAnti");
	if (![[AppDelegate get] perkEnabled:11]) {
		[self sendIntel:@"Anti Recon"];
		[self sendIntel:@"U got Roll'd"];
		[self sendIntel:@"Shoot 3 jammers"];
		for (int x=0; x<3;x++) {
			Radio *radio = [[Radio alloc] initWithFile: @"jammer.png" l:self];
			[radio release];
		}
		if ([AppDelegate get].anti == 0)
			jammerID = [[AppDelegate get].soundEngine playSound:7 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:YES];
		[AppDelegate get].anti = 1;
		if ([AppDelegate get].recon > 0)
			[AppDelegate get].recon = -[AppDelegate get].recon;
	}
}

-(void) stopAnti {
	[AppDelegate get].anti = 0;
	[AppDelegate get].recon = abs([AppDelegate get].recon);
	[[AppDelegate get].soundEngine stopSound:jammerID];	
}

-(void)launchArmor {
	CCLOG(@"launchArmor");
	Armored *vehicle = [[Armored alloc] initWithFile: @"hummer.png" l:self a:[AppDelegate get].vehicleStartPoint];
	[self addChild:vehicle z:8];
	[vehicles addObject:vehicle];
	[vehicle startMoving:ccp(0,0)];
	[self sendIntel:@"Armored Vehicle"];
}

-(void)launchPlane {
	CCLOG(@"launchPlane");
	Plane *vehicle = [[Plane alloc] initWithFile: @"plane.png" l:self a:[AppDelegate get].planeStartPoint];
	[self addChild:vehicle z:8];
	[vehicles addObject:vehicle];
	[vehicle startMoving:ccp(0,0)];
    if ([[AppDelegate get] perkEnabled:37]) { // Sneak Attack
        vehicle.visible = NO;
    }
    else {
        [self sendIntel:@"Plane"];
    }
}

-(void)launchHelicopter {
	CCLOG(@"launchHelicopter");
	Helicopter *vehicle = [[Helicopter alloc] initWithFile: @"chopper1.png" l:self a:[AppDelegate get].heliStartPoint];
	[self addChild:vehicle z:8];
	[vehicles addObject:vehicle];
	[vehicle startMoving:ccp(0,0)];
	[self sendIntel:@"Helicopter"];
}

-(void)launchTruck {
	CCLOG(@"launchTruck");
	Truck *vehicle = [[Truck alloc] initWithFile: @"truck1.png" l:self a:[AppDelegate get].vehicleStartPoint];
	[self addChild:vehicle z:8];
	[vehicles addObject:vehicle];
	[vehicle startMoving:ccp(0,0)];
	[self sendIntel:@"Pickup Truck"];
}

-(void)pressedArmageddon {
	if ([AppDelegate get].multiplayer > 0 || ([AppDelegate get].gameType == SANDBOX && [AppDelegate get].sandboxMode != 1)) {
		[AppDelegate get].money = 0;
		[[AppDelegate get].gkHelper sendAttack:CODEPERK1];
        [[AppDelegate get].gkHelper sendAttack:CODEOVERDRAFT];

	}
	[self launchArmageddon];
}

-(void)launchArmageddon
{
	CCLOG(@"launchArmageddon");
	if ([AppDelegate get].gameType != SURVIVAL)
		[self sendIntel:@"Armaggedon"];
	[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] armageddon];
    if (![[AppDelegate get] perkEnabled:35]) { //Bomb Shelter
        for (Enemy *e in [AppDelegate get].enemies) {
            //CCParticleSystem	*emitter = [CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
            //emitter.position = e.position;
            //[self addChild:emitter z:10];
            if (e.type != 100 ) 
                [e kill];
        }
        for (Vehicle *v in vehicles) {
            //CCParticleSystem *emitter = [CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
            //emitter.position = v.position;
            //[self addChild:emitter z:10];
            [v kill];
        }
        [self stopAnti];
        if (security1 > -1) {
            security1 = -1;
            securityGuard1.position = ccp(-10000,-10000);
        }
        if (security2 > -1) {
            security2 = -1;
            securityGuard2.position = ccp(-10000,-10000);
        }
        [[AppDelegate get].soundEngine stopSound:alertID];
        [AppDelegate get].kidnappers = 0;
        [self hideSniper];
        presHostage.position = ccp(-10000,-10000);
        pres.position = ccp(PREZX, FLOOR3Y-4);
    }
}

-(void)launchMachinegun {
	CCLOG(@"launchMachinegun");
	if ([AppDelegate get].gameType != SURVIVAL)
		[self sendIntel:@"Machine Gun"];
	[[AppDelegate get].soundEngine playSound:12 sourceGroupId:0 pitch:1.0f pan:0.0f gain:1.0f loop:NO];
	machinegunCount = 300;
	[(ControlLayer*) [self.parent getChildByTag:kControlLayer] unschedule: @selector(moneyProgress)];
	[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] hideScope];
	[self schedule: @selector(fireMachinegun) interval: 0.05];
	[self unschedule: @selector(checkIfSighted)];
}

-(void) fireMachinegun {
	machinegunCount--;
	[[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[self shotFired];
	if (machinegunCount < 0) {
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] schedule: @selector(moneyProgress) interval: 0.1];
		[self unschedule: @selector(fireMachinegun)];
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] showScope];
		[self schedule: @selector(checkIfSighted) interval: 0.1];
	}
}

-(void)launchSecurity {
	CCLOG(@"launchSecurity");
	[[[AppDelegate get].m5.childButtons objectAtIndex:2] disable];
	//if (securityAvailable) {
	if ([AppDelegate get].gameType != SURVIVAL)
		[self sendIntel:@"Body Guards"];
		security1 = 2;
		security2 = 2;
		securityGuard1 = [CCSprite spriteWithFile:@"stand.png"];
		[securityGuard1 setPosition:ccp(ROOM1+20, FLOOR3Y)];
		securityGuard1.color=ccBLUE;
		[self addChild:securityGuard1 z:1];
		CCSprite *hat1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png", SECURITYHAT]];
		hat1.anchorPoint=ccp(0.5,0);
		//[hat1 setPosition:ccp(pres.contentSize.width/2,32)];
		[hat1 setPosition:ccp(securityGuard1.contentSize.width/2,securityGuard1.contentSize.height-hat1.contentSize.height/2-4)];
		[securityGuard1 addChild:hat1 z:pres.zOrder+1];
		animateFight1 = [CCAnimation animation];
		for( int i=1;i<4;i++) {
			int x = i;
			if (x == 3)
				x = 1;
			[animateFight1 addFrameWithFilename: [NSString stringWithFormat:@"punch%i.png", x]];
		}
		actionFight1 = [[CCAnimate actionWithDuration:0.5 animation:animateFight1 restoreOriginalFrame:NO] retain];
		
		securityGuard2 = [CCSprite spriteWithFile:@"stand.png"];
		[securityGuard2 setPosition:ccp(ROOM2-20, FLOOR3Y)];
		securityGuard2.color=ccBLUE;
		[self addChild:securityGuard2 z:1];
		CCSprite *hat2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png", SECURITYHAT]];
		hat2.anchorPoint=ccp(0.5,0);
		//[hat2 setPosition:ccp(pres.contentSize.width/2,32)];
		[hat2 setPosition:ccp(securityGuard2.contentSize.width/2,securityGuard2.contentSize.height-hat2.contentSize.height/2-4)];
		[securityGuard2 addChild:hat2 z:pres.zOrder+1];
		securityGuard2.flipX = TRUE;
		hat2.flipX = TRUE;
		animateFight2 = [CCAnimation animation];
		for( int i=1;i<4;i++) {
			int x = i;
			if (x == 3)
				x = 1;
			[animateFight2 addFrameWithFilename: [NSString stringWithFormat:@"punch%i.png", x]];
		}
		actionFight2 = [[CCAnimate actionWithDuration:0.5 animation:animateFight2 restoreOriginalFrame:NO] retain];	
	//}
	// Check kidnappers to make fight
	if ([AppDelegate get].kidnappers > 0) {
		for (Enemy *e in [AppDelegate get].enemies) {
			//CCParticleSystem	*emitter = [CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
			//emitter.position = e.position;
			//[self addChild:emitter z:10];
			if (e.kidnapper>0) {
				[e startFight];
				break;
			}
		}
	}
}

-(BOOL) hasSecurity:(int) i {
	if (i == 1) {
		//if (![actionFight1 isRunning])
			[securityGuard1 runAction: [CCRepeatForever actionWithAction:actionFight1]];
		return (security1 >= 0);
	}
	else {
		//if (![actionFight2 isRunning])
			[securityGuard2 runAction: [CCRepeatForever actionWithAction:actionFight2]];
		return (security2 >= 0);
	}
}

-(BOOL) stopFight:(int) i {
	if (i == 91) { // shot during fight
		[securityGuard1 stopAllActions];
		CCSprite *tmp = [CCSprite spriteWithFile:@"stand.png"];
		securityGuard1.texture = tmp.texture;
		return FALSE;
	}
	else if (i == 92) {
		[securityGuard2 stopAllActions];
		CCSprite *tmp = [CCSprite spriteWithFile:@"stand.png"];
		securityGuard2.texture = tmp.texture;
		return FALSE;
	}
	if (i == 1 && security1 > -1) {
		security1--;
		CCLOG(@"security1:%i",security1);
		[securityGuard1 stopAllActions];
		if (security1 < 0 || [[AppDelegate get] perkEnabled:22]) {
			securityGuard1.anchorPoint = ccp(0,0);
			//[securityGuard1 setRotation:90];
			[securityGuard1 runAction: [CCRotateTo actionWithDuration:0.5 angle:90]];
			[securityGuard1 runAction: [CCFadeOut actionWithDuration:2]];
			for (CCSprite *e in securityGuard1.children) {
				[e runAction: [CCFadeOut actionWithDuration:1.9]];
			}
			return TRUE;
		}
		else {
			CCSprite *tmp = [CCSprite spriteWithFile:@"stand.png"];
			securityGuard1.texture = tmp.texture;
			return FALSE;
		}
	}
	else if (security2 > -1) {
		security2--;
		CCLOG(@"security2:%i",security2);
		[securityGuard2 stopAllActions];
		if (security2 < 0 || [[AppDelegate get] perkEnabled:22]) {
			securityGuard2.anchorPoint = ccp(0,0);
			//[securityGuard2 setRotation:90];
			[securityGuard2 runAction: [CCRotateTo actionWithDuration:0.5 angle:90]];
			[securityGuard2 runAction: [CCFadeOut actionWithDuration:2]];
			for (CCSprite *e in securityGuard2.children) {
				[e runAction: [CCFadeOut actionWithDuration:1.9]];
			}
			return TRUE;
		}
		else {
			CCSprite *tmp = [CCSprite spriteWithFile:@"stand.png"];
			securityGuard2.texture = tmp.texture;
			return FALSE;
		}
	}
	return FALSE;
}

- (void) setZoom:(float) z {
	CGPoint orig = self.position;
	float xDiff,yDiff;
	xDiff = self.position.x - 0;
	yDiff = self.position.y - 0;
	//CCLOG(@"diff x:%f y:%f",xDiff,yDiff);
	if (z == [AppDelegate get].maxZoom) {
		//CCLOG(@"diff scale x:%f y:%f",xDiff*0.5f,yDiff*0.5f);
		[[AppDelegate get].soundEngine playSound:5 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		orig.x += xDiff;
		orig.y += yDiff;
	}
	else {
		[[AppDelegate get].soundEngine playSound:6 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		orig.x -= xDiff*z;
		orig.y -= yDiff*z;
	}
	[AppDelegate get].scale = z;
	self.scale = z;
	self.position = ccp(orig.x,orig.y);
}

- (void) moveBGPostion:(float) x y:(float) y {
	//CCLOG(@"moveBGPostion x:%f y:%f",x,y);
	// Adjust x,y
	if (machinegunCount > 0) {
		if (machinegunCount % 2 == 0) {
			x += (arc4random() % 30);
			y -= (arc4random() % 30);
		}
		else {
			x -= (arc4random() % 30);
			y += (arc4random() % 30);
		}
	}
	
	x = x/(([AppDelegate get].sensitivity+1) * 5);
	y = y/(([AppDelegate get].sensitivity+1) * 5);
	
	if (![[AppDelegate get] perkEnabled:12])
		if (invertKills > 0 || [[AppDelegate get] perkEnabled:4]) {
			x = -x;
			y = -y;
		}
	
	//CGSize s = [[CCDirector sharedDirector] winSize];
	CGSize s = CGSizeMake(1024,512);
	
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
	
	//self.position = ccp(round(x),round(y));
	self.position = ccp(x,y);
	//CCLOG(@"x:%f y:%f",x,y);
	[(ForegroundLayer*) [self.parent getChildByTag:kForegroundLayer] moveBGPostion:x*1.1 y:y*1.1];
	[(MidgroundLayer*) [self.parent getChildByTag:kMidgroundLayer] moveBGPostion:x*1.2 y:y*1.2];
	[(SkylineLayer*) [self.parent getChildByTag:kSkylineLayer] moveBGPostion:x*0.8 y:y*0.8];
	//CCLOG(@"x:%f y:%f",self.position.x,self.position.y);
}

- (int) shotFired {
    if ([[AppDelegate get] perkEnabled:41]) { // Ammo Depot
        shotsFired++;
        if (machinegunCount < 1 && shotsFired == 5) {
            if ([AppDelegate get].multiplayer > 0) {
                [[AppDelegate get].gkHelper sendAttack:CODEAMMODEPOT];
            }
            else if ([AppDelegate get].gameType == SANDBOX) {
                [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showBonus:@"100"];
                [AppDelegate get].money +=10;
            }
            shotsFired = 0;
        }
    }
    
	int gotHim = -1;
	int headshot = 0;
	//CCLOG(@"enemies count %i",[[AppDelegate get].enemies count]);
	for (int i = 0; i < (int) [[AppDelegate get].enemies count]; i++) {
		Enemy *enemy = [[AppDelegate get].enemies objectAtIndex:i];
        if (enemy.currentState != DEAD) {
            int wasShot = [enemy checkIfShot];
            //CCLOG(@"wasShot=%i",wasShot);
            if (wasShot > 0) {
                if (wasShot > 1 && enemy.type != CITIZEN) {
                    headshot=1;
                    //CCLOG(@"heashotStreakBefore=%i",[AppDelegate get].headshotStreak);
                    [AppDelegate get].headshotStreak++;
                    if ([AppDelegate get].gameType == SURVIVAL) {
                        if ([AppDelegate get].headshotStreak > [AppDelegate get].killStreak)
                            [AppDelegate get].killStreak = [AppDelegate get].headshotStreak;
                    }
                    [self doHeadshot:enemy.position i:wasShot];
                    //CCLOG(@"heashotStreakAfter=%i",[AppDelegate get].headshotStreak);
                }
                gotHim = i;
                if (dirtKills > 0) {
                    dirtKills--;
                    if (dirtKills == 0/* && ![[AppDelegate get] perkEnabled:27]*/) // Permanent Scope
                        [(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] blurryOff];
                    
                }
                if (invertKills > 0)
                    invertKills--;
                
                if ([[AppDelegate get] myPerk:33] && enemy.type != CITIZEN) {
                    int distance = GetApproxDistance([enemy convertToWorldSpace:CGPointZero], [desk convertToWorldSpace:CGPointZero]) / [AppDelegate get].scale;
                    CCLOG(@"Distance:%i",distance);
                    
                    if (distance > 450) {
                        int prize = 0;
                        if (distance < 700)
                            prize = 1;
                        else if (distance < 900)
                            prize = 2;
                        else if (distance < 1200)
                            prize = 3;
                        else if (distance < 1480)
                            prize = 4;
                        else if (distance < 1580)
                            prize = 6;
                        else
                            prize = 10;
                        [AppDelegate get].money += prize;
                        [self showBonus:[NSString stringWithFormat:@"%i",prize*10]];
                    }
                }
                break;
            }
        }
	}
	CCLOG(@"heashot=%i",headshot);
	if (headshot == 0 && machinegunCount < 1)
		[AppDelegate get].headshotStreak=0;
	
	if (gotHim > -1) {
		if ([AppDelegate get].loadout.s == 2 || [AppDelegate get].loadout.s == 3) {
			[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] resetScope];
		}
		[[AppDelegate get].enemies removeObjectAtIndex:gotHim];
		return [[AppDelegate get].enemies count];
	}
	else if (machinegunCount < 1) {
		[AppDelegate get].headshotStreak=0;
		return gotHim;
	}
    return gotHim;
}

-(void)towTruck: (Vehicle*) v {
	CCLOG(@"tow Truck"); 
	TowTruck *vehicle = [[TowTruck alloc] initWithFile: @"towtruck.png" l:self v:v];
	[self addChild:vehicle z:8];
	[vehicles addObject:vehicle];
	[vehicle startMoving:ccp(0,0)];
}

-(void) checkIfSighted {
	for (Enemy *e in [AppDelegate get].enemies) {
        if (e.currentState != DEAD) {
            int sighted = [e checkIfSighted];
            [(ControlLayer*) [self.parent getChildByTag:kControlLayer] checkIfSighted:sighted];
            if (sighted > 0)
                break;
        }
	}	
}

-(void) checkProximity {
    if ([AppDelegate get].kidnappers > 0)
        return;
    int closest = 99999;
	for (Enemy *enemy in [AppDelegate get].enemies) {
        if (enemy.currentState != DEAD && enemy.type != 100 && enemy.type != CITIZEN) {
            int distance = GetApproxDistance([enemy convertToWorldSpace:CGPointZero], [desk convertToWorldSpace:CGPointZero]) / [AppDelegate get].scale;
            CCLOG(@"Distance Vehicle:%i",distance);

            if (distance < closest)
                closest = distance;
        }
	}
    [(ControlLayer*) [self.parent getChildByTag:kControlLayer] showProximity:closest];
}

-(void) setDaytime:(int) i {
	CCSprite *c = (CCSprite*) [self getChildByTag:NIGHTSPRITE];
    if (c == nil) {
        c = [CCSprite spriteWithFile:@"b1px.png"];
        //c.color=ccc3(43,69,127);
        [c setScaleY:50000];
        [c setScaleX:50000];
        [c setPosition:ccp([[UIScreen mainScreen] bounds].size.height/2, 160)];
        c.opacity = 0;//100;
        [self addChild:c z:500 tag:NIGHTSPRITE];
    }
	else {
		if (i < 6)
			c.opacity += 40;
		else {
			c.opacity -= 40;
		}
	}
	//CCLOG(@"daytime:%i,opacity:%i",i,c.opacity);
}

///////////////////////////////////////////
-(void) kill 
{
	CCLOG(@"retainCount: %i",[self retainCount]);
	[AppDelegate get].bgLayer = nil;
	[self unscheduleAllSelectors];
	[self stopAllActions];
	for (Enemy *e in [AppDelegate get].enemies) {
		[e kill];
	}
	for (Vehicle *v in vehicles) {
		[v kill];
	}
	[[AppDelegate get].soundEngine stopSourceGroup:0];
	[[AppDelegate get].enemies removeAllObjects];
	[vehicles removeAllObjects];
	[self removeAllChildrenWithCleanup:YES];
	/*for (id *i in self.children) {
		if ([i respondsToSelector:@selector(resetSystem)]) {
			CCLOG(@"emitter");
		}
	}*/
	CCLOG(@"retainCount: %i",[self retainCount]);	
}

- (void) onEnter
{
	if(!m_paused)
	{
		[super onEnter];
		
		// schedule selectors here
		//[self schedule:@selector(step:)];
		//[self activateTimers];
	}
}

- (void) onExit
{
	CCLOG(@"GameLayer onExit");
	if(!m_paused)
	{
		[super onExit];
		
	}
}

- (void) pause
{
	if(m_paused)
	{
		return;
	}
	[self onExit];
	m_paused = YES;
	[self.parent addChild:[PauseLayer node] z:20 tag:kPauseLayer];
	[[CCDirector sharedDirector] pause];
}

- (void) unpause
{
	if(!m_paused)
	{
		return;
	}
	[self.parent removeChildByTag:kPauseLayer cleanup:YES];
	m_paused = NO;
	[[CCDirector sharedDirector] resume];
	[self onEnter];
}

///////////////////////////////////////////

- (void) dealloc {
	CCLOG(@"dealloc GameLayer"); 
	[super dealloc];
}

@end

@implementation ControlLayer
@synthesize info1,info2,info3,info4;
- (id) init {
	CCLOG(@"ControlLayer");
    self = [super init];
    if (self != nil) {		
		//CGSize s = [[CCDirector sharedDirector] winSize];
		if ([AppDelegate get].controls == 1) {
			//Joystick
			vStick = [[[Joystick alloc] init:0 y:50 w:320 h:420] retain];
			[self schedule: @selector(step:)];
		}
		recoilRate = 15;
		distance = 240;
        
		if ([AppDelegate get].loadout.r == 1) {
			distance /=3;
			recoilRate /=3;
		}
		else if ([AppDelegate get].loadout.r == 0) {
			distance /=2;
			recoilRate /=2;
		}
		self.isTouchEnabled = YES;
		
		//bulletCount = [[AppDelegate get].enemies count] * 2;
		bulletCount = 10;
		[AppDelegate get].minZoom = 0.5f;
		[AppDelegate get].maxZoom = 1.0f;
		
		// Bullets
		/*for (int i=0; i<bulletCount;i++) {
			CCSprite *b = [CCSprite spriteWithFile:@"bullet.png"];
			[b setPosition:ccp(20, 230-(i*12))];
			[self addChild:b z:1 tag:i+9000];
		}
		*/
	
		/*MyDial *sensitivityButton = [[MyDial alloc] initWithFile: @"reflex.png"];
		[self addChild:sensitivityButton z:12];
		sensitivityButton.position = ccp(366, 30);

		CCSprite *dialMark = [CCSprite spriteWithFile: @"g1px.png"];
		[self addChild:dialMark z:12];
		dialMark.position = ccp(sensitivityButton.position.x-sensitivityButton.contentSize.width/2-4,sensitivityButton.position.y-2);
		[dialMark setAnchorPoint:ccp(0.0,0.0)];	
		[dialMark setScaleX:4];
		[dialMark setScaleY:4];*/
		
		// Zoom Button
		/*MyToggle *myZoomButton = [[MyToggle alloc] initWithFile: @"zoom"]; 
		[myZoomButton setPosition:ccp(366, 30)];
		[self addChild:myZoomButton z:12];*/
		
		CCMenuItem *myZoomButton = [CCMenuItemImage itemFromNormalImage:@"zoom.png" selectedImage:@"zoom1.png" target:self selector:@selector(zoomButtonPressed:)]; 
		CCMenu *zoomMenu = [CCMenu menuWithItems:myZoomButton, nil];
		[zoomMenu setPosition:ccp([[UIScreen mainScreen] bounds].size.height-114, 30)];
		[self addChild:zoomMenu z:12];
		
		zoomedInButton = [CCSprite spriteWithFile:@"zoom1.png"];
		[zoomedInButton setPosition:zoomMenu.position];
		[self addChild:zoomedInButton z:13];
		zoomedInButton.visible=FALSE;
		
		// Fire Button
		CCMenuItem *myFireButton = [CCMenuItemImage itemFromNormalImage:@"fireButtonChrome.png" selectedImage:@"fireButtonChromePressed.png" target:self selector:@selector(fireButtonPressed:)];
		CCMenu *buttonMenu = [CCMenu menuWithItems:myFireButton, nil];
		//buttonMenu.tag = kButtonMenu;
		[buttonMenu setPosition:ccp([[UIScreen mainScreen] bounds].size.height-30, 30)];
		[self addChild:buttonMenu z:12];

		[CCMenuItemFont setFontSize:14];
		if ([AppDelegate get].multiplayer == 0) {
			CCMenuItem *pauseMenu = [CCMenuItemFont itemFromString:@"Pause"
															target:self
														  selector:@selector(pauseMenu:)];
			CCMenu *pMenu = [CCMenu menuWithItems:pauseMenu, nil];
			pMenu.position = ccp([[UIScreen mainScreen] bounds].size.height-90/*390*/,310);
			[self addChild:pMenu];
			for (CCMenuItem *mi in pMenu.children) {
				CGSize tmp = mi.contentSize;
				tmp.width = tmp.width*1.3;
				tmp.height = tmp.height*1.3;
				[mi setContentSize:tmp];
			}
		}
		
		CCMenuItem *mainMenu = [CCMenuItemFont itemFromString:@"Menu"
													   target:self
													 selector:@selector(mainMenu:)];
		CCMenu *mMenu = [CCMenu menuWithItems:mainMenu, nil];
        mMenu.position = ccp([[UIScreen mainScreen] bounds].size.height-24/*456*/,310);
		[self addChild:mMenu];
		for (CCMenuItem *mi in mMenu.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		[self setup];
	}
	return self;
}

-(void)showInfo:(int)i {
    Perk *p = [[AppDelegate get].perks objectAtIndex:i-1];
    CCLayer *popup = [[[PopupLayer alloc] initWithMessage:p.d t:p.n] autorelease];
    [self addChild:popup z:100];
}

-(void) setup {
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
	taunts = [[NSArray alloc] initWithObjects:@"You will lose",@"Nice try",@"lol", @"Too easy",@"This is fun!",@"I'm so good",@"Not even trying",@"Going down",@"Still tryin 2 win?",@"I'll be gentle",@"Embarrassing",@"Do I annoy you?",nil];
	tauntIndex = 0;
	
    //Bonus Money
    bonusSpriteLabel = [BonusSprite spriteWithFile:@"cinset.png"];
    bonusSpriteLabel.position = ccp(110,70);
    bonusSpriteLabel.scaleY=0.8;
    [self addChild:bonusSpriteLabel];
    [bonusSpriteLabel hide];
    
	levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
											  @"Day %2i", 0] fontName:[AppDelegate get].clearFont fontSize:14];
	levelLabel.anchorPoint=ccp(0,0);
	[levelLabel setPosition:ccp(10, 300)];
	[self addChild:levelLabel];
	
	JDMenuItem *aButton = [JDMenuItem itemFromNormalImage:@"buttonarmageddon.png" selectedImage:@"buttonarmageddondisabled.png"
												   target:self
												 selector:@selector(armageddon:)];		
	aMenu = [CCMenu menuWithItems:aButton,nil];
	aMenu.position = ccp(-10000, -10000);
	[self addChild:aMenu];
	
	JDMenuItem *mButton = [JDMenuItem itemFromNormalImage:@"buttonmachinegun.png" selectedImage:@"buttonmachinegundisabled.png"
												   target:self
												 selector:@selector(machinegun:)];		
	gMenu = [CCMenu menuWithItems:mButton,nil];
	gMenu.position = ccp(-10000, -10000);
	[self addChild:gMenu];
    
    // Proximity indicator
    if ([[AppDelegate get] perkEnabled:48]) {
        //Bonus Money
        proximiyIndicator = [CCSprite spriteWithFile:@"proximityCircle.png"];
        proximiyIndicator.position = ccp([[UIScreen mainScreen] bounds].size.height/2,[[UIScreen mainScreen] bounds].size.width/2);
        proximiyIndicator.scale = 1.16;
        proximiyIndicator.color = ccBLACK;
        proximiyIndicator.opacity = 0;
        [self addChild:proximiyIndicator];
    }
	

	if ([AppDelegate get].gameType != SURVIVAL) {
        //Agent Count
        if ([[AppDelegate get] perkEnabled:43]) {
            fieldReport = [BonusSprite spriteWithFile:@"cinset.png"];
            fieldReport.position = ccp([[UIScreen mainScreen] bounds].size.height/2,[[UIScreen mainScreen] bounds].size.width-10);
            fieldReport.scaleX = 0.5;
            fieldReport.scaleY=0.5;
            fieldReport.val = 0;
            [fieldReport updateLabel:@"0"];//[NSString stringWithFormat: @"%5i",0]];
            [self addChild:fieldReport z:100];
        }
        //Enemy Money
        if ([[AppDelegate get] perkEnabled:42]) {
            enemyMoney = [BonusSprite spriteWithFile:@"cinset.png"];
            enemyMoney.position = ccp([[UIScreen mainScreen] bounds].size.height/2,10);
            enemyMoney.scaleX=0.5;
            enemyMoney.scaleY=0.5;
            enemyMoney.val = 0;
            [self addChild:enemyMoney z:100];
            [enemyMoney updateLabel:[NSString stringWithFormat: @"%i",0]];
        }
		menuTray = [CCSprite spriteWithFile: @"menutray3.png"];
		menuTray.position = ccp(menuTray.contentSize.width/2, 160);
		[self addChild:menuTray z:11];
		
		if ([AppDelegate get].playerLevel != 0 || [AppDelegate get].gameType == SANDBOX)
			[self showPerks];
		[self addChild:[AppDelegate get].glassSlider z:10];
		[AppDelegate get].glassSlider.position = ccp(menuTray.position.x-[AppDelegate get].glassSlider.contentSize.width/2, 160);
		[[AppDelegate get].glassSlider initActions];
		//[AppDelegate get].glassSlider = glassSlider;
		
		float currentY = 320;
		float spacer = 4;
		//[AppDelegate get].actionButtons = [[NSMutableArray alloc] init];
		[AppDelegate get].lastActionButton = -1;
		
		[self addChild:[AppDelegate get].m5 z:25 tag:9000];
		currentY-=spacer*2+[AppDelegate get].m5.contentSize.height/2;
		[AppDelegate get].m5.position = ccp([AppDelegate get].m5.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m4 z:25 tag:9001];
		currentY-=[AppDelegate get].m4.contentSize.height+spacer;
		[AppDelegate get].m4.position = ccp([AppDelegate get].m4.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m3 z:25 tag:9002];
		currentY-=[AppDelegate get].m3.contentSize.height+spacer;
		[AppDelegate get].m3.position = ccp([AppDelegate get].m3.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m2 z:25 tag:9003];
		currentY-=[AppDelegate get].m2.contentSize.height+spacer;
		[AppDelegate get].m2.position = ccp([AppDelegate get].m2.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m1 z:25 tag:9004];
		currentY-=[AppDelegate get].m1.contentSize.height+spacer;
		[AppDelegate get].m1.position = ccp([AppDelegate get].m1.contentSize.width/2+4, currentY);
		
		CCSprite *bulletInset = [CCSprite spriteWithFile: @"blackinset.png"];
		[self addChild:bulletInset z:11];
		bulletInset.position = ccp(menuTray.contentSize.width/2, 26);
		
		/*bullet = [CCSprite spriteWithFile: @"bullet.png"];
		[self addChild:bullet z:12];
		bullet.position = ccp(menuTray.contentSize.width/2, 26);*/
		/*moneyLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
												  @"%5i", (int) [AppDelegate get].money*10] fontName:[AppDelegate get].clearFont fontSize:14];*/
		moneyLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat: 
																   @"%5i", (int) [AppDelegate get].money*10] fntFile:@"bombard.fnt"];
		[moneyLabel setPosition:ccp(menuTray.contentSize.width/2, 26)];
		moneyLabel.color = ccGREEN;
		[self addChild:moneyLabel z:12];
	}
	else {
		CCSprite *objective1 = [CCSprite spriteWithFile: @"squareborder.png"];
		objective1.position = ccp(46,220);
		[self addChild:objective1 z:12];
		CCLabelTTF *objective1Text = [CCLabelTTF labelWithString:@"Protect" fontName:[AppDelegate get].clearFont fontSize:12];
		objective1Text.position = ccp(objective1.position.x,objective1.position.y+objective1.contentSize.height/2+8);
		[self addChild:objective1Text z:3];
		// President
		CCSprite *pres = [CCSprite spriteWithFile:@"stand.png"];
		[pres setPosition:ccp(objective1.position.x, objective1.position.y)];
		pres.color=ccBLACK;
		[self addChild:pres z:13];
		CCSprite *patch = [CCSprite spriteWithFile:@"eyepatch.png"];
		patch.anchorPoint=ccp(0.5,0);
		[patch setPosition:ccp(pres.contentSize.width/2,34)];
		[pres addChild:patch z:pres.zOrder+1];
		
		
		CCSprite *objective2 = [CCSprite spriteWithFile: @"squareborder.png"];
		objective2.position = ccp(46,110);
		[self addChild:objective2 z:12];
		CCLabelTTF *objective2Text = [CCLabelTTF labelWithString:@"Destroy" fontName:[AppDelegate get].clearFont fontSize:12];
		objective2Text.position = ccp(objective2.position.x,objective2.position.y+objective2.contentSize.height/2+8);
		[self addChild:objective2Text z:3];
		CCSprite *enemy = [CCSprite spriteWithFile:@"shooting2.png"];
		[enemy setPosition:ccp(objective2.position.x,objective2.position.y)];
		enemy.color=ccRED;
		[self addChild:enemy z:13];
		CCSprite *glasses = [CCSprite spriteWithFile:@"hat1.png"];
		glasses.anchorPoint=ccp(0.5,0);
		[glasses setPosition:ccp(enemy.contentSize.width/2,32)];
		[enemy addChild:glasses z:enemy.zOrder+1];
		CCSprite *g = [CCSprite spriteWithFile:@"gun.png"];
		[enemy addChild:g z:-1];
		[g setPosition:ccp(4,enemy.contentSize.height/2+2)];
		
	}		
	
	float infoX = winSize.height-94;//386;
	float infoY = 280;
	CCLabelTTF *infoTitle = [CCLabelTTF labelWithString:@"Recon" fontName:[AppDelegate get].clearFont fontSize:12];
	infoTitle.position = ccp(infoX,infoY);
	infoTitle.anchorPoint=ccp(0,0);
	[self addChild:infoTitle z:3];
	
	infoY-=20;
	info1 = [CCLabelTTF labelWithString:@"." fontName:[AppDelegate get].clearFont fontSize:12];
	info1.position = ccp(infoX,infoY);
	info1.color = ccBLACK;
	info1.anchorPoint=ccp(0,0);
	[self addChild:info1 z:3];
	
	infoY-=20;
	info2 = [CCLabelTTF labelWithString:@"." fontName:[AppDelegate get].clearFont fontSize:12];
	info2.position = ccp(infoX,infoY);
	info2.color = ccBLACK;
	info2.anchorPoint=ccp(0,0);
	[self addChild:info2 z:3];
	
	infoY-=20;
	info3 = [CCLabelTTF labelWithString:@"." fontName:[AppDelegate get].clearFont fontSize:12];
	info3.position = ccp(infoX,infoY);
	info3.color = ccBLACK;
	info3.anchorPoint=ccp(0,0);
	[self addChild:info3 z:3];
	
	infoY-=20;
	info4 = [CCLabelTTF labelWithString:@"." fontName:[AppDelegate get].clearFont fontSize:12];
	info4.position = ccp(infoX,infoY);
	info4.color = ccBLACK;
	info4.anchorPoint=ccp(0,0);
	[self addChild:info4 z:3];
	
	//[self schedule: @selector(ticker:)];
	
	// Survival Setup
	if ([AppDelegate get].gameType == SURVIVAL) {
		[AppDelegate get].currentLevel = 1;
		levelType=0;
		[AppDelegate get].recon=1;
		currentInterval = 15;
		//[AppDelegate get].money = 1000;
        if ([AppDelegate get].survivalMode == 1) {
            [self showSurvivalPerks];
            currentInterval = 8;
        }
		[self schedule: @selector(runLevel) interval: 3];		
	}
	else {
		[self schedule: @selector(moneyProgress) interval: 0.1];
		//[self schedule: @selector(moneyUpdate) interval: 0.5];
	}
	
    if ([[AppDelegate get] perkEnabled:32])
        [self schedule:@selector(hiccup) interval:10];
}

-(void) showBonus:(NSString*)bonus {
    [[AppDelegate get].soundEngine playSound:20 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN-0.5 loop:NO];
    [bonusSpriteLabel updateLabel:bonus];
    [self unschedule: @selector(hideBonus)];
    [self schedule: @selector(hideBonus) interval: 2];
}

-(void) hideBonus {
    [self unschedule: @selector(hideBonus)];
    [bonusSpriteLabel hide];
    
}

-(void)showEnemyMoney:(int)i {
    if (enemyMoney != nil && enemyMoney.val != i) {
        enemyMoney.val = i;
        [enemyMoney updateLabel:[NSString stringWithFormat: @"Agents:%i", (int) i * 10]];
    }
}

-(void)showAgentCount:(int)i {
    if (fieldReport != nil && fieldReport.val != i) {
        fieldReport.val = i;
        [fieldReport updateLabel:[NSString stringWithFormat: @"$%i", (int) i]];
    }
}

-(void) hiccup {
 	if ([AppDelegate get].scale == 1)
		zoomedInButton.visible=FALSE;
	else {
		zoomedInButton.visible=TRUE;
	}
    
	[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] zoomButtonPressed];   
}

-(void) showProximity:(int)i {
    if (i<700)
        proximiyIndicator.opacity = 255;
    if (i<100)
        proximiyIndicator.color = ccRED;
    else if (i<300)
        proximiyIndicator.color = ccORANGE;
    else if (i<500)
        proximiyIndicator.color = ccYELLOW;
    else if (i<700)
        proximiyIndicator.color = ccGREEN;
    else {
        proximiyIndicator.color = ccBLACK;
        proximiyIndicator.opacity = 0;
    }

}

-(void) zoomButtonPressed: (id)sender {
	if ([AppDelegate get].scale == 1)
		zoomedInButton.visible=FALSE;
	else {
		zoomedInButton.visible=TRUE;
	}

	[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] zoomButtonPressed];
}

-(void) showPerks {
	CGSize s = [[CCDirector sharedDirector] winSize];
	//Perks
	float perkX = menuTray.position.x+menuTray.contentSize.width/2-14;
	float perkScale = 0.6;
	int perkCount = 0;

	if ([AppDelegate get].loadout.s1 > 0) {
		perkCount++;
		Perk *perk1 = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s1-1];
		//CCSprite *perk1 = [CCSprite spriteWithFile:x.img];
		perk1.scale=perkScale;
		[self addChild:perk1 z:10];
		perkX = perkX+perk1.contentSize.width/2+8;
		perk1.position = ccp(perkX, perk1.contentSize.height/2-6);
	}
	if ([AppDelegate get].loadout.s2 > 0) {
		perkCount++;
		Perk *perk2 = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s2-1];
		//CCSprite *perk2 = [CCSprite spriteWithFile:x.img];
		perk2.scale=perkScale;
		[self addChild:perk2 z:10];
		perkX = perkX+perk2.contentSize.width/2+8;
		perk2.position = ccp(perkX, perk2.contentSize.height/2-6);
	}
	if ([AppDelegate get].loadout.s3 > 0) {
		perkCount++;
		Perk *perk3 = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s3-1];
		//CCSprite *perk3 = [CCSprite spriteWithFile:x.img];
		perk3.scale=perkScale;
		[self addChild:perk3 z:10];
		perkX = perkX+perk3.contentSize.width/2+8;
		perk3.position = ccp(perkX, perk3.contentSize.height/2-6);
	}
    
	if (perkCount > 0) {
		CCLabelTTF *perkTitle = [CCLabelTTF labelWithString:@"Perks" fontName:[AppDelegate get].clearFont fontSize:12];
		perkTitle.position = ccp(menuTray.position.x+menuTray.contentSize.width/2+4,36);
		perkTitle.anchorPoint=ccp(0,0);
		[self addChild:perkTitle z:3];
	}
	
	if (([[AppDelegate get] perkEnabled:21]) && [[AppDelegate get].opponentPerks count] > 0) {
		CCLabelTTF *opPerkTitle = [CCLabelTTF labelWithString:@"Opponent Perks" fontName:[AppDelegate get].clearFont fontSize:12];
		opPerkTitle.position = ccp(menuTray.position.x+menuTray.contentSize.width/2+4,s.height-48);
		opPerkTitle.anchorPoint=ccp(0,0);
		[self addChild:opPerkTitle z:3];
		
		perkX = menuTray.position.x+menuTray.contentSize.width/2-14;
		perkCount = 0;
		CCLOG(@"opponent perk count %d", [[AppDelegate get].opponentPerks count]);
		for (uint i=0; i<[[AppDelegate get].opponentPerks count]; i++) {
			int perkNO = [[[AppDelegate get].opponentPerks objectAtIndex:i] integerValue];
			CCLOG(@"perk %d: %d", i,perkNO);
			if (perkNO > 0) {
				perkCount++;
				Perk *perk1 = [[AppDelegate get].perks objectAtIndex:perkNO-1];
				//CCSprite *perk1 = [CCSprite spriteWithFile:x.img];
				perk1.scale=perkScale;
				[self addChild:perk1 z:10];
				perkX = perkX+perk1.contentSize.width/2+8;
				perk1.position = ccp(perkX, s.height-perk1.contentSize.height/2+6);
			}
		}
	}	
}

-(void) showSurvivalPerks {
    [[AppDelegate get].opponentPerks removeAllObjects];

	float perkX = -8.0f;
	float perkScale = 0.6;

    NSArray *perkChoices = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:5],
                                                            [NSNumber numberWithInt:6],
                                                            [NSNumber numberWithInt:7],
                                                            [NSNumber numberWithInt:13],
                                                            [NSNumber numberWithInt:15],
                                                            [NSNumber numberWithInt:17],
                                                            [NSNumber numberWithInt:18],
                                                            [NSNumber numberWithInt:22],
                                                            [NSNumber numberWithInt:23],
                                                            nil];
	
    uint one = (int) (arc4random() % perkChoices.count);
	uint two = (int) (arc4random() % perkChoices.count);
    if (two == one) {
        if (one == perkChoices.count-1)
            two = 0;
        else
            two = one+1;
    }
	uint three = (int) (arc4random() % perkChoices.count);
    if (three == one) {
        if (one == perkChoices.count-1)
            three = 0;
        else
            three = one+1;
    }
    if (three == two) {
        if (two == perkChoices.count-1)
            three = 0;
        else
            three = two+1;
    }
    if (three == one) {
        if (one == perkChoices.count-1)
            three = 0;
        else
            three = one+1;
    }
	NSNumber *p1 = [perkChoices objectAtIndex:one];
	NSNumber *p2 = [perkChoices objectAtIndex:two];
	NSNumber *p3 = [perkChoices objectAtIndex:three];
    [[AppDelegate get].opponentPerks addObject:p1];
    [[AppDelegate get].opponentPerks addObject:p2];
    [[AppDelegate get].opponentPerks addObject:p3];
	CCLOG(@"perks:%i,%i,%i",one,two,three);

	CCLabelTTF *perkTitle = [CCLabelTTF labelWithString:@"Perks" fontName:[AppDelegate get].clearFont fontSize:12];
	//perkTitle.position = ccp(menuTray.position.x+menuTray.contentSize.width/2+4,36);
	perkTitle.position = ccp(10,36);
	perkTitle.anchorPoint=ccp(0,0);
	[self addChild:perkTitle z:3];

	Perk *perk1 = [[AppDelegate get].perks objectAtIndex:[p1 intValue]-1];
	//CCSprite *perk1 = [CCSprite spriteWithFile:x1.img];
	perk1.scale=perkScale;
	perkX = perkX+perk1.contentSize.width/2+8;
	perk1.position = ccp(perkX, perk1.contentSize.height/2-6);
	[self addChild:perk1 z:10];
	Perk *perk2 = [[AppDelegate get].perks objectAtIndex:[p2 intValue]-1];
	//CCSprite *perk2 = [CCSprite spriteWithFile:x2.img];
	perk2.scale=perkScale;
	[self addChild:perk2 z:10];
	perkX = perkX+perk2.contentSize.width/2+8;
	perk2.position = ccp(perkX, perk2.contentSize.height/2-6);
	Perk *perk3 = [[AppDelegate get].perks objectAtIndex:[p3 intValue]-1];
	//CCSprite *perk3 = [CCSprite spriteWithFile:x3.img];
	perk3.scale=perkScale;
	[self addChild:perk3 z:10];
	perkX = perkX+perk3.contentSize.width/2+8;
	perk3.position = ccp(perkX, perk3.contentSize.height/2-6);
}


-(void) showArmageddon {
	[[[AppDelegate get].m5.childButtons objectAtIndex:0] disable];
	aMenu.position = ccp([[UIScreen mainScreen] bounds].size.height-30, 168);
}

-(void) showMachinegun {
	[[[AppDelegate get].m5.childButtons objectAtIndex:1] disable];
	gMenu.position = ccp([[UIScreen mainScreen] bounds].size.height-30, 108);
}	

-(void) hideArmageddon {
	aMenu.position = ccp(-10000, -10000);
}

-(void) hideMachinegun {
	gMenu.position = ccp(-10000, -10000);
}	

-(void) armageddon: (id)sender {
	[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] pressedArmageddon];
	[self hideArmageddon];
}
-(void) machinegun: (id)sender {
	[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] launchMachinegun];
	[self hideMachinegun];
}

-(void) checkIfSighted:(int) sighted {
	if (sighted == 2) {
		if ([AppDelegate get].loadout.e == 1)
			[[AppDelegate get].soundEngine playSound:11 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		else if ([AppDelegate get].loadout.e == 2)
			[self fireButtonPressed:self];
	}
	if ([AppDelegate get].loadout.s == 2 || [AppDelegate get].loadout.s == 3) {
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] checkIfSighted:sighted];
	}
}

-(void) updateInfo:(NSString*)s cc:(ccColor3B) cc {	
	if ([[AppDelegate get] perkEnabled:15] && ![[AppDelegate get] perkEnabled:11]) {
		s = [taunts objectAtIndex:tauntIndex];
		tauntIndex++;
		if (tauntIndex >= [taunts count])
			tauntIndex = 0;
		cc = ccYELLOW;
	}
	[self.info4 setString:self.info3.string];
	[self.info4 setColor:self.info3.color];
	[self.info3 setString:self.info2.string];
	[self.info3 setColor:self.info2.color];
	[self.info2 setString:self.info1.string];
	[self.info2 setColor:self.info1.color];
	[self.info1 setString:s];
	[self.info1 setColor:cc];
}

-(void) moneyProgress {
	if ([AppDelegate get].gameType == SANDBOX && [AppDelegate get].sandboxMode == 1) {
		[moneyLabel setString:@"99999"];
	}
	else {
		[AppDelegate get].money+=MRATE;
		if ([[AppDelegate get] perkEnabled:10])
			[AppDelegate get].money+=(MRATE*0.2f);
        if ([[AppDelegate get] perkEnabled:39]) {
            if ([AppDelegate get].money > 700)
                [AppDelegate get].money = 700;
        }
        else {
            if ([AppDelegate get].money > 500)
                [AppDelegate get].money = 500;
        }
		/*if ([[AppDelegate get] perkEnabled:3])
			[AppDelegate get].money-=(MRATE*0.2f);*/
		
		if ([AppDelegate get].money * 10 > 99999)
			[moneyLabel setString:@"99999"];
		else 
			[moneyLabel setString:[NSString stringWithFormat: @"%5i", (int) [AppDelegate get].money * 10]];
	}
    if ([AppDelegate get].gameType == SANDBOX) {
        if ([[AppDelegate get] myPerk:42])
            [enemyMoney updateLabel:moneyLabel.string];
        if ([[AppDelegate get] myPerk:43]) {
            [self showAgentCount:[AppDelegate get].enemies.count-[AppDelegate get].jammers-1];
        }
    }
}

-(void) step: (ccTime) delta
{
	CGPoint velocity = [vStick getCurrentVelocity];
	//if (velocity.x + velocity.y != 0) {
		//CCLOG(@"Velocity x:%f y:%f",velocity.x, velocity.y);
	//}
	
	if ([AppDelegate get].reload == 0)
		[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] moveBGPostion:-velocity.x y:-velocity.y];
	//[self checkAttributes];
}

-(void) runLevel {
    if ([AppDelegate get].survivalMode == 0) {
        levelType++;
        if (levelType == 9) {
            [AppDelegate get].currentLevel++;
            //don't save to file like this.  it will overwrite
            /*if ([AppDelegate get].currentLevel % 5 == 0) {
                [AppDelegate get].stats.su = [AppDelegate get].currentLevel;
            }*/
            NSString *c = [NSString stringWithFormat:@"Day %4i",[AppDelegate get].currentLevel-1];
            [levelLabel setString:c];
            levelType = 1;
            [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEINVERTED + (arc4random() % 2) pid:@"me"];
        }
        //CCLOG(@"level type: %i",levelType);
        int launch = 0;
        switch (levelType)
        {
            case 1: 
            case 2:
            case 3:
            case 5:
            case 6:
            case 7:
                launch = (arc4random() % 4) + 1;
                break;
            case 4:
            case 8: 
                launch = CODEARMOR + (arc4random() % 4);
                break;
        }
        CCLOG(@"launch: %i",launch);
        [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:launch pid:@"me"];
        CCLOG(@"current Level: %i",[AppDelegate get].currentLevel);
        if (levelType == 1) {
            if ([AppDelegate get].currentLevel >= 5) {
                CCLOG(@"--------------Increasing Difficulty---------------");
                /*if ([AppDelegate get].currentLevel % 15 == 0) {
                    [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEPERK3 pid:@"me"];
                }	
                if ([AppDelegate get].currentLevel % 10 == 0) {
                    [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEPERK1 pid:@"me"];
                    [self unschedule: @selector(runLevel)];
                }*/
                if ([AppDelegate get].currentLevel % 5 == 0) {
                    [self resetLevel];
                    [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEANTI pid:@"me"];	
                }
            }	
        }
        if (levelType == 1) {
            [self unschedule: @selector(runLevel)];
            [self schedule: @selector(runLevel) interval: currentInterval];
        }
    }
    else if ([AppDelegate get].survivalMode == 1) {  // Extreme
        levelType++;
        [(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] setDaytime:levelType];
        if (levelType == 9) {
            [AppDelegate get].currentLevel++;
            NSString *c = [NSString stringWithFormat:@"Day %4i",[AppDelegate get].currentLevel-1];
            [levelLabel setString:c];
            levelType = 1;
            [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEINVERTED + (arc4random() % 2) pid:@"me"];
        }
        CCLOG(@"level type: %i",levelType);
        int launch = 0;
        switch (levelType)
        {
            case 1: 
            case 2:
            case 3:
            case 5:
            case 6:
            case 7:
                launch = (arc4random() % 4) + 1;
                break;
            case 4:
            case 8: 
                launch = CODEARMOR + (arc4random() % 4);
                break;
        }
        //CCLOG(@"launch: %i",launch);
        [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:launch pid:@"me"];
        CCLOG(@"current Level: %i",[AppDelegate get].currentLevel);
        if (levelType == 1) {
            if ([AppDelegate get].currentLevel >= 5) {
                CCLOG(@"--------------Increasing Difficulty---------------");
                /*if ([AppDelegate get].currentLevel % 15 == 0) {
                 [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEPERK3 pid:@"me"];
                 }	
                 if ([AppDelegate get].currentLevel % 10 == 0) {
                 [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEPERK1 pid:@"me"];
                 [self unschedule: @selector(runLevel)];
                 }*/
                if ([AppDelegate get].currentLevel % 5 == 0) {
                    [self resetLevel];
                    [(BackgroundLayer*) ([AppDelegate get].bgLayer) onAttackReceived:CODEANTI pid:@"me"];	
                }
            }	
        }
        if (levelType == 1) {
            [self unschedule: @selector(runLevel)];
            [self schedule: @selector(runLevel) interval: currentInterval];
        }
    }
}


-(void) resetLevel {
	if (currentInterval > 1) {
		[(BackgroundLayer*) ([AppDelegate get].bgLayer) sendIntel:@"Speeding Up"];
		currentInterval--;
		[self schedule: @selector(runLevel) interval: currentInterval];
	}
}

-(void) fireButtonPressed: (id)sender {
	CCLOG(@"Fire Button Pressed");

	if ([AppDelegate get].reload == 0 && [AppDelegate get].money >= BMONEY) {
		if ([AppDelegate get].gameType != SURVIVAL) {
            if ([[AppDelegate get] perkEnabled:25]) // Supply Lines
                [AppDelegate get].money -= (BMONEY/2);
            else
                [AppDelegate get].money-=BMONEY;
        }
		if (bulletCount > 0) {
			//bulletCount--;
		//if (bulletCount > 0) {
			//CCLOG(@"Fire Button Pressed");
			[[AppDelegate get].soundEngine playSound:0 sourceGroupId:0 pitch:0.6f pan:0.0f gain:DEFGAIN loop:NO];
/*			
			CCSprite *s = (CCSprite*)[self getChildByTag:1000+bulletCount-1];
			s.visible = NO;
			if ([AppDelegate get].gameType != 2) // Sandbox
				bulletCount--;
*/
			if ([(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] shotFired] == 0) {
//
			}
			
			[AppDelegate get].reload = 1;
			if ([AppDelegate get].loadout.b != 1) {
				[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] moveBGPostion:-distance y:-distance];
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
	
}

- (void) doReload
{
	[self unschedule: @selector(doReload)];
	[AppDelegate get].reload = 0;
}

- (void) doReloadSound
{
	[self unschedule: @selector(doReloadSound)];
	[[AppDelegate get].soundEngine playSound:1 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
}

- (void) doRecoil
{
	if (elapsed >= recoilRate)
	{
		CCLOG(@"moveScope: done");
		[self unschedule: @selector(doRecoil)];
	}
	else
	{
		[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] moveBGPostion:(distance/recoilRate) y:(distance/recoilRate)];
		
		elapsed++;
	}
}

-(void)nothing: (id)sender {
 //Nothing
}

-(void)mainMenu: (id)sender {
	if ([AppDelegate get].gameType == SURVIVAL || [AppDelegate get].gameType == SANDBOX || [AppDelegate get].gameType == MISSIONS || [AppDelegate get].multiplayer > 0) {
	UIAlertView *add = [[UIAlertView alloc] initWithTitle: @"Exit to Main Menu?" 
												  message: @"Are you sure you want to exit?" 
												 delegate: self 
										cancelButtonTitle: @"Cancel"
										otherButtonTitles:nil
						]; 
	[add addButtonWithTitle:@"Yes"];
	[add show]; 
	[add release]; 
	}
	else {
		[[AppDelegate get].soundEngine stopSourceGroup:0];
		MenuScene *s = [MenuScene node];
		[[CCDirector sharedDirector] replaceScene:s];
	}
}

- (void)alertView: (UIAlertView * ) alertView clickedButtonAtIndex : (NSInteger ) buttonIndex 
{ 
	CCLOG(@"Button index %i",buttonIndex);
	if (buttonIndex != 0) {
		if ([AppDelegate get].multiplayer > 0) {
			[[AppDelegate get].gkHelper sendAttack:DISCONNECT];
			[[AppDelegate get].gkHelper disconnectCurrentMatch];
		}
		
		[[AppDelegate get].soundEngine stopSourceGroup:0];
		MenuScene *s = [MenuScene node];
		[[CCDirector sharedDirector] replaceScene:s];
	}
}

-(void)pauseMenu: (id)sender {
	[(BackgroundLayer*)[AppDelegate get].bgLayer pause];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchBegan: GameScene");
	return [vStick ccTouchBegan:touch withEvent:event];  
} 

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchMoved: GameScene");
	[vStick ccTouchMoved:touch withEvent:event]; 
	//return kEventHandled; 
} 

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchEnded: GameScene");
	[vStick ccTouchEnded:touch withEvent:event]; 
	//return kEventHandled; 
} 

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (void) dealloc {
	[vStick release];
	[[AppDelegate get].soundEngine stopSourceGroup:0];
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc ControlLayer"); 
	[super dealloc];
}

@end

@implementation ScopeLayer
@synthesize blur;
- (id) init {
	CCLOG(@"ScopeLayer");
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		//Scope
        CCSprite *scopeScreen = [CCSprite spriteWithFile:@"scopeblack.png"];
        [scopeScreen setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:scopeScreen z:5];
		scopeScreen.opacity=255;
		if ([AppDelegate get].gameType == TUTORIAL) {
			scope = [CCSprite spriteWithFile:@"scope1.png"];
		}
		else if ([AppDelegate get].loadout.s == 2 || [AppDelegate get].loadout.s == 3) {
			scope = [CCSprite spriteWithFile:@"scope2.png"]; 
			scope.color=ccBLACK;
		}
		else {
			scope = [CCSprite spriteWithFile:[NSString stringWithFormat:@"scope%i.png",[AppDelegate get].loadout.s]];
		}
		//scope.opacity=255;
        [scope setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:scope z:5];
		
		machinegun = [CCSprite spriteWithFile:@"machinegun.png"];
		[machinegun setPosition:ccp(s.width/2, s.height/2-machinegun.contentSize.height/2)];
        [self addChild:machinegun z:4];
		machinegun.visible=FALSE;
		
		self.blur = [CCSprite spriteWithFile:@"fingerprint.png"];
        [blur setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:blur z:4];
		self.blur.visible=FALSE;
		
		if ([AppDelegate get].gameType != SURVIVAL) {
			showArrow = 0;
			// Sniper arrow
			arrow = [CCSprite spriteWithFile:@"arrow1.png"];
			arrow.position=ccp(-10000,-10000);
			//arrow.position=ccp(240,160);
			//arrow.opacity=200;
			[self addChild:arrow z:4];
		}
	}
	return self;
}

-(void) showSniper {
	if (showArrow == 0) {
		showArrow = 1;
		arrow.position=ccp([[UIScreen mainScreen] bounds].size.height/2,160);
		[arrow runAction: [CCFadeOut actionWithDuration:0.9]];
		[self schedule: @selector(doArrow) interval: 1];
	}
}

-(void) hideSniper {
	showArrow = 0;
	arrow.position=ccp(-10000,-10000);
	[self unschedule: @selector(doArrow)];
	[arrow stopAllActions];
}

-(void) doArrow {
	//CCLOG(@"bgposition:%f",[AppDelegate get].bgLayer.position.x);
	if ([(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] leftOfSniper]) {
		arrow.position=ccp([[UIScreen mainScreen] bounds].size.height/2,160);
		
		//Rotate arrow
		CGPoint location = [self convertToWorldSpace:CGPointZero];
		CGPoint sniperPos = [(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] getSniperPos];
		arrow.rotation = 360-(findAngle(sniperPos,ccp([[UIScreen mainScreen] bounds].size.height/2-location.x,150-location.y)));
		//CCLOG(@"Arrow rotation:%f",arrow.rotation);
		if (showArrow == 2) {
			showArrow = 1;
			[arrow runAction: [CCFadeOut actionWithDuration:0.9]];
		}
		else {
			showArrow = 2;
			[arrow runAction: [CCFadeIn actionWithDuration:0.9]];
		}
	}
	else {
		arrow.position=ccp(-10000,-10000);
	}
}

float findAngle(CGPoint pt1, CGPoint pt2) {
	float angle = atan2(pt1.y - pt2.y, pt1.x - pt2.x) * (180 / M_PI);
	angle = angle < 0 ? angle + 360 : angle;
	
	return angle;
}

-(void) resetScope {
	scope.color=ccBLACK;
}

-(void) hideScope {
	scope.visible=FALSE;
	machinegun.visible=TRUE;
}

-(void) showScope {
	machinegun.visible=FALSE;
	scope.visible=TRUE;
}

-(void) checkIfSighted:(int) sighted {
	if (sighted > 0) {
		if (sighted == 1)
			scope.color=ccRED;
		else if ([AppDelegate get].loadout.s == 3) 
			scope.color=ccBLUE;
		else
			scope.color=ccRED;
	}
	else {
		scope.color=ccBLACK;
	}
}

- (void) blurryOn {
	//CCLOG(@"Blury On");
	self.blur.visible=TRUE;
}
- (void) blurryOff {
	//CCLOG(@"Blury Off");
	self.blur.visible=FALSE;	
}

-(void) armageddon {
	CCLOG(@"Armageddon");
	[[AppDelegate get].soundEngine playSound:10 sourceGroupId:0 pitch:1.0f pan:0.0f gain:1.0f loop:NO];
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCSprite *whiteScreen= [CCSprite spriteWithFile:@"w1px.png"];
	whiteScreen.scaleX = s.width;
	whiteScreen.scaleY = s.height;
	whiteScreen.position = ccp(s.width/2,s.height/2);
	[self addChild:whiteScreen z:0];
	[whiteScreen runAction: [CCFadeOut actionWithDuration:8]];
}

- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc ScopeLayer"); 
	[super dealloc];
}

@end

@implementation MidgroundLayer
- (id) init {
	CCLOG(@"MidgroundLayer");
    self = [super init];
    if (self != nil) {
		[self setScale:[AppDelegate get].scale];
		//Tower1
		[self makeBuilding:1 y:6 cc:ccc3(122,107,98) cg:ccp(-620, -1000)];
		
		[self makeBuilding:3 y:4 cc:ccc3(186,153,8) cg:ccp(-500, -750)];
		
		[self makeBuilding:3 y:6 cc:ccc3(198,142,137) cg:ccp(1200, -920)];
		//Tower2
		[self makeBuilding:1 y:6 cc:ccc3(20,160,239) cg:ccp(750, -710)];
        if ([[AppDelegate get] perkEnabled:27] && [AppDelegate get].gameType != SURVIVAL) {
            [self schedule: @selector(nightTime) interval: 2];
        }
	}
	return self;
}

-(void) nightTime {
    CCSprite *c = (CCSprite*) [self getChildByTag:NIGHTSPRITE];
    if (c == nil) {
        gettingDarker = YES;
        c = [CCSprite spriteWithFile:@"b1px.png"];
        //c.color=ccc3(43,69,127);
        [c setScaleY:50000];
        [c setScaleX:50000];
        [c setPosition:ccp([[UIScreen mainScreen] bounds].size.height/2, 160)];
        c.opacity = 0;
        [self addChild:c z:500 tag:NIGHTSPRITE];
    }
	if (gettingDarker) {
        if (c.opacity <= 220) {
            c.opacity += 10;
        }
        else {
            c.opacity -=10;
            gettingDarker=NO;
        }
    }
    else if (!gettingDarker) {
        if (c.opacity > 10) {
            c.opacity -= 10;
        }
        else {
            c.opacity += 10;
            gettingDarker=YES;
        }
    }
}
- (void) moveBGPostion:(float) x y:(float) y {
	self.position = ccp(x,y);
}

- (void) setZoom:(float) z {
	CGPoint orig = self.position;
	float xDiff,yDiff;
	xDiff = self.position.x - 0;
	yDiff = self.position.y - 0;
	//CCLOG(@"diff x:%f y:%f",xDiff,yDiff);
	if (z == 1) {
		//CCLOG(@"diff scale x:%f y:%f",xDiff*0.5f,yDiff*0.5f);
		orig.x += xDiff;
		orig.y += yDiff;
	}
	else {
		orig.x -= xDiff*z;
		orig.y -= yDiff*z;
	}
	[AppDelegate get].scale = z;
	self.scale = z;
	self.position = ccp(orig.x,orig.y);
}

- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B) cc cg:(CGPoint)cg
{
	for (int i=0;i<x;i++) {
		for (int j=0;j<y;j++) {
			CCSprite *part= [CCSprite spriteWithFile:@"cube.png"];
			part.color=cc;
			part.position=ccp(cg.x+i*part.contentSize.width/1.6,cg.y+j*part.contentSize.height/1.7);
			[self addChild:part z:1];
			CCSprite *window= [CCSprite spriteWithFile:@"window.png"];
			window.position=ccp(part.contentSize.width/2,part.contentSize.height/2+window.contentSize.height/7);
			window.anchorPoint=ccp(1,1);
			[part addChild:window];
			CCSprite *windowside= [CCSprite spriteWithFile:@"windowside.png"];
			windowside.position=ccp(part.contentSize.width-windowside.contentSize.width/4,part.contentSize.height/2+windowside.contentSize.height/2.4);
			windowside.anchorPoint=ccp(1,1);
			[part addChild:windowside];
		}
	}
}


- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc MidgroundLayer"); 
	[super dealloc];
}

@end

@implementation ForegroundLayer
- (id) init {
	CCLOG(@"ForegroundLayer");
    self = [super init];
    if (self != nil) {
		[self setScale:[AppDelegate get].scale];
		CCLOG(@"ForegroundLayer");


		//Tower1
		[self makeBuilding:1 y:6 cc:ccc3(64,103,185) cg:ccp(-520, -800)];
		[self makeBuilding:3 y:4 cc:ccc3(185,185,185) cg:ccp(-820, -800)];
		//Left
        [self makeBuilding:2 y:16 cc:ccc3(210,180,137) cg:ccp(MINX-4-(([[UIScreen mainScreen] bounds].size.height-480)/2), -800)];
		//Right
		[self makeBuilding:3 y:17 cc:ccc3(255,223,206) cg:ccp(MAXX, -800)];
		
		
		
		[self makeBuilding:1 y:5 cc:ccc3(180,180,180) cg:ccp(280, -870)];
		//Tower2
		[self makeBuilding:1 y:6 cc:ccc3(185,127,64) cg:ccp(100, -780)];
		
		[self makeBuilding:1 y:5 cc:ccc3(160,160,160) cg:ccp(860, -820)];
		/*
        CCSprite *tree = [CCSprite spriteWithFile:@"tree.png"];
		[tree setPosition:ccp(350, -300)];
        [self addChild:tree z:1];
		CCSprite *tree2 = [CCSprite spriteWithFile:@"tree.png"];
		[tree2 setPosition:ccp(-220, -125)];
        [self addChild:tree2 z:1];
*/
	}
	return self;
}

- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B) cc cg:(CGPoint)cg
{
	for (int i=0;i<x;i++) {
		for (int j=0;j<y;j++) {
			CCSprite *part= [CCSprite spriteWithFile:@"cube.png"];
			part.color=cc;
			part.position=ccp(cg.x+i*part.contentSize.width/1.6,cg.y+j*part.contentSize.height/1.7);
			[self addChild:part z:1];
			CCSprite *window= [CCSprite spriteWithFile:@"window.png"];
			window.position=ccp(part.contentSize.width/2,part.contentSize.height/2+window.contentSize.height/7);
			window.anchorPoint=ccp(1,1);
			[part addChild:window];
			CCSprite *windowside= [CCSprite spriteWithFile:@"windowside.png"];
			windowside.position=ccp(part.contentSize.width-windowside.contentSize.width/4,part.contentSize.height/2+windowside.contentSize.height/2.4);
			windowside.anchorPoint=ccp(1,1);
			[part addChild:windowside];
		}
	}
}

- (void) moveBGPostion:(float) x y:(float) y {
	self.position = ccp(x,y);
}

- (void) setZoom:(float) z {
	CGPoint orig = self.position;
	float xDiff,yDiff;
	xDiff = self.position.x - 0;
	yDiff = self.position.y - 0;
	//CCLOG(@"diff x:%f y:%f",xDiff,yDiff);
	if (z == 1) {
		//CCLOG(@"diff scale x:%f y:%f",xDiff*0.5f,yDiff*0.5f);
		orig.x += xDiff;
		orig.y += yDiff;
	}
	else {
		orig.x -= xDiff*z;
		orig.y -= yDiff*z;
	}
	[AppDelegate get].scale = z;
	self.scale = z;
	self.position = ccp(orig.x,orig.y);
}

- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc ForegroundLayer"); 
	[super dealloc];
}

@end

@implementation SkylineLayer
- (id) init {
	CCLOG(@"SkyLineLayer");
    self = [super init];
    if (self != nil) {
		[self setScale:[AppDelegate get].scale];
		//Level Background
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		
		// Sky
		CCSprite *sky = [CCSprite spriteWithFile:@"w1px.png"];
		sky.anchorPoint=ccp(0,0);
		[sky setPosition:ccp(-1200,700)];	
		[sky setScaleY:200];
		[sky setScaleX:3000];
		sky.color= ccc3(109,207,246);
		[self addChild:sky z:0];	
		
		float myScale=1.46;
		//float myScale = 1;
		//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
		//if ([CCDirector getAvailableMegaBytes] > .25) {
			for(int i=1;i<5;i++) {
					CCLOG(@"Load:bkgrnd%i.png",i);
				int x = i;
				if (i > 2)
					x = i - 2;
					CCSprite *bg1 = [CCSprite spriteWithFile: [NSString stringWithFormat:@"background%i.png",x]];
					//CCSprite *bg1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bkgrnd3.png",i]];
					bg1.anchorPoint=ccp(0,0);
					bg1.position=ccp(-1200+(i-1)*bg1.contentSize.width*myScale,400);
					bg1.scale=myScale;
					[self addChild:bg1 z:0];
			}
		//}
		
		//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		// Water
		CCSprite *water = [CCSprite spriteWithFile:@"w1px.png"];
		water.anchorPoint=ccp(0,0);
		[water setPosition:ccp(-1200,0)];	
		[water setScaleY:400];
		[water setScaleX:3000];
		water.color= ccc3(168,225,255);
		[self addChild:water z:0];			
	}
	return self;
}

- (void) moveBGPostion:(float) x y:(float) y {
	self.position = ccp(x,y);
}

- (void) setZoom:(float) z {
	CGPoint orig = self.position;
	float xDiff,yDiff;
	xDiff = self.position.x - 0;
	yDiff = self.position.y - 0;
	//CCLOG(@"diff x:%f y:%f",xDiff,yDiff);
	if (z == 1) {
		//CCLOG(@"diff scale x:%f y:%f",xDiff*0.5f,yDiff*0.5f);
		orig.x += xDiff;
		orig.y += yDiff;
	}
	else {
		orig.x -= xDiff*z;
		orig.y -= yDiff*z;
	}
	[AppDelegate get].scale = z;
	self.scale = z;
	self.position = ccp(orig.x,orig.y);
}

- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc SkyLineLayer"); 
	[super dealloc];
}

@end

@implementation PauseLayer
- (id) init {
	CCLOG(@"PauseLayer");
    self = [super init];
    if (self != nil) {
		self.isTouchEnabled = YES;
		CGSize s = [[CCDirector sharedDirector] winSize];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
		
		[CCMenuItemFont setFontSize:20];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Paused" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:16];
		TextMenuItem *up = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(unPause:) label:@"Resume"];
		CCMenu *unpause = [CCMenu menuWithItems:up,nil];
        [self addChild:unpause];
		unpause.anchorPoint=ccp(0.0,1);
		[unpause setPosition:ccp([[UIScreen mainScreen] bounds].size.height/2, 200)];
		
		/*
		 [CCMenuItemFont setFontSize:16];
		 CCMenuItem *mm = [CCMenuItemFont itemFromString:@"Main Menu"
		 target:self
		 selector:@selector(mainMenu:)];
		 [mm setColor:ccBLACK];
		 CCMenu *back = [CCMenu menuWithItems:mm,nil];
		 [self addChild:back];
		 [back setPosition:ccp(436, 300)];*/
		//[[CCDirector sharedDirector] pause];
    }
    return self;
}

-(void)unPause: (id)sender {
	//CCScene* runningScene = [[CCDirector sharedDirector] runningScene];
	[(BackgroundLayer*)[AppDelegate get].bgLayer unpause];
	//[[CCDirector sharedDirector] resume];
}

- (void) dealloc {
	//[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc PauseLayer"); 
	[super dealloc];
}

@end

