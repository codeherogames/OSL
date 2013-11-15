//
//  PixelSniperAppDelegate.h
//  PixelSniper
//
//  Created by James Dailey on 1/20/11.
//  Copyright James Dailey 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "GameKitHelper.h"
#import "GlassSlider.h"
#import "CCNotifications.h"
#import "Loadout.h"
#import "Stats.h"
#import "JDMenuItem.h"
#import "TextMenuItem.h"
//#import "LocalyticsSession.h"
#import "CustomPoint.h"
#import "DeviceDetection.h"
//#import "SHK.h"

@class RootViewController;
@class MyMenuButton;

@interface AppDelegate : NSObject <UIApplicationDelegate,GameKitHelperProtocol,CCNotificationsDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	CDAudioManager *am;
	CDSoundEngine  *soundEngine;
	
	int controls, sensitivity, gameType, tagCounter, reload,lastActionButton,multiplayer,tutorialState,playerLevel,playerWager,currentMission,lowRes,missionPage,friendInvite,sandboxMode,gameState,survivalMode;
	int recon,anti,jammers,currentLevel,allowRotate,help,helpPage,headshotStreak,killStreak,tjg,nightVision;
	float scale,minZoom,maxZoom,money;
	NSMutableArray *enemies,*actionButtons;
	NSMutableArray *walkStartPoint,*planeStartPoint,*vehicleStartPoint,*heliStartPoint,*roofStartPoint,*citizenStartPoint,*jumperStartPoint;
	CCLayer *bgLayer;
	GameKitHelper *gkHelper;
	GlassSlider *glassSlider;
	NSString *menuFont,*helpFont,*clearFont,*headshotFont,*currentOpponent,*vidFont,*docPath;
	//NSArray *matchPlayers;
	MyMenuButton *m1,*m2,*m3,*m4,*m5;
	NSMutableArray *rifles,*scopes,*ammo,*extras,*perks,*news,*opponentPerks;
	Loadout *loadout;
	Stats *stats;
	NSData /**kd,*/*dk;
	CustomPoint *Cbuilding1F4Elevator;
	/*ALChannelSource* SourceChannelOne;
	ALChannelSource* SourceChannelTwo;
	ALBuffer* buffer;*/
	int gkAvailable;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CDSoundEngine *soundEngine;
@property (nonatomic, retain) CDAudioManager *am;

@property (nonatomic, assign) int controls,sensitivity,gameType,tagCounter,reload,lastActionButton,recon,anti,kidnappers,jammers,currentLevel,allowRotate,multiplayer,help,helpPage,headshotStreak,tutorialState,killStreak,playerLevel,playerWager,currentMission,lowRes,missionPage,friendInvite,sandboxMode,survivalMode,gameState,gkAvailable,tjg,nightVision;
@property (nonatomic, assign) float scale,minZoom,maxZoom,money;
@property (nonatomic, retain) NSMutableArray *enemies,*actionButtons;
@property (nonatomic, retain) NSMutableArray *vehicleStartPoint,*walkStartPoint,*planeStartPoint,*heliStartPoint,*roofStartPoint,*citizenStartPoint,*jumperStartPoint;
@property (nonatomic, retain) CCLayer *bgLayer;
@property (nonatomic, retain) GameKitHelper *gkHelper;
@property (nonatomic, retain) GlassSlider *glassSlider;
@property (nonatomic, assign) NSString *menuFont,*helpFont,*clearFont,*headshotFont,*currentOpponent;
@property (nonatomic, retain) NSString *docPath,*vidFont;
@property (nonatomic, retain) NSData *dk,/**kd,*/*kdhd;
//@property (nonatomic, retain) NSArray *matchPlayers;
@property (nonatomic, retain) MyMenuButton *m1,*m2,*m3,*m4,*m5;
@property (nonatomic, retain) NSMutableArray *rifles,*scopes,*ammo,*extras,*perks,*news,*opponentPerks;
@property (nonatomic, retain) Loadout *loadout;
@property (nonatomic, retain) Stats *stats;
@property (nonatomic, retain) CustomPoint *Cbuilding1F4Elevator;

+(AppDelegate *) get;
+ (void) showNotification:(NSString*)m;
-(void) setUpAudioManager:(NSObject*) data;
-(void) loadingInit;
-(void) loadingStep0;
-(void) loadingStep1;
-(void) loadingDone;
-(void) loadData;
-(BOOL) perkEnabled:(int)i;
-(BOOL) myPerk:(int)i;
-(CCSprite*) getSprite:(NSString*) spriteName;

-(void) writeData:(NSString*)f d:(id)d;
//-(id) readData:(NSString*)f;
-(id) readDataHD:(NSString*)f;
-(id) initData:(NSString*)f;
-(void) loadItem:(NSString*)f;
-(void) loadImages:(NSString*)f;

@end
