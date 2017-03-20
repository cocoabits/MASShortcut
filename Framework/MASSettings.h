//
//  MASSettings.h
//  MASShortcut
//
//  Created by Volodymyr Dudchak on 3/17/17.
//  Copyright © 2017 Vadim Shpakovski. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface MASSettings : NSObject

+ (NSUserDefaults *)userDefaults; /* [NSUserDefaults standardUserDefaults] by default */
+ (void)setUserDefaults:(nullable NSUserDefaults *)userDefaults;

+ (NSUserDefaultsController *)userDefaultsController;

@end

NS_ASSUME_NONNULL_END
