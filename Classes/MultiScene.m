//
//  Multiplayer.m
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MultiScene.h"
#import "PerkScene.h"
#import "MenuScene.h"
#import "PopupLayer.h"
#import "JDMenuItem.h"

@implementation MultiScene
- (id) init {
    self = [super init];
    if (self != nil) {
		[AppDelegate get].multiplayer = 0;
		[AppDelegate get].friendInvite = 0;
		//[[AppDelegate get].gkHelper queryMatchmakingActivity];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
		[self addChild:[MultiLayer node] z:2 tag:2];
		[self addChild:[WaitLayer node] z:1 tag:3];
		[self getChildByTag:3].visible=NO;
		[AppDelegate get].playerWager = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}

-(void) showWait 
{
	[AppDelegate get].gameState = CONNECTING;
	[self getChildByTag:3].visible=YES;
	[self getChildByTag:2].visible=NO;
}

-(void) hideWait 
{
	[AppDelegate get].gameState = NOGAME;
	[self getChildByTag:3].visible=NO;
	[self getChildByTag:2].visible=YES;
}
- (void) dealloc {
	CCLOG(@"dealloc MultiScene"); 
	[super dealloc];
}
@end

@implementation MultiLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
		[goldBack setPosition:ccp(32,308)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
		[self addChild:goldBack z:0];
		CCLabelTTF *gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=goldBack.position;
		[self addChild:gold z:1];
		[CCMenuItemFont setFontSize:20];
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Multiplayer" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:18];
		
		TextMenuItem *two = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												   selector:@selector(players2:) label:@"2 Player VS" fontSize:14];
		two.tag = 456;
		/*TextMenuItem *three = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(players3:) label:@"3 Player Mayhem" fontSize:14];
		TextMenuItem *four = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(players4:) label:@"4 Player Insanity" fontSize:14];
		
		three.isEnabled=NO;
		four.isEnabled=NO;
		*/		
		CCMenu *menu = [CCMenu menuWithItems:two, nil];
		[menu alignItemsVerticallyWithPadding: 16.0f];
		menu.position = ccp(240,190);
		[self addChild:menu z:4];
		
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
		[back setPosition:ccp(448, 300)];
		
		JDMenuItem *Q2 = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													 target:self
												   selector:@selector(pop2:)];
		/*
		JDMenuItem *Q3 = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													target:self
												  selector:@selector(pop3:)];

		JDMenuItem *Q4 = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
												  target:self
												selector:@selector(pop4:)];
		*/
		CCMenu *questionMenu1 = [CCMenu menuWithItems:Q2, nil];
		[questionMenu1 alignItemsVerticallyWithPadding: 16.0f];
		questionMenu1.position = ccp(336,190);
		[self addChild:questionMenu1 z:4];
		
		CCLabelTTF *gameOptions = [CCLabelTTF labelWithString:@"Match Options" fontName:[AppDelegate get].menuFont fontSize:20];
		[gameOptions setColor:ccYELLOW];
		gameOptions.position =ccp(s.width/2, 100);
		[self addChild:gameOptions z:1];
		
		TextMenuItem *rook = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(fake:) label:@"Rookie" fontSize:14];
		TextMenuItem *pro = [TextMenuItem itemFromNormalImage:@"buttonlongh.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(fake:) label:@"Professional" fontSize:14];
		
		CCMenuItemToggle* toggleType = [CCMenuItemToggle itemWithTarget:self selector:@selector(playerType:) items:rook, pro, nil];

		/*TextMenuItem *wagerNO = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(fake:) label:@"No Wager" fontSize:14];
		TextMenuItem *wagerYES = [TextMenuItem itemFromNormalImage:@"buttonlongh.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(fake:) label:@"Wager 20G" fontSize:14];
		
		toggleWager = [CCMenuItemToggle itemWithTarget:self selector:@selector(wagerType:) items:wagerNO, wagerYES, nil];*/
		
		CCMenu *optionsMenu = [CCMenu menuWithItems:toggleType, nil];
		[optionsMenu alignItemsVerticallyWithPadding: 10.0f];
		optionsMenu.position = ccp(240,44);
		[self addChild:optionsMenu z:4];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"playerLevel"] != nil) {
			CCLOG(@"pl=%i",[[NSUserDefaults standardUserDefaults] integerForKey:@"playerLevel"]);
			[toggleType setSelectedIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"playerLevel"]];
			[AppDelegate get].playerLevel = (int) [toggleType selectedIndex];
		}
		else {
			[AppDelegate get].playerLevel = 0;
		}
		/*if ([[NSUserDefaults standardUserDefaults] objectForKey:@"playerWager"] != nil) {
			CCLOG(@"pw=%i",[[NSUserDefaults standardUserDefaults] integerForKey:@"playerWager"]);
			[toggleWager setSelectedIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"playerWager"]];
			[AppDelegate get].playerWager = (int) [toggleWager selectedIndex] * 20;
		}
		else {
			[AppDelegate get].playerWager = 0;
		}*/
		
		JDMenuItem *rookQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													  target:self
													selector:@selector(popRook:)];
		/*JDMenuItem *proQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													 target:self
												   selector:@selector(popPro:)];*/
		
		CCMenu *questionMenu = [CCMenu menuWithItems:rookQ, nil];
		[questionMenu alignItemsVerticallyWithPadding: 10.0f];
		questionMenu.position = ccp(336,44);
		[self addChild:questionMenu z:4];
    }
    return self;
}

-(void) pop2:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Play online against one opponent.  Protect Smitty from enemy Agents and send your own attacks to get your Agents to their leader first.  Your agents will sound the alarms once they extract the enemy sniper's location.  Follow the arrow and eliminate them before they get you.  Every victory earns Gold and is recorded to the leaderboards.  Choose Rookie or Pro level below." t:@"2 Player VS"] autorelease];
	[self addChild:popup z:10];
}

-(void) pop3:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"The same as 2 Player except with a twist.  You will battle 2 opponents at once.  Every attack you launch is sent to every opponent, making it fairly hectic.  The reward is 40G (plus wagers) and winner takes all." t:@"3 Player Mahem"] autorelease];
	[self addChild:popup z:10];
}

-(void) pop4:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"The same as 2 Player except with a twist.  You will battle 3 opponents at once.  Every attack you launch is sent to every opponent, making it extremely hectic.  The winner gets 40G (plus 3 wagers), 2nd place gets 40G (plus 1 wager)." t:@"4 Player Insanity"] autorelease];
	[self addChild:popup z:10];
}

-(void) popRook:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Rookie - play against opponents without using any perks.  Custom equipment is allowed.  Helpful for learning the ropes before going all in.  Winner gets 25G.\n\nProfessional - anything goes.  You can use all your custom weapons and perks.  This adds lots of strategy and dynamic gameplay.  Plus, it's really fun!  Winner gets 50G." t:@"Rookie vs. Professional"] autorelease];
	[self addChild:popup z:10];
}

-(void) popPro:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Wager 20G - You can choose to wager 20G of your Gold and you will be matched against players willing to do the same.  The winner gets the usual reward plus player wagers.  This is for mercenaries that are willing to put their money where their mouth is.\n\nNo Wager - The winner of the match wins Gold without having to wager any money." t:@"Wager vs. No Wager"] autorelease];
	[self addChild:popup z:10];
}

-(void) fake:(id)sender {

}

-(void) playerType:(id)sender {
	[AppDelegate get].playerLevel = (int) [sender selectedIndex];
	CCLOG(@"playerLevel:%i",[AppDelegate get].playerLevel);
}

-(void) wagerType:(id)sender {
	if ([AppDelegate get].loadout.g >19) {
		[AppDelegate get].playerWager = (int) [sender selectedIndex] * 20;
		if ([AppDelegate get].playerWager != 0)
			[AppDelegate get].playerWager = 20;
	}
	else {
		[toggleWager setSelectedIndex:0];
		[AppDelegate get].playerWager = 0;
		CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"You can only wager if you have enough Gold.  Please choose No Wager or get more Gold." t:@"Not Enough Gold"] autorelease];
		[self addChild:popup z:10];
	}
	//CCLOG(@"playerWager:%i",[AppDelegate get].playerWager);
}

-(void) players2:(id)sender {
	[AppDelegate get].friendInvite = 0;
	/*int pw = [AppDelegate get].playerWager;
	if (pw > 0)
		pw = 1;
	[[NSUserDefaults standardUserDefaults] setInteger:pw forKey:@"playerWager"];*/
	[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].playerLevel forKey:@"playerLevel"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[AppDelegate get].gkHelper showMatchMaker:2];
	//[[AppDelegate get].gkHelper queryMatchmakingActivity];
	[AppDelegate get].gameType = MULTIPLAYER;
	[AppDelegate get].multiplayer = 1;
	[(MultiScene*)self.parent showWait];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Multiplayer - %i",[AppDelegate get].multiplayer+1]];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Level - %i",[AppDelegate get].playerLevel]];
	/*[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Wager - %i",[AppDelegate get].playerWager]];*/
	//[[CCDirector sharedDirector] replaceScene:[WaitScene node]];
}

-(void) players3:(id)sender {
	[AppDelegate get].friendInvite = 0;
	int pw = [AppDelegate get].playerWager;
	if (pw > 0)
		pw = 1;
	[[NSUserDefaults standardUserDefaults] setInteger:pw forKey:@"playerWager"];
	[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].playerLevel forKey:@"playerLevel"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[AppDelegate get].gkHelper showMatchMaker:3];
	//[[AppDelegate get].gkHelper queryMatchmakingActivity];
	[AppDelegate get].gameType = MULTIPLAYER;
	[AppDelegate get].multiplayer = 2;
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Multiplayer - %i",[AppDelegate get].multiplayer+1]];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Level - %i",[AppDelegate get].playerLevel]];
	 //[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Wager - %i",[AppDelegate get].playerWager]];
	//[[CCDirector sharedDirector] replaceScene:[WaitScene node]];
}

-(void) players4:(id)sender {
	[AppDelegate get].friendInvite = 0;
	int pw = [AppDelegate get].playerWager;
	if (pw > 0)
		pw = 1;
	[[NSUserDefaults standardUserDefaults] setInteger:pw forKey:@"playerWager"];
	[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].playerLevel forKey:@"playerLevel"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[AppDelegate get].gkHelper showMatchMaker:4];
	//[[AppDelegate get].gkHelper queryMatchmakingActivity];
	[AppDelegate get].gameType = MULTIPLAYER;
	[AppDelegate get].multiplayer = 3;
	/*[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Multiplayer - %i",[AppDelegate get].multiplayer+1]];
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Level - %i",[AppDelegate get].playerLevel]];
	 [[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Player Wager - %i",[AppDelegate get].playerWager]];*/
	//[[CCDirector sharedDirector] replaceScene:[WaitScene node]];
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc MultiLayer"); 
	[super dealloc];
}

@end

@implementation WaitLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		CGSize s = [[CCDirector sharedDirector] winSize];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:bg z:0];
		[CCMenuItemFont setFontSize:20];
		
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Connecting..." fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		[CCMenuItemFont setFontSize:16];
		CCMenuItem *mm = [CCMenuItemFont itemFromString:@"Cancel"
												 target:self
											   selector:@selector(mainMenu:)];
		CCMenu *back = [CCMenu menuWithItems:mm,nil];
		[back setColor:ccBLACK];
        [self addChild:back];
		[back setPosition:ccp(436, 300)];
		for (CCMenuItem *mi in back.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		
    }
    return self;
}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc WaitLayer"); 
	[super dealloc];
}
@end;

