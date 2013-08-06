
// Import the interfaces
#import "CustomScene.h"
#import "MenuScene.h"
#import "EquipmentScene.h"
#import "PerkScene.h"
#import "GoldScene.h"

@implementation CustomScene

- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"menuBackground.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
        [self addChild:[CustomLayer node] z:1 tag:1];
		
    }
    return self;
}

-(void) customPop {
	[[self getChildByTag:1] customPop];
}

-(void) go {
	[[self getChildByTag:1] go];
}

- (void) dealloc {
	CCLOG(@"dealloc CustomScene"); 
	[super dealloc];
}
@end

@implementation CustomLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
		[goldBack setPosition:ccp(32,308)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
		[self addChild:goldBack z:0];
		gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=goldBack.position;
		[self addChild:gold z:1];
		
		[CCMenuItemFont setFontSize:20];
        //[CCMenuItemFont setFontName:@"Helvetica"];
		// Controls
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Customize" fontName:[AppDelegate get].menuFont fontSize:30];
		[label setColor:ccYELLOW];
		label.position =ccp(s.width/2-20, s.height-label.contentSize.height);
		[self addChild:label z:1];
		
		
		[CCMenuItemFont setFontSize:18];
		TextMenuItem *t = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													 target:self
												   selector:@selector(showTap:) label:@"Earn Gold"];
		t.tag = 456;
		
		TextMenuItem *g = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(gold:) label:@"Buy Gold"];
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(equipment:) label:@"Weapons"];
		TextMenuItem *b = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
													  target:self
													selector:@selector(perks:) label:@"Perks"];
	
		CCMenu *menu;
		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending) {
			menu = [CCMenu menuWithItems:t,g,a,b,nil];
		}
		else {
			menu = [CCMenu menuWithItems:g,a,b,nil];
		}
			
		[menu alignItemsVerticallyWithPadding: 20.0f];
		menu.position = ccp(s.width/2-16,s.height/2-20);
		[self addChild:menu];
			
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
		
		if ([AppDelegate get].tjg > 0)
			[self customPop];
	}
    return self;
}

-(void)showTap: (id)sender {
	[TapjoyConnect showOffersWithViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

-(void) customPop {
	UIAlertView *add = [[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Redeem %i Gold",[AppDelegate get].tjg] 
												  message: [NSString stringWithFormat:@"You earned %i Gold!\nWould you like to claim it now?  Transaction may take a couple seconds.  Please stay on this screen until your Gold increases.",[AppDelegate get].tjg] 
												 delegate: self 
										cancelButtonTitle: @"No"
										otherButtonTitles:nil
						]; 
	[add addButtonWithTitle:@"Yes"];
	[add show]; 
	[add release]; 
	
}

- (void)alertView: (UIAlertView * ) alertView clickedButtonAtIndex : (NSInteger ) buttonIndex 
{ 
	CCLOG(@"Button index %i",buttonIndex);
	if (buttonIndex != 0) {
		[TapjoyConnect spendTapPoints:[AppDelegate get].tjg];
		[[NSNotificationCenter defaultCenter] addObserver:[UIApplication sharedApplication].delegate selector:@selector(getUpdatedPoints:) name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	}
}

-(void)go {
	CCLOG(@"go");
	// Add Gold but make sure transaction went through first
	oldG = [AppDelegate get].loadout.g;
	[AppDelegate get].loadout.g += [AppDelegate get].tjg;
	[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
	[AppDelegate get].tjg = 0;
	[self schedule: @selector(updateG) interval: 0.05];
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

-(void)equipment: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[EquipmentScene node]];
}

-(void)perks: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[PerkScene node]];
}

-(void)headgear: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

-(void)gold: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc CustomScene"); 
	[super dealloc];
}

@end