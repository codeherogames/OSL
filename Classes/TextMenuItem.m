//
//  TextMenuItem.m
//  OSL
//
//  Created by James Dailey on 4/8/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "TextMenuItem.h"


@implementation TextMenuItem
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s label:(NSString*) label
{
	CCSprite *sprite  = [CCSprite spriteWithFile:value];
	CCSprite *sprite2  = [CCSprite spriteWithFile:value2];
	
	self = [super itemFromNormalSprite:sprite selectedSprite:sprite2 target:t selector:s];
	CCLabelTTF *myLabel = [CCLabelTTF labelWithString:label fontName:[AppDelegate get].menuFont fontSize:20];
	[myLabel setColor:ccBLACK];
	myLabel.position =ccp(sprite.contentSize.width/2, sprite.contentSize.height/2-2);
	[self addChild:myLabel z:sprite.zOrder+1];
	//pressed = 0;
	return self;
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s label:(NSString*) label fontSize:(int)fontSize
{
	CCSprite *sprite  = [CCSprite spriteWithFile:value];
	CCSprite *sprite2  = [CCSprite spriteWithFile:value2];
	
	self = [super itemFromNormalSprite:sprite selectedSprite:sprite2 target:t selector:s];
	CCLabelTTF *myLabel = [CCLabelTTF labelWithString:label fontName:[AppDelegate get].menuFont fontSize:fontSize];
	[myLabel setColor:ccBLACK];
	myLabel.position =ccp(sprite.contentSize.width/2, sprite.contentSize.height/2-2);
	[self addChild:myLabel z:sprite.zOrder+1];
	//pressed = 0;
	return self;
}

-(void) activate
{
	CCLOG(@"activate");
	[[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[super activate];
	if (self.tag < 400)
		[self setIsEnabled:NO];
}
@end
