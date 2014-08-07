#import "MASShortcutMonitor.h"

@interface MASShortcutBinder : NSObject

@property(strong) MASShortcutMonitor *shortcutMonitor;
@property(copy) NSDictionary *bindingOptions;

- (void) bindShortcutWithDefaultsKey: (NSString*) defaultsKeyName toAction: (dispatch_block_t) action;
- (void) breakBindingWithDefaultsKey: (NSString*) defaultsKeyName;

@end
