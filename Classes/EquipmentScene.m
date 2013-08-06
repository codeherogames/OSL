//
//  EquipmentScene.m
//  OSL
//
//  Created by James Dailey on 3/9/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "EquipmentScene.h"
#import "CustomScene.h"
#import "Rifle.h"
#import "Scope.h"
#import "Ammo.h"
#import "Extras.h"
#import "Loadout.h"
#import "GoldScene.h"
#import "PopupLayer.h"
//#import "JDMenuItem.h"

@implementation EquipmentScene

- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"Cmain.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Weapons are used in ALL game modes.  Your current weapon loadout is on the left as well as associated Power, Recoil and Accuracy.  View equipment types by selecting the buttons on the bottom.  On the right, use arrows to view different equipment descriptions and prices.  Select Purchase to unlock, Equip to use it.  Only Extras can be Unequipped, the rest are replaced when you Equip a different item." t:@"Customizing Weapons"] autorelease];
		[self addChild:popup z:10];

        EquipmentLayer *m = [EquipmentLayer node];
        [self addChild:m z:1];
        if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (winSize.height == 568)) {
            m.position = ccp(44, 0);
        }
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc EquipmentScene"); 
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

@implementation EquipmentLayer
-(id) init
{
	if( (self=[super init] )) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
        [goldBack setPosition:ccp(88,298)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
        [self addChild:goldBack z:0];
		
		gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=ccp(88,298);
		[self addChild:gold z:1];
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"Customize Weapons" fontName:[AppDelegate get].clearFont fontSize:16];
		[title setColor:ccWHITE];
		title.position=ccp(s.width/2,294);
		[self addChild:title z:1];
		
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
		[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
		
		//Background boxes
		CCSprite *blueBox = [CCSprite spriteWithFile:@"cbluebox.png"];
        [blueBox setPosition:ccp(336,218)];
        [self addChild:blueBox z:0];
		
		CCSprite *rifleRedBox = [CCSprite spriteWithFile:@"credbox2.png"];
        [rifleRedBox setPosition:ccp(s.width/3-16,240)];
        [self addChild:rifleRedBox z:0];
		
		CCSprite *scopeRedBox = [CCSprite spriteWithFile:@"credbox1.png"];
        [scopeRedBox setPosition:ccp(s.width/5+2,rifleRedBox.position.y-rifleRedBox.contentSize.height/2-scopeRedBox.contentSize.height/2+2)];
        [self addChild:scopeRedBox z:0];
		
		CCSprite *ammoRedBox = [CCSprite spriteWithFile:@"credbox1.png"];
        [ammoRedBox setPosition:ccp(scopeRedBox.position.x+scopeRedBox.contentSize.width+5,scopeRedBox.position.y)];
        [self addChild:ammoRedBox z:0];	

		CCSprite *e1RedBox = [CCSprite spriteWithFile:@"credbox1.png"];
        [e1RedBox setPosition:ccp(scopeRedBox.position.x,scopeRedBox.position.y-scopeRedBox.contentSize.height/2-e1RedBox.contentSize.height/2+2)];
        [self addChild:e1RedBox z:0];
		
		CCSprite *e2RedBox = [CCSprite spriteWithFile:@"credbox1.png"];
        [e2RedBox setPosition:ccp(ammoRedBox.position.x,e1RedBox.position.y)];
        [self addChild:e2RedBox z:0];	
		
		/*CCSprite *statInset = [CCSprite spriteWithFile:@"cinset.png"];
        [statInset setPosition:ccp(rifleRedBox.position.x,84)];
		statInset.scaleX=2.14;
		statInset.scaleY=1.2;
        [self addChild:statInset z:0];*/
		
		//set main points
		mainRifle = ccp(rifleRedBox.position.x,rifleRedBox.position.y - 10);
		mainScope = ccp(scopeRedBox.position.x,scopeRedBox.position.y - 6);
		mainAmmo = ccp(ammoRedBox.position.x,ammoRedBox.position.y - 6);
		selectPoint = ccp(blueBox.position.x,244);
		
		//Titles 
		rifleName = [CCLabelTTF labelWithString:@"Rifle Slot" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:14];
		[rifleName setColor:ccWHITE];
		rifleName.position=ccp(rifleRedBox.position.x-36,rifleRedBox.position.y+rifleRedBox.contentSize.height/2-17);
		[self addChild:rifleName z:3];
		
		scopeName = [CCLabelTTF labelWithString:@"Scope Slot" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:10];
		[scopeName setColor:ccWHITE];
		scopeName.position=ccp(scopeRedBox.position.x+10,scopeRedBox.position.y+scopeRedBox.contentSize.height/2-13);
		[self addChild:scopeName z:3];
		
		ammoName = [CCLabelTTF labelWithString:@"Ammo Slot" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:10];
		[ammoName setColor:ccWHITE];
		ammoName.position=ccp(ammoRedBox.position.x+10,ammoRedBox.position.y+ammoRedBox.contentSize.height/2-13);
		[self addChild:ammoName z:3];
		
		extra1Name = [CCLabelTTF labelWithString:@"Bipod" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:10];		
		[extra1Name setColor:ccWHITE];
		extra1Name.position=ccp(e1RedBox.position.x+10,e1RedBox.position.y+e1RedBox.contentSize.height/2-13);
		[self addChild:extra1Name z:3];
		
		extra2Name = [CCLabelTTF labelWithString:@"Attachment" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:10];
		[extra2Name setColor:ccWHITE];
		extra2Name.position=ccp(e2RedBox.position.x+10,e2RedBox.position.y+e2RedBox.contentSize.height/2-13);
		[self addChild:extra2Name z:3];		
		
		// Stats
		CCLabelTTF *pow = [CCLabelTTF labelWithString:@"POWER" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:14];
		[pow setColor:ccWHITE];
		pow.position=ccp(114,104);
		[self addChild:pow z:3];		
		for (int x=1;x<6;x++) {
			CCSprite *b = nil;
			if (x <= [AppDelegate get].loadout.po)
				b = [CCSprite spriteWithFile:@"BOX.png"];
			else
				b = [CCSprite spriteWithFile:@"BOXOUTLINE.png"];
			[b setPosition:ccp(120+(20*x),104)];
			[self addChild:b z:1 tag:(200+0+x)];
		}
		
		CCLabelTTF *rec = [CCLabelTTF labelWithString:@"RECOIL" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:14];
		[rec setColor:ccWHITE];
		rec.position=ccp(114,84);
		[self addChild:rec z:3];
		for (int x=1;x<6;x++) {
			CCSprite *b = nil;
			if (x <= [AppDelegate get].loadout.re)
				b = [CCSprite spriteWithFile:@"BOX.png"];
			else
				b = [CCSprite spriteWithFile:@"BOXOUTLINE.png"];
			[b setPosition:ccp(120+(20*x),84)];
			[self addChild:b z:1 tag:(200+10+x)];
		}
		
		CCLabelTTF *acc = [CCLabelTTF labelWithString:@"ACCURACY" dimensions:CGSizeMake(100,16) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:14];
		[acc setColor:ccWHITE];
		acc.position=ccp(114,64);
		[self addChild:acc z:3];
		for (int x=1;x<6;x++) {
			CCSprite *b = nil;
			if (x <= [AppDelegate get].loadout.ac)
				b = [CCSprite spriteWithFile:@"BOX.png"];
			else
				b = [CCSprite spriteWithFile:@"BOXOUTLINE.png"];
			[b setPosition:ccp(120+(20*x),64)];
			[self addChild:b z:1 tag:(200+20+x)];
		}
		
		JDMenuItem *left = [JDMenuItem itemFromNormalImage:@"Carrow.png" selectedImage:@"Carrow.png"
														 target:self
													   selector:@selector(showLeft:)];
		
		JDMenuItem *right = [JDMenuItem itemFromNormalImage:@"Carrow.png" selectedImage:@"Carrow.png"
														  target:self
														selector:@selector(showRight:)];
		right.rotation = -180;
		CCMenu *m3 = [CCMenu menuWithItems:left,right, nil];
        [m3 alignItemsHorizontallyWithPadding: 102.0f];
        m3.position = ccp(336,178);
		[self addChild:m3 z:3];
		
		[CCMenuItemFont setFontSize:18];
		JDMenuItem *a = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
												target:self
											  selector:@selector(showRifle:)];
		a.tag=11;
		JDMenuItem *b = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
												target:self
											  selector:@selector(showScope:)];
		b.tag=12;
		JDMenuItem *c = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
												target:self
											  selector:@selector(showAmmo:)];
		c.tag=13;
		JDMenuItem *d = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
												target:self
											  selector:@selector(showExtra:)];		
		d.tag=14;
		menu = [CCMenu menuWithItems:a,b,c,d,nil];
		[menu alignItemsHorizontallyWithPadding: 2.0f];
		menu.position = ccp(s.width/2-2,37);
		[self addChild:menu];
		a.selected;

		CCLabelTTF *rButton = [CCLabelTTF labelWithString:@"Rifles" fontName:[AppDelegate get].clearFont fontSize:16];
		[rButton setColor:ccWHITE];
		rButton.position=ccp(92,38);
		[self addChild:rButton z:1];
		CCLabelTTF *sButton = [CCLabelTTF labelWithString:@"Scopes" fontName:[AppDelegate get].clearFont fontSize:16];
		[sButton setColor:ccWHITE];
		sButton.position=ccp(190,38);
		[self addChild:sButton z:1];
		CCLabelTTF *aButton = [CCLabelTTF labelWithString:@"Ammo" fontName:[AppDelegate get].clearFont fontSize:16];
		[aButton setColor:ccWHITE];
		aButton.position=ccp(288,38);
		[self addChild:aButton z:1];
		CCLabelTTF *eButton = [CCLabelTTF labelWithString:@"Extras" fontName:[AppDelegate get].clearFont fontSize:16];
		[eButton setColor:ccWHITE];
		eButton.position=ccp(386,38);
		[self addChild:eButton z:1];
		//test
		Rifle *r = [[AppDelegate get].rifles objectAtIndex:0];
		
		itemName = [CCLabelTTF labelWithString:r.n fontName:[AppDelegate get].clearFont fontSize:14];
		[itemName setColor:ccWHITE];
		itemName.position=ccp(blueBox.position.x,208);
		[self addChild:itemName z:1];
		
		itemDescription = [CCLabelTTF labelWithString:r.d dimensions:CGSizeMake(190,200) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:14];
		[itemDescription setColor:ccWHITE];
		itemDescription.position=ccp(338,54);
		[self addChild:itemDescription z:1];
		
		JDMenuItem *purchase = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
													  target:self
													selector:@selector(purchaseEquip:)];		
		CCMenu *purchaseMenu = [CCMenu menuWithItems:purchase,nil];
		purchaseMenu.position = ccp(blueBox.position.x,72);
		[self addChild:purchaseMenu];
		
		pButton = [CCLabelTTF labelWithString:@"Equip" fontName:[AppDelegate get].clearFont fontSize:16];
		[pButton setColor:ccYELLOW];
		pButton.position=ccp(blueBox.position.x,72);
		[self addChild:pButton z:1];
		
		moneyButton = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",r.c] fontName:[AppDelegate get].clearFont fontSize:16];	
		[moneyButton setColor:ccYELLOW];
		moneyButton.position=ccp(blueBox.position.x,178);
		//moneyButton.anchorPoint=ccp(0,0);
		[self addChild:moneyButton z:1];
		if (r.c == 0)
			[moneyButton setString:[NSString stringWithFormat:@"Standard",c]];	
		
		hidden = ccp(-1000,-1000);

		//Rifles
		for (int i=0; i < [[AppDelegate get].rifles count]; i++) {
			Rifle *r = [[AppDelegate get].rifles objectAtIndex:i];
			r.position = hidden;
			int myTag = 0 + i;
			[self addChild:r z:3 tag:myTag];
			if (i == 0) {
				r.position = selectPoint;
			}
			if (i == [AppDelegate get].loadout.r) {
				rifleTop = [CCSprite spriteWithFile:r.img];
				rifleTop.position = mainRifle;
				[self addChild:rifleTop z:1];
				[rifleName setString:r.n];
			}
		}
		
		//Scopes
		for (int i=0; i < [[AppDelegate get].scopes count]; i++) {
			Scope *r = [[AppDelegate get].scopes objectAtIndex:i];
			r.position = hidden;
			int myTag = (1*10) + i;
			[self addChild:r z:3 tag:myTag];
			
			if (i == [AppDelegate get].loadout.s) {
				scopeTop = [CCSprite spriteWithFile:r.img];
				scopeTop.position = mainScope;
				scopeTop.scale=0.5;
				[self addChild:scopeTop z:1];
				[scopeName setString:r.n];
			}
		}
		
		//Ammo
		for (int i=0; i < [[AppDelegate get].ammo count]; i++) {
			Ammo *r = [[AppDelegate get].ammo objectAtIndex:i];
			r.position = hidden;
			int myTag = (2*10) + i;
			[self addChild:r z:3 tag:myTag];
			
			if (i == [AppDelegate get].loadout.a) {
				ammoTop = [CCSprite spriteWithFile:r.img];
				ammoTop.position = mainAmmo;
				ammoTop.scale=0.4;
				[self addChild:ammoTop z:1];
				[ammoName setString:r.n];
			}
		}
		
		//Extras
		extra1 = nil;
		mainScope = ccp(scopeRedBox.position.x,scopeRedBox.position.y - 6);
		
		// Set image
		Extras *ee = [[AppDelegate get].extras objectAtIndex:1];
		extra2 = [CCSprite spriteWithFile:ee.img];
		extra2.position = ccp(e2RedBox.position.x,e2RedBox.position.y - 6);
		extra2.scale=0.6;
		[self addChild:extra2 z:1];
		extra2.visible=FALSE;
		
		for (int i=0; i < [[AppDelegate get].extras count]; i++) {
			Extras *r = [[AppDelegate get].extras objectAtIndex:i];
			r.position = hidden;
			int myTag = (3*10) + i;
			[self addChild:r z:3 tag:myTag];
			
			if (i == 0) {
				extra1 = [CCSprite spriteWithFile:r.img];
				extra1.position = ccp(e1RedBox.position.x,e1RedBox.position.y - 6);
				extra1.scale=0.6;
				[self addChild:extra1 z:1];
				if ([AppDelegate get].loadout.b == 0)
					extra1.visible=FALSE;
				[extra1Name setString:r.n];
			}
			else if (i == [AppDelegate get].loadout.e) {
				CCSprite *tmpExtra = [CCSprite spriteWithFile:r.img];
				extra2.texture = tmpExtra.texture;
				extra2.textureRect = tmpExtra.textureRect;
				extra2.visible=TRUE;
				if ([AppDelegate get].loadout.e == r.x)
					extra2.visible=TRUE;
				[extra2Name setString:r.n];
			}
		}
		
	}
	return self;
}

-(void) updateStats
{
	CCLOG(@"updateStats");
	CCSprite *box = [CCSprite spriteWithFile:@"BOX.png"];
	CCSprite *empty = [CCSprite spriteWithFile:@"BOXOUTLINE.png"];
	// reset 
	[[AppDelegate get].loadout updateStats];
	for (int x=1;x<6;x++) {
		CCSprite *b = (CCSprite*) [self getChildByTag:(200+0+x)];
		if (x <= [AppDelegate get].loadout.po) {
			b.texture = box.texture;
			b.textureRect = box.textureRect;
		}
		else {
			b.texture = empty.texture;
			b.textureRect = empty.textureRect;
		}
	}	
	for (int x=1;x<6;x++) {
		CCSprite *b = (CCSprite*) [self getChildByTag:(200+10+x)];
		if (x <= [AppDelegate get].loadout.re) {
			b.texture = box.texture;
			b.textureRect = box.textureRect;
		}
		else {
			b.texture = empty.texture;
			b.textureRect = empty.textureRect;
		}
	}
	for (int x=1;x<6;x++) {
		CCSprite *b = (CCSprite*) [self getChildByTag:(200+20+x)];
		if (x <= [AppDelegate get].loadout.ac) {
			b.texture = box.texture;
			b.textureRect = box.textureRect;
		}
		else {
			b.texture = empty.texture;
			b.textureRect = empty.textureRect;
		}
	}	
}

-(void)purchaseEquip: (id)sender {
	CCLOG(@"purchaseEquip");
	if (category == 0) {
		if (pButton.string == @"Equip") {
			if (selected != 2 && [AppDelegate get].loadout.a == 2) {
				CCLOG(@"Bad combo");
				[self badCombo];
			}
			else {
				[AppDelegate get].loadout.r = selected;
				Rifle *x = [[AppDelegate get].rifles objectAtIndex:selected];
				CCSprite *new = [CCSprite spriteWithFile:x.img];
				rifleTop.texture = new.texture;
				rifleTop.textureRect = new.textureRect;
				[rifleName setString:x.n];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[self updateStats];
			}
		}
		else if (pButton.string == @"Purchase") {
			Rifle *x = [[AppDelegate get].rifles objectAtIndex:selected];
			if ([AppDelegate get].loadout.g >= x.c) {
				[AppDelegate get].loadout.g -= x.c;
				x.u = 1;
				[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
				[[AppDelegate get] writeData:@"r" d:[AppDelegate get].rifles];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[pButton setString:@"Equip"];
				//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Equipment Purchase - %@",x.n]];
			}
		}
		else { // Buy Gold
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	else if (category == 1) {
		if (pButton.string == @"Equip") {
			[AppDelegate get].loadout.s = selected;
			Scope *x = [[AppDelegate get].scopes objectAtIndex:selected];
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			scopeTop.texture = new.texture;
			scopeTop.textureRect = new.textureRect;
			[scopeName setString:x.n];
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			[self updateStats];
		}
		else if (pButton.string == @"Purchase") {
			Scope *x = [[AppDelegate get].scopes objectAtIndex:selected];
			if ([AppDelegate get].loadout.g >= x.c) {
				[AppDelegate get].loadout.g -= x.c;
				x.u = 1;
				[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
				[[AppDelegate get] writeData:@"s" d:[AppDelegate get].scopes];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[pButton setString:@"Equip"];
				//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Equipment Purchase - %@",x.n]];
			}
		}
		else { // Buy Gold
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	else if (category == 2) {
		if (pButton.string == @"Equip") {
			if (selected == 2 && [AppDelegate get].loadout.r != 2) {
				CCLOG(@"Bad combo");
				[self badCombo];
			}
			else {
				[AppDelegate get].loadout.a = selected;
				Ammo *x = [[AppDelegate get].ammo objectAtIndex:selected];
				CCSprite *new = [CCSprite spriteWithFile:x.img];
				ammoTop.texture = new.texture;
				ammoTop.textureRect = new.textureRect;
				[ammoName setString:x.n];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[self updateStats];
			}
		}
		else if (pButton.string == @"Purchase") {
			Ammo *x = [[AppDelegate get].ammo objectAtIndex:selected];
			if ([AppDelegate get].loadout.g >= x.c) {
				[AppDelegate get].loadout.g -= x.c;
				x.u = 1;
				[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
				[[AppDelegate get] writeData:@"a" d:[AppDelegate get].ammo];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[pButton setString:@"Equip"];
				//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Equipment Purchase - %@",x.n]];
			}
		}
		else { // Buy Gold
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	else if (category == 3) {
		if (pButton.string == @"Equip") {
			Extras *x = [[AppDelegate get].extras objectAtIndex:selected];
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			if (selected == 0) {
				[AppDelegate get].loadout.b = 1;
				extra1.texture = new.texture;
				extra1.textureRect = new.textureRect;
				extra1.visible=TRUE;
				[extra1Name setString:x.n];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			}
			else {
				[AppDelegate get].loadout.e = selected;
				extra2.texture = new.texture;
				extra2.textureRect = new.textureRect;
				extra2.visible=TRUE;
				[extra2Name setString:x.n];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			}
			[pButton setString:@"UnEquip"];
			[self updateStats];
		}
		else if (pButton.string == @"Purchase") {
			Extras *x = [[AppDelegate get].extras objectAtIndex:selected];
			if ([AppDelegate get].loadout.g >= x.c) {
				[AppDelegate get].loadout.g -= x.c;
				x.u = 1;
				[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
				[[AppDelegate get] writeData:@"e" d:[AppDelegate get].extras];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
				[pButton setString:@"Equip"];
				//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Equipment Purchase - %@",x.n]];
			}
		}
		else if (pButton.string == @"UnEquip") {
			if (selected == 0) {
				[AppDelegate get].loadout.b = 0;
				extra1.visible=FALSE;
				//[extra1Name setString:x.n];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			}
			else {
				[AppDelegate get].loadout.e = 0;
				extra2.visible=FALSE;
				[extra2Name setString:@"Attachment"];
				[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			}
			[pButton setString:@"Equip"];
			[self updateStats];
		}
		else { // Buy Gold
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	
}

-(void) badCombo {
	UIAlertView *add = [[UIAlertView alloc] initWithTitle: nil 
												  message: @"Only the Barret Rifle can handle 50 Caliber Ammo" 
												 delegate: self 
										cancelButtonTitle: @"Cancel"
										otherButtonTitles:nil
						]; 
	[add show]; 
	[add release]; 
	
}

-(void)showRifle: (id)sender {
	CCLOG(@"showRifle");
	for (CCMenuItem *mi in menu.children) {
		if (mi.tag == 11)
			mi.selected;
		else
			mi.unselected;
	}
	category = 0;
	selected = 0;
	[self hideAll];
	[self getChildByTag:(category*10)].position=selectPoint;
	Rifle *x = [[AppDelegate get].rifles objectAtIndex:0];
	int newTag = (category*10) + selected;
	[self updateDescriptions:x.d c:x.c n:x.n u:x.u tag:newTag];
}

-(void)showScope: (id)sender {
	CCLOG(@"showScope");
	for (CCMenuItem *mi in menu.children) {
		if (mi.tag == 12)
			mi.selected;
		else
			mi.unselected;
	}
	category = 1;
	selected = 0;
	[self hideAll];
	[self getChildByTag:(category*10)].position=selectPoint;
	Scope *x = [[AppDelegate get].scopes objectAtIndex:0];
	int newTag = (category*10) + selected;
	[self updateDescriptions:x.d c:x.c n:x.n u:x.u tag:newTag];	
}

-(void)showAmmo: (id)sender {
	CCLOG(@"showAmmo");
	for (CCMenuItem *mi in menu.children) {
		if (mi.tag == 13)
			mi.selected;
		else
			mi.unselected;
	}
	category = 2;
	selected = 0;
	[self hideAll];
	[self getChildByTag:(category*10)].position=selectPoint;
	Ammo *x = [[AppDelegate get].ammo objectAtIndex:0];
	int newTag = (category*10) + selected;
	[self updateDescriptions:x.d c:x.c n:x.n u:x.u tag:newTag];	
}

-(void)showExtra: (id)sender {
	CCLOG(@"showExtra");
	for (CCMenuItem *mi in menu.children) {
		if (mi.tag == 14)
			mi.selected;
		else
			mi.unselected;
	}
	category = 3;
	selected = 0;
	[self hideAll];
	[self getChildByTag:(category*10)].position=selectPoint;
	Extras *x = [[AppDelegate get].extras objectAtIndex:0];
	int newTag = (category*10) + selected;
	[self updateDescriptions:x.d c:x.c n:x.n u:x.u tag:newTag];	
}

-(void)hideAll {
	for (Rifle *r in [AppDelegate get].rifles) {
		r.position = hidden;
	}
	for (Scope *r in [AppDelegate get].scopes) {
		r.position = hidden;
	}
	for (Ammo *r in [AppDelegate get].ammo) {
		r.position = hidden;
	}
	for (Extras *r in [AppDelegate get].extras) {
		r.position = hidden;
	}
}
-(void)showLeft: (id)sender {
	CCLOG(@"showLeft");
	int myTag = (category*10) + selected;
	[self getChildByTag:myTag].position=hidden;
	selected--;
	int max;
	int cost,u = 0;
	NSString *des,*name;
	switch (category)
	{
        case 0: // Rifle
			max = [[AppDelegate get].rifles count];
			if (selected == -1)
				selected = max-1;
			Rifle *r = [[AppDelegate get].rifles objectAtIndex:selected];
			cost = r.c;
			des = r.d;
			name = r.n;
			u = r.u;
			break;
        case 1: // Scope
			max = [[AppDelegate get].scopes count];
			if (selected == -1)
				selected = max-1;
			Scope *s = [[AppDelegate get].scopes objectAtIndex:selected];
			cost = s.c;
			des = s.d;
			name = s.n;
			u = s.u;
			break;
        case 2: // Ammo
			max = [[AppDelegate get].ammo count];
			if (selected == -1)
				selected = max-1;
			Ammo *a = [[AppDelegate get].ammo objectAtIndex:selected];
			cost = a.c;
			des = a.d;
			name = a.n;
			u = a.u;
			break;
        case 3: // Extra
			max = [[AppDelegate get].extras count];
			if (selected == -1)
				selected = max-1;
			Extras *e = [[AppDelegate get].extras objectAtIndex:selected];
			cost = e.c;
			des = e.d;
			name = e.n;
			u = e.u;
			break;
			
	}
	int newTag = (category*10) + selected;
	[self getChildByTag:newTag].position=selectPoint;
	[self updateDescriptions:des c:cost n:name u:u tag:newTag];
}

-(void)showRight: (id)sender {
	CCLOG(@"showRight");
	int myTag = (category*10) + selected;
	[self getChildByTag:myTag].position=hidden;
	selected++;
	int max;
	int cost,u = 0;
	NSString *des,*name;
	switch (category)
	{
        case 0: // Rifle
			max = [[AppDelegate get].rifles count];
			if (selected == max)
				selected = 0;
			Rifle *r = [[AppDelegate get].rifles objectAtIndex:selected];
			cost = r.c;
			des = r.d;
			name = r.n;
			u = r.u;
			break;
		case 1: // Scope
			max = [[AppDelegate get].scopes count];
			if (selected == max)
				selected = 0;
			Scope *s = [[AppDelegate get].scopes objectAtIndex:selected];
			cost = s.c;
			des = s.d;
			name = s.n;
			u = s.u;
			break;
        case 2: // Ammo
			max = [[AppDelegate get].ammo count];
			if (selected == max)
				selected = 0;
			Ammo *a = [[AppDelegate get].ammo objectAtIndex:selected];
			cost = a.c;
			des = a.d;
			name = a.n;
			u = a.u;
			break;
        case 3: // Extra
			max = [[AppDelegate get].extras count];
			if (selected == max)
				selected = 0;
			Extras *e = [[AppDelegate get].extras objectAtIndex:selected];
			cost = e.c;
			des = e.d;
			name = e.n;
			u = e.u;
			break;
	}

	int newTag = (category*10) + selected;
	[self getChildByTag:newTag].position=selectPoint;
	[self updateDescriptions:des c:cost n:name u:u tag:newTag];
}

-(void) updateDescriptions:(NSString*)d c:(int)c n:(NSString*)n u:(int)u tag:(int)tag
{
	if (c != 0)
		[moneyButton setString:[NSString stringWithFormat:@"%iG",c]];
	else
		[moneyButton setString:[NSString stringWithFormat:@"Standard",c]];

	[itemDescription setString:d];
	[itemName setString:n];

	if (u == 0) {
		if (c > [AppDelegate get].loadout.g) {
			[pButton setString:@"Buy Gold"];
		}
		else {
			[pButton setString:@"Purchase"];
		}
	}
	else if (u == 1) { //test if equipped so user can remove
		if(tag > 29) {
			if (tag - 30 == 0 && [AppDelegate get].loadout.b == 1) {
				[pButton setString:@"UnEquip"];
			}
			else if (tag - 30 > 0 && tag - 30 == [AppDelegate get].loadout.e) {
				[pButton setString:@"UnEquip"];
			}
			else {
				[pButton setString:@"Equip"];
			}
		}
		else {
			[pButton setString:@"Equip"];
		}
	}
}

-(void)mainMenu: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] upload];
	[[CCDirector sharedDirector] replaceScene:[CustomScene node]];
}

- (void) dealloc {
	CCLOG(@"dealloc EquipmentLayer"); 
	[super dealloc];
}
@end
