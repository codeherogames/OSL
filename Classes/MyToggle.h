//
//  myToggle.h
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface MyToggle :  CCSprite <CCTargetedTouchDelegate> {
	CGRect rect;
	CCTexture2D *t,*tOrig;
}
@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, retain) CCTexture2D *t,*tOrig;
@end
