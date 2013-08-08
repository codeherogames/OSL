//
//  CreditScene.m
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "CreditScene.h"


@implementation CreditScene
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
		[self addChild:bg z:0];
		[self addChild:[CreditLayer node] z:1 tag:2];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc CreditScene");
	[super dealloc];
}
@end

@implementation CreditLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		self.isTouchEnabled = YES;
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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Credits" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		CCLabelTTF *labelConcept = [CCLabelTTF labelWithString:@"Concept/Development" fontName:[AppDelegate get].menuFont fontSize:20];
		[labelConcept setColor:ccBLUE];
		labelConcept.position =ccp(label.position.x, label.position.y-label.contentSize.height-labelConcept.contentSize.height/2+10);
		[self addChild:labelConcept z:1];
		
		CCLabelTTF *labelDev = [CCLabelTTF labelWithString:@"James Dailey" fontName:[AppDelegate get].menuFont fontSize:16];
		labelDev.position = ccp(labelConcept.position.x, labelConcept.position.y-labelConcept.contentSize.height);
		[self addChild:labelDev z:1];

		CCLabelTTF *labelDesign = [CCLabelTTF labelWithString:@"Graphic Design" fontName:[AppDelegate get].menuFont fontSize:20];
		[labelDesign setColor:ccBLUE];
		labelDesign.position =ccp(labelDev.position.x, labelDev.position.y-labelDev.contentSize.height-labelDesign.contentSize.height/2);
		[self addChild:labelDesign z:1];
		
		CCLabelTTF *labelSteph = [CCLabelTTF labelWithString:@"Stephanie Lopez" fontName:[AppDelegate get].menuFont fontSize:16];
		labelSteph.position = ccp(labelDesign.position.x, labelDesign.position.y-labelDesign.contentSize.height);
		[self addChild:labelSteph z:1];

		CCLabelTTF *labelTest = [CCLabelTTF labelWithString:@"Head Beta Tester" fontName:[AppDelegate get].menuFont fontSize:20];
		[labelTest setColor:ccBLUE];
		labelTest.position =ccp(labelSteph.position.x, labelSteph.position.y-labelSteph.contentSize.height-labelTest.contentSize.height/2);
		[self addChild:labelTest z:1];
		
		CCLabelTTF *labelEthan = [CCLabelTTF labelWithString:@"Ethan Dailey" fontName:[AppDelegate get].menuFont fontSize:16];
		labelEthan.position = ccp(labelTest.position.x, labelTest.position.y-labelTest.contentSize.height);
		[self addChild:labelEthan z:1];
		
		CCLabelTTF *labelThanks = [CCLabelTTF labelWithString:@"Special Thanks" fontName:[AppDelegate get].menuFont fontSize:20];
		[labelThanks setColor:ccBLUE];
		labelThanks.position =ccp(labelEthan.position.x, labelEthan.position.y-labelEthan.contentSize.height-labelThanks.contentSize.height/2);
		[self addChild:labelThanks z:1];
		
		CCSprite *cocos = [CCSprite spriteWithFile: @"cocos2d.png"];
		[self addChild:cocos z:1];
		cocos.position = ccp(s.width/2, labelThanks.position.y-labelThanks.contentSize.height);
		
		CCLabelTTF *labelPimp = [CCLabelTTF labelWithString:@"Jennifer Dailey" fontName:[AppDelegate get].menuFont fontSize:16];
		labelPimp.position = ccp(labelPimp.contentSize.width/2+40, labelThanks.position.y-labelThanks.contentSize.height);
		[self addChild:labelPimp z:1];
		
		CCLabelTTF *labeFont = [CCLabelTTF labelWithString:@"DaFont.com" fontName:[AppDelegate get].menuFont fontSize:16];
		labeFont.position = ccp(s.width-labeFont.contentSize.width/2-64, labelThanks.position.y-labelThanks.contentSize.height);
		[self addChild:labeFont z:1];
		
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
    }
    return self;
}

-(void)setControls: (id)sender {
	[AppDelegate get].controls = (int) [sender selectedIndex];
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc CreditLayer"); 
	[super dealloc];
}

@end

