//
//  PixelSniperAppDelegate.m
//  PixelSniper
//
//  Created by James Dailey on 1/20/11.
//  Copyright James Dailey 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "RootViewController.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "LinearPoint.h"
#import "MyMenuButton.h"
#import "ChildMenuButton.h"
#import "MyIAPHelper.h"
#import "NSDataAES256.h"
#import "Perk.h"
#import "Rifle.h"
#import "Scope.h"
#import "Ammo.h"
#import "Extras.h"
#import "TutorialSplash.h";
#import "Reachability.h"
#import "ConnectingScene.h"

@implementation AppDelegate

@synthesize window;
@synthesize controls,sensitivity,scale,minZoom,maxZoom,gameType,tagCounter,reload,money,lastActionButton,recon,anti,kidnappers,jammers,currentLevel,allowRotate,playerLevel,playerWager,currentMission,lowRes,missionPage,friendInvite,gkAvailable,tjg;
@synthesize am,soundEngine,bgLayer,gkHelper,glassSlider,multiplayer,m1,m2,m3,m4,m5;
@synthesize enemies,actionButtons,menuFont,currentOpponent,help,headshotStreak; //matchPlayers
@synthesize walkStartPoint,planeStartPoint,vehicleStartPoint,heliStartPoint,roofStartPoint,citizenStartPoint,jumperStartPoint;
@synthesize rifles,scopes,ammo,extras,perks,helpPage,helpFont,clearFont,headshotFont,news,stats,loadout,vidFont,docPath,kd,dk,Cbuilding1F4Elevator,opponentPerks,tutorialState,killStreak,sandboxMode,survivalMode,gameState,kdhd;

- (void) removeStartupFlicker
{
	allowRotate = 1;
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

	CC_ENABLE_DEFAULT_GL_STATES();
	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	sprite.position = ccp(size.width/2, size.height/2);
	sprite.rotation = -90;
	[sprite visit];
	[[director openGLView] swapBuffers];
	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
#ifdef ANDROID
    // UIScreenIPhone3GEmulationMode , UIScreenBestEmulatedMode, UIScreenAspectFitEmulationMode
    [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
#endif
	[[SKPaymentQueue defaultQueue] addTransactionObserver:[MyIAPHelper sharedHelper]];
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES])
		CCLOG(@"Retina Display Not supported");

	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/30];
	//[director setDisplayFPS:YES];
	
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	[glView setMultipleTouchEnabled:YES];
	
	// make the View Controller a child of the main window
	//[window addSubview: viewController.view];
    
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this mehod on ios6
        [window setRootViewController:viewController];
    }
	
	//[[LocalyticsSession sharedLocalyticsSession] startSession:@"037824fde0fbf8f9dcda299-cf2fc20c-5627-11e0-f8f0-007f58cb3154"];
	
	//Set up audio engine
	[self setUpAudioManager:nil];
	/*[OALSimpleAudio sharedInstance];
	[OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
	[OALAudioSession sharedInstance].handleInterruptions = YES;*/
	
	//////////////////////////////
	
	controls = 1;
	gameType = MULTIPLAYER;
	multiplayer = 2;
	tagCounter = 1;
	sensitivity = 0;
	help = 0;
	helpPage = 0;
	headshotStreak = 0;
	killStreak = 0;
	playerLevel = 0;
	playerWager = 0;
	currentMission = 0;
	gameState = NOGAME; //1 connecting, 2 ingame
	menuFont = @"GearsOfPeace";
	helpFont = @"MKStencilsansBlack.ttf";
	clearFont = @"BOMBARD_.ttf";
	headshotFont = @"foo.ttf";
	friendInvite = 0;
	sandboxMode = 0;
    survivalMode = 0;
	tjg = 0;
	vidFont = [[[UIDevice currentDevice] uniqueIdentifier] retain];
	enemies = [[NSMutableArray alloc] init];
	opponentPerks = [[NSMutableArray alloc] init];
	[CCMenuItemFont setFontName:menuFont];
	docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] retain];

	int ze = 8;
	int zt = ze-5;
	int zs = zt+4;
	int zw = zt-1;
	dk =[[[NSString stringWithFormat:@"j%i%iT%i%i%i.m",ze,zw,zt,zs,ze] dataUsingEncoding:NSUTF8StringEncoding] retain];
	kd =[[[NSString stringWithFormat:@"Sprite%@%i.png",vidFont,(ze*zs)] dataUsingEncoding:NSUTF8StringEncoding] retain];
	kdhd =[[[NSString stringWithFormat:@"Sprite%@%i.png",@"Helvetica",(ze*zs)] dataUsingEncoding:NSUTF8StringEncoding] retain];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	NSString *devName = (NSString*)[DeviceDetection returnDeviceName: NO];
	CCLOG(@"device:%@",devName);
	lowRes = 0;
	if ([devName isEqualToString:@"iPod Touch"] || [devName isEqualToString:@"iPod Touch 2"] || [devName isEqualToString:@"iPod Touch 3"] || [devName isEqualToString:@"iPhone"] || [devName isEqualToString:@"iPhone 3G"]) {
		CCLOG(@"Going RGBA4444");
		lowRes = 1;
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	}
	else {
		CCLOG(@"Going RGBA8888");
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	}
	//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
	
	// Removes the startup flicker
	[self removeStartupFlicker];

   /** Init CCNotifications (very easy) **/
   CCNotifications *notifications = [CCNotifications sharedManager];
   [notifications setDelegate:self];
	
   /** Add to cocos2d loop **/
   [[CCDirector sharedDirector] setNotificationNode:notifications];
	
	Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
	if ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending && gameKitLocalPlayerClass != nil) {
		CCLOG(@"game center available");
		gkHelper = [GameKitHelper sharedGameKitHelper];
		gkHelper.delegate = self;
		[gkHelper authenticateLocalPlayer];
		window.rootViewController = viewController;
		gkAvailable = 1;
	}
	else {
		CCLOG(@"Game Center not supported on this device");
		gkAvailable = 0;
		//[self showNotification:@"Game Center not supported on this device"];
	}
	
	
	
	[window makeKeyAndVisible];
	
	//[TapjoyConnect requestTapjoyConnect:@"6a75ed93-318a-420d-b1b6-f8c76fd376f0" secretKey:@"UWIj5ZSXO6CVNN16htpl"];

	
	//Init
	[self loadingInit];
	
	// Run the intro Scene
	//[[CCDirector sharedDirector] runWithScene: [MenuScene node]];	
}

BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
	
    // The device must be running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (localPlayerClassAvailable && osVersionSupported);
}

#pragma mark CCNotifications delegate methods (optional)
+ (void) showNotification:(NSString*)m
{
	CCLOG(@"ShowNotification: %@",m);
	//Complex method
	[[CCNotifications sharedManager] addWithTitle:@"hi" message:m image:nil tag:9999 animate:YES waitUntilDone:YES];
}

- (void) notification:(ccNotificationData*)notification newState:(char)state
{
	switch (state) {
		case kCCNotificationStateHide:
			//CCLOG(@"Notification hidden");
			//Play sound
			break;
		case kCCNotificationStateShowing:
			//CCLOG(@"Showing notification");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationIn:
			//CCLOG(@"Animation-In, began");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationOut:
			//CCLOG(@"Animation-Out, began");
			//Play sound
			
			break;
		default: break;
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	CCLOG(@"applicationDidReceiveMemoryWarning");
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	//[[LocalyticsSession sharedLocalyticsSession] close];
	//[[LocalyticsSession sharedLocalyticsSession] upload];
	if ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending) {
		[GKMatchmaker sharedMatchmaker].inviteHandler = nil;
	}
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	//[[LocalyticsSession sharedLocalyticsSession] resume];
	//[[LocalyticsSession sharedLocalyticsSession] upload];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//[[LocalyticsSession sharedLocalyticsSession] close];
	//[[LocalyticsSession sharedLocalyticsSession] upload];
	if ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending) {
		if ([AppDelegate get].multiplayer > 0) {
			[[AppDelegate get].gkHelper disconnectCurrentMatch];
		}
	}
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void) setUpAudioManager:(NSObject*) data {
	
	//Channel groups define how voices are shared, the maximum number of voices is defined by 
	//CD_MAX_SOURCES in the CocosDenshion.h file
	//When a request is made to play a sound within a channel group the next available voice
	//is used.  If no voices are free then the least recently used voice is stopped and reused.
	//int channelGroupCount = CGROUP_TOTAL;
	int channelGroups[3];
	channelGroups[CGROUP_BACKGGROUND] = 1;//background
	channelGroups[CGROUP_VOICES] = 7;//voices shared
	channelGroups[CGROUP_WEAPONS] = 16;//weapon sounds shared
	
	//Initialise audio manager asynchronously as it can take a few seconds
	//[CDAudioManager initAsynchronously:kAudioManagerFxPlusMusic channelGroupDefinitions:channelGroups channelGroupTotal:channelGroupCount];
	[CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
}

+(AppDelegate *) get {
    
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

-(BOOL) perkEnabled:(int)i {
	if (gameType == SANDBOX) {
		return  (loadout.s1 == i || loadout.s2 == i || loadout.s3 == i);
	}
    else if (gameType == SURVIVAL && [AppDelegate get].survivalMode == 1) {
        return ([[AppDelegate get].opponentPerks containsObject:[NSNumber numberWithInteger:i]]);
    }
	else if (multiplayer > 0 && [AppDelegate get].playerLevel > 0) {
		Perk *p = [[AppDelegate get].perks objectAtIndex:i-1];
		//CCLOG(@"perkEnabled:%@ multi:%d",p.n,p.m);
		if (p.m == 1)
			return ([[AppDelegate get].opponentPerks containsObject:[NSNumber numberWithInteger:i]]);
		else
			return (loadout.s1 == i || loadout.s2 == i || loadout.s3 == i);
	}
	return FALSE;
}

-(BOOL) myPerk:(int)i {
	return  (loadout.s1 == i || loadout.s2 == i || loadout.s3 == i);
}
///////////////////////////////////
-(void)getPoints:(NSNotification*)notifyObj
{
	NSNumber *tp = notifyObj.object;
	tjg = [tp intValue];
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	// Print out the updated points value.
	CCLOG(@"Points: %i", tjg);
	if(tjg > 0) {
		CCLOG(@"Call Custom Scene");//redeemMenu.position=ccp(220,30);
		if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(customPop)]) {
			[[[CCDirector sharedDirector] runningScene] customPop];
		}
		else {
			[AppDelegate showNotification:@"Go to Customize to claim your Gold"];
		}
	}
}

-(void)getUpdatedPoints:(NSNotification*)notifyObj
{
	CCLOG(@"UpdatedPoints");
	NSNumber *tp = notifyObj.object;
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	if([tp intValue] == 0) {
		if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(go)]) {
			[[[CCDirector sharedDirector] runningScene] go];
		}
	}
}
/////////////////////////////////////////

#pragma mark GameKitHelper delegate methods
-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
	[gkHelper getPlayerInfo:friends];
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	//[AppDelegate get].matchPlayers = players;
	CCLOG(@"onPlayerInfoReceived: %@", [players description]);	
	//[gkHelper getPlayerInfo:players];
}

-(void) onAttackReceived:(int)attack pid:(NSString*)pid m:(int)m a:(int)a {
	CCLOG(@"attack recieved %i",attack);
    [bgLayer onAttackReceived:attack pid:pid];
    if ([[AppDelegate get] myPerk:42])
        [bgLayer showEnemyMoney:m];
    if ([[AppDelegate get] myPerk:43])
        [bgLayer showAgentCount:a];
}

-(void) onAliasReceived:(NSString*)alias {
	CCLOG(@"onAliasReceived %@",alias);
	currentOpponent = [alias mutableCopy];
	gameState = INGAME;
	[[CCDirector sharedDirector] replaceScene: [GameScene node]];
}

-(void) onScoresReceived:(NSArray*)scores {
	CCLOG(@"onScoresReceived");
	int myScore = 1;
	if (scores != nil && [scores count] > 0) {
		CCLOG(@"got Score: %@",[scores objectAtIndex:0]);
		if ([scores objectAtIndex:0] != nil) {
			myScore = (int) (((GKScore*) [scores objectAtIndex:0]).value);
			if (myScore < 0 || myScore > 100000)
				myScore = 1;
			else 
				myScore++;
		}
	}
	
	// Fix score if GC doesn't have latest
	if ([AppDelegate get].multiplayer > 0) {
		if ([AppDelegate get].playerLevel > 0) {
			if (myScore <= [AppDelegate get].stats.w3w) {
				myScore = [AppDelegate get].stats.w3w;
				CCLOG(@"updating myscore: %i",myScore);
			}
			else {
				[AppDelegate get].stats.w3w = myScore;
				CCLOG(@"updating stats: %i",myScore);
				[self writeData:@"t" d:stats];
			}
		}
		else {
			if (myScore <= [AppDelegate get].stats.w2) {
				myScore = [AppDelegate get].stats.w2;
				CCLOG(@"updating myscore: %i",myScore);
			}
			else {
				[AppDelegate get].stats.w2 = myScore;
				CCLOG(@"updating stats: %i",myScore);
				[self writeData:@"t" d:stats];
			}
		}
	}
	CCLOG(@"got score:%i for level:%i",myScore,self.playerLevel);
	[gkHelper submitScore:myScore category:[NSString stringWithFormat:@"%i", (self.gameType + self.playerLevel)]];
}

// Only submit when score is higher than highest
/*-(void) onTopScoreReceived:(NSArray*)scores s:(int)s {
	if (scores != nil) {
		CCLOG(@"got Score: %@",[scores objectAtIndex:0]);
		if (s>(((GKScore*) [scores objectAtIndex:0]).value))
			[gkHelper submitScore:s category:[NSString stringWithFormat:@"%i", self.gameType]];
	}
	else {
		[gkHelper submitScore:s category:[NSString stringWithFormat:@"%i", self.gameType]];
	}
}
*/
-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}


-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
	if (activity > 0)
		[AppDelegate showNotification:[NSString stringWithFormat:@"Recent Multiplayer Activity: %i", activity]];
}

-(void) onMatchFound:(GKMatch*)match
{
	CCLOG(@"onMatchFound: %@", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(NSString*)playerID
{
	CCLOG(@"onPlayerConnected: %@", playerID);
}

-(void) onPlayerDisconnected:(NSString*)playerID
{
	CCLOG(@"onPlayerDisconnected: %@", playerID);
	if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(hideWait)]) {
		[AppDelegate showNotification:@"Opponent Disconnected"];
		[[[CCDirector sharedDirector] runningScene] hideWait];
	}
	else if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(handleDisconnect)]) {
		if (gameState == INGAME) {
			CCLOG(@"in game");
			gameState = NOGAME;
			[[[CCDirector sharedDirector] runningScene] handleDisconnect];
		}
	}
	//[AppDelegate showNotification:[NSString stringWithFormat:@"Player: %@ disconnected", currentOpponent]];
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
	//[[CCDirector sharedDirector] replaceScene: [GameScene node]];
}
///////////////////////////////////

- (void) loadingInit
{
	CCLOG(@"loadingInit");
	[AppDelegate get].news =  [[NSMutableArray alloc] init];
	//[self performSelectorOnMainThread:@selector(getNews) withObject:nil waitUntilDone:NO];
	
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
	{
		[NSThread detachNewThreadSelector:@selector(getNews) 
								 toTarget:self 
							   withObject:nil];
	}
	else
	{
		CCLOG(@"Skip news download");
	}
	
    //[self unschedule: @selector(loadingInit)];
	///////////////////////////////////////////
	//CustomPoint *pauseAction =  [[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(0,0) s:PAUSE z:ZOUT n:@"Pause"];
	// Prez
	CustomPoint *prezRoomRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ROOM2,FLOOR3Y) s:WALK z:ZIN n:@"prezRoomRight"];
	CustomPoint *prezRoomLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ROOM1,FLOOR3Y) s:WALK z:ZIN n:@"prezRoomLeft"];
	
	// Roof
	CustomPoint *building1RoofElevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,ROOF) s:WALK z:ZOUT n:@"building1RoofElevator"];
	CustomPoint *building1RoofRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGE,ROOF) s:WALK z:ZOUT n:@"building1RoofRight"];	
	
	// 5th Floor
	CustomPoint *building1F5Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR5Y) s:WALK z:ZIN n:@"building1F5Elevator"];	
	//[building1F5Elevator.nextPoints addObject:building1F4Elevator];
	
	CustomPoint *building1F5Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORRIGHT,FLOOR5Y) s:WALK z:ZIN n:@"building1F5Escalator"];
	//[building1F5Escalator.nextPoints addObject:building1F4Escalator];
	
	CustomPoint *building1F5Right =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(BUILDINGEDGE,FLOOR5Y) s:CLIMB z:ZOUT n:@"building1F5Right"];	
	//[building1F5Right.nextPoints addObject:building1F4Right];
	[building1F5Right.nextPoints addObject:building1F5Escalator];
	[building1F5Right.nextPoints addObject:building1F5Elevator];
	
	[building1RoofElevator.nextPoints addObject:building1F5Elevator];
	[building1RoofRight.nextPoints addObject:building1F5Right];
	
	// 4th Floor
	CustomPoint *building1F4Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR4Y) s:WALK z:ZIN n:@"building1F4Elevator"];	
	//[building1F4Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *building1F4Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORLEFT,FLOOR4Y) s:WALK z:ZIN n:@"building1F4Escalator"];
	[building1F4Escalator.nextPoints addObject:building1F4Elevator];
	
	CustomPoint *building1F4Right =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(BUILDINGEDGE,FLOOR4Y) s:CLIMB z:ZOUT n:@"building1F4Right"];
	
	
	[building1F5Right.nextPoints addObject:building1F4Right];
	[building1F5Escalator.nextPoints addObject:building1F4Escalator];
	[building1F5Elevator.nextPoints addObject:building1F4Elevator];
	
	// 3rd Floor
	CustomPoint *building1F3Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR3Y) s:WALK z:ZIN n:@"building1F3Elevator"];	
	[building1F3Elevator.nextPoints addObject:prezRoomLeft];
	
	[building1F4Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *building1F3Right =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(BUILDINGEDGE,FLOOR3Y) s:CLIMB z:ZOUT n:@"building1F3Right"];	
	[building1F3Right.nextPoints addObject:prezRoomRight];
	[building1F3Right.nextPoints addObject:building1F4Right];
	
	[building1F4Right.nextPoints addObject:building1F3Right];
	[building1F4Right.nextPoints addObject:building1F4Elevator];
	[building1F4Right.nextPoints addObject:building1F5Right];
	
	// 2nd Floor
	CustomPoint *building1F2Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR2Y) s:WALK z:ZIN n:@"building1F2Elevator"];	
	[building1F2Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *building1F2Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORLEFT,FLOOR2Y) s:WALK z:ZIN n:@"building1F2Escalator"];
	[building1F2Escalator.nextPoints addObject:building1F2Elevator];
	
	CustomPoint *building1F2Right =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(BUILDINGEDGE,FLOOR2Y) s:CLIMB z:ZOUT n:@"building1F2Right"];		
	[building1F2Right.nextPoints addObject:building1F3Right];
	[building1F2Right.nextPoints addObject:building1F2Elevator];
	
	// 1st Floor (Ground)
	CustomPoint *building1F1Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR1Y) s:WALK z:ZIN n:@"building1F1Elevator"];	
	[building1F1Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *building1F1Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORRIGHT,FLOOR1Y) s:WALK z:ZIN n:@"building1F1Escalator"];	
	[building1F1Escalator.nextPoints addObject:building1F2Escalator];
	
	CustomPoint *building1F1Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGE,SIDEWALK) s:WALK z:ZOUT n:@"building1F1Right"];
	[building1F1Right.nextPoints addObject:building1F2Right];
	
	CustomPoint *building1F1Inside =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGDOOR,FLOOR1Y) s:WALK z:ZIN n:@"building1F1Door"];
	/// switch this order back
	[building1F1Inside.nextPoints addObject:building1F1Escalator];
	[building1F1Inside.nextPoints addObject:building1F1Elevator];
	
	
	CustomPoint *building1F1Door =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGDOOR,SIDEWALK) s:WALK z:ZOUT n:@"building1F1Door"];
	[building1F1Door.nextPoints addObject:building1F1Inside];
	
	// Start Points
	CustomPoint *sidewalkRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(MAXX,SIDEWALK) s:WALK z:ZOUT n:@"sidewalkRight"];
	[sidewalkRight.nextPoints addObject:building1F1Right];
	[sidewalkRight.nextPoints addObject:building1F1Door];	
	
	CustomPoint *sidewalkLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(MINX,SIDEWALK) s:WALK z:ZOUT n:@"sidewalkLeft"];
	[sidewalkLeft.nextPoints addObject:building1F1Right];
	[sidewalkLeft.nextPoints addObject:building1F1Door];
	
	// Start Walk Points
	[AppDelegate get].walkStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].walkStartPoint addObject:sidewalkRight];
	[[AppDelegate get].walkStartPoint addObject:sidewalkLeft];
	
	// Roof Walk Points
	[AppDelegate get].roofStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].roofStartPoint addObject:building1RoofRight];
	[[AppDelegate get].roofStartPoint addObject:building1RoofElevator];
	
	
	//// Citizen ////
	// 5th Floor
	CustomPoint *Cbuilding1F5Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR5Y) s:WALK z:ZIN n:@"Cbuilding1F5Elevator"];	
	//[building1F5Elevator.nextPoints addObject:building1F4Elevator];
	
	CustomPoint *Cbuilding1F5Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORRIGHT,FLOOR5Y) s:WALK z:ZIN n:@"Cbuilding1F5Escalator"];
	//[building1F5Escalator.nextPoints addObject:building1F4Escalator];
	CustomPoint *Cbuilding1F5Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGECITIZEN,FLOOR5Y) s:WALK z:ZIN n:@"Cbuilding1F5Right"];		
	[Cbuilding1F5Elevator.nextPoints addObject:Cbuilding1F5Right];
	[Cbuilding1F5Right.nextPoints addObject:Cbuilding1F5Escalator];
	[Cbuilding1F5Right.nextPoints addObject:Cbuilding1F5Elevator];
	
	// 4th Floor
	Cbuilding1F4Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR4Y) s:WALK z:ZIN n:@"Cbuilding1F4Elevator"];	
	//[building1F4Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *Cbuilding1F4Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORLEFT,FLOOR4Y) s:WALK z:ZIN n:@"Cbuilding1F4Escalator"];
	
	CustomPoint *Cbuilding1F4Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGECITIZEN,FLOOR4Y) s:WALK z:ZIN n:@"Cbuilding1F4Right"];	
	[Cbuilding1F4Escalator.nextPoints addObject:Cbuilding1F4Elevator];
	[Cbuilding1F4Escalator.nextPoints addObject:Cbuilding1F5Escalator];
	[Cbuilding1F5Escalator.nextPoints addObject:Cbuilding1F4Escalator];
	[Cbuilding1F5Elevator.nextPoints addObject:Cbuilding1F4Elevator];
	[Cbuilding1F4Elevator.nextPoints addObject:Cbuilding1F4Right];
	[Cbuilding1F4Elevator.nextPoints addObject:Cbuilding1F5Elevator];
	[Cbuilding1F4Right.nextPoints addObject:Cbuilding1F4Elevator];
	[Cbuilding1F4Right.nextPoints addObject:Cbuilding1F4Escalator];
	
	// 3rd Floor
	/*Cbuilding1F3Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR4Y) s:WALK z:ZIN n:@"Cbuilding1F4Elevator"];	
	[building1F4Elevator.nextPoints addObject:building1F3Elevator];
	
	CustomPoint *Cbuilding1F3Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGECITIZEN,FLOOR3Y) s:WALK z:ZIN n:@"Cbuilding1F3Right"];	
	[Cbuilding1F3Elevator.nextPoints addObject:Cbuilding1F3Right];
	[Cbuilding1F3Right.nextPoints addObject:Cbuilding1F3Elevator];
	[Cbuilding1F3Elevator.nextPoints addObject:Cbuilding1F4Elevator];*/
	
	// 2nd Floor
	CustomPoint *Cbuilding1F2Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR2Y) s:WALK z:ZIN n:@"Cbuilding1F2Elevator"];	
	
	
	CustomPoint *Cbuilding1F2Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORLEFT,FLOOR2Y) s:WALK z:ZIN n:@"Cbuilding1F2Escalator"];
	
	
	CustomPoint *Cbuilding1F2Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGECITIZEN,FLOOR2Y) s:WALK z:ZIN n:@"Cbuilding1F2Right"];	
	[Cbuilding1F2Escalator.nextPoints addObject:Cbuilding1F2Elevator];
	[Cbuilding1F2Escalator.nextPoints addObject:Cbuilding1F2Right];
	[Cbuilding1F2Elevator.nextPoints addObject:Cbuilding1F4Elevator];
	[Cbuilding1F2Elevator.nextPoints addObject:Cbuilding1F2Escalator];
	[Cbuilding1F2Elevator.nextPoints addObject:Cbuilding1F2Right];
	[Cbuilding1F2Right.nextPoints addObject:Cbuilding1F2Escalator];
	[Cbuilding1F2Right.nextPoints addObject:Cbuilding1F2Elevator];
	
	[Cbuilding1F4Elevator.nextPoints addObject:Cbuilding1F2Elevator];
	
	CustomPoint *Cbuilding1F1Elevator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,FLOOR1Y) s:WALK z:ZIN n:@"Cbuilding1F1Elevator"];	
	
	CustomPoint *Cbuilding1F1Escalator =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ESCALATORRIGHT,FLOOR1Y) s:WALK z:ZIN n:@"Cbuilding1F1Escalator"];	
	
	CustomPoint *Cbuilding1F1Inside =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGDOOR,FLOOR1Y) s:WALK z:ZIN n:@"Cbuilding1F1Inside"];
	[Cbuilding1F1Escalator.nextPoints addObject:Cbuilding1F1Elevator];
	[Cbuilding1F1Escalator.nextPoints addObject:Cbuilding1F1Inside];
	[Cbuilding1F1Escalator.nextPoints addObject:Cbuilding1F2Escalator];
	[Cbuilding1F1Elevator.nextPoints addObject:Cbuilding1F2Elevator];
	[Cbuilding1F1Elevator.nextPoints addObject:Cbuilding1F1Escalator];
	[Cbuilding1F1Elevator.nextPoints addObject:Cbuilding1F1Inside];
	[Cbuilding1F1Inside.nextPoints addObject:Cbuilding1F1Escalator];
	[Cbuilding1F1Inside.nextPoints addObject:Cbuilding1F1Elevator];
	
	[Cbuilding1F2Escalator.nextPoints addObject:Cbuilding1F1Escalator];
	[Cbuilding1F2Elevator.nextPoints addObject:Cbuilding1F1Elevator];
	
	CustomPoint *Cbuilding1F1Door =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGDOOR,SIDEWALK) s:WALK z:ZOUT n:@"Cbuilding1F1Door"];
	[Cbuilding1F1Door.nextPoints addObject:Cbuilding1F1Inside];
	[Cbuilding1F1Inside.nextPoints addObject:Cbuilding1F1Door];
	
	// Outside
	CustomPoint *CRandomRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGE+200,SIDEWALK) s:WALK z:ZOUT n:@"CRandomRight"];
	
	CustomPoint *CRandomLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ELEVATORX,SIDEWALK) s:WALK z:ZOUT n:@"CRandomLeft"];
	
	CustomPoint *Cbuilding1F1Right =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDINGEDGE,SIDEWALK) s:WALK z:ZOUT n:@"Cbuilding1F1Right"];
	[Cbuilding1F1Right.nextPoints addObject:CRandomLeft];
	[Cbuilding1F1Right.nextPoints addObject:CRandomRight];
	[Cbuilding1F1Right.nextPoints addObject:Cbuilding1F1Door];
	[Cbuilding1F1Door.nextPoints addObject:Cbuilding1F1Right];
	[CRandomRight.nextPoints addObject:Cbuilding1F1Right];
	[CRandomLeft.nextPoints addObject:Cbuilding1F1Door];
	
	CustomPoint *CsidewalkRight =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(MAXX,SIDEWALK) s:WALK z:ZOUT n:@"sidewalkRight"];
	
	[CsidewalkRight.nextPoints addObject:CRandomRight];
	
	CustomPoint *CsidewalkLeft =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(MINX,SIDEWALK) s:WALK z:ZOUT n:@"sidewalkLeft"];
	[CsidewalkLeft.nextPoints addObject:CRandomLeft];
	
	//[CRandomRight.nextPoints addObject:CsidewalkRight];
	//[CRandomLeft.nextPoints addObject:CsidewalkLeft];
	
	[AppDelegate get].citizenStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].citizenStartPoint addObject:CsidewalkRight];
	[[AppDelegate get].citizenStartPoint addObject:CsidewalkLeft];	
	
	//// Jumper ////
	CustomPoint *jPoint5 =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(ROOM2,FLOOR3Y) s:WALK z:ZIN n:@"jPoint5"];
	CustomPoint *jPoint4 =  [[CustomPoint alloc] initWithData:CLIMBRATE p:ccp(BUILDINGEDGE,FLOOR3Y) s:CLIMB z:ZOUT n:@"jPoint4"];
	CustomPoint *jPoint3 =  [[CustomPoint alloc] initWithData:RAPPELRATE p:ccp(BUILDINGEDGE,FLOOR4Y) s:RAPPEL z:ZOUT n:@"jPoint3"];
	CustomPoint *jPoint2 =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDING2LEFT,ROOF+6) s:WALK z:ZOUT n:@"jPoint2"];
	CustomPoint *jPoint1 =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(BUILDING2RIGHT,ROOF+6) s:WALK z:ZOUT n:@"jPoint1"];
	
	// Start Points
	CustomPoint *JbuildingRight =  [[CustomPoint alloc] initWithData:INSTANTRATE p:ccp(BUILDING2RIGHT,ROOF+6) s:WALK z:ZOUT n:@"JbuildingRight"];
	[jPoint4.nextPoints addObject:jPoint5];
	[jPoint3.nextPoints addObject:jPoint4];
	[jPoint2.nextPoints addObject:jPoint3];
	[jPoint1.nextPoints addObject:jPoint2];
	[JbuildingRight.nextPoints addObject:jPoint1];
	
	[AppDelegate get].jumperStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].jumperStartPoint addObject:JbuildingRight];	
	
	//// Vehicles ////
	LinearPoint *pauseDrop =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(0,0) s:PAUSE z:ZOUT n:@"Pause"];
	LinearPoint *building1StreetDoor =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(BUILDINGDOOR,STREET) s:DRIVE z:ZOUT n:@"building1StreetDoor"];
	LinearPoint *streetRight =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(MAXX,STREET) s:DRIVE z:ZOUT n:@"streetRight"];		
	LinearPoint *streetLeft =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(MINX,STREET) s:DRIVE z:ZOUT n:@"streetLeft"];
	
	[AppDelegate get].vehicleStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].vehicleStartPoint addObject:streetRight];
	[[AppDelegate get].vehicleStartPoint addObject:building1StreetDoor];
	[[AppDelegate get].vehicleStartPoint addObject:pauseDrop];
	[[AppDelegate get].vehicleStartPoint addObject:building1StreetDoor];
	[[AppDelegate get].vehicleStartPoint addObject:streetLeft];	
	
	//// Helicopter ////
	LinearPoint *pauseDropHeli =  [[CustomPoint alloc] initWithData:WALKRATE p:ccp(0,0) s:PAUSE z:ZOUT n:@"Pause"];
	LinearPoint *leftDescent =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(ELEVATORX,SKYY-40) s:DRIVE z:ZOUT n:@"leftDescent"];
	LinearPoint *rightDescent =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(BUILDINGEDGE,SKYY-40) s:DRIVE z:ZOUT n:@"rightDescent"];
	LinearPoint *helipad =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(HELIPADX,ROOF+30) s:DRIVE z:ZOUT n:@"helipad"];	
	
	// Start Points
	LinearPoint *heliLeft =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(MINX-200,SKYY-40) s:DRIVE z:ZOUT n:@"heliLeft"];
	LinearPoint *heliRight =  [[CustomPoint alloc] initWithData:VEHICLE1RATE p:ccp(MAXX+200,SKYY-40) s:DRIVE z:ZOUT n:@"heliRight"];
	
	[AppDelegate get].heliStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].heliStartPoint addObject:heliRight];
	[[AppDelegate get].heliStartPoint addObject:rightDescent];
	[[AppDelegate get].heliStartPoint addObject:helipad];
	[[AppDelegate get].heliStartPoint addObject:pauseDropHeli];
	[[AppDelegate get].heliStartPoint addObject:helipad];
	[[AppDelegate get].heliStartPoint addObject:leftDescent];
	[[AppDelegate get].heliStartPoint addObject:heliLeft];	
	
	
	//// Plane ////
	LinearPoint *dropPoint6 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2)-300,SKYY) s:DROP z:ZOUT n:@"dropPoint4"];
	LinearPoint *dropPoint5 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2),SKYY) s:DROP z:ZOUT n:@"dropPoint4"];
	LinearPoint *dropPoint4 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2)+300,SKYY) s:DROP z:ZOUT n:@"dropPoint4"];
	LinearPoint *dropPoint3 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2)+600,SKYY) s:DROP z:ZOUT n:@"dropPoint3"];
	LinearPoint *dropPoint2 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2)+900,SKYY) s:DROP z:ZOUT n:@"dropPoint2"];
	LinearPoint *dropPoint1 =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(((ELEVATORX + BUILDINGEDGE)/2)+1200,SKYY) s:DROP z:ZOUT n:@"dropPoint1"];
	
	// Start Points
	LinearPoint *skyLeft =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(MINX-200,SKYY) s:DRIVE z:ZOUT n:@"skyLeft"];
	LinearPoint *skyRight =  [[CustomPoint alloc] initWithData:VEHICLE2RATE p:ccp(MAXX+200,SKYY) s:DRIVE z:ZOUT n:@"skyRight"];
	
	// Drop Raid 1
	[AppDelegate get].planeStartPoint =  [[NSMutableArray alloc] init];
	[[AppDelegate get].planeStartPoint addObject:skyRight];
	[[AppDelegate get].planeStartPoint addObject:dropPoint1];
	[[AppDelegate get].planeStartPoint addObject:dropPoint2];	
	[[AppDelegate get].planeStartPoint addObject:dropPoint3];
	[[AppDelegate get].planeStartPoint addObject:dropPoint4];
	[[AppDelegate get].planeStartPoint addObject:dropPoint5];
	[[AppDelegate get].planeStartPoint addObject:dropPoint6];
	[[AppDelegate get].planeStartPoint addObject:skyLeft];
	
	// [self schedule: @selector(loadingStep0) interval: .1];
	[self loadingStep0];
}

- (void) loadingStep0
{
	CCLOG(@"loadingStep0"); 
	
	/*SourceChannelOne = [[ALChannelSource channelWithSources:7] retain];
	SourceChannelTwo = [[ALChannelSource channelWithSources:2] retain];*/
	//[[OALSimpleAudio sharedInstance] preloadEffect:SHOOT_SOUND];
	
	[AppDelegate get].am = [CDAudioManager sharedManager];
	[AppDelegate get].soundEngine = [AppDelegate get].am.soundEngine;
	
	int soundCount = 0;
	
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"gunshot.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"reload.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"buttonClick.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"open.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"close.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"zoomIn.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"zoomOut.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"rickroll.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"alarm.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"pageturn.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"armageddonMono.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"beep.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"gogetsome.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"headshot.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"multikill.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"killstreak.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"dominating.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"massacre.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"godlike.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"unstoppable.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"success.wav"];
	soundCount++;	
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"bodyshot.wav"];
	soundCount++;
	[[AppDelegate get].soundEngine loadBuffer:soundCount filePath:@"coin.wav"];
	soundCount++;	
	[[AppDelegate get].am backgroundMusic].volume = 0.2;
	[[AppDelegate get].am playBackgroundMusic:@"bgmusic.wav" loop:TRUE];
	//[[AppDelegate get].soundEngine setChannelGroupNonInterruptible:1 isNonInterruptible:TRUE];
	//[[AppDelegate get].soundEngine setChannelGroupNonInterruptible:2 isNonInterruptible:TRUE];
	
	[[AppDelegate get].am setResignBehavior:kAMRBStopPlay autoHandle:TRUE];
	
	//////////////////////////////////
	glassSlider = [[GlassSlider alloc] initWithFile:@"glassSlider.png"];
	
	actionButtons = [[NSMutableArray alloc] init];
	lastActionButton = -1;
	m5 = [[MyMenuButton alloc] initWithName:@"buttonarmageddon" t:5 val:T5];
	//Children		
	[m5.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"armageddonicon.png" t:CODEPERK1 d:@"Armageddon" ld:@"Nuclear bomb destroys all agents and vehicles on both your screen and opponent screen.  Your money will go to zero but your opponent will retain their money.  A button will show bottom right to launch the bomb.  During multiplayer, ONLY the first person to choose this will have it available.  One time use."]];
	[m5.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"machinegunicon.png" t:CODEPERK2 d:@"Machine Gun" ld:@"Get a machine gun with unlimited ammo for 10 seconds to destroy as much as you can.  A button will show bottom right to fire the machine gun.  During multiplayer, ONLY the first person to choose this will have it available.  One time use."]];
	[m5.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"securityicon.png" t:CODEPERK3 d:@"Body Guards" ld:@"Get a body guard on each side of Smitty to protect him from Agents.  Each one can defeat 2 Agents in hand to hand combat.  During multiplayer, ONLY the first person to choose this will have it available.  One time use."]];
	
	m4 = [[MyMenuButton alloc] initWithName:@"buttonchopper" t:4 val:T4];
	//Children
	[m4.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"planeicon.png" t:CODEPLANE d:@"Plane" ld:@"Launches a Military Plane.  The Plane is unstoppable.  It flies above the scene and drops off several paratroopers.  Once it unloads the cargo, it heads back to base."]];
	[m4.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"truckicon.png" t:CODETRUCK d:@"Truck" ld:@"Launches a Pickup Truck.  The Truck has a driver and two Agents and will stop in strategic places.  Once it stops, it drops off the two Agents and heads back to base.  It will continue to do so until you shoot the driver.  If you shoot the driver, the vehicle will stop moving but Agents will jump out and continue on their way."]];
	[m4.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"choppericon.png" t:CODECHOPPER d:@"Helicopter" ld:@"Launches a Helicopter.  The Helicopter has a pilot and two Agents and will land in strategic places.  Once it lands, it drops off the two Agents and heads back to base.  It will continue to do so until you shoot the pilot.  If you shoot the pilot while passengers are on board, they will parachute out."]];
	
	m3 = [[MyMenuButton alloc] initWithName:@"buttonradio" t:3 val:T3];
	//Children
	[m3.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"walkietalkieicon.png" t:CODERECON d:@"Enable Recon" ld:@"Enables Reconnaissance.  Recon is extremely helpful because it shows you the last several actions performed by your opponent.  The Recon section on the right will show your moves in green and opponent moves in red. Knowing what is coming is half the battle."]];
	[m3.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"NOwalkietalkieicon.png" t:CODEANTI d:@"Anti Recon" ld:@"Launches Anti-Recon against your opponent.  Anti-Recon accomplishes two things.  First, it disables opponent recon information so they cannot see what you launch. Second, it annoys the heck out of them.  To remove, destroy 3 radio jammers located in your base."]];
	[m3.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"hummericon.png" t:CODEARMOR d:@"Armored Vehicle" ld:@"Launches an Armored Vehicle.  The Armored Vehicle can not be stopped.  It quickly drops off 2 Agents in a convenient spot and then heads back to base."]];
	
	m2 = [[MyMenuButton alloc] initWithName:@"buttonscope" t:2 val:T2];
	//Children
	[m2.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"ziplineicon.png" t:CODEJUMPER d:@"Zipline Agent" ld:@"Launches a Zipline Agent.  Zipline Agents roam the rooftops and will rappel down a zipline to get to their goal quickly."]];
	[m2.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"scopeicon.png" t:CODEINVERTED d:@"Invert Scope" ld:@"Inverts the scope controls of your opponent, making it difficult to control.  To remove, eliminate 3 Agents."]];
	[m2.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"fingerprinticon.png" t:CODETHUMB d:@"Smudge Scope" ld:@"Puts a big thumb print on scope of your opponent, making it difficult for them to see.  To remove, eliminate 3 Agents."]];
	
	m1 = [[MyMenuButton alloc] initWithName:@"buttonman" t:1 val:T1];
	//Children
	[m1.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"guyicon.png" t:CODEAGENT d:@"Agent" ld:@"Launches a Foot Agent.  Agents will stop at nothing to reach their goal.  If you shoot an agent in the body, the agent will pause for short time to recover from their wound and then continue."]];
	[m1.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"citizenicon.png" t:CODECITIZEN d:@"Citizen" ld:@"Launches a Citizen.  Citizens roam around and get in the way.  If you shoot one, you will pay a penalty as innocent casualties are unacceptible."]];
	[m1.childButtons addObject:[[ChildMenuButton alloc] initWithFile:@"parachuteicon.png" t:CODEPARACHUTE d:@"Paratrooper" ld:@"Launches a single Paratrooper from the sky.  Once they hit the ground, they act like Foot Agents."]];
	
	[self loadingStep1];
}

- (void) loadingStep1
{
	CCLOG(@"loadingStep1");
	////////////////////////////////////////////////////
	/// Add Images to cache
	////////////////////////////////////////////////////
	/*
	for(int i=1;i<3;i++) {
		[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"background%i.png",i] ];
	}

	[[CCTextureCache sharedTextureCache] addImageAsync:@"menuBackground.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"w1px.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"b1px.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"g1px.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"cube.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"scopeblack.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"fingerprint.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"bldg2.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"mainbldg1.png" target:self selector:@selector(imageLoaded:)];
	*/
	[self loadData];
}

-(void) imageLoaded: (CCTexture2D*) tex
{
  
}

- (void) loadingDone
{

	CCLOG(@"LoadingDone"); 
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"t"] != nil) {
		[[CCDirector sharedDirector] runWithScene: [MenuScene node]];
	}
	else {
		[[CCDirector sharedDirector] runWithScene: [TutorialSplash node]];
	}
}

-(void) loadData {
	//Get news plist
	CCLOG(@"loadData");
    perks = (NSMutableArray*) [[self initData:@"p"] retain];
	rifles = (NSMutableArray*) [[self initData:@"r"] retain];
	scopes = (NSMutableArray*) [[self initData:@"s"] retain];
	ammo = (NSMutableArray*) [[self initData:@"a"] retain];
	extras = (NSMutableArray*) [[self initData:@"e"] retain];
    loadout = (Loadout*) [[self initData:@"l"] retain];
	stats = (Stats*) [[self initData:@"t"] retain];
    
	[self loadItem:@"p"];
	[self loadItem:@"r"];
	[self loadItem:@"s"];
	[self loadItem:@"a"];
	[self loadItem:@"e"];
    
	[self loadImages:@"l"];
	[self loadImages:@"t"];
	[self loadingDone];
}

-(void) loadItem:(NSString*)f {
	NSMutableArray *obj;// = [[NSMutableArray alloc] init];
    bool found = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px-hd.pvr",f]]]) {
		//CCLOG(@"%@-hd exists",f);
		obj = [(NSMutableArray*) [self readDataHD:f] retain];
        found = YES;
	}
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px.pvr",f]]]) {
		//CCLOG(@"%@ exists",f);
		obj = [(NSMutableArray*) [self readData:f] retain];
        found = YES;
	}
    if (found) {
        if ([f isEqualToString:@"p"]) {
            for (uint i=0; i<obj.count;i++) {
                if (i < obj.count) {
                    Perk *p2 = [obj objectAtIndex:i];
                    //CCLOG(@"i:%i pcount:%i",i,perks.count);
                
                    Perk *p1 = [perks objectAtIndex:i];
                    p1.s = p2.s;
                }
            }
            [self writeData:f d:perks];
        }
        else if ([f isEqualToString:@"r"]) {
            for (uint i=0; i<obj.count;i++) {
                Rifle *p2 = [obj objectAtIndex:i];
                Rifle *p1 = [rifles objectAtIndex:i];
                p1.u = p2.u;
            }
            [self writeData:f d:rifles];
        }
        else if ([f isEqualToString:@"s"]) {
            for (uint i=0; i<obj.count;i++) {
                Scope *p2 = [obj objectAtIndex:i];
                Scope *p1 = [scopes objectAtIndex:i];
                p1.u = p2.u;
            }
            [self writeData:f d:scopes];
        }
        else if ([f isEqualToString:@"a"]) {
            for (uint i=0; i<obj.count;i++) {
                Ammo *p2 = [obj objectAtIndex:i];
                Ammo *p1 = [ammo objectAtIndex:i];
                p1.u = p2.u;
            }
            [self writeData:f d:ammo];
        }
        else if ([f isEqualToString:@"e"]) {
            for (uint i=0; i<obj.count;i++) {
                Extras *p2 = [obj objectAtIndex:i];
                Extras *p1 = [extras objectAtIndex:i];
                p1.u = p2.u;
            }
            [self writeData:f d:extras];
        }
		[obj release];
    }
}

-(void) loadImages:(NSString*)f {
    id obj;
    bool found = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px-hd.pvr",f]]]) {
		CCLOG(@"%@-hd exists",f);
		obj = [[self readDataHD:f] retain];
        found = YES;
	}
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px.pvr",f]]]) {
		CCLOG(@"%@ exists",f);
		obj = [[self readData:f] retain];
        found = YES;
	}
    if (found) {
        if ([f isEqualToString:@"l"]) {
            Loadout *p2 = (Loadout*) obj;
            Loadout *p1 = [[Loadout alloc] init];
            p1.r = p2.r;
            p1.s = p2.s;
            p1.a = p2.a;
            p1.b = p2.b;
            p1.e = p2.e;
            p1.g = p2.g;
            p1.po = p2.po;
            p1.ac = p2.ac;
            p1.re = p2.re;
            p1.s1 = p2.s1;
            p1.s2 = p2.s2;
            p1.s3 = p2.s3;
			loadout = p1;
            [self writeData:f d:p1];
        }
        else if ([f isEqualToString:@"t"]) {
            Stats *p2 = (Stats*) obj;
            Stats *p1 = [[Stats alloc] init];
            p1.w2 = p2.w2;
            p1.w3 = p2.w3;
            p1.w4 = p2.w4;
            p1.w2w = p2.w2w;
            p1.w3w = p2.w3w;
            p1.w4w = p2.w4w;
            p1.su = p2.su;
            p1.st = p2.st;
            p1.sa = p2.sa;
            p1.he = p2.he;
            p1.tut = p2.tut;
            p1.tg = p2.tg;
            p1.mi = p2.mi;
			p1.sux = p2.sux;
			stats = p1;
            [self writeData:f d:p1];
        }
		[obj release];
    }
}

-(void) writeData:(NSString*)f d:(id)d {
	CCLOG(@"writeDate: %@",f);
	// Get the full path of your file in the documents directory:
	NSString* myPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px-hd.pvr",f]];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:d forKey:f];
    [archiver finishEncoding];
	NSData *encData = [data encryptedWithKey:kdhd];
    [encData writeToFile:myPath atomically:YES];
    [archiver release];
	[data release];
}

-(id) readData:(NSString*)f {
	NSString* myPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px.pvr",f]];
	NSData *codedData = [[[NSData alloc] initWithContentsOfFile:myPath] autorelease];
    if (codedData == nil) {
		CCLOG(@"no data");  //Handles this better
		return nil;
	}
	else {
		NSData *uncodedData = [[codedData decryptedWithKey:kd] retain];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:uncodedData];
		id obj = [[unarchiver decodeObjectForKey:f] retain];
		[unarchiver finishDecoding];
		[unarchiver release];
		[uncodedData release];
		return obj;
	}
}

-(id) readDataHD:(NSString*)f {
	NSString* myPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@1px-hd.pvr",f]];
	NSData *codedData = [[[NSData alloc] initWithContentsOfFile:myPath] autorelease];
    if (codedData == nil) {
		CCLOG(@"no data");  //Handles this better
		return nil;
	}
	else {
		NSData *uncodedData = [[codedData decryptedWithKey:kdhd] retain];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:uncodedData];
		id obj = [[unarchiver decodeObjectForKey:f] retain];
		[unarchiver finishDecoding];
		[unarchiver release];
		[uncodedData release];
		return obj;
	}
}

-(id) initData:(NSString*)f {
	//NSString *myPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"d%@1x.png",f]] retain];
	NSString *myPath  = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: [NSString stringWithFormat:@"d%@1x.png",f]] retain];
	/*CCLOG(@"myPath:%@",myPath);
	 if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ds1x.png"]]) {
	 CCLOG(@"file existsAtPath");
	 }
	 else {
	 CCLOG(@"file NOT existsAtPath");
	 }*/
	
	NSData *codedData = [[[NSData alloc] initWithContentsOfFile:myPath] autorelease];
	[myPath release];
    if (codedData == nil) {
		CCLOG(@"no data");  //Handles this better
		return nil;
	}
	else {
		NSData *uncodedData = [[codedData decryptedWithKey:dk] retain];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:uncodedData];
		id obj = [[unarchiver decodeObjectForKey:f] retain];
		[unarchiver finishDecoding];
		[unarchiver release];
		[uncodedData release];
		return obj;
	}
}

-(void) getNews {
    /*
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Reachability *reach = [[Reachability reachabilityWithHostName: @"battlecourt.com"] retain];	
	NetworkStatus netStatus = [reach currentReachabilityStatus];
    [reach release];
	if (netStatus == NotReachable) {        
		CCLOG(@"No internet connection!");        
	} else {
		CCLOG(@"Fetching News");
		NSString *newsURL = [NSString stringWithFormat:@"http://www.battlecourt.com/sniper/news.%@.plist",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:newsURL]];
		if (dictionary != nil) {
			news = [dictionary objectForKey:@"News"];
		}
		//[dictionary release];
	}	
	[pool release];*/
}
/////////////////////////////
-(CCSprite*) getSprite:(NSString*) spriteName
{
	CCSpriteFrame * spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName];
	if(spriteFrame)
		return [CCSprite spriteWithSpriteFrame:spriteFrame];
	else
		return [CCSprite spriteWithFile:spriteName];
	//		return nil;
}
////////////////////////
- (void)dealloc {
	/*[SourceChannelOne release];
	[SourceChannelTwo release];
	[buffer release];*/
	[dk release];
	[kd release];
	[docPath release];
	[soundEngine release];
	[am release];
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
