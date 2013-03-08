//
//  TutorialSplash.m
//  OSL
//
//  Created by James Dailey on 4/22/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "TutorialSplash.h"
#import "MenuScene.h"
#import "TutorialScene.h"
#import "TextMenuItem.h"
#import "GameScene.h"

@implementation TutorialSplash
- (id) init {
    self = [super init];
    if (self != nil) {
		[AppDelegate get].multiplayer = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tut"] != nil) {
			[AppDelegate get].tutorialState = [[NSUserDefaults standardUserDefaults] integerForKey:@"tut"];
		}
		else {
			[AppDelegate get].tutorialState = 0;
		}
		CGSize s = [[CCDirector sharedDirector] winSize];
        CCSprite * bg = [CCSprite spriteWithFile:@"splash.png"];
        [bg setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:bg z:0];
        [self addChild:[TutorialSplashLayer node] z:1];
		//reward = [[NSUserDefaults standardUserDefaults] integerForKey:@"t"];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}	
@end

@implementation TutorialSplashLayer
-(id) init {
    self = [super init];
    if (self != nil) {	
		//[AppDelegate get].tutorialState = 20;
		CGSize s = [[CCDirector sharedDirector] winSize];
		NSString *m = @"So, you wanna be a mercenary?  Well, you came to the right place. I'm Smitty and I can train you to be the best. In training you will learn everything you need to know to dominate.  Complete training now and earn 800 Gold which you can use to upgrade your equipment and perks.  If you EXIT the tutorial now but come back later through the HELP menu, you only earn 400 Gold.  Click NEXT to start training or click EXIT to start playing without any training.";
		if ([AppDelegate get].tutorialState > 0) {
			if ([AppDelegate get].tutorialState >= MAXTUT)
				m = @"Welcome Back.  You already completed training.  Great Work!  You can always do it again by clicking NEXT.  You will start at the beginning.";
			else
				m = @"Welcome Back.  Looks like you made some progress in training but you never finished.  You can complete training now and get your free Gold by clicking NEXT.  You will start where you left off.";

		}
		t = [CCLabelTTF labelWithString:m dimensions:CGSizeMake(s.width-(s.width*.5),s.height-(s.height*.2)) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:16];
		[t setColor:ccWHITE];
		t.position=ccp(s.width/3.2,s.height/2);
		[self addChild:t z:1];
		
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(next:) label:@"Next"];
		a.tag = 456;
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(mainMenu:) label:@"Exit"];
		
		CCMenu *menu = [CCMenu menuWithItems:b,a,nil];
		[menu alignItemsVerticallyWithPadding: 170.0f];
		menu.position = ccp(s.width*0.84,s.height/2+30);
		[self addChild:menu z:1];
		
	}
	return self;
}

-(void) next:(id)sender {
	//if ([AppDelegate get].tutorialState == 0) { // && 
	if ([AppDelegate get].stats.tut == 0) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"t"] == nil) {
			[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"t"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Tutorial at Startup"];
		}
	}
	if ([AppDelegate get].tutorialState >= 3) {
		if ([AppDelegate get].tutorialState >= MAXTUT) {
			[AppDelegate get].tutorialState = 3;
		}
		/*else {
			[AppDelegate get].stats.tut = [AppDelegate get].tutorialState;
			//[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
		}*/
		[AppDelegate get].gameType = TUTORIAL;
		CCMenuItem *item = (CCMenuItem *)sender;
		[item setIsEnabled:NO];
		[[CCDirector sharedDirector] replaceScene:[TutorialScene node]];
	}
	else {
		[t setString:@"A couple things before you move on.  I mentioned weapon and perk upgrades.  They are unlocked with Gold earned from completing this tutorial, doing Missions or beating opponents in Multiplayer Mode.\n\nThe Help section contains this tutorial and the Mercenary Handbook.  The Handbook provides further descriptions about the game.  I suggest you read through it when you get a chance.  Let's begin your training."];
		[AppDelegate get].tutorialState = 2;
	}
	[AppDelegate get].tutorialState++;
}

-(void)mainMenu: (id)sender {
	if ([AppDelegate get].stats.tut == 0) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"t"] == nil) {
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"t"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Skip Tutorial at Startup"];
		}
	}
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}
- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc TutorialSplashLayer"); 
	[super dealloc];
}

@end
