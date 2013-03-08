//
//  Joystick.m
//  Sniper
//
//  Created by James Dailey on 10/16/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "Joystick.h" 
#import "Vector.h" 
#import "CCDirector.h" 
@implementation Joystick 
-(id)init:(float)x y:(float)y w:(float)w h:(float)h 
{ 
	self = [super init]; 
	if( self ) 
	{ 
		CGPoint location = [[CCDirector sharedDirector] convertToGL:CGPointMake(x,y)]; 

		//if ([[Director sharedDirector] landscape]) 
			mBounds = CGRectMake(location.x, location.y, h, w); 
		//else 
			//mBounds = CGRectMake(location.x, location.y, w, h); 
		mBounds.origin = CGPointMake(0,0);
		mCenter = CGPointMake(0,0); 
		mCurPosition = CGPointMake(0,0); 
		mActive = NO; 
		mStaticCenter = NO; 
	} 
	return self; 
} 

-(void)setCenterX:(float)x y:(float)y 
{ 
	mCenter = CGPointMake(x, y); 
	mStaticCenter = YES; 
} 

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchBegan: Joystick");
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	//CCLOG(@"TouchBegan: Joystick: location: %f %f", location.x, location.y);
	//CCLOG(@"TouchBegan: Joystick: mBounds: %f %f", mBounds.size.width, mBounds.size.height);
	//CCLOG(@"TouchBegan: Joystick: mBounds: Origin: %f %f", mBounds.origin.x, mBounds.origin.y);
	if (CGRectContainsPoint(mBounds, location)) 
	{ 
		//CCLOG(@"TouchBegan: Joystick: CGRectContainsPoint");
		mActive = YES; 
		if (!mStaticCenter) 
			mCenter = CGPointMake(location.x, location.y); 
		mCurPosition = CGPointMake(location.x, location.y); 
		return YES;
	} 
	else
	{
		return NO;
	}
} 


-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchMoved: Joystick");
	if (!mActive) 
		return; 
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	//if([background containsPoint:[background convertToNodeSpace:location]]){
	//location = [self convertToNodeSpace:location];

		if (CGRectContainsPoint(mBounds, location)) 
		{ 
			mCurPosition = CGPointMake(location.x, location.y); 
		} 
} 

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{ 
	//CCLOG(@"TouchEnded: Joystick");
	if (!mActive) return; 
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]]; 
		if (CGRectContainsPoint(mBounds, location)) 
		{ 
			mActive = NO; 
			if (!mStaticCenter) 
				mCenter = CGPointMake(0,0); 
			mCurPosition = CGPointMake(0,0); 
		} 
} 

-(CGPoint)getCurrentVelocity 
{ 
	return [Vector subtract:mCenter from:mCurPosition]; 
} 

-(CGPoint)getCurrentDegreeVelocity 
{ 
	float dx = mCenter.x - mCurPosition.x; 
	float dy = mCenter.y - mCurPosition.y; 
	CGPoint vel = [self getCurrentVelocity]; 
	vel.y = [Vector length:vel]; 
	vel.x = atan2f(-dy, dx) * (180/3.14); 
	return vel; 
} 

@end 