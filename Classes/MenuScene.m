//
//  MenuScene.m
//  DieMonstersDie
//
//  Created by James Dailey on 9/1/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "MenuScene.h"
#import "cocos2d.h"
#import "PlayScene.h"
#import "SettingsScene.h"
#import "CreditScene.h"
#import "CustomScene.h"
#import "PreHelpScene.h"
#import "StatsScene.h"
#import "ComingSoon.h"
#import "WinScene.h"
#import "TextMenuItem.h"
#import "MyMenuButton.h"
#import "ChildMenuButton.h"
#import "PopupLayer.h"
#import <Tapjoy/Tapjoy.h>
#import "AddThis.h"

/*#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"*/

@implementation MenuScene
- (id) init {
	CCLOG(@"MenuScene init"); 
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"cityscape.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        [self addChild:bg z:0];
        MenuLayer *m = [MenuLayer node];
        [self addChild:m z:1 tag:1];
        bg.scaleX = winSize.height/bg.contentSize.width;
		[AppDelegate get].multiplayer = 0;
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc MenuScene"); 
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

@implementation MenuLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		CCLOG(@"MenuLayer init");
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
		/*if ([AppDelegate get].loadout.g > 0) {
			CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
			[goldBack setPosition:ccp(440,298)];
			goldBack.scaleX=0.8;
			goldBack.scaleY=0.6;
			[self addChild:goldBack z:0];
			
			CCLabelTTF *gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
			[gold setColor:ccYELLOW];
			gold.position=ccp(440,298);
			[self addChild:gold z:1];
		}*/
		
		[AppDelegate get].tagCounter = 1;
		[CCMenuItemFont setFontSize:26];
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Online Sniper League" fontName:[AppDelegate get].menuFont fontSize:38];
		[label setColor:ccYELLOW];
		label.position =ccp(10, 300);
		label.anchorPoint=ccp(0.0,1);
		[self addChild:label z:3];
		//[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
		CCLabelTTF *ver = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] fontName:[AppDelegate get].clearFont fontSize:14];
		[ver setColor:ccWHITE];
		ver.position =ccp(winSize.height-50, 310);
		[self addChild:ver z:3];

		[CCMenuItemFont setFontSize:16];

		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(customize:) label:@"Customize"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(stats:) label:@"Stats"];
		
		TextMenuItem *c = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(settings:) label:@"Settings"];
		
		TextMenuItem *d = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(help:) label:@"Help"];
		
		TextMenuItem *e = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(credits:) label:@"Credits"];
		
		TextMenuItem *play = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(play:) label:@"Play"];
		
		//controls.anchorPoint=ccp(0.0,1);
		a.anchorPoint=ccp(0.0,1);
		b.anchorPoint=ccp(0.0,1);
		c.anchorPoint=ccp(0.0,1);
		d.anchorPoint=ccp(0.0,1);
		e.anchorPoint=ccp(0.0,1);
		play.anchorPoint=ccp(0.0,1);
		
        CCMenu *menu = [CCMenu menuWithItems:play,a,b,d,e, nil];
        [menu alignItemsVerticallyWithPadding: 20.0f];
        menu.position = ccp(winSize.height-140,150);
		[self addChild:menu];

		//[AppDelegate showNotification:@"Test"];
		//[controls setSelectedIndex: [AppDelegate get].controls];
		
		JDMenuItem *Q2 = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
												  target:self
												selector:@selector(policy:)];
		
		CCMenuItemImage *twit = [CCMenuItemImage itemFromNormalImage:@"twitterButton.png" selectedImage:@"twitterButton.png" 
													   target:self
													 selector:@selector(twitter:)];
		twit.tag = 456;
		CCMenuItemImage *fb = [CCMenuItemImage itemFromNormalImage:@"fbButton.png" selectedImage:@"fbButton.png" 
															  target:self
															selector:@selector(facebook:)];
		fb.tag = 456;
		CCMenu *socialMenu = [CCMenu menuWithItems:twit,fb,Q2,nil];
		[socialMenu alignItemsHorizontallyWithPadding: 16.0f];
		socialMenu.position = ccp(72,200);
		[self addChild:socialMenu z:4];
		
		if ([[AppDelegate get].news count] > 0) {
			currentIndex=0;
			newsLabel = [CCLabelTTF labelWithString:(NSString*)[[AppDelegate get].news objectAtIndex:currentIndex] fontName:[AppDelegate get].clearFont fontSize:16];
			newsLabel.position = ccp(20,230);
			newsLabel.anchorPoint=ccp(0,0);
			[self addChild:newsLabel z:3];
			[self schedule: @selector(loopNews) interval: 10];
		}
		// This method requests the tapjoy server for current virtual currency of the user.
		//[Tapjoy getTapPoints];
		
		// A notification method must be set to retrieve the points.
		[[NSNotificationCenter defaultCenter] addObserver:[UIApplication sharedApplication].delegate selector:@selector(getPoints:) name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
    }
    return self;
}

-(void) fake: (id) sender {
	
}

-(void) loopNews {	
	currentIndex++;
	if (currentIndex == [[AppDelegate get].news count])
		currentIndex = 0;
	[newsLabel setString:(NSString*)[[AppDelegate get].news objectAtIndex:currentIndex]];
	//CCLOG(@"News%@",(NSString*)[[AppDelegate get].news objectAtIndex:currentIndex]);
}

-(void)twitter: (id)sender {
    [AddThisSDK shareURL:@"https://itunes.apple.com/us/app/online-sniper-league/id419812538?mt=8"
			 withService:@"twitter"
				   title:@"I love Online Sniper League for the iPhone!  Come play me, it's FREE!"
			 description:@"I love Online Sniper League for the iPhone!  Come play me, it's FREE!"];
	/*SHKItem *item = [SHKItem URL:[NSURL URLWithString:SHKMyAppURL] title:@"I love Online Sniper League for the iPhone!  Come play me, it's FREE!"];
	[SHKTwitter shareItem:item];*/
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Twitter"];
}

-(void)facebook: (id)sender {
/*	SHKItem *item = [SHKItem text:@"I love Online Sniper League for the iPhone!  Come play me, it's FREE!"];
	[SHKFacebook shareItem:item];*/
	
	[AddThisSDK shareURL:@"https://itunes.apple.com/us/app/online-sniper-league/id419812538?mt=8"
			 withService:@"facebook"
				   title:@"I love Online Sniper League for the iPhone!  Come play me, it's FREE!"
			 description:@""];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Facebook"];
}

-(void) policy:(id)sender {
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Social Networking sites are a great way to let your friends know about OSL.  After you play Survival or win in Multiplayer, you can choose to share your accomplishments with friends.  We do not capture, store or sell your username, password, tweets, posts, profiles, etc.  All posts are controlled by you. We only provide the buttons for your convenience.  Thank you.     Log Out from Help Menu." t:@"Social Networking"] autorelease];
	[self addChild:popup z:10];
}

-(void)customize: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Customize"];
	[[CCDirector sharedDirector] replaceScene:[CustomScene node]];
	//[[CCDirector sharedDirector] replaceScene:[ComingSoon node]];
}

-(void)settings: (id)sender {
    //SettingsScene * ms = [SettingsScene node];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Settings"];
	[[CCDirector sharedDirector] replaceScene:[ComingSoon node]];
}

-(void)credits: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Credits"];
    CreditScene * ms = [CreditScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

-(void)help: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[PreHelpScene node]];
}

-(void)play: (id)sender {
	[[[AppDelegate get].m1.childButtons objectAtIndex:0] enable];
	[[[AppDelegate get].m1.childButtons objectAtIndex:1] enable];
	[[[AppDelegate get].m1.childButtons objectAtIndex:2] enable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:0] enable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:1] enable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:2] enable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:0] enable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:1] enable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:2] enable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:0] enable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:1] enable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:2] enable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:0] enable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:1] enable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:2] enable];
    PlayScene * ms = [PlayScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

-(void) stats: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Stats"];
	[[CCDirector sharedDirector] replaceScene:[StatsScene node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	CCLOG(@"dealloc MenuLayer"); 
	[super dealloc];
}

@end