//
//  BigTouchMenuItem.h
//  OSL
//
//  Created by James Dailey on 2/12/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface JDMenuItem : CCMenuItemImage {
}
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s;
@end
