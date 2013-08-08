//
//  StatsScene.m
//  OSL
//
//  Created by James Dailey on 3/27/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "StatsScene.h"
#import "MenuScene.h"

@implementation StatsScene
- (id) init {
	CCLOG(@"MenuScene init"); 
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Stats" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2-20, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		if ([AppDelegate get].gkAvailable == 1) {
			[CCMenuItemFont setFontSize:18];
			
			TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													   target:self
													 selector:@selector(leaderboards:) label:@"Leaderboards"];
			a.tag = 456;
			TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													   target:self
													 selector:@selector(achievements:) label:@"Achievements"];
			b.tag = 457;
			
			CCMenu *menu = [CCMenu menuWithItems:a,b,nil];
			[menu alignItemsVerticallyWithPadding: 20.0f];
			menu.position = ccp(s.width/2-8,s.height/2);
			[self addChild:menu];
			
			CCSprite *gc = [CCSprite spriteWithFile:@"gamecenter.png"];
			[gc setPosition:ccp(s.width/2-64-gc.contentSize.width, 186)];
			[self addChild:gc z:1];
			
			CCSprite *gc2 = [CCSprite spriteWithFile:@"gamecenter.png"];
			[gc2 setPosition:ccp(s.width/2-64-gc.contentSize.width, 134)];
			[self addChild:gc2 z:1];
		}
		else {
			CCLabelTTF *labelConcept = [CCLabelTTF labelWithString:@"Survival Top Score" fontName:[AppDelegate get].menuFont fontSize:20];
			[labelConcept setColor:ccBLUE];
			labelConcept.position =ccp(label.position.x+20, label.position.y-label.contentSize.height-labelConcept.contentSize.height/2);
			[self addChild:labelConcept z:1];
			
			CCLabelTTF *labelDev = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i Days",[AppDelegate get].stats.su] fontName:[AppDelegate get].clearFont fontSize:20];
			labelDev.position = ccp(labelConcept.position.x, labelConcept.position.y-labelConcept.contentSize.height);
			[self addChild:labelDev z:1];
			
			CCLabelTTF *labelDesign = [CCLabelTTF labelWithString:@"Longest Kill Streak" fontName:[AppDelegate get].menuFont fontSize:20];
			[labelDesign setColor:ccBLUE];
			labelDesign.position =ccp(labelDev.position.x, labelDev.position.y-labelDev.contentSize.height-labelDesign.contentSize.height/2-20);
			[self addChild:labelDesign z:1];
			
			int ks = 0;
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"oslKillStreak"] != nil) {
				ks = [[NSUserDefaults standardUserDefaults] integerForKey:@"oslKillStreak"];
			}
			
			CCLabelTTF *labelSteph =  [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i Kills",ks] fontName:[AppDelegate get].clearFont fontSize:20];
			labelSteph.position = ccp(labelDesign.position.x, labelDesign.position.y-labelDesign.contentSize.height);
			[self addChild:labelSteph z:1];
			
			CCLabelTTF *labelTest = [CCLabelTTF labelWithString:@"Missions Completed" fontName:[AppDelegate get].menuFont fontSize:20];
			[labelTest setColor:ccBLUE];
			labelTest.position =ccp(labelSteph.position.x, labelSteph.position.y-labelSteph.contentSize.height-labelTest.contentSize.height/2-20);
			[self addChild:labelTest z:1];
			
			int mis = [AppDelegate get].stats.mi-1;
			if (mis < 0)
				mis = 0;
			CCLabelTTF *labelEthan = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i Missions",mis] fontName:[AppDelegate get].clearFont fontSize:20];
			labelEthan.position = ccp(labelTest.position.x, labelTest.position.y-labelTest.contentSize.height);
			[self addChild:labelEthan z:1];
			
			label.position = ccp(label.position.x+20,label.position.y);
		}
		
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
		
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}

-(void) leaderboards: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Leaderboards"];
	[[AppDelegate get].gkHelper showLeaderboard];
}
-(void) achievements: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Achievements"];
	[[AppDelegate get].gkHelper showAchievements];
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	CCLOG(@"dealloc StatScene"); 
	[super dealloc];
}


@end
