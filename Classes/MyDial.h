//
//  Dial.h
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface MyDial :  CCSprite <CCTargetedTouchDelegate> {
		CGRect rect;
}
@property(nonatomic, readonly) CGRect rect;
@end
