//
//  PerkScene.h
//  PixelSnipe
//
//  Created by James Dailey on 1/12/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface PerkScene : CCScene {}
@end

@interface PerkLayer : CCLayer
{
	CCLabelTTF *gold,*name,*description,*instructions,*pButton,*slot1Text,*slot2Text,*slot3Text;
	CCSprite *preview,*slot1,*slot2,*slot3;
	int selected;
}
-(void)showInfo: (int) i;
@end