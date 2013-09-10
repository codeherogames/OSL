//
//  Perk.h
//  OSL
//
//  Created by James Dailey on 3/15/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

/*
x 25: Supply Lines: 1/2 price ammo
x 26: Double Sabotage: 6 shots to disable sabotage
x 27: End of Days: Opponent screen cycles day and night
x 28: Bounty Bonus: Shooting driver gives 800
x 29: Greed Hurts: 3peat penalty
x 30: All Access: Citizens allowed on 3rd floor
x 31: Overdraft Fee: Opponent Zero balance gives you 100
x 32: Hiccups: Opponent scope zooms/unzooms randomly
x 33: Risky Business: Shots far from Smitty earn money
x 34: Sleeper Cell: Citizens turn Agents when leaving building
x 35: Bomb Shelter: Immune to Armageddon
x 36: Hush Money: Lose no money when killing citizens
x 37: Sneak Attack: Planes invisible and don't show on recon
x 38: Scrap Metal: Every vehicle towed gives you 400
x 39: Valued Customer: Max money ceiling is 7000
x 40: Seat Taken: All opponent vehicles carry one less Agent
x 41: Ammo Depot: Every opponent shot earns you 10
x 42: Insider Trading: Shows amount of money opponent has
x 43: Field Report: Reports number of agents and citizens alive
x 44: Trifecta: Shoot passengers, then driver gives 5000
x 45: Circuits Busy: Delay Sniper Found alert 3 seconds
x 46: Slippery Scope: Opponent scope over-responsive
x 47: Auto-Snipe: Auto-jumps scope to sniper when visible
x 48: Proximity Indicator: Indicates agent proximity to Smitty
*/
@interface Perk : CCSprite <NSCoding,CCTargetedTouchDelegate> {
	NSString *img,*n,*d,*ed;
	int x,c,s,m,flashCount;
	CGRect rect;
	//CCSprite *highlight;
}
@property (readwrite, nonatomic) int x,c,s,m;
@property (nonatomic, retain) NSString *n,*d,*img,*ed;
@property(nonatomic, readonly) CGRect rect;

-(void) reset;
-(void) showHighlight;
-(void) flash;
- (id) initWithFile: (NSString*) iX nX:(NSString*) nX dX:(NSString*)dX xX:(int)xX cX:(int)cX sX:(int)sX mX:(int)mX;
@end
