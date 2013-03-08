//
//  PopupLayer.h
//  OSL
//
//  Created by James Dailey on 4/21/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PopupLayer : CCLayer <CCTargetedTouchDelegate>
{
	CGRect rect;
}

-(id) initWithMessage: (NSString*)m t:(NSString*)t;

@end
