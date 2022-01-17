//
//  MASSecureDataTransformer.h
//  MASShortcut
//
//  Created by Vitalii Budnik on 11/24/21.
//  Copyright © 2021 Vadim Shpakovski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MASSecureDataTransformerName;

@interface MASSecureDataTransformer : NSSecureUnarchiveFromDataTransformer

/// Registeres @c MASSecureDataTransformer .
+ (void) registerIfNeeded;

@end

NS_ASSUME_NONNULL_END
