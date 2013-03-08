//
//  CustomScene.h

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface CustomScene : CCScene
{
}
-(void) customPop;
-(void) go;
@end

@interface CustomLayer : CCLayer {
	int oldG;
	CCLabelTTF *gold;
}
-(void) customPop;
-(void) go;

@end
