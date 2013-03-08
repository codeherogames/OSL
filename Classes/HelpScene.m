//
//  HelpScene.m
//  OSL
//
//  Created by James Dailey on 2/16/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "HelpScene.h"
#import "MyDial.h"
#import "MyToggle.h"
#import "MyMenuButton.h"
#import "MenuScene.h"
#import "ComputerScene.h"

@implementation HelpScene

- (id) init {
    self = [super init];
    if (self != nil) {
		//[director setDepthTest: YES];
		[[CCDirector sharedDirector] setProjection:CCDirectorProjection3D];
		[CCMenuItemFont setFontName:[AppDelegate get].helpFont];
		maxPage = SECTION5;
		fontColor = ccc3(71,10,10);
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *bg = [CCSprite spriteWithFile: @"paper.png"];
		[self addChild:bg z:0];
		bg.position = ccp(s.width/2, s.height/2);
		
		CCSprite *curl = [CCSprite spriteWithFile: @"pagecurl.png"];
		[self addChild:curl z:1];
		curl.position = ccp(s.width-curl.contentSize.width/2, curl.contentSize.height/2);

		CCSprite *backcurl = [CCSprite spriteWithFile: @"pagecurl.png"];
		[self addChild:backcurl z:1];
		backcurl.flipX = TRUE;
		backcurl.position = ccp(curl.contentSize.width/2, curl.contentSize.height/2);
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Mercenary Handbook" fontName:[AppDelegate get].helpFont fontSize:30];
		[label setColor:fontColor];

		label.position =ccp(s.width/2, s.height-label.contentSize.height/2-4);
		[self addChild:label z:1];
		
		CCSprite *eagle = [CCSprite spriteWithFile: @"eagle.png"];
		//eagle.scale=3.3;
		//eagle.opacity=255;
		eagle.color=ccc3(61,10,10);
		
		[self addChild:eagle z:1];
		eagle.position = ccp(s.width-(eagle.contentSize.width/2)-4, label.position.y - label.contentSize.height/2 - eagle.contentSize.height/2 - 4);
		
		CCSprite *eagle2 = [CCSprite spriteWithFile: @"eagle.png"];
		//eagle.scale=3.3;
		//eagle.opacity=255;
		eagle2.color=ccc3(61,10,10);
		
		[self addChild:eagle2 z:1];
		eagle2.position = ccp(eagle2.contentSize.width/2+4, label.position.y - label.contentSize.height/2 - eagle.contentSize.height/2 - 4);
	
		CCMenuItem *mainMenu = [CCMenuItemFont itemFromString:@"Menu"
													   target:self
													 selector:@selector(mainMenu:)];
		CCMenu *mMenu = [CCMenu menuWithItems:mainMenu, nil];
		[mMenu setColor:fontColor];
        mMenu.position = ccp(456,310);
		[self addChild:mMenu];
		for (CCMenuItem *mi in mMenu.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		
		CCLabelTTF *page = nil;
		if ([AppDelegate get].helpPage != 0) {
			CCMenuItem *toc = [CCMenuItemFont itemFromString:@"TOC"
														   target:self
														 selector:@selector(TOC:)];
			
			CCMenu *tMenu = [CCMenu menuWithItems:toc, nil];
			[tMenu setColor:fontColor];
			tMenu.position = ccp(30,310);
			[self addChild:tMenu];
			for (CCMenuItem *mi in tMenu.children) {
				CGSize tmp = mi.contentSize;
				tmp.width = tmp.width*1.3;
				tmp.height = tmp.height*1.3;
				[mi setContentSize:tmp];
			}
			page = [CCLabelTTF labelWithString:[NSString stringWithFormat: 
												@"%i",[AppDelegate get].helpPage ] fontName:[AppDelegate get].helpFont fontSize:20];
			[page setColor:fontColor];
			
			page.position =ccp(s.width/2, page.contentSize.height/2+4);
			[self addChild:page z:1];
		}
		int nextPage = [AppDelegate get].helpPage+1;
		if ([AppDelegate get].helpPage == maxPage)
			nextPage = 0;
		
		int backPage = [AppDelegate get].helpPage-1;
		if ([AppDelegate get].helpPage == 0)
			backPage = maxPage;
		
		//CCLOG(@"backPage : %i",backPage);
		CCLOG(@"nextPage : %i",nextPage);
		CCMenuItem *back = [CCMenuItemImage itemFromNormalImage:@"t1px.png" selectedImage:@"t1px.png"
													   target:self
													 selector:@selector(Back:)];
		CCMenuItem *next = [CCMenuItemImage itemFromNormalImage:@"t1px.png" selectedImage:@"t1px.png"
												   target:self
												 selector:@selector(Next:)];
		back.scale = 100;
		next.scale = 100;
		CCMenu *menu = [CCMenu menuWithItems:back,next, nil];
		[menu setColor:fontColor];
		[menu alignItemsHorizontallyWithPadding: 320.0f];
        menu.position = ccp(s.width/2,50);
		//menu.position = ccp(s.width-50,0);
		[self addChild:menu];

		[self addChild:[HelpLayer node] z:1 tag:1];
		[self getChildByTag:123].position=ccp(-100000,-100000);
    }
    return self;
}

-(void) onExit {
	CCLOG(@"onexit");
	[self removeAllChildrenWithCleanup:YES];
	//[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void)Back: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[AppDelegate get].helpPage--;
	CCLOG(@"back : %i",[AppDelegate get].helpPage);
	if ([AppDelegate get].helpPage == -1)
		[AppDelegate get].helpPage = maxPage;		

	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node] backwards:YES]];
}
-(void)Next: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[AppDelegate get].helpPage++;
	CCLOG(@"next : %i",[AppDelegate get].helpPage);
	if ([AppDelegate get].helpPage == maxPage+1)
		[AppDelegate get].helpPage = 0;
	//[self removeChildByTag:123 cleanup:YES];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node] backwards:NO]];
}

-(void)mainMenu: (id)sender {
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[AppDelegate get].helpPage = 0;
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

-(void)TOC: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[AppDelegate get].helpPage=0;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}

- (void) dealloc {
	CCLOG(@"dealloc HelpScene"); 
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
	//[director setDepthTest: NO];
	[super dealloc];
}
@end

@implementation HelpLayer
@synthesize fontColor;
- (id) init {
    self = [super init];
    if (self != nil) {	
		self.isTouchEnabled = YES;
		self.fontColor = ccc3(71,10,10);
		CGSize s = [[CCDirector sharedDirector] winSize];
		headingPos = ccp(s.width/2,s.height*0.68);
		titlePos = ccp(s.width/2,s.height*0.8);
		text1Pos = ccp(s.width/2,s.height*0.2);
		midTextPos = ccp(s.width/2,s.height*0.30);
		
		headingSize=20;
		textSize=16;
		titleSize=24;
		midTextSize=16;
		
		if ([AppDelegate get].helpPage == 0)
			[self toc];
		else if ([AppDelegate get].helpPage >= SECTION5)
			[self computer];
		else if ([AppDelegate get].helpPage  >= SECTION4)
			[self customization];
		else if ([AppDelegate get].helpPage  >= SECTION3)
			[self modes];
		else if ([AppDelegate get].helpPage  >= SECTION2)
			[self controls];
		else
			[self rules];

	}
	return self;
}

-(void) toc
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCMenuItem *section1 = [CCMenuItemFont itemFromString:@"1. The Code"
												   target:self
												 selector:@selector(goSection1:)];
	
	CCMenuItem *section2 = [CCMenuItemFont itemFromString:@"2. Controls"
												   target:self
												 selector:@selector(goSection2:)];
	
	CCMenuItem *section3 = [CCMenuItemFont itemFromString:@"3. Mission Types"
												   target:self
												 selector:@selector(goSection3:)];
	
	CCMenuItem *section4 = [CCMenuItemFont itemFromString:@"4. Customization"
												   target:self
												 selector:@selector(goSection4:)];
	
	CCMenuItem *section5 = [CCMenuItemFont itemFromString:@"5. Wrist Computer"
												   target:self
												 selector:@selector(goSection5:)];
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"Table Of Contents" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	CCMenu *menu = [CCMenu menuWithItems:section1,section2,section3,section4,section5, nil];
	menu.anchorPoint=ccp(0,0);
	[menu setColor:ccc3(71,10,10)];
	[menu alignItemsVerticallyWithPadding: 20.0f];
	menu.position = ccp(140,s.height/2.4);
	[self addChild:menu];
	for (CCMenuItem *mi in menu.children) {
		CGSize tmp = mi.contentSize;
		tmp.width = tmp.width*1.3;
		tmp.height = tmp.height*1.3;
		[mi setContentSize:tmp];
		mi.anchorPoint=ccp(0,0);
	}
}


-(void) rules
{
	CCLOG(@"Rules");
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *heading;
	CCLabelTTF *text1;
	switch ([AppDelegate get].helpPage) {
		case 1:
			heading = [CCLabelTTF labelWithString:@"Rule #1: Stick to your objective" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"If you break this rule, you will be terminated." fontName:[AppDelegate get].helpFont fontSize:textSize];
			CCSprite *alert = [CCSprite spriteWithFile:@"helpAlert.png"];
			[alert setPosition:ccp(s.width/2, s.height/2-20)];
			[self addChild:alert z:2];
			break;
		case 2:
			heading = [CCLabelTTF labelWithString:@"Rule #2: Protect your team at all costs" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"Your team is your family." fontName:[AppDelegate get].helpFont fontSize:textSize];
			// President
			CCSprite *pres = [CCSprite spriteWithFile:@"stand.png"];
			[pres setPosition:ccp(s.width/2, s.height/2-20)];
			pres.color=ccBLACK;
			[self addChild:pres z:2];
			CCSprite *patch = [CCSprite spriteWithFile:@"eyepatch.png"];
			patch.anchorPoint=ccp(0.5,0);
			[patch setPosition:ccp(pres.contentSize.width/2,34)];
			[pres addChild:patch z:pres.zOrder+1];
			
			CCLabelTTF *name = [CCLabelTTF labelWithString:@"Smitty" fontName:[AppDelegate get].helpFont fontSize:textSize];
			name.color=ccBLACK;
			[name setPosition:ccp(pres.position.x,pres.position.y + pres.contentSize.width/2 + 8)];
			[self addChild:name];
			break;
		case 3:
			heading = [CCLabelTTF labelWithString:@"Rule #3: Do not shoot innocent people" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"All contracts require zero collateral damage." fontName:[AppDelegate get].helpFont fontSize:textSize];
			// President
			CCSprite *citizen = [CCSprite spriteWithFile:@"walk1.png"];
			[citizen setPosition:ccp(s.width*.4, s.height/2-20)];
			citizen.color=ccRED;
			[self addChild:citizen z:2];
			CCSprite *hat1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png", 2]];
			hat1.anchorPoint=ccp(0.5,0);
			[hat1 setPosition:ccp(citizen.contentSize.width/2,citizen.contentSize.height-hat1.contentSize.height/2-4)];
			[citizen addChild:hat1 z:citizen.zOrder+1];

			
			CCSprite *securityGuard2 = [CCSprite spriteWithFile:@"stand.png"];
			[securityGuard2 setPosition:ccp(s.width*.6, s.height/2-20)];
			securityGuard2.color=ccBLUE;
			[self addChild:securityGuard2 z:1];
			CCSprite *hat2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hat%i.png", SECURITYHAT]];
			hat2.anchorPoint=ccp(0.5,0);
			//[hat2 setPosition:ccp(pres.contentSize.width/2,32)];
			[hat2 setPosition:ccp(securityGuard2.contentSize.width/2,securityGuard2.contentSize.height-hat2.contentSize.height/2-4)];
			[securityGuard2 addChild:hat2 z:securityGuard2.zOrder+1];
			securityGuard2.flipX = TRUE;
			hat2.flipX = TRUE;
			
			
			break;
		case 4:
			heading = [CCLabelTTF labelWithString:@"Rule #4: Eliminate threats quickly and discreetly" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"Take them out before they do harm and be wary of disguises." fontName:[AppDelegate get].helpFont fontSize:textSize];
			// President
			CCSprite *enemy = [CCSprite spriteWithFile:@"shooting2.png"];
			[enemy setPosition:ccp(s.width/2, s.height/2-20)];
			enemy.color=ccRED;
			[self addChild:enemy z:2];
			CCSprite *glasses = [CCSprite spriteWithFile:@"hat1.png"];
			glasses.anchorPoint=ccp(0.5,0);
			[glasses setPosition:ccp(enemy.contentSize.width/2,32)];
			[enemy addChild:glasses z:enemy.zOrder+1];
			CCSprite *g = [CCSprite spriteWithFile:@"gun.png"];
			[enemy addChild:g z:-1];
			[g setPosition:ccp(4,enemy.contentSize.height/2+2)];
			break;
		default:
			break;
		
	}
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"The Code" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:self.fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	
	[heading setColor:self.fontColor];
	heading.position=headingPos;
	[self addChild:heading z:1];
	
	[text1 setColor:self.fontColor];
	text1.position=text1Pos;
	[self addChild:text1 z:1];
}

-(void) controls
{
	CCLOG(@"Controls");
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *heading;
	CCLabelTTF *text1;
	switch ([AppDelegate get].helpPage) {
		case SECTION2:
			heading = [CCLabelTTF labelWithString:@"Controlling Scope Movement" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"Drag left thumb on the screen without lifting." fontName:[AppDelegate get].helpFont fontSize:textSize];
			
			CCSprite *thumb = [CCSprite spriteWithFile: @"thumb.png"];
			[self addChild:thumb z:11];
			thumb.position = ccp(s.width/2, s.height/2-20);
			break;
		case SECTION2+1:
			heading = [CCLabelTTF labelWithString:@"Zooming Scope In/Out" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"Touch Zoom with right thumb to zoom in or out." fontName:[AppDelegate get].helpFont fontSize:textSize];
			
			CCSprite *zoom = [CCSprite spriteWithFile: @"zoom1.png"];
			[self addChild:zoom z:11];
			zoom.position = ccp(s.width/2, s.height/2-20);
			break;	
		case SECTION2+2:
			heading = [CCLabelTTF labelWithString:@"Firing Rifle" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			text1 = [CCLabelTTF labelWithString:@"Touch Fire with right thumb to shoot target." fontName:[AppDelegate get].helpFont fontSize:textSize];
			
			CCSprite *fire = [CCSprite spriteWithFile: @"fireButtonChrome.png"];
			[self addChild:fire z:11];
			fire.position = ccp(s.width/2, s.height/2-20);			
			break;
		default:
			break;
			
	}
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"Controls" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:self.fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	
	[heading setColor:self.fontColor];
	heading.position=headingPos;
	[self addChild:heading z:1];
	
	[text1 setColor:self.fontColor];
	text1.position=text1Pos;
	[self addChild:text1 z:1];
}

-(void) modes
{
	CCLOG(@"Modes");
	//CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *heading;
	CCLabelTTF *midText;
	switch ([AppDelegate get].helpPage) {
		case SECTION3:
			heading = [CCLabelTTF labelWithString:@"Missions" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Fulfill contracts from your boss to earn prestige as well as some extra Gold.  Each mission requires skill and strategy.  New missions will be released periodically, so pay attention to updates and the news feed." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		case SECTION3+1:
			heading = [CCLabelTTF labelWithString:@"Survival" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Defend your base against never ending waves of enemies for as many days as you can.  Go for kill streaks to unlock extra defense mechanisms.  Compare how many days you can last against others on the leaderboards.  Unlock Achievements to prove your skills.  Custom weapons can be used but perks cannot." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		case SECTION3+2:
			heading = [CCLabelTTF labelWithString:@"Sandbox Mode" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Multiplayer training and Fun sandbox.  All attacks you launch go against yourself.  This is great training for Multiplayer.  You can formulate attack plans as you can see what you opponent will see.  You can figure out the best way to handle incoming attacks.  Hone your sniping skills and your attack skills.  Or just dial up some enemies and take them out for fun!" dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;	
		case SECTION3+3:
			heading = [CCLabelTTF labelWithString:@"Multiplayer" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Play against another person over the internet via Game Center.  Launch attacks against them and protect against their attacks in a fun and strategic battle.  Interrogate their leader to find your opponent's location and then take them out.  See how high you can climb on the leaderboards.  Perks and custom weapons can be used in Professional level.  Winner wins Gold." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		case SECTION3+4:
			heading = [CCLabelTTF labelWithString:@"Multiplayer Tiers" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Rookie - play against opponents without using any perks.  Custom equipment is allowed.  Helpful for learning the ropes before going all in.\n\nProfessional - anything goes.  You can use all your custom weapons and perks.  This adds lots of strategy and dynamic gameplay.  Plus, it's really fun!" dimensions:CGSizeMake(380,200) alignment:UITextAlignmentLeft fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		case SECTION3+5:
			heading = [CCLabelTTF labelWithString:@"Multiplayer Wagers" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"You can choose to wager 20G of your Gold and you will be matched against players willing to do the same.  The winner gets the usual reward plus player wagers.  This is for mercenaries that are willing to put their money where their mouth is." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;	
		default:
			break;
			
	}
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"Play Modes" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:self.fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	
	[heading setColor:self.fontColor];
	heading.position=headingPos;
	[self addChild:heading z:1];
	
	[midText setColor:self.fontColor];
	midText.position=midTextPos;
	[self addChild:midText z:1];
}

-(void) customization
{
	CCLOG(@"Modes");
	//CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *heading;
	CCLabelTTF *midText;
	switch ([AppDelegate get].helpPage) {
		case SECTION4:
			heading = [CCLabelTTF labelWithString:@"Weapons" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Your sniper rife, scope, ammo and other equipment are upgradable and customizable.  You can upgrade your weapons and set up your loadout in the Customization section.  You can use the loadout you configure in every Play Mode.  Make your loadout the way you want it!" dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		case SECTION4+1:
			heading = [CCLabelTTF labelWithString:@"Perks" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Perks are special abilities you can use to defeat your opponents.  Each perk has the ability to give you the upperhand in Professional Multipalyer modes.  They can give you a leg up or they can be a detriment to your opponent.  Perks can be obtained and configured within the Customization section." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			break;
		default:
			break;
			
	}
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"Customization" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:self.fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	
	[heading setColor:self.fontColor];
	heading.position=headingPos;
	[self addChild:heading z:1];
	
	[midText setColor:self.fontColor];
	midText.position=midTextPos;
	[self addChild:midText z:1];
}

-(void) computer
{
	CCLOG(@"Computer");
	//CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *heading;
	CCLabelTTF *midText;
	CGSize s = [[CCDirector sharedDirector] winSize];
	switch ([AppDelegate get].helpPage) {
		case SECTION5:
			heading = [CCLabelTTF labelWithString:@"Overview" fontName:[AppDelegate get].helpFont fontSize:headingSize];
			midText = [CCLabelTTF labelWithString:@"Your wrist computer is used to hire your fellow mercenary agents.  Buttons will only be active when you can afford a tier of actions.  When you click a button, it will slide out your options at the associated price level." dimensions:CGSizeMake(400,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].helpFont fontSize:midTextSize];
			
			CCMenuItem *launch = [CCMenuItemFont itemFromString:@"Touch here to view Wrist Computer"
														   target:self
														 selector:@selector(launchWrist:)];
			
			CCMenu *menu = [CCMenu menuWithItems:launch, nil];
			//menu.anchorPoint=ccp(0,0);
			[menu setColor:ccc3(71,10,10)];
			for (CCMenuItem *mi in menu.children) {
				CGSize tmp = mi.contentSize;
				tmp.width = tmp.width*1.3;
				tmp.height = tmp.height*1.3;
				[mi setContentSize:tmp];
			}
			menu.position = ccp(s.width/2+40,text1Pos.y);
			[self addChild:menu];
			break;		
		default:
			break;
			
	}
	
	CCLabelTTF *title = [CCLabelTTF labelWithString:@"Wrist Computer" fontName:[AppDelegate get].helpFont fontSize:titleSize];
	[title setColor:self.fontColor];
	title.position=titlePos;
	[self addChild:title z:1];
	
	
	[heading setColor:self.fontColor];
	heading.position=headingPos;
	[self addChild:heading z:1];
	
	[midText setColor:self.fontColor];
	midText.position=midTextPos;
	[self addChild:midText z:1];
}

-(void)launchWrist: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	 [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[ComputerScene node]]];
}

-(void)goSection1: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
 [AppDelegate get].helpPage=1;
 [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}
	 
-(void)goSection2: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
 [AppDelegate get].helpPage=SECTION2;
 [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}
-(void)goSection3: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[AppDelegate get].helpPage=SECTION3;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}
-(void)goSection4: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:1.0f loop:NO];
	[AppDelegate get].helpPage=SECTION4;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}
-(void)goSection5: (id)sender {
	[[AppDelegate get].soundEngine playSound:9 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[AppDelegate get].helpPage=SECTION5;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[HelpScene node]]];
}

- (void) dealloc {
	CCLOG(@"dealloc HelpLayer"); 
	[super dealloc];
}
@end