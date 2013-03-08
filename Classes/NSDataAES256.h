//
//  NSDataAES256.h
//  OSL
//
//  Created by James Dailey on 3/18/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData*) encryptedWithKey:(NSData*) key;

- (NSData*) decryptedWithKey:(NSData*) key;

@end
