//
//  MultiScene.h
//  PixelSniper
//
//  Created by James Dailey on 2/2/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface MultiScene : CCScene {

}
-(void) showWait;
-(void) hideWait;
@end
@interface MultiLayer : CCLayer {
	CCMenuItemToggle* toggleWager;
}
@end

@interface WaitLayer : CCLayer {
	
}
@end
