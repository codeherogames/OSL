//
//  LoseScene.h
//  PixelSniper
//
//  Created by James Dailey on 1/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface LoseScene : CCScene {}
@end

@interface LoseLayer : CCLayer {
	CCLabelTTF *gold;
	int oldG;
}	
-(void) checkAchievements;
-(void)mainMenu: (id)sender;
-(int) checkIt;
@end
