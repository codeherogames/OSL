//
//  SurvivalMenuScene.m
//  OSL
//
//  Created by Dailey, James M [CCC-OT] on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SurvivalMenuScene.h"
#import "PlayScene.h"
#import "GameScene.h"
#import "PopupLayer.h"

@implementation SurvivalMenuScene
- (id) init {
    self = [super init];
    if (self != nil) {
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[AppDelegate get].help = 0;
		[AppDelegate get].multiplayer = 0;
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        [self addChild:[SurvivalMenuLayer node] z:1 tag:1];
		[[AppDelegate get].opponentPerks removeAllObjects];
		[AppDelegate get].survivalMode = 0;
    }
    return self;
}

-(void) popupClicked {
	[(PlayLayer*) [self getChildByTag:1] popupClicked];
}

- (void) dealloc {
	CCLOG(@"dealloc SurvivalMenuScene"); 
	//[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

@implementation SurvivalMenuLayer
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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Survival Mode" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2-20, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:18];		
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
                                                     target:self
                                                   selector:@selector(survival:) label:@"Rookie"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
                                                     target:self
                                                   selector:@selector(survivalExtreme:) label:@"Extreme"];
		
		JDMenuItem *aQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													  target:self
													selector:@selector(popSurvival:)];
		JDMenuItem *bQ = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
														 target:self
													   selector:@selector(popSurvivalExtreme:)];
		
        menu = [CCMenu menuWithItems:a,b,nil];
        [menu alignItemsVerticallyWithPadding: 20.0f];
        menu.position = ccp(s.width/2-16,s.height/2);
        [self addChild:menu];
        
        CCMenu *questionMenu = [CCMenu menuWithItems:aQ,bQ,nil];
        [questionMenu alignItemsVerticallyWithPadding: 20.0f];
        questionMenu.position = ccp(menu.position.x+96,menu.position.y);
        [self addChild:questionMenu z:4];
		[CCMenuItemFont setFontSize:20];
		
		CCMenuItem *mm = [CCMenuItemFont itemFromString:@"Back"
												 target:self
											   selector:@selector(mainMenu:)];
		CCMenu *back = [CCMenu menuWithItems:mm,nil];
		back.color=ccBLACK;
        [self addChild:back];
		[back setPosition:ccp(448, 300)];
	}
    return self;
}

-(void)survival: (id)sender {
	[self hideMenu];
	[AppDelegate get].gameType = SURVIVAL;
    [AppDelegate get].survivalMode = 0;
	[[CCDirector sharedDirector] replaceScene:[GameScene node]];
}

-(void)survivalExtreme: (id)sender {
	[self hideMenu];
	[AppDelegate get].gameType = SURVIVAL;
    [AppDelegate get].survivalMode = 1;
	[[CCDirector sharedDirector] replaceScene:[GameScene node]];
}

-(void)mainMenu: (id)sender {
    PlayScene * ms = [PlayScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

-(void) popSurvival:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Defend your base against never ending waves of enemies for as many days as you can.  Go for kill streaks to unlock extra defense mechanisms.  Compare how many days you can last against others on the leaderboards.  Unlock Achievements to prove your skills.  Custom weapons can be used but perks cannot." t:@"Survival"] autorelease];
	[self addChild:popup z:10];
}

-(void) popSurvivalExtreme:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"The same as Rookie, but very intense.  The speed of this mode is very quick.  The sun sets and rises each day, so prepare for darkness.  We also choose 3 perks at random that will make your life miserable.  Play it again and again for a new challenge each time!  If you have a heart condition or are afraid of the dark or are scared of clowns, think twice about trying this mode." t:@"Survival"] autorelease];
	[self addChild:popup z:10];
}

-(void) hideMenu 
{
	CCLOG(@"hideMenu");
	menu.position = ccp(-1000,-1000);
}

-(void) popupClicked {
	
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	[self unscheduleAllSelectors];
	CCLOG(@"dealloc SurvivalMenuLayer"); 
	[super dealloc];
}

@end