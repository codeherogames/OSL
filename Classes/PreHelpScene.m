//
//  PreHelpScene.m
//  OSL
//
//  Created by James Dailey on 4/22/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "PreHelpScene.h"
#import "HelpScene.h"
#import "TutorialSplash.h"
#import "MenuScene.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"

@implementation PreHelpScene
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];

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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Help" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2-20, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:18];
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(help:) label:@"Help Manual"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(tutorial:) label:@"Tutorial"];
		TextMenuItem *c = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(twlogout:) label:@"Exit Twitter"];
		TextMenuItem *d = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(fblogout:) label:@"Exit FB"];
		
		CCMenu *menu = [CCMenu menuWithItems:a,b,c,d,nil];
		[menu alignItemsVerticallyWithPadding: 20.0f];
		menu.position = ccp(s.width/2-16,s.height/2-20);
		[self addChild:menu];
		
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
	}
    return self;
}

-(void)help: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Help"];
	[[CCDirector sharedDirector] replaceScene:[HelpScene node]];
}

-(void)twlogout: (id)sender {
	[SHKTwitter logout];
	[AppDelegate showNotification:@"Logged Out From Twitter"];
}

-(void)fblogout: (id)sender {
	[SHKFacebook logout];
	[AppDelegate showNotification:@"Logged Out From Facebook"];
}

-(void)tutorial: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Tutorial"];
	[AppDelegate get].gameType = TUTORIAL;
	[[CCDirector sharedDirector] replaceScene:[TutorialSplash node]];
}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc PreHelpScene"); 
	[super dealloc];
}

@end