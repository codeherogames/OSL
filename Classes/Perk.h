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
25: Supply Lines: 1/2 price ammo
26: Double Sabotage: 6 shots to disable sabotage
27: Machine gun: start with it
28: Bounty Bonus: Shooting driver gives 800
29: Greed Hurts: 3peat penalty
30: All Access: Citizens allowed on 3rd floor
31: Overdraft Fee: Opponent Zero balance gives you 100
32: Hiccups: Opponent scope zooms/unzooms randomly
33: Risky Business: Shots far from Smitty earn money
34: Sleeper Cell: Citizens turn Agents when leaving building
35: Bomb Shelter: Immune to Armageddon
36: Hush Money: Lose no money when killing citizens
37: Sneak Attack: Planes invisible and don't show on recon
38: Scrap Metal: Every vehicle towed gives you 400
39: Valued Customer: Max money ceiling is 7000
40: Seat Taken: All opponent vehicles carry one less Agent
41: Ammo Depot: Every 5 opponent shots earns you 100
42: Armageddon: Start with it
43: Traffic: Parade of trucks
44: Trifecta: Shoot passengers, then driver gives 2000
45: Circuits Busy: Delay Sniper Found alert 3 seconds
46: Slippery Scope: Opponent scope over-responsive
47: Auto-Snipe: Auto-jumps scope to sniper when visible
48: Proximity Indicator: Indicates agent proximity to Smitty
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
