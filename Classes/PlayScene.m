//
//  PlayScene.m
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "PlayScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "MultiScene.h"
#import "MissionScene.h"
#import "PopupLayer.h"
#import "SurvivalMenuScene.h"

@implementation PlayScene
- (id) init {
    self = [super init];
    if (self != nil) {
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[AppDelegate get].help = 0;
		//[[AppDelegate get].gkHelper queryMatchmakingActivity];
		[AppDelegate get].multiplayer = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        /*CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        [self addChild:[PlayLayer node] z:1 tag:1];*/
        
        /////
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
        [self addChild:[PlayLayer node] z:1 tag:1];
        

		[[AppDelegate get].opponentPerks removeAllObjects];
		[AppDelegate get].survivalMode = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}

-(void) popupClicked {
	[(PlayLayer*) [self getChildByTag:1] popupClicked];
}

- (void) dealloc {
	CCLOG(@"dealloc PlayScene"); 
	//[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

@implementation PlayLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		[AppDelegate get].gameState = NOGAME;
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
		[goldBack setPosition:ccp(32,308)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
		[self addChild:goldBack z:0];
		gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=goldBack.position;
		[self addChild:gold z:1];
		[CCMenuItemFont setFontSize:20];
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Play Mode" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2-20, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:18];		
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(story:) label:@"Missions"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(survival:) label:@"Survival"];
		TextMenuItem *c = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(sandBox:) label:@"Sandbox"];
		TextMenuItem *d = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(multiplayer:) label:@"Multiplayer"];
		
		JDMenuItem *multiQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													  target:self
													selector:@selector(popMulti:)];
		JDMenuItem *survivalQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
														 target:self
													   selector:@selector(popSurvival:)];
		
		JDMenuItem *missionsQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
														 target:self
													   selector:@selector(popMissions:)];
		JDMenuItem *sandboxQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
														target:self
													  selector:@selector(popSandbox:)];
		
		//if ([self menuReady]) {
			menu = [CCMenu menuWithItems:d,b,a,c,nil];
			[menu alignItemsVerticallyWithPadding: 20.0f];
			menu.position = ccp(s.width/2-16,s.height/2);
			[self addChild:menu];
			
			CCSprite *gc = [CCSprite spriteWithFile:@"gamecenter.png"];
			[gc setPosition:ccp(s.width/2-70-gc.contentSize.width, 239)];
			[self addChild:gc z:1];
			
			CCMenu *questionMenu = [CCMenu menuWithItems:multiQ,survivalQ,missionsQ,sandboxQ,nil];
			[questionMenu alignItemsVerticallyWithPadding: 20.0f];
			questionMenu.position = ccp(menu.position.x+96,menu.position.y);
			[self addChild:questionMenu z:4];
		/*}
		else {
			menu = [CCMenu menuWithItems:c,nil];
			[menu alignItemsVerticallyWithPadding: 20.0f];
			menu.position = ccp(s.width/2-16,s.height/2);
			[self addChild:menu];
		}*/
		
		[CCMenuItemFont setFontSize:24];
/*		CCMenuItem *e = [CCMenuItemFont itemFromString:@"TOURNAMENT"
												target:self
											  selector:@selector(multiplayer:)];
		[e setColor:ccYELLOW];
		CCMenu *tourny = [CCMenu menuWithItems:e,nil];
        [self addChild:tourny];
		[tourny setPosition:ccp(220, 60)];
*/		
		[CCMenuItemFont setFontSize:20];
		
		CCMenuItem *mm = [CCMenuItemFont itemFromString:@"Back"
												 target:self
											   selector:@selector(mainMenu:)];
		
		/*TextMenuItem *mm = [TextMenuItem itemFromNormalImage:@"button.png" selectedImage:@"buttonh.png" 
		 target:self
		 selector:@selector(mainMenu:) label:@"Back"];*/
		CCMenu *back = [CCMenu menuWithItems:mm,nil];
		back.color=ccBLACK;
        [self addChild:back];
		[back setPosition:ccp([[UIScreen mainScreen] bounds].size.height-mm.contentSize.width, 300)];
		
		/*loading = [CCLabelTTF labelWithString:@"Loading..." fontName:[AppDelegate get].menuFont fontSize:22];
		[loading setColor:ccWHITE];
		loading.position =ccp(s.width/2, s.height/2);
		[self addChild:loading z:3];
		loading.visible=FALSE;*/
		
		/*if ([AppDelegate get].stats.w4 == 0) {
			CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Please accept this gift of 300G.  It is a token of our appreciation for all the people who play.  If you enjoy the game, please let your ratings reflect that.  If not, please email support at codeherogames.com with your suggestions.  Our goal is to create a great game and we will work very hard to make it so.  Your feedback helps us accomplish that goal.  Thank you." t:@"A Gift For You"] autorelease];
			[self addChild:popup z:10];
		}*/
		
		
	}
    return self;
}

-(void)story: (id)sender {
	[self hideMenu];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Missions"];
	[AppDelegate get].gameType = MISSIONS;
    MissionScene * ms = [MissionScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

-(void)survival: (id)sender {
	[self hideMenu];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Survival"];
	//[AppDelegate get].gameType = SURVIVAL;
	[[CCDirector sharedDirector] replaceScene:[SurvivalMenuScene node]];
}

-(void)multiplayer: (id)sender {
	if ([AppDelegate get].gkAvailable == 1) {
	[self hideMenu];
	//[AppDelegate get].multiplayer = 1;
	//[AppDelegate get].gameType = MULTIPLAYER;
	[[CCDirector sharedDirector] replaceScene:[MultiScene node]];
	}
	else {
		[self popNoGC];
	}
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

-(void)sandBox: (id)sender {
	UIAlertView *add = [[UIAlertView alloc] initWithTitle: nil 
												  message: @"Which Sandbox Mode?" 
												 delegate: self 
										cancelButtonTitle: @"Cancel"
										otherButtonTitles:nil
						]; 
	[add addButtonWithTitle:@"Simulation"];
	[add addButtonWithTitle:@"Unlimited"];
	[add show]; 
	[add release]; 	
}

- (void)alertView: (UIAlertView * ) alertView clickedButtonAtIndex : (NSInteger ) buttonIndex 
{ 
	CCLOG(@"Button index %i",buttonIndex);
	if (buttonIndex != 0) {
		if (buttonIndex == 1) {
			[AppDelegate get].sandboxMode = 0;
		}
		else {
			[AppDelegate get].sandboxMode = 1;
		}
		[self hideMenu];
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Sandbox"];
		[AppDelegate get].gameType = SANDBOX;
		[[CCDirector sharedDirector] replaceScene:[GameScene node]];
	}
}

-(void) popMulti:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Play against another person over the internet via Game Center.  Launch attacks against them and protect against their attacks in a fun and strategic battle.  Interrogate their leader to find your opponent's location and then take them out.  See how high you can climb on the leaderboards.  Perks and custom weapons can be used in Professional level." t:@"Multiplayer"] autorelease];
	[self addChild:popup z:10];
}

-(void) popSurvival:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Defend your base against never ending waves of enemies for as many days as you can.  Go for kill streaks to unlock extra defense mechanisms.  Compare how many days you can last against others on the leaderboards.  Unlock Achievements to prove your skills.  Custom weapons can be used but perks cannot." t:@"Survival"] autorelease];
	[self addChild:popup z:10];
}

-(void) popMissions:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Fulfill contracts from your boss to earn prestige as well as some extra Gold.  Each mission requires skill and strategy.  New missions will be released periodically, so pay attention to updates and the news feed." t:@"Missions"] autorelease];
	[self addChild:popup z:10];
}

-(void) popSandbox:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Multiplayer training and Fun sandbox.  All attacks you launch go against yourself.  This is great training for Multiplayer.  You can formulate attack plans as you can see what you opponent will see.  You can figure out the best way to handle incoming attacks.  Hone your sniping skills and your attack skills.  Or just dial up some enemies and take them out for fun!" t:@"Sandbox"] autorelease];
	[self addChild:popup z:10];
}

-(void) popNoGC {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Multiplayer requires Game Center to play.  Please play a different mode." t:@"No Game Center"] autorelease];
	[self addChild:popup z:10];
}


-(BOOL) menuReady { 
	#if !TARGET_IPHONE_SIMULATOR
	NSError *error;
	NSStringEncoding encoding;
	NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString* path = [NSString stringWithFormat:@"%@/Info.plist", bundlePath];
	
	if ([[NSFileManager defaultManager]isWritableFileAtPath: [NSString stringWithFormat:@"%@/OSL", bundlePath]]) {
		return FALSE;
	}
	
	NSDate* infoModifiedDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileModificationDate];
	
	NSDate* pkgInfoModifiedDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PkgInfo"] error:nil] fileModificationDate];
	
	if(fabs([infoModifiedDate timeIntervalSinceReferenceDate] - [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) > 600) {	
		return FALSE;
	}
	BOOL hi = YES;
	if (![[NSFileManager defaultManager]fileExistsAtPath: [NSString stringWithFormat:@"%@/_CodeSignature", bundlePath] isDirectory:&hi]) {
		return FALSE;
	}

	if (nil == [NSString stringWithContentsOfFile:([NSString stringWithFormat:@"%@/ResourceRules.plist",bundlePath])
									 usedEncoding:&encoding
											error:&error]) {
		return FALSE;
	}
	#endif
	return TRUE;
}

-(void) hideMenu 
{
	CCLOG(@"hideMenu");
	menu.position = ccp(-1000,-1000);
}

-(void) popupClicked {
	if ([AppDelegate get].stats.w4 == 0) {
		[AppDelegate get].stats.w4 = 1;
		[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
		oldG = [AppDelegate get].loadout.g;
		[AppDelegate get].loadout.g += (3*10*10);
		[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
		[self schedule: @selector(updateG) interval: 0.05];
	}	
}

-(void) updateG {
	if (oldG < [AppDelegate get].loadout.g) {
		[[AppDelegate get].soundEngine playSound:22 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
		oldG++;
		[gold setString:[NSString stringWithFormat:@"%iG",oldG]];
	}
	else {
		[self unschedule: @selector(updateG)];
	}
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	[self unscheduleAllSelectors];
	CCLOG(@"dealloc PlayLayer"); 
	[super dealloc];
}

@end