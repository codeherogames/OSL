//
//  Story.m
//  OSL
//
//  Created by James Dailey on 4/10/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Story.h"
#import "MissionScene.h"
#import "Mission1.h"

@implementation Story
- (id) init {
    self = [super init];
    if (self != nil) {
		//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        CCSprite * bg = [CCSprite spriteWithFile:@"splitscreen.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        [self addChild:[PhoneLayer node] z:1 tag:1];
		
    }
    return self;
}
- (void) dealloc {
	CCLOG(@"dealloc Story"); 
	[super dealloc];
}
@end

@implementation PhoneLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		[CCMenuItemFont setFontSize:16];
		[CCMenuItemFont setFontName:[AppDelegate get].clearFont];
		CCMenuItem *b = [CCMenuItemFont itemFromString:@"BACK"
												target:self
											  selector:@selector(mainMenu:)];
		CCMenuItem *p = [CCMenuItemFont itemFromString:@"PLAY"
												target:self
											  selector:@selector(play:)];
		[b setPosition:ccp(34, 300)];
		[p setPosition:ccp(458, 300)];
		CCMenu *back = [CCMenu menuWithItems:b,p,nil];
        [self addChild:back];
		back.color=ccWHITE;
		[back setPosition:ccp(0, 0)];
		for (CCMenuItem *mi in back.children) {
			CGSize tmp = mi.contentSize;
			tmp.width = tmp.width*1.3;
			tmp.height = tmp.height*1.3;
			[mi setContentSize:tmp];
		}
		[CCMenuItemFont setFontName:[AppDelegate get].menuFont];
		//[CCMenuItemFont setFontSize:16];
		
		idx = 0;
		dialog = [[NSArray arrayWithObjects:@"Hello?",@"Shadow",@"Hey man, are you OK?  I heard about...",@"Listen I need your help",@"Sure, anything",@"Well actually we need each other",@"Whoa...I don't go that way bro",@"Very funny.  Seriously, something isn't right",@"What happened?  How is your sight?",@"That's not why I called.  I need backup",@"Why, because you got roughed up by a couple dirt maggots?",@"No",@"I'm retired remember?  Plus you have Radomsky and Hines",@"They can't do it",@"I trained them myself, they are the best",@"When was the last time you heard from them?",@"I don't know, maybe 3 months ago",@"Exactly",@"Hey, you know I can't do anything",@"They were looking for you",@"Who?  The agency?",@"The Shizkas.  Except I don't think they were Shizkas",@"You were found hogtied in the barn after they shot them",@"They interrogated me and then dumped me much later",@"How would they even know me?",@"That's the thing.  They...um...used your first name",@"What the?  My mother doesn't even use my first name",@"That's what makes me doubt it was Shikzas",@"Only a couple people at the agency...",@"See what I'm talking about?  I don't trust anybody",@"What did they ask about me?",@"Where you were",@"And",@"My guess is they didn't like my answer",@"......your...eye...",@"Forget about it.  Let's just figure out what's going on",@"Jeez, I'll do anything",@"I'm on a job in Elkbar for 5 days.  I need you to hawk",@"OK.  How will we communicate over there?",@"I took a recon prototype from the agency weeks ago",@"You know I hate computers.  Plus I haven't...",@"You won't have to do anything.  Just hawk",@"I'll get my gear ready, when do we leave?",@"Be at the spot 16:00 tomorrow",@"Man, I might as well go there now cause I won't sleep",@"Yeah, keep your eyes open and trust nobody",nil] retain];
		
		right = [CCLabelTTF labelWithString:(NSString*)[dialog objectAtIndex:idx+1] dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:16];
		[right setColor:ccYELLOW];
		right.position =ccp(s.width - s.width/4, 20);
		[self addChild:right z:1];
		
		left = [CCLabelTTF labelWithString:(NSString*)[dialog objectAtIndex:idx] dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:[AppDelegate get].clearFont fontSize:16];
		[left setColor:ccWHITE];
		left.position =ccp(s.width/4, 20);
		[self addChild:left z:1];
		
		[right runAction: [CCFadeOut actionWithDuration:0]];
		//[self schedule: @selector(showText) interval: 6];
		
		JDMenuItem *rightArrow = [JDMenuItem itemFromNormalImage:@"Carrow.png" selectedImage:@"Carrow.png"
														  target:self
														selector:@selector(showText:)];
		rightArrow.rotation = -180;
		CCMenu *m3 = [CCMenu menuWithItems:rightArrow, nil];
        [m3 alignItemsHorizontallyWithPadding: 102.0f];
        m3.position = ccp(s.width/2,30);
		[self addChild:m3 z:3];
	}
    return self;
}	

-(void) showText:(id) sender {
	idx++;
	CCLOG(@"showText: %i, %i",idx,[dialog count]);
	if (idx < [dialog count]) {
		if (idx % 2 == 0)
			[self showLeft];
		else 
			[self showRight];
	}
	else {
		[[CCDirector sharedDirector] replaceScene:[Mission1 node]];
	}
}

-(void) showLeft {
	CCLOG(@"showLeft");
	[left setString:(NSString*)[dialog objectAtIndex:idx]];
	[left runAction: [CCFadeIn actionWithDuration:0.5]];
	[right runAction: [CCFadeOut actionWithDuration:0.5]];
}

-(void) showRight {
	CCLOG(@"showRight");
	[right setString:(NSString*)[dialog objectAtIndex:idx]];
	[left runAction: [CCFadeOut actionWithDuration:0.5]];
	[right runAction: [CCFadeIn actionWithDuration:0.5]];
}

-(void)mainMenu: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[MissionScene node]];
}

-(void)play: (id)sender {
	[[CCDirector sharedDirector] replaceScene:[Mission1 node]];
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc Story"); 
	[dialog release];
	[super dealloc];
}

@end
