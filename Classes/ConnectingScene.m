//
//  ConnectingScene.m
//  OSL
//
//  Created by James Dailey on 5/21/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "ConnectingScene.h"
#import "MultiScene.h"
#import "MenuScene.h"

@implementation ConnectingScene
- (id) init {
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(s.width/2, s.height/2)];
        [self addChild:bg z:0];
		[CCMenuItemFont setFontSize:20];
		
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Connecting..." fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		[CCMenuItemFont setFontSize:16];
		CCMenuItem *mm = [CCMenuItemFont itemFromString:@"Cancel"
												 target:self
											   selector:@selector(mainMenu:)];
		CCMenu *back = [CCMenu menuWithItems:mm,nil];
		[back setColor:ccBLACK];
        [self addChild:back];
		[back setPosition:ccp(436, 300)];
		for (CCMenuItem *mi in back.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		
		
    }
    return self;
}

-(void) hideWait 
{
	[AppDelegate get].gameState = NOGAME;
	[[CCDirector sharedDirector] replaceScene:[MultiScene node]];
}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

- (void) dealloc {
	CCLOG(@"dealloc ConnectingScene"); 
	[super dealloc];
}
@end