//
//  Story.h
//  OSL
//
//  Created by James Dailey on 4/10/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface Story : CCScene {

}

@end

@interface PhoneLayer : CCLayer {
	CCLabelTTF *left,*right;
	NSArray *dialog;
	int idx;
}
-(void) showLeft;
-(void) showRight;
@end
