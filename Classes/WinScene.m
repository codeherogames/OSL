//
//  WinScene.m
//  PixelSniper
//
//  Created by James Dailey on 1/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "WinScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "MultiScene.h"
#import "Mission1.h"
#import "MissionSplash.h"
#import "PopupLayer.h"
#import "AddThis.h"
/*#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"*/

@implementation WinScene
- (id) init {
    self = [super init];
    if (self != nil) {
		CCLOG(@"WinLayer"); 
        CCSprite * bg = [CCSprite spriteWithFile:@"missioncompleted.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
		[self addChild:[WinLayer node] z:1];
		
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc WinScene"); 
	[super dealloc];
}
@end

@implementation WinLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		if ([AppDelegate get].multiplayer > 0) {
			[[AppDelegate get].gkHelper disconnectCurrentMatch];
			if ([AppDelegate get].friendInvite > -1) {
				
				CCLabelTTF *share = [CCLabelTTF labelWithString:@"Share victory with your friends!" fontName:[AppDelegate get].clearFont fontSize:20];
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
																	selector:@selector(twitterMultiplayer:)];
				twit.tag = 456;
				CCMenuItemImage *fb = [CCMenuItemImage itemFromNormalImage:@"fbButton.png" selectedImage:@"fbButton.png" 
																	target:self
																  selector:@selector(facebookMultiplayer:)];
				fb.tag = 456;
				CCMenu *socialMenu = [CCMenu menuWithItems:twit,fb, nil];
				[socialMenu alignItemsHorizontallyWithPadding: 40.0f];
				socialMenu.position = ccp(340,30);
				[self addChild:socialMenu z:4];
			}
		}

		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
		[goldBack setPosition:ccp(50,278)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
		[self addChild:goldBack z:0];
		
		gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=goldBack.position;
		[self addChild:gold z:1];
		
		[CCMenuItemFont setFontSize:22];
		TextMenuItem *mm = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(mainMenu:) label:@"Main Menu"];
		
		TextMenuItem *ta = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													target:self
												  selector:@selector(playAgain:) label:@"Play Again"];
		TextMenuItem *next = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													target:self
												  selector:@selector(nextMission:) label:@"Next Mission"];
		
		
		
        CCMenu *menu = [CCMenu menuWithItems:mm,ta,nil];
		if ([AppDelegate get].gameType == MISSIONS) {
			[menu addChild:next];
			[menu setPosition:ccp(80, 70)];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Mission Won - %i",[AppDelegate get].currentMission]];
		}
		else {
			[menu setPosition:ccp(80, 50)];
		}
		[menu setColor:ccWHITE];
        [self addChild:menu];
		[menu alignItemsVerticallyWithPadding: 16.0f];
		[CCMenuItemFont setFontSize:16];
		
		if ([AppDelegate get].gameType == MISSIONS && [AppDelegate get].stats.mi <= [AppDelegate get].currentMission) {
			[AppDelegate get].stats.mi = [AppDelegate get].stats.mi+1;
			[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
			[self showWinnings];
		}
		else if ([AppDelegate get].multiplayer > 0) {
			//if ([AppDelegate get].multiplayer == 1) {
				if ([AppDelegate get].playerLevel > 0) {
					[AppDelegate get].stats.w3w+=1;
					[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
					if ([AppDelegate get].friendInvite > -1)
						[[AppDelegate get].gkHelper getMyScore:@"3"];
				}
				else {
					[AppDelegate get].stats.w2+=1;
					[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
					if ([AppDelegate get].friendInvite > -1)
						[[AppDelegate get].gkHelper getMyScore:@"2"];
				}
			//}
			[self showWinnings];
		}
	}
    return self;
}

-(void) showWinnings {
	//if ([AppDelegate get].friendInvite > -1) {
		CCLabelTTF *winTitle = [CCLabelTTF labelWithString:@"You Earned" fontName:[AppDelegate get].clearFont fontSize:16];
		[winTitle setColor:ccBLACK];
		winTitle.position=ccp([[UIScreen mainScreen] bounds].size.height/2+74/*314*/,200);
		[self addChild:winTitle z:1];
		winTitle.rotation=6;
		
		/*if ([AppDelegate get].playerWager != 0)
			[AppDelegate get].playerWager = 20;*/
		int mWon = 25*([AppDelegate get].playerLevel+1);
		mWon += [self checkIt];
		CCLOG(@"won:%i",mWon);
		if ([AppDelegate get].gameType == MISSIONS) {
			if ([AppDelegate get].currentMission == 5) {
				[AppDelegate showNotification:@"Achievement Earned: Contract Killer"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl7" percentComplete:100.0f];

			}
			else if ([AppDelegate get].currentMission == 10) {
				[AppDelegate showNotification:@"Achievement Earned: Contract Assassin"];
				[[AppDelegate get].gkHelper reportAchievementWithID:@"osl8" percentComplete:100.0f];

			}
			mWon = 10 * [AppDelegate get].currentMission;
		}
		oldG = [AppDelegate get].loadout.g;
		CCLOG(@"oldG:%i",oldG);
		[AppDelegate get].loadout.g += mWon;
		CCLOG(@"g:%i",[AppDelegate get].loadout.g);
		[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];	
		CCLabelTTF *winnings = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG", mWon] fontName:[AppDelegate get].clearFont fontSize:30];
		[winnings setColor:ccBLACK];
		winnings.position=ccp([[UIScreen mainScreen] bounds].size.height/2+76/*316*/,174);
		[self addChild:winnings z:1];
		winnings.rotation=7;
		CCLabelTTF *winnings2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG", mWon] fontName:[AppDelegate get].clearFont fontSize:30];
		[winnings2 setColor:ccYELLOW];
		winnings2.position=ccp([[UIScreen mainScreen] bounds].size.height/2+74/*314*/,176);
		[self addChild:winnings2 z:1];
		winnings2.rotation=7;
		[self schedule: @selector(updateG) interval: 0.05];
	/*}
	else if ([AppDelegate get].multiplayer > 0) {
		CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"To protect the integrity of the game, no Gold or Win is earned when you do Friend Invite and then win by your opponent Diconnecting.  If you do Auto-Match, you will earn Gold and a Win when your opponent Disconnects.  Thank you for understanding." t:@"No Gold Earned"] autorelease];
		[self addChild:popup z:10];
	}*/
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

-(void)nextMission: (id)sender {
	/*if ([AppDelegate get].gameType == MISSIONS)
		[[LocalyticsSession sharedLocalyticsSession] upload];*/
	[AppDelegate get].currentMission++;
	[[CCDirector sharedDirector] replaceScene: [MissionSplash node]];
}

-(void)twitterMultiplayer: (id)sender {
	NSString *p = [AppDelegate get].currentOpponent;
	if (p == nil)
		p = @"another opponent";
	[AddThisSDK shareURL:@"http://bit.ly/p3SgzQ"
			 withService:@"twitter"
				   title:[NSString stringWithFormat:@"I just defeated '%@' in Online Sniper League for the iPhone!  Come play me, it's FREE!",p]
			 description:[NSString stringWithFormat:@"I just defeated '%@' in Online Sniper League for the iPhone!  Come play me, it's FREE!",p]];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Twitter"];
	/*SHKItem *item = [SHKItem URL:[NSURL URLWithString:SHKMyAppURL] title:[NSString stringWithFormat:@"I just defeated '%@' in Online Sniper League for the iPhone!  Come play me, it's FREE!",p]];
	[SHKTwitter shareItem:item];*/
}

-(void)facebookMultiplayer: (id)sender {
	NSString *p = [AppDelegate get].currentOpponent;
	if (p == nil)
		p = @"another opponent";
	/*SHKItem *item = [SHKItem text:[NSString stringWithFormat:@"I just defeated '%@' head to head in Online Sniper League for the iPhone!  Come play me, it's FREE!",p]];
	[SHKFacebook shareItem:item];*/
	[AddThisSDK shareURL:@"http://bit.ly/p3SgzQ"
			 withService:@"facebook"
				   title:[NSString stringWithFormat:@"I just defeated '%@' head to head in Online Sniper League for the iPhone!  Come play me, it's FREE!",p]
			 description:@""];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Facebook"];
}

- (void) dealloc {
	CCLOG(@"dealloc WinLayer"); 
	[AppDelegate get].friendInvite = 0;
	[super dealloc];
}
@end
