//
//  GoldScene.m
//  OSL
//
//  Created by James Dailey on 3/14/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "GoldScene.h"
#import "CustomScene.h"
#import "MyIAPHelper.h"
#import "Reachability.h"

@implementation GoldScene
- (id) init {
	//CCLOG(@"perk scene called"); 
    self = [super init];
    if (self != nil) {
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"GoldScene"];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"perkscreen.png"];
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        [bg setPosition:ccp(winSize.height/2, winSize.width/2)];
        bg.scaleX = winSize.height/bg.contentSize.width;
        [self addChild:bg z:0];
        [self addChild:[GoldLayer node] z:1];
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc GoldScene"); 
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[super dealloc];
}
@end

@implementation GoldLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		[NSObject cancelPreviousPerformRequestsWithTarget:self]; 
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
		CCSprite *goldBack = [CCSprite spriteWithFile:@"cinset.png"];
        [goldBack setPosition:ccp(88,298)];
		goldBack.scaleX=0.8;
		goldBack.scaleY=0.6;
        [self addChild:goldBack z:0];
		
		gold = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g] fontName:[AppDelegate get].clearFont fontSize:16];
		[gold setColor:ccYELLOW];
		gold.position=ccp(88,298);
		[self addChild:gold z:1];
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"Purchase Gold" fontName:[AppDelegate get].clearFont fontSize:16];
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
		[back setPosition:ccp(s.width/2+166+((s.width-480)/2), 298)];
		for (CCMenuItem *mi in back.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		
		
		message = [CCLabelTTF labelWithString:@"Loading Products" fontName:[AppDelegate get].clearFont fontSize:22];
		message.position=ccp(s.width/2,260);
		[self addChild:message z:1];
		
		id fade = [CCFadeOut actionWithDuration:1.0f];
		id fade_back = [fade reverse];
		id seq = [CCSequence actions: fade, fade_back, nil];
		fadeAction = [[CCRepeatForever actionWithAction:seq] retain];
		[message runAction:fadeAction];
		if ([MyIAPHelper sharedHelper].products == nil) {
			CCLOG(@"NO products!!!");
			Reachability *reach = [[Reachability reachabilityForInternetConnection] retain];	
			NetworkStatus netStatus = [reach currentReachabilityStatus];    
			[reach release];
			if (netStatus == NotReachable) {        
				CCLOG(@"No internet connection!");        
			} else {        
				if ([MyIAPHelper sharedHelper].products == nil) {
					[[MyIAPHelper sharedHelper] requestProducts];
					//self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
					[self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
					
				}        
			}
		}
		else {
			[self showProducts];
		}
    }
    return self;
}
//////////////////////////////////
- (void)timeout:(id)arg {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Gold-Error" attributes:[NSDictionary dictionaryWithObjectsAndKeys: @"error", @"Timeout", nil]];
	[NSObject cancelPreviousPerformRequestsWithTarget:self]; 
	CCLOG(@"Timed Out Connecting to IAP");
	[message stopAllActions];
	message.opacity=255;
	[message setString:@"Transaction Timed Out"];
}

- (void)productsLoaded:(NSNotification *)notification 
{
	[self showProducts];
}

- (void)showProducts 
{
	CGSize s = [[CCDirector sharedDirector] winSize];
    CCLOG(@"ProductsLoaded: %i",[[MyIAPHelper sharedHelper].products count]);
	if ([[MyIAPHelper sharedHelper].products count] > 0) {
		[message stopAllActions];
		message.opacity=255;
		[message setString:@"Choose Gold Amount"];
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		//[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		
		[CCMenuItemFont setFontName:[AppDelegate get].clearFont];
		[CCMenuItemFont setFontSize:24];
		goldMenu = [CCMenu menuWithItems:nil];
		for (int i=0; i<[[MyIAPHelper sharedHelper].products count]; i++) {
			SKProduct *product = [[MyIAPHelper sharedHelper].products objectAtIndex:i];
			[numberFormatter setLocale:product.priceLocale];
			CCLOG(@"product: %@ price:%@ id:%@ des:%@",product.localizedTitle,[numberFormatter stringFromNumber:product.price],product.productIdentifier,product.localizedDescription);
			CCMenuItemFont *p = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%@G - %@",product.localizedTitle,[numberFormatter stringFromNumber:product.price]]
														target:self
													  selector:@selector(doPurchase:)];
			p.tag = [product.localizedTitle intValue];	
			[goldMenu addChild:p];
		}
		goldMenu.color=ccYELLOW;
		[goldMenu alignItemsVerticallyWithPadding: 30.0f];
		goldMenu.position = ccp(s.width/2,s.height/2-26);
		[self addChild:goldMenu];
	}
}

- (void)productPurchased:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self]; 
	/*NSString *productIdentifier = (NSString *) notification.object;
	CCLOG(@"Purchased: %@", productIdentifier);
	int g = 0;
	if ([productIdentifier isEqualToString:@"osl1000"])
		g=1000;
	else if ([productIdentifier isEqualToString:@"osl2500"])
		g=2500;
	else if ([productIdentifier isEqualToString:@"osl5000"])
		g=5000;
	else if ([productIdentifier isEqualToString:@"osl8000"])
		g=8000;
	[AppDelegate get].loadout.g += g;
	[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];*/
	[gold setString:[NSString stringWithFormat:@"%iG",[AppDelegate get].loadout.g]];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"GoldPurchase: %i",g]];
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:[NSString stringWithFormat:@"GoldPurchase-Complete: %i",[productIdentifier intValue]]];
	[message stopAllActions];
	message.opacity=255;
	[message setString:@"Thank you for your purchase."];
	[self toggleMenu:1];
}

-(void) toggleMenu:(int)i {
	CGSize s = [[CCDirector sharedDirector] winSize];
	if (i == 1)
		goldMenu.position = ccp(s.width/2,s.height/2-26);
	else
		goldMenu.position = ccp(-1000,-1000);
}

- (void)productPurchaseFailed:(NSNotification *)notification {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"GoldPurchase-Failed"];
	[message stopAllActions];
	message.opacity=255;
	[message setString:@"Choose Gold Amount"];
	[self toggleMenu:1]; 
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	 
	SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
	if (transaction.error.code != SKErrorPaymentCancelled) {    
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error!" 
														 message:transaction.error.localizedDescription 
												delegate:nil 
												cancelButtonTitle:nil 
												otherButtonTitles:@"OK", nil] autorelease];
		 
		 [alert show];
	}
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Gold-Error" attributes:[NSDictionary dictionaryWithObjectsAndKeys: @"error", transaction.error.localizedDescription, nil]];
}
	 
//////////////////////////////////
-(void)doPurchase: (id)sender {
	//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"GoldPurchase-Attempt"];
	[NSObject cancelPreviousPerformRequestsWithTarget:self]; 
	int chosen = (int) [sender tag];
	CCLOG(@"Purchase: %i",chosen);
	[message runAction:fadeAction];
    [message setString:@"Processing Purchase..."];
    [[MyIAPHelper sharedHelper] buyProductIdentifier:[NSString stringWithFormat:@"osl%i",chosen]];

    [self toggleMenu:0];
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
	
}

-(void)mainMenu: (id)sender {
	[NSObject cancelPreviousPerformRequestsWithTarget:self]; 
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[[CCDirector sharedDirector] replaceScene:[CustomScene node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc GoldLayer"); 
	[fadeAction release];
	[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
	[super dealloc];
}

@end
