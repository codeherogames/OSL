//
//  BonusSprite.h
//  OSL
//
//  Created by James Dailey on 8/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BonusSprite : CCSprite {
    CCLabelBMFont *bonusLabel;
}

@property (nonatomic, assign) int val;

-(void) updateLabel:(NSString*) l;
-(void) hide;
@end
