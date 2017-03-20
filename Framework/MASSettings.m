//
//  MASSettings.m
//  MASShortcut
//
//  Created by Volodymyr Dudchak on 3/17/17.
//  Copyright © 2017 Vadim Shpakovski. All rights reserved.
//

#import "MASSettings.h"

@implementation MASSettings

static NSUserDefaults* sMASUserDefaults = nil;
static NSUserDefaultsController* sMASUserDefaultsController = nil;

+ (dispatch_queue_t)internalQueue
{
    static dispatch_queue_t MASSettingsInternalQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MASSettingsInternalQueue = dispatch_queue_create("com.MASShorcut.settings.internalQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return MASSettingsInternalQueue;
}

+ (NSUserDefaults *)userDefaults
{
    __block NSUserDefaults *userDefaults = nil;
    dispatch_barrier_sync([self internalQueue], ^{
        userDefaults = sMASUserDefaults ?: [NSUserDefaults standardUserDefaults];
    });
    return userDefaults;
}

+ (void)setUserDefaults:(NSUserDefaults *)userDefaults
{
    dispatch_async([self internalQueue], ^{
        if (userDefaults != sMASUserDefaults)
        {
            sMASUserDefaults = userDefaults;
            NSDictionary *oldInitialValues = sMASUserDefaultsController ? [sMASUserDefaultsController initialValues] : [[NSUserDefaultsController sharedUserDefaultsController] initialValues];
            sMASUserDefaultsController = [[NSUserDefaultsController alloc] initWithDefaults:userDefaults initialValues:oldInitialValues];
        }
    });
}

+ (NSUserDefaultsController *)userDefaultsController
{
    __block NSUserDefaultsController *userDefaultsController = nil;
    dispatch_barrier_sync([self internalQueue], ^{
        userDefaultsController = sMASUserDefaultsController ?: [NSUserDefaultsController sharedUserDefaultsController];
    });
    return userDefaultsController;
}

@end
