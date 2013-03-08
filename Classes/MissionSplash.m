//
//  MissionSplash.m
//  OSL
//
//  Created by James Dailey on 4/22/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MissionSplash.h"
#import "MenuScene.h"
#import "TextMenuItem.h"
#import "Mission1.h"

@implementation MissionSplash
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		CGSize s = [[CCDirector sharedDirector] winSize];
        CCSprite * bg = [CCSprite spriteWithFile:@"splash.png"];
        [bg setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:bg z:0];
        [self addChild:[MissionSplashLayer node] z:1];
		//reward = [[NSUserDefaults standardUserDefaults] integerForKey:@"t"];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}	
@end

@implementation MissionSplashLayer
-(id) init {
    self = [super init];
    if (self != nil) {	
		//[AppDelegate get].tutorialState = 20;
		CGSize s = [[CCDirector sharedDirector] winSize];
		NSString *m;
		if ([AppDelegate get].stats.mi == 0) {
			m = @"Hey, come on in.  I heard great things about you so far and we think you can handle contract missions.  We take every mission seriously and there is ZERO room for error.  One mistake and we don't get paid - which means you don't get paid.  Understand?  Each mission requires ZERO civilian casualities and you cannot be detected by anybody, especially the authorities.  One shot one kill - got it?  Let me check the file...";
			
		}
		else if ([AppDelegate get].currentMission == 1 || [AppDelegate get].currentMission == 6) {
			m = @"We need you to stake out the Capitol Building.  Our client is running for office in a very hostile environment.  He gets death threats daily.  We have credible evidence the incumbent hired a hitman to eliminate our client during his motorcade past the Capitol Building.  We have a tip that he may do it from within the building itself.  This client has lots of money and political power.  If you can pull this off, it will be great for both of us.  Report back here after.";
		}
		else if ([AppDelegate get].currentMission == 2 || [AppDelegate get].currentMission == 7) {
			m = @"Nice work taking that guy out!  Our client was so impressed, he wants you personally to protect him until further notice.  He's giving a speech on the steps of the Capitol Building in two days.  A large crowd is expected.  We got another tip from the same source.  An assassin disguised as a union worker will make an attempt on his life.  Ironically, our client supports the unions.  Keep your eyes open and be careful.";
		}
		else if ([AppDelegate get].currentMission == 3 || [AppDelegate get].currentMission == 8) {
			m = @"Man, you got that guy just in time.  The opponent is behind bars and our client won the election .  But he still needs your services.  We intercepted a phone conversation about a package bomb.  Unfortunately, it is customary for citizens to leave gifts at the Capitol Building for newly elected officials.  Building security will monitor the packages but that may not be enough.  Destroy the bomb and do not let the perps get away.";
		}
		else if ([AppDelegate get].currentMission == 4 || [AppDelegate get].currentMission == 9) {
			m = @"That was a close one.  It seems there are people unhappy with the election results.  We need you to perform surveillance full time until further notice.  For the next week the Capitol Building and street access are closed for summer recess.  But our client is working there to get up to speed.  Nobody knows this except his inside circle so there shouldn't be any action.  There should be no people or vehicles allowed to approach.";
		}
		else if ([AppDelegate get].currentMission == 5 || [AppDelegate get].currentMission == 10) {
			m = @"OK, this is getting out of hand.  Since you foiled their last plot, we learned it's not just our client that is being targeted now.  Looks like you killed the leader of a terrorist group.   They will do anything to carry out the last order he gave them.  They are intent on destroying the Capitol Building because it is a symbol of Democracy.  We need you on night shift.  Day shift is covered.";
		}
		else {
			CCLOG(@"Current Mission:%i",[AppDelegate get].currentMission);
			m = @"New Missions Coming Soon...";	
		}
		t = [CCLabelTTF labelWithString:m dimensions:CGSizeMake(s.width-(s.width*.5),s.height-(s.height*.2)) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:16];
		[t setColor:ccWHITE];
		t.position=ccp(s.width/3.2,s.height/2);
		[self addChild:t z:1];
		
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(next:) label:@"Next"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(mainMenu:) label:@"Back"];
		a.tag = 456;
		CCMenu *menu;
		if ([AppDelegate get].currentMission < 11) {
			menu = [CCMenu menuWithItems:b,a,nil];
			[menu alignItemsVerticallyWithPadding: 170.0f];
			menu.position = ccp(s.width*0.84,s.height/2+30);
		}
		else {
			menu = [CCMenu menuWithItems:b,nil];
			menu.position = ccp(s.width*0.84,290);		
		}

		[self addChild:menu z:1];
		
	}
	return self;
}

-(void) next:(id)sender {
	if ([AppDelegate get].stats.mi == 0) {
		[t setString:@"We need you to stake out the Capitol Building.  Our client is running for office in a very hostile environment.  He gets death threats daily.  We have credible evidence the incumbent hired a hitman to eliminate our client during his motorcade past the Capitol Building.  We have a tip that he may do it from within the building itself.  This client has lots of money and political power.  If you can pull this off, it will be great for both of us.  Report back here after."];
		[AppDelegate get].currentMission = 1;
		[AppDelegate get].stats.mi = 1;
		[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
	}
	else {
		CCMenuItem *item = (CCMenuItem *)sender;
		[item setIsEnabled:NO];
		[[CCDirector sharedDirector] replaceScene:[Mission1 node]];
	}
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}
- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc TutorialSplashLayer"); 
	[super dealloc];
}

@end
