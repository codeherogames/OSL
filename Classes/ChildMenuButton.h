//
//  ChildMenuButton.h
//  PixelSniper
//
//  Created by James Dailey on 1/26/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface ChildMenuButton : CCSprite <CCTargetedTouchDelegate>
{
	int type,status;
	ccColor3B  disabledColor,enabledColor;
	CGRect rect;
	NSString *des,*longDescription;
}
@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, assign) NSString *des,*longDescription;
@property(nonatomic, readwrite) int type,status;
@property(nonatomic, assign) ccColor3B  disabledColor,enabledColor,selectedColor;

- (id) initWithFile: (NSString*) s t:(int) t d:(NSString*)d ld:(NSString*)ld;
-(void) reset;
-(void) disable;
-(void) enable;
@end
