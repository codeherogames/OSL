//
//  PerkScene.m
//  PixelSnipe
//
//  Created by James Dailey on 1/12/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "PerkScene.h"
#import "CustomScene.h"
#import "Perk.h"
#import "GoldScene.h"
#import "PopupLayer.h"

@implementation PerkScene
- (id) init {
	//CCLOG(@"perk scene called"); 
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"perkscreen.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
        PerkLayer *m = [PerkLayer node];
        [self addChild:m z:1];
        if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (winSize.height == 568)) {
            m.position = ccp(44, 0);
        }
		if ([AppDelegate get].lowRes == 1)
			[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		CCLayer *popup = [[[PopupLayer alloc] initWithMessage:@"Perks are used in multiplayer and sandbox modes.  They can give you an ability or be a detriment to your opponent.  Locked perks are dimmed until unlocked.  Choose a perk to see the description in the bottom left.  Purchase the perk and then Enable the perk to use it.  You can assign perks to unlocked slots on the bottom right." t:@"What are Perks?"] autorelease];
		[self addChild:popup z:10];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc PerkScene"); 
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

@implementation PerkLayer
- (id) init {
    self = [super init];
    if (self != nil) {		
		selected = 1;
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
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"Customize Perks" fontName:[AppDelegate get].clearFont fontSize:16];
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
		
		int columns = 8;
		CGPoint pos = ccp(22,254);
		float y = 0;
		float x = 0;
		for (int i=0; i<[[AppDelegate get].perks count];i++) {
			Perk *pk = [[AppDelegate get].perks objectAtIndex:i];
			x++;
			if (i>0 && i % columns == 0) {
				y++;
				x=1;
			}
			[pk reset];
			pk.scale = 0.8;
			pk.position = ccp(pos.x + (48*x),pos.y-(y*48));
			[self addChild:pk];
		}
		Perk *pk1 = [[AppDelegate get].perks objectAtIndex:0];
		[pk1 showHighlight];
		pk1.opacity=255;
		
		CCSprite *pinset = [CCSprite spriteWithFile:@"perkinset.png"];
        [pinset setPosition:ccp(146,78)];
        [self addChild:pinset z:0];

		/////////// Slots
		slot1 = [CCSprite spriteWithFile:@"emptyslot.png"];
        [slot1 setPosition:ccp(282,52)];
        [self addChild:slot1 z:1];
		slot1Text = [CCLabelTTF labelWithString:@"\nEmpty\n" dimensions:CGSizeMake(50,50) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:14];
		[slot1Text setColor:ccYELLOW];
		slot1Text.position=ccp(slot1.position.x,slot1.position.y);
		[self addChild:slot1Text z:2];
		JDMenuItem *slot1MenuItem = [JDMenuItem itemFromNormalImage:@"emptyslot.png" selectedImage:@"emptyslot.png" 
															 target:self
														   selector:@selector(purchaseSlot1:)];		
		CCMenu *slot1Menu = [CCMenu menuWithItems:slot1MenuItem,nil];
		slot1Menu.position = ccp(slot1.position.x,slot1.position.y);
		[self addChild:slot1Menu z:0];
		
		if ([AppDelegate get].loadout.s1 > 0) {
			Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s1-1];
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			slot1.texture = new.texture;
			slot1.textureRect = new.textureRect;
			slot1Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s1 = x.x;
		}
		
		slot2 = [CCSprite spriteWithFile:@"emptyslot.png"];		
        [slot2 setPosition:ccp(slot1.position.x+slot1.contentSize.width + 8,slot1.position.y)];
        [self addChild:slot2 z:1];
		slot2Text = [CCLabelTTF labelWithString:@"\nEmpty\n" dimensions:CGSizeMake(50,50) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:14];
		[slot2Text setColor:ccYELLOW];
		slot2Text.position=ccp(slot2.position.x,slot2.position.y);
		[self addChild:slot2Text z:2];	
		//if ([AppDelegate get].loadout.s2 == -1) {
			JDMenuItem *slot2MenuItem = [JDMenuItem itemFromNormalImage:@"emptyslot.png" selectedImage:@"emptyslot.png" 
																	  target:self
																	selector:@selector(purchaseSlot2:)];		
			CCMenu *slot2Menu = [CCMenu menuWithItems:slot2MenuItem,nil];
			slot2Menu.position = ccp(slot1.position.x+slot1.contentSize.width + 8,slot1.position.y);
			[self addChild:slot2Menu z:0];
			if ([AppDelegate get].loadout.s2 > -1)
				[slot2Text setString:@"\nEmpty\n"];
			else if ([AppDelegate get].loadout.g>=1000)
				[slot2Text setString:@"Unlock for 1000G"];
			else
				[slot2Text setString:@"Touch to Buy Gold"];
		//}
		if ([AppDelegate get].loadout.s2 > 0) {
			Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s2-1];
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			slot2.texture = new.texture;
			slot2.textureRect = new.textureRect;
			slot2Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s2 = x.x;
		}
		
		slot3 = [CCSprite spriteWithFile:@"emptyslot.png"];
        [slot3 setPosition:ccp(slot2.position.x+slot2.contentSize.width + 8,slot1.position.y)];
        [self addChild:slot3 z:1];
		slot3Text = [CCLabelTTF labelWithString:@"\nEmpty\n" dimensions:CGSizeMake(50,50) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:14];
		[slot3Text setColor:ccYELLOW];
		slot3Text.position=ccp(slot3.position.x,slot3.position.y);
		[self addChild:slot3Text z:2];
		//if ([AppDelegate get].loadout.s3 == -1) {
			JDMenuItem *slot3MenuItem = [JDMenuItem itemFromNormalImage:@"emptyslot.png" selectedImage:@"emptyslot.png" 
																	  target:self
																	selector:@selector(purchaseSlot3:)];		
			CCMenu *slot3Menu = [CCMenu menuWithItems:slot3MenuItem,nil];
			slot3Menu.position = ccp(slot2.position.x+slot2.contentSize.width + 8,slot2.position.y);
			[self addChild:slot3Menu z:0];
	
			if ([AppDelegate get].loadout.s3 > -1)
				[slot3Text setString:@"\nEmpty\n"];
			else if ([AppDelegate get].loadout.g>=1000)
				[slot3Text setString:@"Unlock for 1000G"];
			else
				[slot3Text setString:@"Touch to Buy Gold"];
		//}
		if ([AppDelegate get].loadout.s3 > 0) {
			Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s3-1];
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			slot3.texture = new.texture;
			slot3.textureRect = new.textureRect;
			slot3Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s3 = x.x;
		}
		
		CCLabelTTF *slot1Label = [CCLabelTTF labelWithString:@"Slot 1" fontName:[AppDelegate get].clearFont fontSize:16];
		[slot1Label setColor:ccWHITE];
		slot1Label.position=ccp(slot1.position.x,slot1.position.y+slot1.contentSize.height/2 + 8);
		[self addChild:slot1Label z:1];
		CCLabelTTF *slot2Label = [CCLabelTTF labelWithString:@"Slot 2" fontName:[AppDelegate get].clearFont fontSize:16];
		[slot2Label setColor:ccWHITE];
		slot2Label.position=ccp(slot2.position.x,slot2.position.y+slot2.contentSize.height/2 + 8);
		[self addChild:slot2Label z:1];
		CCLabelTTF *slot3Label = [CCLabelTTF labelWithString:@"Slot 3" fontName:[AppDelegate get].clearFont fontSize:16];
		[slot3Label setColor:ccWHITE];
		slot3Label.position=ccp(slot3.position.x,slot3.position.y+slot3.contentSize.height/2 + 8);
		[self addChild:slot3Label z:1];
		
		/////////////
		
		preview = [CCSprite spriteWithFile:pk1.img];
		preview.position = ccp(78,96);
		[self addChild:preview z:1];
		
		name = [CCLabelTTF labelWithString:pk1.n fontName:[AppDelegate get].clearFont fontSize:18];
		[name setColor:ccWHITE];
		name.anchorPoint=ccp(0,0);
		name.position=ccp(preview.position.x + preview.contentSize.width/2 + 4,preview.position.y+8);
		[self addChild:name z:1];

		description = [CCLabelTTF labelWithString:pk1.d dimensions:CGSizeMake(190,200) alignment:UITextAlignmentLeft fontName:[AppDelegate get].clearFont fontSize:14];
		[description setColor:ccWHITE];
		//name.anchorPoint=ccp(0,0);
		description.position=ccp(preview.position.x+70,-34);
		[self addChild:description z:1];
		
		JDMenuItem *purchase = [JDMenuItem itemFromNormalImage:@"Cbutton.png" selectedImage:@"Cbuttonhighlighted.png"
															 target:self
														   selector:@selector(purchaseEquip:)];		
		CCMenu *purchaseMenu = [CCMenu menuWithItems:purchase,nil];
		purchaseMenu.position = ccp(preview.position.x + preview.contentSize.width + 26,preview.position.y-8);
		[self addChild:purchaseMenu];
		
		NSString *pkStatus = @"Equip";
		if (pk1.s == 0) {
			if (pk1.c > [AppDelegate get].loadout.g)
				pkStatus = @"Buy Gold";
			else
				pkStatus = @"Purchase";
		}
		else if ([AppDelegate get].loadout.s1 == pk1.x || [AppDelegate get].loadout.s2 == pk1.x || [AppDelegate get].loadout.s3 == pk1.x) {
			pkStatus = @"UnEquip";
		}
		pButton = [CCLabelTTF labelWithString:pkStatus fontName:[AppDelegate get].clearFont fontSize:16];
		[pButton setColor:ccYELLOW];
		pButton.position=ccp(purchaseMenu.position.x,purchaseMenu.position.y);
		[self addChild:pButton z:1];	
		
		CCLabelTTF *myP = [CCLabelTTF labelWithString:@"300G" fontName:[AppDelegate get].clearFont fontSize:16];
		[myP setColor:ccYELLOW];
		myP.position=ccp(purchaseMenu.position.x+70,purchaseMenu.position.y);
		[self addChild:myP z:1];
    }
    return self;
}

-(void)purchaseEquip: (id)sender {
	CCLOG(@"purchaseEquip:%@",pButton.string);
	Perk *x = [[AppDelegate get].perks objectAtIndex:selected-1];
	if (pButton.string == @"Equip") {
		if ([AppDelegate get].loadout.s2 != -1 || [AppDelegate get].loadout.s3 != -1) {
			//NSString *message = @"Choose a Slot";
			UIAlertView *add = [[UIAlertView alloc] initWithTitle: nil 
														  message: @"Choose a Slot" 
														 delegate: self 
												cancelButtonTitle: @"Cancel"
								otherButtonTitles:nil
								]; 
			[add addButtonWithTitle:@"Slot 1"];
			if ([AppDelegate get].loadout.s2 != -1)
				[add addButtonWithTitle:@"Slot 2"];
			if ([AppDelegate get].loadout.s3 != -1)
				[add addButtonWithTitle:@"Slot 3"];
			[add show]; 
			[add release]; 
		}
		else {
			CCSprite *new = [CCSprite spriteWithFile:x.img];
			slot1.texture = new.texture;
			slot1.textureRect = new.textureRect;
			slot1Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s1 = x.x;
			[pButton setString:@"UnEquip"];	
		}
	}
	else if (pButton.string == @"Purchase") {
		if ([AppDelegate get].loadout.g >= x.c) {
			[AppDelegate get].loadout.g -= x.c;
			x.s = 1;
			[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
			[pButton setString:@"Equip"];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Perk-Purchase" attributes:[NSDictionary dictionaryWithObjectsAndKeys: @"id", x.n, nil]];
			//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"Perk Purchase - %@",x.n]];
		}
	}
	else if (pButton.string == @"UnEquip") {
		CCSprite *new = [CCSprite spriteWithFile:@"emptyslot.png"];
		if ([AppDelegate get].loadout.s1 == x.x) {
			slot1.texture = new.texture;
			slot1.textureRect = new.textureRect;
			slot1Text.position=slot1.position;
			[AppDelegate get].loadout.s1 = 0;
		}
		else if ([AppDelegate get].loadout.s2 == x.x) {
			slot2.texture = new.texture;
			slot2.textureRect = new.textureRect;
			slot2Text.position=slot2.position;
			[AppDelegate get].loadout.s2 = 0;
		}
		else if ([AppDelegate get].loadout.s3 == x.x) {
			slot3.texture = new.texture;
			slot3.textureRect = new.textureRect;
			slot3Text.position=slot3.position;
			[AppDelegate get].loadout.s3 = 0;
		}		
		//save slot and perk info
		[pButton setString:@"Equip"];
	}
	else { // Buy Gold
		[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
	}
	if ([AppDelegate get].loadout.g<1000) {
		if ([AppDelegate get].loadout.s2 == -1)
			[slot2Text setString:@"Touch to Buy Gold"];
		if ([AppDelegate get].loadout.s3 == -1)
			[slot3Text setString:@"Touch to Buy Gold"];
	}
}

- (void)alertView: (UIAlertView * ) alertView clickedButtonAtIndex : (NSInteger ) buttonIndex 
{ 
	CCLOG(@"Button index %i",buttonIndex);
	if (buttonIndex != 0) {
	Perk *x = [[AppDelegate get].perks objectAtIndex:selected-1];
	CCSprite *new = [CCSprite spriteWithFile:x.img];
	if (buttonIndex == 1) {
		slot1.texture = new.texture;
		slot1.textureRect = new.textureRect;
		slot1Text.position=ccp(-1000,-1000);
		[AppDelegate get].loadout.s1 = x.x;
		
		if ([AppDelegate get].loadout.s2 == selected) {
			CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
			slot2.texture = empty.texture;
			slot2.textureRect = empty.textureRect;
			slot2Text.position=slot2.position;
			[AppDelegate get].loadout.s2 = 0;
		}
		if ([AppDelegate get].loadout.s3 == selected) {
			CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
			slot3.texture = empty.texture;
			slot3.textureRect = empty.textureRect;
			slot3Text.position=slot3.position;
			[AppDelegate get].loadout.s3 = 0;
		}
	}
	else if (buttonIndex == 2) {
		if ([AppDelegate get].loadout.s2 != -1) { //if 2 is empty
			slot2.texture = new.texture;
			slot2.textureRect = new.textureRect;
			slot2Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s2 = x.x;
			
			if ([AppDelegate get].loadout.s1 == selected) {
				CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
				slot1.texture = empty.texture;
				slot1.textureRect = empty.textureRect;
				slot1Text.position=slot1.position;
				[AppDelegate get].loadout.s1 = 0;
			}
			if ([AppDelegate get].loadout.s3 == selected) {
				CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
				slot3.texture = empty.texture;
				slot3.textureRect = empty.textureRect;
				slot3Text.position=slot3.position;
				[AppDelegate get].loadout.s3 = 0;
			}
		}
		else {
			slot3.texture = new.texture;
			slot3.textureRect = new.textureRect;
			slot3Text.position=ccp(-1000,-1000);
			[AppDelegate get].loadout.s3 = x.x;
			
			if ([AppDelegate get].loadout.s2 == selected) {
				CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
				slot2.texture = empty.texture;
				slot2.textureRect = empty.textureRect;
				slot2Text.position=slot2.position;
				[AppDelegate get].loadout.s2 = 0;
			}
			if ([AppDelegate get].loadout.s1 == selected) {
				CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
				slot1.texture = empty.texture;
				slot1.textureRect = empty.textureRect;
				slot1Text.position=slot1.position;
				[AppDelegate get].loadout.s1 = 0;
			}			
		}
	}
	else if (buttonIndex == 3) {
		slot3.texture = new.texture;
		slot3.textureRect = new.textureRect;
		slot3Text.position=ccp(-1000,-1000);
		[AppDelegate get].loadout.s3 = x.x;
		
		if ([AppDelegate get].loadout.s2 == selected) {
			CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
			slot2.texture = empty.texture;
			slot2.textureRect = empty.textureRect;
			slot2Text.position=slot2.position;
			[AppDelegate get].loadout.s2 = 0;
		}
		if ([AppDelegate get].loadout.s1 == selected) {
			CCSprite *empty = [CCSprite spriteWithFile:@"emptyslot.png"];
			slot1.texture = empty.texture;
			slot1.textureRect = empty.textureRect;
			slot1Text.position=slot1.position;
			[AppDelegate get].loadout.s1 = 0;
		}
	}
	[pButton setString:@"UnEquip"];
	}
}

-(void)purchaseSlot1: (id)sender {
	CCLOG(@"purchase slot 1");
	if ([AppDelegate get].loadout.s1 > 0) {
		Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s1-1];
		[self showInfo:x.x];
	}
}
-(void)purchaseSlot2: (id)sender {
	CCLOG(@"purchase slot 2");
	if ([AppDelegate get].loadout.s2 == -1) {
		if ([AppDelegate get].loadout.g >= 1000) {
			[AppDelegate get].loadout.g -= 1000;
			[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
			[AppDelegate get].loadout.s2 = 1;
			[slot2Text setString:@"\nEmpty\n"];
			if ([AppDelegate get].loadout.g<1000) {
				if ([AppDelegate get].loadout.s3 == -1)
					[slot3Text setString:@"Touch to Buy Gold"];
			}
			/*if ([AppDelegate get].loadout.s3 == 1)
				[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Perk-Purchase: BothSlots"];
			else
				[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Perk-Purchase: Slot2"];*/
		}
		else {
			[[AppDelegate get] writeData:@"p" d:[AppDelegate get].perks];
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	else if ([AppDelegate get].loadout.s2 > 0) {
		Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s2-1];
		[self showInfo:x.x];
	}
}

-(void)purchaseSlot3: (id)sender {
	CCLOG(@"purchase slot 3");
	if ([AppDelegate get].loadout.s3 == -1) {
		if ([AppDelegate get].loadout.g >= 1000) {
			[AppDelegate get].loadout.g -= 1000;
			[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
			[AppDelegate get].loadout.s3 = 1;
			[slot3Text setString:@"\nEmpty\n"];
			if ([AppDelegate get].loadout.g<1000) {
				if ([AppDelegate get].loadout.s2 == -1)
					[slot2Text setString:@"Touch to Buy Gold"];
			}
			/*if ([AppDelegate get].loadout.s2 == 1)
				[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Perk-Purchase: BothSlots"];
			else
				[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Perk-Purchase: Slot3"];*/
		}
		else {
			[[AppDelegate get] writeData:@"p" d:[AppDelegate get].perks];
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			//[[LocalyticsSession sharedLocalyticsSession] upload];
			[[CCDirector sharedDirector] replaceScene:[GoldScene node]];
		}
	}
	else if ([AppDelegate get].loadout.s3 > 0) {
		Perk *x = [[AppDelegate get].perks objectAtIndex:[AppDelegate get].loadout.s3-1];
		[self showInfo:x.x];
	}
}

-(void)showInfo: (int) i {
	selected = i;
	Perk *pk = [[AppDelegate get].perks objectAtIndex:i-1];
	CCSprite *tmp = [CCSprite spriteWithFile:pk.img];
	preview.texture = tmp.texture;
	preview.textureRect = tmp.textureRect;
	[name setString:pk.n];
	[description setString:pk.d];
	
	// Add logic for unequip
	NSString *pkStatus = @"Equip";
	if (pk.s == 0) {
		if (pk.c > [AppDelegate get].loadout.g)
			pkStatus = @"Buy Gold";
		else
			pkStatus = @"Purchase";
	}
	else if ([AppDelegate get].loadout.s1 == selected || [AppDelegate get].loadout.s2 == selected || [AppDelegate get].loadout.s3 == selected) {
		pkStatus = @"UnEquip";
	}
	[pButton setString:pkStatus];
}

-(void)mainMenu: (id)sender {
	[[AppDelegate get] writeData:@"p" d:[AppDelegate get].perks];
	[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
	//[[LocalyticsSession sharedLocalyticsSession] upload];
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[[CCDirector sharedDirector] replaceScene:[CustomScene node]];
}

- (void) dealloc {
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	CCLOG(@"dealloc PerkScene"); 
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[super dealloc];
}

@end
