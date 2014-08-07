#import "MASShortcutMonitor.h"

@interface MASShortcutBinder : NSObject

+ (instancetype) sharedBinder;

@property(strong) MASShortcutMonitor *shortcutMonitor;
@property(copy) NSDictionary *bindingOptions;

- (void) bindShortcutWithDefaultsKey: (NSString*) defaultsKeyName toAction: (dispatch_block_t) action;
- (void) breakBindingWithDefaultsKey: (NSString*) defaultsKeyName;

/**
    @brief Register default shortcuts in user defaults.

    This is a convenience frontent to [NSUserDefaults registerDefaults].
    The dictionary should contain a map of user defaults’ keys to appropriate
    keyboard shortcuts. The shortcuts will be transformed according to
    @p bindingOptions and registered using @p registerDefaults.
*/
- (void) registerDefaultShortcuts: (NSDictionary*) defaultShortcuts;

@end
