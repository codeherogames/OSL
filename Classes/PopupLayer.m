//
//  PopupLayer.m
//  OSL
//
//  Created by James Dailey on 4/21/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "PopupLayer.h"
#import "AppDelegate.h"

@implementation PopupLayer
-(id) initWithMessage: (NSString*)m t:(NSString*)t {
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		/*CCSprite *bg = [CCSprite spriteWithFile:@"b1px.png"];
		bg.scaleX = s.width;
		bg.scaleY = s.height;
        [bg setPosition:ccp(s.width/2,s.height/2)];
        [self addChild:bg z:0];*/
		
		CCSprite *notice = [CCSprite spriteWithFile:@"b1px.png"];
		notice.scaleX = s.width-(s.width*.3);
		notice.scaleY = s.height-(s.height*.3);
        [notice setPosition:ccp(s.width/2,s.height/2)];
		notice.opacity = 180;
        [self addChild:notice z:0];
		
		CCSprite *b1 = [CCSprite spriteWithFile:@"w1px.png"];
		b1.color=ccYELLOW;
		b1.scaleX = notice.scaleX;
		b1.scaleY = 2;
        [b1 setPosition:ccp(s.width/2,s.height*.3/2)];
        [self addChild:b1 z:2];
		
		CCSprite *b2 = [CCSprite spriteWithFile:@"w1px.png"];
		b2.color=ccYELLOW;
		b2.scaleX = notice.scaleX;
		b2.scaleY = 2;
        [b2 setPosition:ccp(s.width/2,s.height-(s.height*.3/2))];
        [self addChild:b2 z:2];		

		CCSprite *b3 = [CCSprite spriteWithFile:@"w1px.png"];
		b3.color=ccYELLOW;
		b3.scaleX = 2;
		b3.scaleY = notice.scaleY;
        [b3 setPosition:ccp(s.width-(s.width*.3/2),s.height/2)];
        [self addChild:b3 z:2];

		CCSprite *b4 = [CCSprite spriteWithFile:@"w1px.png"];
		b4.color=ccYELLOW;
		b4.scaleX = 2;
		b4.scaleY = notice.scaleY;
        [b4 setPosition:ccp(s.width*.3/2,s.height/2)];
        [self addChild:b4 z:2];
		
		CCSprite *bk = [CCSprite spriteWithFile:@"w1px.png"];
		bk.color=ccYELLOW;
		bk.scaleX = 134;
		bk.scaleY = 36;
        [bk setPosition:ccp(s.width/2,48)];
        [self addChild:bk z:2];
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:t fontName:[AppDelegate get].clearFont fontSize:16];
		[title setColor:ccYELLOW];
		title.position=ccp(s.width/2,s.height-66);
		[self addChild:title z:1];

		CCLabelTTF *message = [CCLabelTTF labelWithString:m dimensions:CGSizeMake(s.width-(s.width*.3)-20,s.height-(s.height*.3)-20) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:16];
		[message setColor:ccWHITE];
		message.position=ccp(s.width/2,s.height/2-24);
		[self addChild:message z:1];
		
		TextMenuItem *a = [TextMenuItem itemFromNormalImage:@"buttonlong.png" selectedImage:@"buttonlongh.png" 
												   target:self
												 selector:@selector(clicked:) label:@"Continue"];
		
		CCMenu *menu = [CCMenu menuWithItems:a,nil];
		menu.position = ccp(s.width/2,48);
		[self addChild:menu z:2];
	}
	return self;
}

-(void) clicked:(id)sender {
	if ([self.parent respondsToSelector:@selector(popupClicked)])
		[self.parent popupClicked];
	[self.parent removeChild:self cleanup:YES];	
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-128 swallowsTouches:YES];
	CGSize sz = [self contentSize];
	rect = CGRectMake(-sz.width / 2, -sz.height / 2, sz.width, sz.height);
	[super onEnter];
}

- (void)onExit
{
	CCLOG(@"popuplayer exit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//[self reset];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	/*if ( [self containsTouchLocation:touch] ) {
		//CCLOG(@"my touch");
		[self.parent removeChild:self cleanup:YES];
		return YES;
	}
	else {
		return NO;
	}
	 */
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}


- (void) dealloc {
	CCLOG(@"dealloc PopupLayer"); 
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}

@end

