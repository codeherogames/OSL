//
//  TutorialScene.h
//  OSL
//
//  Created by James Dailey on 4/22/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
//#import "Joystick.h"
#import "GameScene.h"

@interface TutorialScene : GameScene {
}
-(void) popup: (NSString*) m t:(NSString*)t;
-(void) popupClicked;
@end

@interface TutorialLayer : BackgroundLayer {
	int successCount,targetCount,lastState;
	CCLabelTTF *three;
}
-(void) nextStep;
-(void) showSuccess;
-(void) popup: (NSString*) m t:(NSString*)t;
-(void) popupClicked;
-(void) kill;
- (void) setZoom2:(float) z;
@end

@interface TutorialControlLayer : ControlLayer {
	CCSprite *success,*arrow;
	CCMenu *questionMenu;
}
-(void) hideQuestion;
-(void) hideArrow;
-(void) showQuestion;
-(void) showSuccess;
- (void) disableAll;
-(void) popup: (NSString*) m t:(NSString*)t;
float findAngle(CGPoint pt1, CGPoint pt2);
@end




