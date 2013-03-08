//
//  Vector.h
//  Sniper
//
//  Created by James Dailey on 10/16/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h> 
@interface Vector : NSObject 
+ (CGPoint) makeWithX: (float)x Y:(float)y; 
+ (CGPoint) makeIdentity; 
+ (CGPoint) add: (CGPoint) vec1 to: (CGPoint) vec2; 
+ (CGPoint) truncate: (CGPoint) vec to: (float) max; 
+ (CGPoint) multiply: (CGPoint) vec by: (float) factor; 
+ (float) lengthSquared: (CGPoint) vec; 
+ (float) length: (CGPoint) vec; 
+ (CGPoint) subtract: (CGPoint) vec from: (CGPoint) vec; 
+ (CGPoint) invert: (CGPoint) vec; 
+ (CGPoint) normalize:(CGPoint) pt; 
+ (float) distanceBetween:(CGPoint)vec vec2:(CGPoint)vec2; 
+ (CGPoint) asAngleVelocity:(CGPoint)vec; 
+ (CGPoint) fromAngleVelocity:(CGPoint)vec; 
@end 
