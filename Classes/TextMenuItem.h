//
//  TextMenuItem.h
//  OSL
//
//  Created by James Dailey on 4/8/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface TextMenuItem : CCMenuItemSprite {
	int pressed;
}
//@property (nonatomic, assign) int pressed;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s label:(NSString*) label;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s label:(NSString*) label fontSize:(int)fontSize;
@end
