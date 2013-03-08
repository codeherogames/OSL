//
//  LoseScene.m
//  PixelSniper
//
//  Created by James Dailey on 1/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "LoseScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "MultiScene.h"
#import "Mission1.h"
#import "PopupLayer.h"
#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"

@implementation LoseScene
- (id) init {
    self = [super init];
    if (self != nil) {
		CCLOG(@"LoseLayer");
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		if ([AppDelegate get].gameType == MISSIONS) {
			CCSprite *c = [CCSprite spriteWithFile:@"w1px.png"];
			c.color=ccc3(43,69,127);
			c.scaleX = 480;
			c.scaleY = 320;
			[c setPosition:ccp(240, 160)];
			[self addChild:c z:0];
			
			CCSprite * bg = [CCSprite spriteWithFile:@"newspaper.png"];
			bg.scale = 1.4;
			bg.rotation=-14;
			[bg setPosition:ccp(260, 160)];
			[self addChild:bg z:0];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Mission Lost - %i",[AppDelegate get].currentMission]];
		}
		else {
			CCSprite * bg = [CCSprite spriteWithFile:@"missionfailed.png"];
			[bg setPosition:ccp(240, 160)];
			[self addChild:bg z:0];	
		}
		[self addChild:[LoseLayer node] z:1];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
        
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc LoseScene"); 
	[super dealloc];
}
@end

@implementation LoseLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		//if ([AppDelegate get].multiplayer > 0) {
		//	[[AppDelegate get].gkHelper disconnectCurrentMatch];
		//}
		if ([AppDelegate get].gameType == SURVIVAL) {
			
			CCLabelTTF *share = [CCLabelTTF labelWithString:@"Share scores with your friends!" fontName:[AppDelegate get].clearFont fontSize:20];
			[share setColor:ccYELLOW];
			share.position=ccp(340,70);
			[self addChild:share z:1];
			
			CCSprite *socialBack = [CCSprite spriteWithFile:@"b1px.png"];
			[socialBack setPosition:ccp(340,44)];
			socialBack.scaleX=share.contentSize.width+8;
			socialBack.scaleY=72;
			socialBack.opacity = 180;
			[self addChild:socialBack z:0];
			
			CCMenuItemImage *twit = [CCMenuItemImage itemFromNormalImage:@"twitterButton.png" selectedImage:@"twitterButton.png" 
																  target:self
																selector:@selector(twitterSurvival:)];
			twit.tag = 456;
			CCMenuItemImage *fb = [CCMenuItemImage itemFromNormalImage:@"fbButton.png" selectedImage:@"fbButton.png" 
																target:self
															  selector:@selector(facebookSurvival:)];
			fb.tag = 456;
			CCMenu *socialMenu = [CCMenu menuWithItems:twit,fb, nil];
			[socialMenu alignItemsHorizontallyWithPadding: 40.0f];
			socialMenu.position = ccp(340,30);
			[self addChild:socialMenu z:4];
			
			// survival
			if ([AppDelegate get].survivalMode == 1) {
				if ([AppDelegate get].currentLevel > [AppDelegate get].stats.sux) {
					[AppDelegate showNotification:@"Saving New High Score"];
					[AppDelegate get].stats.sux = [AppDelegate get].currentLevel;
					[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
				}
			}
			else if ([AppDelegate get].currentLevel > [AppDelegate get].stats.su) {
				[AppDelegate showNotification:@"Saving New High Score"];
				[AppDelegate get].stats.su = [AppDelegate get].currentLevel;
				[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
			}
			
			//CCLOG(@"Kill Streak:%i",[AppDelegate get].killStreak);
			CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
			[goldBack setPosition:ccp(50,278)];
			goldBack.scaleX=0.8;
			goldBack.scaleY=0.6;
			[self addChild:goldBack z:0];
			
			gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
			[gold setColor:ccYELLOW];
			gold.position=goldBack.position;
			[self addChild:gold z:1];
			
			CCLabelTTF *levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
																  @"%i Days", [AppDelegate get].currentLevel-1] fontName:[AppDelegate get].clearFont fontSize:14];
			if ([AppDelegate get].currentLevel == 2)
				[levelLabel setString:@"1 Day"];
			
			[levelLabel setColor:ccBLACK];
			[levelLabel setPosition:ccp(16+levelLabel.contentSize.width/2, gold.position.y-gold.contentSize.height-4)];
			[self addChild:levelLabel];
			
			/*CCLabelTTF *killLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
																  @"%i KillStreak", [AppDelegate get].killStreak] fontName:[AppDelegate get].clearFont fontSize:14];*/

			CCLabelTTF *killLabel = [CCLabelTTF labelWithString:@"x 5 = " fontName:[AppDelegate get].clearFont fontSize:14];
			int mWon = 0;
			if ([AppDelegate get].survivalMode == 1) {
				[killLabel setString:@"x 10 = "];
				mWon = 10*([AppDelegate get].currentLevel-1);
			}
			else {
				mWon = 5*([AppDelegate get].currentLevel-1);
			}
			if ([AppDelegate get].currentLevel > 4) {
				mWon += [self checkIt];
			}
			[killLabel setColor:ccBLACK];
			[killLabel setPosition:ccp(16+killLabel.contentSize.width/2, levelLabel.position.y-killLabel.contentSize.height)];
			[self addChild:killLabel];
			
			//int mWon = [AppDelegate get].killStreak+[AppDelegate get].currentLevel;
			CCLabelTTF *gLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
																 @"%i Gold", mWon] fontName:[AppDelegate get].clearFont fontSize:14];
			[gLabel setColor:ccBLACK];
			[gLabel setPosition:ccp(16+gLabel.contentSize.width/2, killLabel.position.y-gLabel.contentSize.height)];
			[self addChild:gLabel];
			oldG = [AppDelegate get].loadout.g;
			[AppDelegate get].loadout.g += mWon;
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			[self schedule: @selector(updateG) interval: 0.05];
			
			/*[[AppDelegate get].gkHelper getMyTopScore:[NSString stringWithFormat:@"%i", [AppDelegate get].gameType] s:[AppDelegate get].currentLevel];*/
			if ([AppDelegate get].gameType == SURVIVAL && [AppDelegate get].survivalMode == 1) {
				[[AppDelegate get].gkHelper submitScore:[AppDelegate get].currentLevel category:[NSString stringWithFormat:@"%i",SURVIVALEXTREME]];
			}
			else {
				[[AppDelegate get].gkHelper submitScore:[AppDelegate get].currentLevel category:[NSString stringWithFormat:@"%i",[AppDelegate get].gameType]];	
			}
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Survival-Score: %i",[AppDelegate get].currentLevel]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"oslKillStreak"] != nil) {
				int ks = [[NSUserDefaults standardUserDefaults] integerForKey:@"oslKillStreak"];
				if ([AppDelegate get].killStreak > ks) {
					[AppDelegate showNotification:@"Saving New High Kill Streak"];
					[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].killStreak forKey:@"oslKillStreak"];
					[[NSUserDefaults standardUserDefaults] synchronize];
					[[AppDelegate get].gkHelper submitKillStreak:[AppDelegate get].killStreak];	
				}
			}
			else {
				[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].killStreak forKey:@"oslKillStreak"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[[AppDelegate get].gkHelper submitKillStreak:[AppDelegate get].killStreak];
			}
			
		}
		[CCMenuItemFont setFontSize:22];
		
		TextMenuItem *mm = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													target:self
												  selector:@selector(mainMenu:) label:@"Main Menu"];
		
		TextMenuItem *ta = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													target:self
												  selector:@selector(playAgain:) label:@"Play Again"];
		
		
		
        CCMenu *menu = [CCMenu menuWithItems:mm,ta,nil];
        [self addChild:menu];
		[menu alignItemsVerticallyWithPadding: 16.0f];
		[menu setPosition:ccp(80, 50)];
		[CCMenuItemFont setFontSize:16];
		
		// killstreak
		if ([AppDelegate get].killStreak > [AppDelegate get].stats.st) {
			[AppDelegate get].stats.st = [AppDelegate get].killStreak;
			[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
		}
		
		[self checkAchievements];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];	
	}
    return self;
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

-(int) checkIt {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"D"];
	int dy = [[formatter stringFromDate:[NSDate date]] intValue];
	[formatter release];
	
	if (dy != [AppDelegate get].stats.w4w) {
		[AppDelegate get].stats.w4w = dy;
		[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
		CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Congratulations!  You got 50G free just for playing today.  Who loves ya?  Come back tomorrow for more free Gold.\n\nAnd remember, this game relies on new players to keep it fresh.  Tell your friends.  Social Networking buttons make it easy." t:@"Daily Gold"] autorelease];
		[self addChild:popup z:10];
		
		return (5*10);
	}
	else {
		return 0;
	}
}

-(void)mainMenu: (id)sender {
	/*if ([AppDelegate get].gameType == MISSIONS)
		[[LocalyticsSession sharedLocalyticsSession] upload];*/
	[[CCDirector sharedDirector] replaceScene: [MenuScene node]];
}

-(void)playAgain: (id)sender {
	if ([AppDelegate get].multiplayer > 0)
		[[CCDirector sharedDirector] replaceScene: [MultiScene node]];
	else if ([AppDelegate get].gameType == MISSIONS) {
		//[[LocalyticsSession sharedLocalyticsSession] upload];
		[[CCDirector sharedDirector] replaceScene: [Mission1 node]];
	}
	else
		[[CCDirector sharedDirector] replaceScene: [GameScene node]];
}

-(void) checkAchievements {
	// Survival Levels
	if ([AppDelegate get].currentLevel > 4) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"osl1"] == nil) {
			[AppDelegate showNotification:@"Achievement Earned: Rookie Of The Day"];
			[[AppDelegate get].gkHelper reportAchievementWithID:@"osl1" percentComplete:100.0f];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"osl1"];
		}
		if ([AppDelegate get].currentLevel > 9) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"osl2"] == nil) {
				[AppDelegate showNotification:@"Achievement Earned: Protector"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl2" percentComplete:100.0f];
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"osl2"];
			}
		}
		if ([AppDelegate get].currentLevel > 19) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"osl3"] == nil) {
				[AppDelegate showNotification:@"Achievement Earned: Guardian Angel"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl3" percentComplete:100.0f];
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"osl3"];
			}
		}
		if ([AppDelegate get].currentLevel > 29) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"osl4"] == nil) {
				[AppDelegate showNotification:@"Achievement Earned: Enforcer"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl4" percentComplete:100.0f];
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"osl4"];
			}
		}
		if ([AppDelegate get].currentLevel > 39) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"osl5"] == nil) {
				[AppDelegate showNotification:@"Achievement Earned: Annihilator"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl5" percentComplete:100.0f];
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"osl5"];
			}
		}
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)twitterSurvival: (id)sender {
	SHKItem *item = [SHKItem URL:[NSURL URLWithString:SHKMyAppURL] title:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]];
	[SHKTwitter shareItem:item];
/*	[AddThisSDK shareURL:@"http://bit.ly/p3SgzQ"
			 withService:@"twitter"
				   title:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]
			 description:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]];*/
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Twitter"];
}

-(void)facebookSurvival: (id)sender {
	SHKItem *item = [SHKItem text:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]];
	[SHKFacebook shareItem:item];
/*	[AddThisSDK shareURL:@"http://bit.ly/p3SgzQ"
			 withService:@"facebook"
				   title:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]
			 description:[NSString stringWithFormat:@"I survived %i days with a %i kill streak in Online Sniper League for the iPhone!  Come play me, it's FREE!",[AppDelegate get].currentLevel,[AppDelegate get].killStreak]];*/
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Facebook"];
}

- (void) dealloc {
	CCLOG(@"dealloc LoseScene"); 
	[super dealloc];
}
@end
