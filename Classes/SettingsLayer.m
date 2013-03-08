//
//  SettingsScene.m
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "SettingsScene.h"

@implementation SettingsScene
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
		[self addChild:[SettingsLayer node] z:1 tag:2];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc SettingsScene");
	[super dealloc];
}
@end

@implementation SettingsLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Settings" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		CCLabelTTF *labelControls = [CCLabelTTF labelWithString:@"Controls" fontName:[AppDelegate get].menuFont fontSize:20];
		[labelControls setColor:ccBLUE];
		labelControls.position =ccp(label.position.x, label.position.y-label.contentSize.height-labelControls.contentSize.height/2);
		[self addChild:labelControls z:1];
		
		[CCMenuItemFont setFontSize:16];
		CCMenuItemToggle *controls = [CCMenuItemToggle itemWithTarget:self selector:@selector(setControls:) items:
		 [CCMenuItemFont itemFromString:@"Tilt"],
		 [CCMenuItemFont itemFromString:@"Joystick"],
		 nil];
		[controls setSelectedIndex: [AppDelegate get].controls];
		
		CCMenu *menu = [CCMenu menuWithItems:controls, nil];
		[menu alignItemsVerticallyWithPadding: 20.0f];
		menu.position = ccp(labelControls.position.x, labelControls.position.y-labelControls.contentSize.height);
		[self addChild:menu z:4];
		for (CCMenuItem *mi in menu.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
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
		[back setPosition:ccp(448, 300)];
    }
    return self;
}

-(void)setControls: (id)sender {

	[AppDelegate get].allowRotate = (int) [sender selectedIndex];
	[AppDelegate get].controls = (int) [sender selectedIndex];
}
-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc SettingsLayer"); 
	[super dealloc];
}

@end

