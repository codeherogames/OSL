//
//  myMenuButton.h
//  PixelSniper
//
//  Created by James Dailey on 1/24/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MyMenuButton :  CCSprite <CCTargetedTouchDelegate>
{
	int type,status,money,selected;
	CCSprite  *disabledColor,*enabledColor,*pressedColor;
	CGRect rect;
	NSMutableArray *childButtons;
}
@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, readwrite) int type,status,money,selected;
@property(nonatomic, retain) CCSprite  *disabledColor,*enabledColor,*pressedColor;
@property(nonatomic, retain) NSMutableArray *childButtons;

- (id) initWithName: s t:(int) t val:(int) val;
-(void) reset;
@end
