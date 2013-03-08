//
//  MenuScene.h
//  Sniper
//
//  Created by James Dailey on 9/1/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface MenuScene : CCScene {}
@end

@interface MenuLayer : CCLayer {
	CCLabelTTF *newsLabel;
	int currentIndex;
}
@end