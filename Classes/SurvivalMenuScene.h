//
//  SurvivalMenuScene.h
//  OSL
//
//  Created by Dailey, James M [CCC-OT] on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface SurvivalMenuScene : CCScene {}
-(void) popupClicked;
@end

@interface SurvivalMenuLayer : CCLayer {
	CCMenu *menu;
	CCLabelTTF *gold;
}
-(void) mainMenu: (id)sender;
-(void) popupClicked;
-(void) hideMenu;
@end