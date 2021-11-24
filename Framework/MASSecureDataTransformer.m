//
//  MASSecureDataTransformer.m
//  MASShortcut
//
//  Created by Vitalii Budnik on 11/24/21.
//  Copyright © 2021 Vadim Shpakovski. All rights reserved.
//

#import "MASSecureDataTransformer.h"
#import "MASShortcut.h"

NSString *const MASSecureDataTransformerName = @"MASSecureDataTransformer";

@implementation MASSecureDataTransformer

+ (void) registerIfNeeded
{
    static dispatch_once_t registerTransformerOnce;
    dispatch_once(&registerTransformerOnce, ^{
        if (![[NSValueTransformer valueTransformerNames] containsObject:MASSecureDataTransformerName]) {
            [NSValueTransformer setValueTransformer:[[MASSecureDataTransformer alloc] init] forName:MASSecureDataTransformerName];
        }
    });
}

+ (Class) transformedValueClass
{
    return [MASShortcut class];
}

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

@end
