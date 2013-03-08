//
//  PlayScene.h
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface PlayScene : CCScene {}
-(void) popupClicked;
@end

@interface PlayLayer : CCLayer {
	CCMenu *menu;
	CCLabelTTF *gold;
	int oldG;
	//CCLabelTTF *loading;
}
-(void) hideMenu;
-(BOOL) menuReady;
-(void) mainMenu: (id)sender;
-(void) popNoGC;
-(void) popupClicked;
@end