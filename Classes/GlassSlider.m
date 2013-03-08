//
//  glassSlider.m
//  PixelSniper
//
//  Created by James Dailey on 1/26/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "GlassSlider.h"
#import "ChildMenuButton.h"

@implementation GlassSlider
@synthesize actionIn,actionOut,status,l1,l2,l3,called;

- (id) initWithFile: (NSString*) s
{
	self =  [super initWithFile:s];
	if (self != nil) {
		self.status = 0;
		self.called = 0;
	}
	return self;
}

- (void) initActions {
	if (self.called == 0) {
		self.called = 1;
		self.actionOut = [[CCMoveTo actionWithDuration: 0.5 position:ccp(self.contentSize.width+8,self.position.y)] retain];
		self.actionIn = [[CCMoveTo actionWithDuration: 0.5 position:ccp(0,self.position.y)] retain];
		for(int i=0;i<3;i++) {
			ChildMenuButton *c =[[ChildMenuButton alloc] initWithFile:@"staricon.png" t:1 d:@"empty" ld:@"empty"];
			[self addChild:c];
			c.position = ccp(self.contentSize.width/2,(self.contentSize.height/3*i) + 50);
		}
		self.l1 = [CCLabelTTF labelWithString:@"x" fontName:[AppDelegate get].clearFont fontSize:10];
		self.l1.color=ccWHITE;
		[self addChild:self.l1];
		self.l1.position = ccp(self.contentSize.width/2,(self.contentSize.height) - 18);
		self.l2 = [CCLabelTTF labelWithString:@"x" fontName:[AppDelegate get].clearFont fontSize:10];
		self.l2.color=ccWHITE;
		[self addChild:self.l2];
		self.l2.position = ccp(self.contentSize.width/2,l1.position.y-106);
		self.l3 = [CCLabelTTF labelWithString:@"x" fontName:[AppDelegate get].clearFont fontSize:10];
		self.l3.color=ccWHITE;
		[self addChild:self.l3];
		self.l3.position = ccp(self.contentSize.width/2,l2.position.y-106);
	}
}

- (void) addButtons: (NSMutableArray*) n
{
	for(int i=0;i<[n count];i++) {
		((ChildMenuButton*)[self.children objectAtIndex:i]).texture = ((ChildMenuButton*)[n objectAtIndex:i]).texture;
		((ChildMenuButton*)[self.children objectAtIndex:i]).type = ((ChildMenuButton*)[n objectAtIndex:i]).type;
		((ChildMenuButton*)[self.children objectAtIndex:i]).des = ((ChildMenuButton*)[n objectAtIndex:i]).des;
		((ChildMenuButton*)[self.children objectAtIndex:i]).longDescription = ((ChildMenuButton*)[n objectAtIndex:i]).longDescription;
		((ChildMenuButton*)[self.children objectAtIndex:i]).status = ((ChildMenuButton*)[n objectAtIndex:i]).status;
		[((ChildMenuButton*)[self.children objectAtIndex:i]) reset];
	}
	[self.l3 setString:((ChildMenuButton*)[self.children objectAtIndex:0]).des];
	[self.l2 setString:((ChildMenuButton*)[self.children objectAtIndex:1]).des];
	[self.l1 setString:((ChildMenuButton*)[self.children objectAtIndex:2]).des];
}

- (void) slideOut
{
	[self stopAllActions];
	self.status=1;
	[self runAction:self.actionOut];
}

- (void) slideIn
{
	[self stopAllActions];
	self.status=0;
	[self runAction:self.actionIn];
}

- (void) dealloc {
	CCLOG(@"Deallocing GlassSlider");
	//[actionIn release];
	//[actionOut release];
	[super dealloc];
}
@end
