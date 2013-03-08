//
//  Joystick.h
//  Sniper
//
//  Created by James Dailey on 10/16/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

// virtual joystick class 
// 
// Create a virtual touch joystick within the bounds passed in. 
// Default mode is that any press begin in the bounds area becomes 
// the center of the joystick. Call setCenter if you want a static 
// joystick center position instead. Querry getCurrentVelocity 
// for an X,Y velocity value, or getCurrentDegreeVelocity for a 
// degree and velocity value. 
#import <Foundation/Foundation.h> 
#import "cocos2d.h"
@interface Joystick : NSObject <CCTargetedTouchDelegate>
{ 
	bool mStaticCenter; 
	CGPoint mCenter; 
	CGPoint mCurPosition; 
	CGPoint mVelocity; 
	CGRect mBounds; 
	bool mActive; 
} 

-(id)init:(float)x y:(float)y w:(float)w h:(float)h; 
-(void)setCenterX:(float)x y:(float)y; 
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event; 
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event; 
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event; 
-(CGPoint)getCurrentVelocity; 
-(CGPoint)getCurrentDegreeVelocity; 
@end 