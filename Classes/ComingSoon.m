//
//  ComingSoon.m
//  OSL
//
//  Created by James Dailey on 2/17/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "ComingSoon.h"
#import "Loadout.h"

@implementation ComingSoon
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        [self addChild:[ComingSoonLayer node] z:1];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}

- (void) dealloc {
	CCLOG(@"dealloc ComingSoon"); 
	[super dealloc];
}
@end

@implementation ComingSoonLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		self.isTouchEnabled = YES;
		CGSize s = [[CCDirector sharedDirector] winSize];
		[CCMenuItemFont setFontSize:20];
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Coming Soon" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2, s.height-label.contentSize.height);
		[self addChild:label z:1];
				
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

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	CCLOG(@"dealloc ComingSoonLayer"); 
	[super dealloc];
}

@end

