//
//  Perk.m
//  OSL
//
//  Created by James Dailey on 3/15/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "Perk.h"
#import "GameScene.h"

enum {
	kLocked = 100,
	kUnlocked = 255,	
};

@implementation Perk
@synthesize x,c,n,d,s,m,img,rect;

- (id) initWithFile: (NSString*) iX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX sX:(int)sX mX:(int)mX
{
	CCLOG(@"--------------Perk init:%@ : %@ : %@",iX,nX,dX);
	self =  [super initWithFile:iX];
	if (self != nil) {
		self.img = iX;
		self.n = nX;
		self.d = dX;
		self.x = xX;
		self.c = cX;
		self.s = 1;//sX;
		self.m = mX;
		/*highlight = [CCSprite spriteWithFile: @"w1px.png"];
		 highlight.color = ccYELLOW;
		 highlight.scale = 58;
		 [self addChild: highlight z:-1];
		 highlight.position=ccp(self.contentSize.width/2,self.contentSize.height/2);
		 highlight.visible=FALSE;*/
	}
	
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:img forKey:@"img"];
    [encoder encodeObject:d forKey:@"d"];
    [encoder encodeInt:x forKey:@"x"];
    [encoder encodeInt:c forKey:@"c"];
    [encoder encodeInt:s forKey:@"s"];
    [encoder encodeObject:n forKey:@"n"];
	[encoder encodeInt:m forKey:@"m"];
}

- (id)initWithCoder:(NSCoder *)decoder {		
	return [self initWithFile: [decoder decodeObjectForKey:@"img"] nX:[decoder decodeObjectForKey:@"n"] dX:[decoder decodeObjectForKey:@"d"] xX:[decoder decodeIntForKey:@"x"] cX:[decoder decodeIntForKey:@"c"] sX:[decoder decodeIntForKey:@"s"] mX:[decoder decodeIntForKey:@"m"]];
}

- (void)onEnter
{
	CCLOG(@"onEnter adding Perk myButtontouchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	CGSize sz = [self contentSize];
	rect = CGRectMake(-sz.width / 2, -sz.height / 2, sz.width, sz.height);
	[super onEnter];
}

- (void)onExit
{
	CCLOG(@"onExit removing Perk touchdispatcher");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	[super onExit];
}	

-(void) showHighlight {
	//highlight.visible=TRUE;
	self.scale = 1;
}

-(void) reset {
	//highlight.visible=FALSE;
	self.scale = .8;
	if (self.s == 0)
		self.opacity=kLocked;
	else if (self.s == 1) {
		self.opacity=kUnlocked;
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//[self reset];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( [self containsTouchLocation:touch] ) {
		CCLOG(@"touched:%i",self.x);
        if (![self.parent isKindOfClass:[ControlLayer class]]) {
            [[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
            for (int i=0; i<[[AppDelegate get].perks count];i++) {
                Perk *pk = [[AppDelegate get].perks objectAtIndex:i];
                if (pk.x != self.x) {
                    [pk reset];
                }
            }
            self.opacity=kUnlocked;
            //highlight.visible=TRUE;
            self.scale = 1;
            [self.parent showInfo:self.x];
        }
        else {
            //NSDate *now = [NSDate date];
            if (touch.tapCount == 2) {
                [[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
                [self.parent showInfo:self.x];
            }
        }
        
		return YES;
	}
	else {
		return NO;
	}
}

-(void) flash {
    flashCount = 3;
    [self schedule: @selector(doFlash) interval: 0.3];
}

-(void)doFlash {

    if (flashCount == 0)
        self.opacity = 255;
    else if (flashCount % 2 == 1)
        self.opacity = 0;
    else
        self.opacity = 255;
    flashCount--;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

- (void) dealloc 
{
	CCLOG(@"Dealloc Perk");
	//[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end