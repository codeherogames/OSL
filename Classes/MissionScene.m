//
//  MissionScene.m
//  OSL
//
//  Created by James Dailey on 3/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "MissionScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "MissionSplash.h"

@implementation MissionScene

- (id) init {
	self = [super init];
	if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[AppDelegate get].currentMission = [AppDelegate get].stats.mi;
		if ([AppDelegate get].stats.mi < 6)
			[AppDelegate get].missionPage = 0;
		else if ([AppDelegate get].stats.mi < 11)
			[AppDelegate get].missionPage = 1;
		
		[AppDelegate get].help = 0;
		[AppDelegate get].multiplayer = 0;
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
		CCSprite * bg = [CCSprite spriteWithFile:@"perkscreen.png"];
		[bg setPosition:ccp(240, 160)];
		[self addChild:bg z:0];
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		
		
		[CCMenuItemFont setFontSize:20];
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
        [goldBack setPosition:ccp(88,298)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
        [self addChild:goldBack z:0];
		
		CCLabelTTF *gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=ccp(88,298);
		[self addChild:gold z:1];
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"Choose Mission" fontName:[AppDelegate get].clearFont fontSize:16];
		[title setColor:ccWHITE];
		title.position=ccp(s.width/2,294);
		[self addChild:title z:1];
		
		JDMenuItem *left = [JDMenuItem itemFromNormalImage:@"Carrow.png" selectedImage:@"Carrow.png"
													target:self
												  selector:@selector(showLeft:)];
		
		JDMenuItem *right = [JDMenuItem itemFromNormalImage:@"Carrow.png" selectedImage:@"Carrow.png"
													 target:self
												   selector:@selector(showRight:)];
		right.rotation = -180;
		CCMenu *m3 = [CCMenu menuWithItems:left,right, nil];
        [m3 alignItemsHorizontallyWithPadding: s.width-178];
        m3.position = ccp(s.width/2-2,260);
		[self addChild:m3 z:3];
		
		
		[self addChild:[MissionLayer node] z:1 tag:123];
	}
	return self;
}


-(void)showLeft: (id)sender {
	[AppDelegate get].missionPage--;
	if ([AppDelegate get].missionPage < 0)
		[AppDelegate get].missionPage = MISSIONMAX;
	[self removeChildByTag:123 cleanup:YES];
	[self addChild:[MissionLayer node] z:1 tag:123];
}

-(void)showRight: (id)sender {
	[AppDelegate get].missionPage++;
	if ([AppDelegate get].missionPage > MISSIONMAX)
		[AppDelegate get].missionPage = 0;
	[self removeChildByTag:123 cleanup:YES];
	[self addChild:[MissionLayer node] z:1 tag:123];
}

- (void) dealloc {
	CCLOG(@"dealloc MissionScene"); 
	[super dealloc];
}
@end

@implementation MissionLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		CGSize s = [[CCDirector sharedDirector] winSize];
		NSString *messageTxt;
		
		NSArray *choices;
		if ([AppDelegate get].missionPage == 0) {
			choices =  [[NSMutableArray alloc] initWithObjects:@"  RAIN ON HIS PARADE",@"  HOSTILE SPEECH",@"  TICK TICK BOOM!",@"  WHAT THE TRUCK?",@"  DEAD OF NIGHT",nil];
			messageTxt = @"Capitol Building";
		}
		else if ([AppDelegate get].missionPage == 1) {
			choices =  [[NSMutableArray alloc] initWithObjects:@"  RAIN ON HIS PARADE",@"  HOSTILE SPEECH",@"  TICK TICK BOOM!",@"  WHAT THE TRUCK?",@"  DEAD OF NIGHT",nil];
			messageTxt = @"Capitol Building - Expert";
		}
		/*else if ([AppDelegate get].missionPage == 3) {
			choices =  [[NSMutableArray alloc] initWithObjects:@"THE PENTHOUSE",@"DIRTY COP",@"THE GREAT ESCAPE",@"MASSACRE",nil];
			messageTxt = @"Russkaya Mafiya";
		}*/
			
		CCLabelTTF *message = [CCLabelTTF labelWithString:messageTxt fontName:[AppDelegate get].clearFont fontSize:22];
		message.color=ccYELLOW;
		message.position=ccp(s.width/2,260);
		[self addChild:message z:1];

		CCMenu *cm = [CCMenu menuWithItems:nil];
		for (int i=0;i<[choices count];i++) {
			TextMenuItem *c = [TextMenuItem itemFromNormalImage:@"missionmenu.png" selectedImage:@"missionmenuPressed.png" 
													  target:self
													 selector:@selector(doMission:) label:[choices objectAtIndex:i] fontSize:14];
			c.tag = ([AppDelegate get].missionPage*[choices count])+i+1;
			c.position = ccp(s.width/2,226-(i*44));
			[cm addChild:c];
			
			if (c.tag>1) { // || [AppDelegate get].missionPage > 0) {
				if ([AppDelegate get].stats.mi < c.tag) {
					CCSprite *lock = [CCSprite spriteWithFile:@"padlock.png"];
					[lock setPosition:ccp(c.position.x-c.contentSize.width/2+lock.contentSize.width/2+6,c.position.y)];
					[self addChild:lock z:1];
					c.isEnabled = NO;
				}
				else if ([AppDelegate get].stats.mi != c.tag) {
					CCSprite *lock = [CCSprite spriteWithFile:@"star.png"];
					[lock setPosition:ccp(c.position.x-c.contentSize.width/2+lock.contentSize.width/2+6,c.position.y)];
					[self addChild:lock z:1];
				}
			}
			else if ([AppDelegate get].stats.mi > 1) {
				CCSprite *lock = [CCSprite spriteWithFile:@"star.png"];
				[lock setPosition:ccp(c.position.x-c.contentSize.width/2+lock.contentSize.width/2+6,c.position.y)];
				[self addChild:lock z:1];
			}
		}
		//cm.color=ccc3(0,174,239);
		cm.position = ccp(0,0);
		//cm.scale=0.8;
		[self addChild:cm];
		[CCMenuItemFont setFontSize:16];
		[CCMenuItemFont setFontName:[AppDelegate get].clearFont];
		
		CCMenuItem *mm = [CCMenuItemFont itemFromString:@"BACK"
												 target:self
											   selector:@selector(mainMenu:)];
		CCMenu *back = [CCMenu menuWithItems:mm,nil];
        [self addChild:back];
		back.color=ccWHITE;
		[back setPosition:ccp(406, 298)];
		for (CCMenuItem *mi in back.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		[CCMenuItemFont setFontSize:16];
		
	}
    return self;
}

-(void) doMission: (id)sender {
	CCMenuItem *item = (CCMenuItem *)sender;
	[AppDelegate get].currentMission=item.tag;
	CCLOG(@"Mission %i chosen:",[AppDelegate get].currentMission);
	[[CCDirector sharedDirector] replaceScene:[MissionSplash node]];
}

-(void)mainMenu: (id)sender {
    MenuScene * ms = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene:ms];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc MissionLayer"); 
	[super dealloc];
}

@end