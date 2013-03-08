//
//  WinScene.h
//  PixelSniper
//
//  Created by James Dailey on 1/30/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface WinScene : CCScene {}
@end

@interface WinLayer : CCLayer {
	CCLabelTTF *gold;
	int oldG;
}	
-(void) showWinnings;
-(void)mainMenu: (id)sender;
-(int) checkIt;
@end