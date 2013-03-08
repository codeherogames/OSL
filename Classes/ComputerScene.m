//
//  ComputerScene.m
//  OSL
//
//  Created by James Dailey on 3/9/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "ComputerScene.h"
#import "MyDial.h"
#import "MyToggle.h"
#import "MyMenuButton.h"
#import "HelpScene.h"
#import "ChildMenuButton.h"
@implementation ComputerScene

- (id) init {
    self = [super init];
    if (self != nil) {
		[self addChild:[ComputerLayer node] z:1 tag:1];
    }
    return self;
}

-(void) showDescription:(NSString*)d
{
	//CCLOG(@"Description:%@",d);
	[(ComputerLayer*)[self getChildByTag:1] showDescription:d];
}
- (void) dealloc {
	CCLOG(@"dealloc ComputerScene"); 
	[super dealloc];
}
@end

@implementation ComputerLayer
@synthesize info1,info2,info3,info4,des;
- (id) init {
    self = [super init];
    if (self != nil) {	
		self.isTouchEnabled = YES;
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Wrist Computer" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		[AppDelegate get].money=999999999999999;
		[AppDelegate get].help = 1;
		
		// Zoom Button
		CCSprite *myZoomButton = [CCSprite spriteWithFile: @"zoom.png"]; 
		[myZoomButton setPosition:ccp(366, 30)];
		[self addChild:myZoomButton z:12];
		
		// Fire Button
		CCMenuItem *myFireButton = [CCMenuItemImage itemFromNormalImage:@"fireButtonChrome.png" selectedImage:@"fireButtonChrome.png" target:self selector:@selector(fake:)];
		CCMenu *buttonMenu = [CCMenu menuWithItems:myFireButton, nil];
		//buttonMenu.tag = kButtonMenu;
		[buttonMenu setPosition:ccp(450, 30)];
		[self addChild:buttonMenu z:12];
		
		[CCMenuItemFont setFontSize:14];
		
		CCMenuItem *mainMenu = [CCMenuItemFont itemFromString:@"Back"
													   target:self
													 selector:@selector(mainMenu:)];
		CCMenu *mMenu = [CCMenu menuWithItems:mainMenu, nil];
        mMenu.position = ccp(456,310);
		[self addChild:mMenu];
		for (CCMenuItem *mi in mMenu.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}		
		
		[[AppDelegate get].m1 reset];
		[[AppDelegate get].m2 reset];
		[[AppDelegate get].m3 reset];
		[[AppDelegate get].m4 reset];
		[[AppDelegate get].m5 reset];
		[[[AppDelegate get].m5.childButtons objectAtIndex:0] enable];
		[[[AppDelegate get].m5.childButtons objectAtIndex:1] enable];
		[[[AppDelegate get].m5.childButtons objectAtIndex:2] enable];
		
		CCSprite *menuTray = [CCSprite spriteWithFile: @"menutray3.png"];
		[self addChild:menuTray z:11];
		menuTray.position = ccp(menuTray.contentSize.width/2, 160);
		
		[self addChild:[AppDelegate get].glassSlider z:10];
		[AppDelegate get].glassSlider.position = ccp(menuTray.position.x-[AppDelegate get].glassSlider.contentSize.width/2, 160);
		[[AppDelegate get].glassSlider initActions];
		//[AppDelegate get].glassSlider = glassSlider;
		
		float currentY = 320;
		float spacer = 4;
		//[AppDelegate get].actionButtons = [[NSMutableArray alloc] init];
		[AppDelegate get].lastActionButton = -1;
		
		[self addChild:[AppDelegate get].m5 z:25 tag:9000];
		currentY-=spacer*2+[AppDelegate get].m5.contentSize.height/2;
		[AppDelegate get].m5.position = ccp([AppDelegate get].m5.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m4 z:25 tag:9001];
		currentY-=[AppDelegate get].m4.contentSize.height+spacer;
		[AppDelegate get].m4.position = ccp([AppDelegate get].m4.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m3 z:25 tag:9002];
		currentY-=[AppDelegate get].m3.contentSize.height+spacer;
		[AppDelegate get].m3.position = ccp([AppDelegate get].m3.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m2 z:25 tag:9003];
		currentY-=[AppDelegate get].m2.contentSize.height+spacer;
		[AppDelegate get].m2.position = ccp([AppDelegate get].m2.contentSize.width/2+4, currentY);
		
		[self addChild:[AppDelegate get].m1 z:25 tag:9004];
		currentY-=[AppDelegate get].m1.contentSize.height+spacer;
		[AppDelegate get].m1.position = ccp([AppDelegate get].m1.contentSize.width/2+4, currentY);
		
		CCSprite *bulletInset = [CCSprite spriteWithFile: @"blackinset.png"];
		[self addChild:bulletInset z:11];
		bulletInset.position = ccp(menuTray.contentSize.width/2, 26);
		
		/*CCSprite *bullet = [CCSprite spriteWithFile: @"bullet.png"];
		[self addChild:bullet z:12];
		bullet.position = ccp(menuTray.contentSize.width/2, 26);*/
		
		float infoX = 388;
		
		CCLabelTTF *infoTitle = [CCLabelTTF labelWithString:@"Recon" fontName:[AppDelegate get].clearFont fontSize:12];
		infoTitle.position = ccp(infoX,270);
		infoTitle.anchorPoint=ccp(0,0);
		[self addChild:infoTitle z:3];
		
		info1 = [CCLabelTTF labelWithString:@"When Recon" fontName:[AppDelegate get].clearFont fontSize:12];
		info1.position = ccp(infoX,250);
		info1.color = ccYELLOW;
		info1.anchorPoint=ccp(0,0);
		[self addChild:info1 z:3];
		
		info2 = [CCLabelTTF labelWithString:@"Is Enabled" fontName:[AppDelegate get].clearFont fontSize:12];
		info2.position = ccp(infoX,230);
		info2.color = ccYELLOW;
		info2.anchorPoint=ccp(0,0);
		[self addChild:info2 z:3];
		
		info3 = [CCLabelTTF labelWithString:@"Info Will" fontName:[AppDelegate get].clearFont fontSize:12];
		info3.position = ccp(infoX,210);
		info3.color = ccYELLOW;
		info3.anchorPoint=ccp(0,0);
		[self addChild:info3 z:3];
		
		info4 = [CCLabelTTF labelWithString:@"Show Here" fontName:[AppDelegate get].clearFont fontSize:12];
		info4.position = ccp(infoX,190);
		info4.color = ccYELLOW;
		info4.anchorPoint=ccp(0,0);
		[self addChild:info4 z:3];
		
		self.des = [CCLabelTTF labelWithString:@"The buttons on the left are part your wrist computer.  They are used to launch actions.  Click on each one to launch your option slider.  Each option on the slider can be clicked for further description.  Try Sandbox Mode to experiment with each of the actions.  The Recon section will list the last several actions taken during a game." dimensions:CGSizeMake(200,300) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:14];
		des.position = ccp(240,100);
		[self addChild:des z:8];
		
	}
	return self;
}

-(void) fake: (id)sender
{
	
}
-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[HelpScene node]];
}

-(void) showDescription:(NSString*)d
{
	CCLOG(@"Description:%@",d);
	[self.des setString:d];
}

- (void) dealloc {
	CCLOG(@"dealloc ComputerLayer");	
	[AppDelegate get].help = 0;
	[super dealloc];
}
@end
