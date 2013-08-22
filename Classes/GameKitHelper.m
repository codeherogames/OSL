//
//  GameKitHelper.m
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"
#import "AppDelegate.h"
#import "LoseScene.h"
#import "ConnectingScene.h"
#import "Enemy.h"
#import "Vehicle.h"
#import "GameScene.h"

static NSString* kCachedAchievementsFile = @"CachedAchievements.archive";

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
-(void) initCachedAchievements;
-(void) cacheAchievement:(GKAchievement*)achievement;
-(void) uncacheAchievement:(GKAchievement*)achievement;
-(void) loadAchievements;
-(void) initMatchInvitationHandler;
-(UIViewController*) getRootViewController;
@end

@implementation GameKitHelper

static GameKitHelper *instanceOfGameKitHelper;

#pragma mark Singleton stuff
/*+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfGameKitHelper == nil, @"Attempted to allocate a second instance of the singleton: GameKitHelper");
		instanceOfGameKitHelper = [[super alloc] retain];
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

+(GameKitHelper*) sharedGameKitHelper
{
	@synchronized(self)
	{
		if (instanceOfGameKitHelper == nil)
		{
			[[GameKitHelper alloc] init];
		}
		
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}*/

+(id) sharedGameKitHelper {
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper =
		[[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

#pragma mark Init & Dealloc

@synthesize delegate;
@synthesize isGameCenterAvailable;
@synthesize lastError;
@synthesize achievements;
@synthesize currentMatch;
@synthesize matchStarted,gotPerks;
/*@synthesize audioSession;
@synthesize voiceChannel;*/
-(id) init
{
	if ((self = [super init]))
	{
		// Test for Game Center availability
		Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
		bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
		
		// Test if device is running iOS 4.1 or higher
		NSString* reqSysVer = @"4.1";
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
		bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
		
		isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
		//NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");

		[self registerForLocalPlayerAuthChange];

		[self initCachedAchievements];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	[instanceOfGameKitHelper release];
	instanceOfGameKitHelper = nil;
	
	[lastError release];
	
	[self saveCachedAchievements];
	[cachedAchievements release];
	[achievements release];

	[currentMatch release];

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
	[lastError release];
	lastError = [error copy];
	
	if (lastError)
	{
		CCLOG(@"GameKitHelper ERROR: %@", [[lastError userInfo] description]);
		//[AppDelegate showNotification:[NSString stringWithFormat:@"Error: %@", [lastError localizedDescription]]];
	}
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
	CCLOG(@"authenticateLocalPlayer");
	if (isGameCenterAvailable == NO)
		return;

	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated == NO)
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
		// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
		[localPlayer authenticateWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			if (error == nil)
			{
				//[self initMatchInvitationHandler];
				[self reportCachedAchievements];
				//[self loadAchievements];
			}
		}];
		
		/*
		 // NOTE: bad example ahead!
		 
		 // If you want to modify a local variable inside a block object, you have to prefix it with the __block keyword.
		 __block bool success = NO;
		 
		 [localPlayer authenticateWithCompletionHandler:^(NSError* error)
		 {
		 	success = (error == nil);
		 }];
		 
		 // CAUTION: success will always be NO here! The block isn't run until later, when the authentication call was
		 // confirmed by the Game Center server. Set a breakpoint inside the block to see what is happening in what order.
		 if (success)
		 	NSLog(@"Local player logged in!");
		 else
		 	NSLog(@"Local player NOT logged in!");
		 */
	}
}

-(void) onLocalPlayerAuthenticationChanged
{
	CCLOG(@"onLocalPlayerAuthenticationChanged");
	[delegate onLocalPlayerAuthenticationChanged];
}

-(void) registerForLocalPlayerAuthChange
{
	CCLOG(@"registerForLocalPlayerAuthChange");
	if (isGameCenterAvailable == NO)
		return;

	// Register to receive notifications when local player authentication status changes
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(onLocalPlayerAuthenticationChanged)
			   name:GKPlayerAuthenticationDidChangeNotificationName
			 object:nil];
}

#pragma mark Friends & Player Info

-(void) getLocalPlayerFriends
{
	CCLOG(@"getLocalPlayerFriends");
	if (isGameCenterAvailable == NO)
		return;
	
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated)
	{
		[self initMatchInvitationHandler];
		// First, get the list of friends (player IDs)
		[localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
		{
			[self setLastError:error];
			[delegate onFriendListReceived:friends];
		}];
	}
}

-(void) getPlayerInfo:(NSArray*)playerList
{
	CCLOG(@"getPlayerInfo");
	if (isGameCenterAvailable == NO)
		return;

	// Get detailed information about a list of players
	if ([playerList count] > 0)
	{
		[GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
		{
			[self setLastError:error];
			[delegate onPlayerInfoReceived:players];
		}];
	}
}

#pragma mark Scores & Leaderboard
/*
-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;

	GKScore* gkScore = [[[GKScore alloc] initWithCategory:[NSString stringWithFormat:@"osl%@", category]] autorelease];
	gkScore.value = score;

	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onScoresSubmitted:success];
	}];
}
*/

-(void) submitScore:(int64_t)s category:(NSString*)category
{
	CCLOG(@"submitScore");
	if (isGameCenterAvailable == NO) {
		return;
	}

	GKScore* gkScore = [[[GKScore alloc] initWithCategory:[NSString stringWithFormat:@"osl%@", category]] autorelease];
	//CCLOG(@"current score:%i for category:%@",s,category);
	if (s  != -1) {
		//CCLOG(@"attempt to post score:%i",s);
		//[AppDelegate showNotification:[NSString stringWithFormat:@"Updating Score: %i", s]];
		[AppDelegate showNotification:@"Updating Score"];
		gkScore.value = s;
		
		[gkScore reportScoreWithCompletionHandler:^(NSError* error)
		 {
			 [self setLastError:error];
			 
			 bool success = (error == nil);
			 if (success)
				 [AppDelegate showNotification:@"Score Successfully Updated"];
			 //else
				 //[AppDelegate showNotification:[NSString stringWithFormat:@"Error Updating Score: %@", [error localizedDescription]]];
		 }];
	}
}

-(void) submitKillStreak:(int64_t)s
{
	if (isGameCenterAvailable == NO) {
		return;
	}
	
	GKScore* gkScore = [[[GKScore alloc] initWithCategory:@"oslKillStreak"] autorelease];
	//CCLOG(@"current score:%i",s);
	if (s  != -1) {
		//CCLOG(@"attempt to post score:%i",s);
		//[AppDelegate showNotification:[NSString stringWithFormat:@"Updating Score: %i", s]];
		[AppDelegate showNotification:@"Updating Kill Streak"];
		gkScore.value = s;
		
		[gkScore reportScoreWithCompletionHandler:^(NSError* error)
		 {
			 [self setLastError:error];
			 
			 bool success = (error == nil);
			 if (success)
				 [AppDelegate showNotification:@"Kill Streak Successfully Updated"];
			 //else
			 //	 [AppDelegate showNotification:[NSString stringWithFormat:@"Error Updating KillStreak: %@", [error localizedDescription]]];
		 }];
	}
}

- (void) getMyScore:(NSString*)category
{
	//score = -1;
	if (isGameCenterAvailable == NO)
		return;
	GKLeaderboard *leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]];
	leaderboard.category = [NSString stringWithFormat:@"osl%@", category];
	leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
	if (leaderboard != nil)
	{
		[leaderboard loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil) {
				CCLOG(@"Error %@",error);
				[self setLastError:error];
			}
			[delegate onScoresReceived:scores];
		}];
		
	}
}

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope 
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboard* leaderboard = nil;
	if ([players count] > 0)
	{
		leaderboard = [[[GKLeaderboard alloc] initWithPlayerIDs:players] autorelease];
	}
	else
	{
		leaderboard = [[[GKLeaderboard alloc] init] autorelease];
		leaderboard.playerScope = playerScope;
	}
	
	if (leaderboard != nil)
	{
		leaderboard.timeScope = timeScope;
		leaderboard.category = [NSString stringWithFormat:@"osl%@", category];
		leaderboard.range = range;
		[leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
		{
			[self setLastError:error];
			[delegate onScoresReceived:scores];
		}];
	}
}

-(void) retrieveTopTenAllTimeGlobalScores
{
	[self retrieveScoresForPlayers:nil
						  category:nil 
							 range:NSMakeRange(1, 10)
					   playerScope:GKLeaderboardPlayerScopeGlobal 
						 timeScope:GKLeaderboardTimeScopeAllTime];
}

#pragma mark Achievements

-(void) loadAchievements
{
	if (isGameCenterAvailable == NO)
		return;

	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
	{
		[self setLastError:error];
		 
		if (achievements == nil)
		{
			achievements = [[NSMutableDictionary alloc] init];
		}
		else
		{
			[achievements removeAllObjects];
		}
		
		for (GKAchievement* achievement in loadedAchievements)
		{
			[achievements setObject:achievement forKey:achievement.identifier];
		}
		 
		[delegate onAchievementsLoaded:achievements];
	}];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
	if (isGameCenterAvailable == NO)
		return nil;
		
	// Try to get an existing achievement with this identifier
	GKAchievement* achievement = [achievements objectForKey:identifier];
	
	if (achievement == nil)
	{
		// Create a new achievement object
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[achievements setObject:achievement forKey:achievement.identifier];
	}
	
	return [[achievement retain] autorelease];
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent
{
	CCLOG(@"reportAchievementWithID: %@",identifier);
	if (isGameCenterAvailable == NO)
		return;

	GKAchievement* achievement = [self getAchievementByID:identifier];
	if (achievement != nil && achievement.percentComplete < percent)
	{
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			bool success = (error == nil);
			if (success == NO)
			{
				// Keep achievement to try to submit it later
				[self cacheAchievement:achievement];
			}
			
			[delegate onAchievementReported:achievement];
		}];
	}
}

-(void) resetAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[achievements removeAllObjects];
	[cachedAchievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		bool success = (error == nil);
		[delegate onResetAchievements:success];
	}];
}

-(void) reportCachedAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	if ([cachedAchievements count] == 0)
		return;

	for (GKAchievement* achievement in [cachedAchievements allValues])
	{
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			bool success = (error == nil);
			if (success == YES)
			{
				[self uncacheAchievement:achievement];
			}
		}];
	}
}

-(void) initCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	
	if ([object isKindOfClass:[NSMutableDictionary class]])
	{
		NSMutableDictionary* loadedAchievements = (NSMutableDictionary*)object;
		cachedAchievements = [[NSMutableDictionary alloc] initWithDictionary:loadedAchievements];
	}
	else
	{
		cachedAchievements = [[NSMutableDictionary alloc] init];
	}
}

-(void) saveCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	[NSKeyedArchiver archiveRootObject:cachedAchievements toFile:file];
}

-(void) cacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements setObject:achievement forKey:achievement.identifier];
	
	// Save to disk immediately, to keep achievements around even if the game crashes.
	[self saveCachedAchievements];
}

-(void) uncacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements removeObjectForKey:achievement.identifier];
	
	// Save to disk immediately, to keep the removed cached achievement from being loaded again
	[self saveCachedAchievements];
}

#pragma mark Matchmaking

-(void) disconnectCurrentMatch
{
	CCLOG(@"disconnectCurrentMatch");
	/*[voiceChannel stop];*/
	[currentMatch disconnect];
	currentMatch.delegate = nil;
	[currentMatch release];
	currentMatch = nil;
}

-(void) setCurrentMatch:(GKMatch*)match
{
	CCLOG(@"setCurrentMatch");
	if ([currentMatch isEqual:match] == NO)
	{
		CCLOG(@"setCurrentMatch newmatch");
		[self disconnectCurrentMatch];
		currentMatch = [match retain];
		currentMatch.delegate = self;
	}
}


-(void) showMatchMaker:(int)players
{
	CCLOG(@"showMatchMaker");
	matchStarted = NO;
	GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
	//[request.isHosted: NO];// request.isHosted = NO;
	request.minPlayers = players;
	request.maxPlayers = players;
	request.playerGroup = [AppDelegate get].playerLevel | [AppDelegate get].playerWager;
	
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[self showMatchmakerWithRequest:request];
	//[self queryMatchmakingActivity];
	
}

-(void) initMatchInvitationHandler
{
	CCLOG(@"initMatchInvitationHandler");
	if (isGameCenterAvailable == NO)
		return;

	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite* acceptedInvite, NSArray* playersToInvite)
	{
		[self disconnectCurrentMatch];
		if (acceptedInvite)
		{
			CCLOG(@"initMatchInvitationHandler : acceptedInvite");
			[self dismissModalViewController];
			//delegate = self;
			//[AppDelegate showConnecting];
			CCLOG(@"showConnecting");
			[AppDelegate get].gameState = CONNECTING;
			[[CCDirector sharedDirector] replaceScene: [ConnectingScene node]];
			[self showMatchmakerWithInvite:acceptedInvite];
		}
		else if (playersToInvite)
		{
			CCLOG(@"initMatchInvitationHandler : playersToInvite");
			//GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
			GKMatchRequest* request = [[GKMatchRequest alloc] init];
			request.minPlayers = 2;
			request.maxPlayers = 2; //[AppDelegate get].gameType;
			request.playerGroup = [AppDelegate get].playerLevel | [AppDelegate get].playerWager;
			request.playersToInvite = playersToInvite;
			
			[self showMatchmakerWithRequest:request];
		}
		else {
			CCLOG(@"initMatchInvitationHandler : should not get here");
		}
	};
}

-(void) findMatchForRequest:(GKMatchRequest*)request
{
	CCLOG(@"findMatchForRequest");
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch* match, NSError* error)
	{
		[self setLastError:error];
		
		if (match != nil)
		{
			[self setCurrentMatch:match];
			[delegate onMatchFound:match];
		}
	}];
}

-(void) addPlayersToMatch:(GKMatchRequest*)request
{
	CCLOG(@"addPlayersToMatch");
	if (isGameCenterAvailable == NO)
		return;

	if (currentMatch == nil)
		return;
	
	[[GKMatchmaker sharedMatchmaker] addPlayersToMatch:currentMatch matchRequest:request completionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onPlayersAddedToMatch:success];
	}];
}

-(void) cancelMatchmakingRequest
{
	CCLOG(@"cancelMatchmakingRequest");
	if (isGameCenterAvailable == NO)
		return;

	[[GKMatchmaker sharedMatchmaker] cancel];
}

-(void) queryMatchmakingActivity
{
	CCLOG(@"queryMatchmakingActivity");
	if (isGameCenterAvailable == NO)
		return;

	[[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError* error)
	{
		[self setLastError:error];
		
		if (error == nil)
		{
			[delegate onReceivedMatchmakingActivity:activity];
		}
	}];
}

#pragma mark Match Connection

-(void) match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
{
	CCLOG(@"match didchangestate");
	switch (state)
	{
		case GKPlayerStateConnected:
			[delegate onPlayerConnected:playerID];
			break;
		case GKPlayerStateDisconnected:
			//NSLog(@"Player :%@ disconnected",playerID);
			if (! [playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
				[delegate onPlayerDisconnected:playerID];
			else {
				[AppDelegate get].gameState = NOGAME;
				[AppDelegate showNotification:@"You Disconnected"];
				[[CCDirector sharedDirector] replaceScene:[LoseScene node]];

			}
			break;
	}
	CCLOG(@"expectedPlayerCount");
	if (matchStarted == NO && match.expectedPlayerCount == 0)
	{
		CCLOG(@"matchStarted");
		[[AppDelegate get].opponentPerks removeAllObjects];
		gotPerks = 0;
		[self sendGameVars];
		[self sendPerks];
		matchStarted = YES;
		//[delegate onStartMatch];
	}
}

-(void) sendAttack:(int) i {
    int eCount=0;
    if ([[AppDelegate get] perkEnabled:43]) {
        BackgroundLayer *bgLayer = (BackgroundLayer*)[AppDelegate get].bgLayer;
        eCount = [BackgroundLayer getEnemyCount];
    }
    NSError *error = nil;
	DataPacket packet;
	packet.type = 1;
	packet.one = i;
	packet.two = eCount;
	packet.three = [AppDelegate get].money;
    //NSData *packet = [NSData dataWithBytes:&packet length:sizeof(packet)];
    [self sendDataToAllPlayers: &packet length:sizeof(packet)];
    if (error != nil)
    {
        // handle the error
		CCLOG(@"send attack Error!");
    }	
}

-(void) sendPerks {
	CCLOG(@"Send Perks");
    NSError *error = nil;
	DataPacket packet;
	packet.type = 2;
	packet.one = [AppDelegate get].loadout.s1;
	packet.two = [AppDelegate get].loadout.s2;
	packet.three = [AppDelegate get].loadout.s3;
    //NSData *packet = [NSData dataWithBytes:&packet length:sizeof(packet)];
    [self sendDataToAllPlayers: &packet length:sizeof(packet)];
    if (error != nil)
    {
        // handle the error
		CCLOG(@"send perks Error!");
    }	
}

-(void) sendGameVars {
	CCLOG(@"sendGameVars");
    NSError *error = nil;
	DataPacket packet;
	packet.type = 3;
	packet.one = [AppDelegate get].playerLevel;
	packet.two = [AppDelegate get].playerWager;
	packet.three = [AppDelegate get].multiplayer;
    [self sendDataToAllPlayers: &packet length:sizeof(packet)];
    if (error != nil)
    {
        // handle the error
		CCLOG(@"send gamevars Error!");
    }	
}

-(void) sendDataToAllPlayers:(void*)data length:(NSUInteger)length
{
	if (isGameCenterAvailable == NO)
		return;
	
	NSError* error = nil;
	NSData* packet = [NSData dataWithBytes:data length:length];
	BOOL success = [currentMatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:&error];
    
    if (!success) {
        // try again, or review your code or wait for disconnection
        CCLOG(@"sendDataToAllPlayers Error!");
    }

	[self setLastError:error];
}

/*
-(void) match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	[delegate onReceivedData:data fromPlayer:playerID];
}*/

/*-(void)match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString *)playerID
{
	CCLOG(@"match didReceiveData from: %@", playerID);
    int* receivedScorePtr = (int*)[data bytes];
	int receivedScore = *receivedScorePtr;
    CCLOG(@"attack: %d", receivedScore);
	[delegate onAttackReceived:receivedScore pid:playerID];
}*/

-(void)match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString *)playerID
{
	CCLOG(@"match didReceiveData from: %@", playerID);
	DataPacket* packet = (DataPacket*)[data bytes];
	if (packet->type == 1) {
		CCLOG(@"match didReceiveData: attack: %d", packet->one);
		int attack = packet->one;
		[delegate onAttackReceived:attack pid:playerID m:packet->two a:packet->three];
	}
	else if (packet->type == 2) {
		NSNumber *one = [NSNumber numberWithInteger:packet->one];
		NSNumber *two = [NSNumber numberWithInteger:packet->two];
		NSNumber *three = [NSNumber numberWithInteger:packet->three];
		CCLOG(@"match didReceiveData: perks: %d,%d,%d", one.intValue,two.intValue,three.intValue);
		if (one > 0 && ![[AppDelegate get].opponentPerks containsObject:one])
			[[AppDelegate get].opponentPerks addObject:one];
		if (two > 0 && ![[AppDelegate get].opponentPerks containsObject:two])
			[[AppDelegate get].opponentPerks addObject:two];
		if (three > 0 && ![[AppDelegate get].opponentPerks containsObject:three])
			[[AppDelegate get].opponentPerks addObject:three];
		gotPerks++;
		if (gotPerks == 2)  // Change to expected players
			[self getPlayerAlias];
	}
	else if (packet->type == 3) {
		NSNumber *one = [NSNumber numberWithInteger:packet->one];
		NSNumber *two = [NSNumber numberWithInteger:packet->two];
		NSNumber *three = [NSNumber numberWithInteger:packet->three];
		CCLOG(@"match didReceiveData: gamevars: %d,%d,%d", one.intValue,two.intValue,three.intValue);
		[AppDelegate get].playerLevel = one.intValue;
		[AppDelegate get].playerWager = two.intValue;
		[AppDelegate get].multiplayer = three.intValue;
		gotPerks++;
		if (gotPerks == 2)  // Change to expected players
			[self getPlayerAlias];
	}
}


-(void)getPlayerAlias
{
	CCLOG(@"getPlayerAlias");
	[GKPlayer loadPlayersForIdentifiers:currentMatch.playerIDs withCompletionHandler:^(NSArray *players, NSError *error)
	 {
		 if (error != nil)
		 {
			 // Handle the error.
		 }
		 if (players != nil)
		 {
			 [AppDelegate get].gameType = MULTIPLAYER;
			 [delegate onAliasReceived: ((GKPlayer*) [players lastObject]).alias];
		 }
	 }];
}

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController*)vc {
    [[CCDirector sharedDirector] pause];
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentViewController:vc animated:YES completion:nil];
}

-(void) dismissModalViewController {
    [[CCDirector sharedDirector] resume];
    UIViewController* rootVC = [self getRootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}
/*
-(void) presentViewController:(UIViewController*)vc
{
	[[CCDirector sharedDirector] pause];
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentModalViewController:vc animated:YES];
}

-(void) dismissModalViewController
{
	[[CCDirector sharedDirector] resume];
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissModalViewControllerAnimated:YES];
}
*/
// Leaderboards

-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[[GKLeaderboardViewController alloc] init] autorelease];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onLeaderboardViewDismissed];
}

// Achievements

-(void) showAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[[GKAchievementViewController alloc] init] autorelease];
	if (achievementsVC != nil)
	{
		achievementsVC.achievementDelegate = self;
		[self presentViewController:achievementsVC];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onAchievementsViewDismissed];
}

// Matchmaking

-(void) showMatchmakerWithInvite:(GKInvite*)invite
{
	CCLOG(@"showMatchmakerWithInvite");
	GKMatchmakerViewController* inviteVC = [[[GKMatchmakerViewController alloc] initWithInvite:invite] autorelease];
	if (inviteVC != nil)
	{
		CCLOG(@"showMatchmakerWithInvite:inviteVC");
		//inviteVC.hosted = NO;
		inviteVC.matchmakerDelegate = self;
		[self presentViewController:inviteVC];
		[AppDelegate get].friendInvite = 1;
		//matchStarted = YES;
		//[self getPlayerAlias];
		//GKPlayerConnectionState = GKPlayerStateConnected;
	}
}

-(void) showMatchmakerWithRequest:(GKMatchRequest*)request
{
	CCLOG(@"showMatchmakerWithRequest");
	GKMatchmakerViewController* hostVC = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
	if (hostVC != nil)
	{
		CCLOG(@"showMatchmakerWithRequest: OK");
		hostVC.matchmakerDelegate = self;
		[self presentViewController:hostVC];
////////////
//			CCLOG(@"jimtest:matchStarted");
//			matchStarted = YES;
//			[self getPlayerAlias];
////////////
	}
}

-(void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
	CCLOG(@"matchmakerViewControllerWasCancelled");
	if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(hideWait)])
		[[[CCDirector sharedDirector] runningScene] hideWait];
	[self dismissModalViewController];
	[delegate onMatchmakingViewDismissed];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
{
	CCLOG(@"matchmakerViewController:didFailWithError");
	if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(hideWait)])
		[[[CCDirector sharedDirector] runningScene] hideWait];
	[self dismissModalViewController];
	[self setLastError:error];
	[AppDelegate showNotification:@"Match Maker Failed"];
	[delegate onMatchmakingViewError];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)match
{
	CCLOG(@"matchmakerViewController:didFindMatch");
	[self dismissModalViewController];
	[self setCurrentMatch:match];
	if (matchStarted == NO && [match expectedPlayerCount] == 0 )
	{
		//CCLOG(@"matchmakerViewController:didFindMatch:playersToInvite=%i",[match.playersToInvite count]);
		CCLOG(@"matchmakerViewController:didFindMatch:matchStarted");
		/*audioSession = [AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:(NSError**)lastError];
		[audioSession setActive: YES error: (NSError**)lastError];
		voiceChannel = [[match voiceChatWithName:@"allPlayers"] retain];
		voiceChannel.active = YES;
		[voiceChannel start];*/
		//[[AppDelegate get].opponentPerks removeAllObjects];
		
		//[self sendGameVars];
		//[self sendPerks];
		//matchStarted = YES;
		
		//matchStarted = YES;
		//[self getPlayerAlias];  //blocking match?
		
        
		if ([AppDelegate get].friendInvite == 1) {
			CCLOG(@"matchmakerViewController:didFindMatch:matchStarted:FRIEND");
			gotPerks = 1;
			[self sendPerks];
			matchStarted = YES;
		}
		else {
			CCLOG(@"matchmakerViewController:didFindMatch:matchStarted:INVITER");
			[AppDelegate get].friendInvite = -1;
			gotPerks = 1;
			[self sendGameVars];
			[self sendPerks];
			matchStarted = YES;
		}
        /*
            CCLOG(@"matchmakerViewController:matchStarted");
            [[AppDelegate get].opponentPerks removeAllObjects];
            gotPerks = 0;
            if ([AppDelegate get].friendInvite != 1)
                [self sendGameVars];
            [self sendPerks];
            matchStarted = YES;
            //[delegate onStartMatch];*/
		
	}
	//match.delegate = self;
	//[match playerIDs
	//[delegate onMatchFound:match];
	//[[CCDirector sharedDirector] replaceScene:[WaitScene node]];
}

@end
