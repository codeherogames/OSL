//
//  GameScene.h
//  Sniper
//
//  Created by James Dailey on 10/15/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "Joystick.h"
#import "Enemy.h"
#import "Plane.h"
#import "Helicopter.h"
#import "Armored.h"
#import "Truck.h"
#import "TowTruck.h"
#import "Sniper.h"
#import "PopupLayer.h"
#import "BonusSprite.h"

@interface GameScene : CCScene {

}
-(void) addLayers;
-(void) doSnow;
-(void) handleDisconnect;

@end

@interface BackgroundLayer : CCLayer 
{
	float lastAngleX,lastAngleY;
	int invertKills,dirtKills,atPresident,gameMins;
	CGPoint sniperLocation;
	CCSprite *sniperWindow,*billboard,*pres,*presHostage;
	int jammerID,alertID,countDown,officePartyCount,mutinyCount,security1,security2,machinegunCount;
	bool m_paused,machinegunAvailable,bombAvailable,securityAvailable;
	NSMutableArray *vehicles;
	CCSprite *securityGuard1, *securityGuard2,*rope,*zipline;
	CCAnimation *animateFight1, *animateFight2;
	id actionFight1,actionFight2;
	CCLabelTTF *headshotLabel;
	NSArray *streakName;
	Sniper *sniper;
	int myBeat,theirBeat,lastAttack,lastAttackCount,shotsFired;
	//CCLabelTTF *opponent,*opLabel;
}

@property (nonatomic,assign) NSMutableArray *vehicles;

//- (void) setSchedule;
-(void) setup;
-(void) kill;
- (void) pause;
- (void) unpause;

-(void) doHeadshot:(CGPoint) p i:(int) i;
- (void) showRope;
- (void) showZipline;
- (void) hideZipline;
-(BOOL) hasSecurity:(int) i;
-(BOOL) stopFight:(int) i;
-(void) setDaytime:(int) i;

//-(void) updateBillboard: (NSString*) alias;
-(void)pressedArmageddon;
-(void) launchOfficeParty;
- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B) cc cg:(CGPoint)cg;
-(void) showSniper;
-(void) hideSniper;
-(BOOL) leftOfSniper;
-(CGPoint) getSniperPos;
- (void) moveBGPostion: (float) x y: (float) y;
- (void) setZoom:(float) z;
- (int) shotFired;
-(void) zoomButtonPressed;
- (void) towTruck: (Vehicle*) v;
-(void) onAttackReceived:(int)attack pid:(NSString*)pid;
-(void) menuAttack:(int)attack;

-(void) sendIntel:(NSString*)s;
-(void) sendMyIntel:(NSString*)s;

-(void)launchSniperFound;
-(void)launchKidnapperDead;
-(void)launchInnocent;
-(void)launchGrunt;
-(void)launchCitizen;
-(void)launchParachute;

-(void)launchJumper;
-(void)launchInverted;
-(void)launchDirt;

-(void)launchRecon;
-(void)launchAnti;
-(void) stopAnti;
-(void)launchArmor;

-(void)launchPlane;
-(void)launchHelicopter;
-(void)launchTruck;

-(void)launchArmageddon;
-(void)launchMachinegun;
-(void)launchSecurity;

-(void)showEnemyMoney:(int)i;
-(void)showAgentCount:(int)i;
-(void) showBonus:(NSString*)bonus;
-(int)getEnemyCount;

@end

@interface ForegroundLayer : CCLayer {}
- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B)cc cg:(CGPoint)cg;
- (void) moveBGPostion: (float) x y: (float) y;
- (void) setZoom:(float) z;
@end

@interface ControlLayer : CCLayer {
	Joystick *vStick;
	int bulletCount,currentInterval,levelType;
	uint tauntIndex;
	CCMenu *launchMenu;
	float elapsed, distance,recoilRate;
	CGPoint speedVector;
	CCSprite *bullet,*menuTray,*zoomedInButton;
	CCLabelTTF *info1,*info2,*info3,*info4,*levelLabel;
	CCLabelBMFont *moneyLabel;
	NSArray *taunts;
	CCMenu *aMenu,*gMenu;
    BonusSprite *bonusSpriteLabel,*fieldReport,*enemyMoney;
}
@property (nonatomic,retain) CCLabelTTF *info1,*info2,*info3,*info4;
//@property (nonatomic,retain) BonusSprite *bonusSpriteLabel;
-(void) setup;
-(void) showPerks;
-(void) showSurvivalPerks;
-(void) updateInfo: (NSString*)s cc:(ccColor3B) cc;
-(void) resetLevel;
-(void) runLevel;
-(void) fireButtonPressed: (id)sender;
-(void) checkIfSighted:(int) sighted;
-(void)showArmageddon;
-(void)showMachinegun;
-(void)hideArmageddon;
-(void)hideMachinegun;
-(void) hiccup;
-(void)showEnemyMoney:(int)i;
-(void)showAgentCount:(int)i;
-(void)showProximity:(int) i;
-(void)showInfo:(int)i;
-(void) showBonus:(NSString*)bonus;
@end

@interface ScopeLayer : CCLayer {
	CCSprite *blur,*scope,*machinegun,*arrow;
	int showArrow;
}
@property (nonatomic, retain) CCSprite *blur;
- (void) blurryOn;
- (void) blurryOff;
-(void) armageddon;
-(void) checkIfSighted:(int) sighted;
-(void) resetScope;
-(void) hideScope;
-(void) showScope;
-(void) showSniper;
-(void) hideSniper;
float findAngle(CGPoint pt1, CGPoint pt2);
@end

@interface MidgroundLayer : CCLayer {}
- (void) makeBuilding:(int)x y:(int)y cc:(ccColor3B)cc cg:(CGPoint)cg;
- (void) moveBGPostion: (float) x y: (float) y;
- (void) setZoom:(float) z;
@end

@interface SkylineLayer : CCLayer {}
- (void) moveBGPostion: (float) x y: (float) y;
- (void) setZoom:(float) z;
@end

@interface PauseLayer : CCLayer {}
@end

