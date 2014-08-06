#import "MASShortcut.h"

@interface MASShortcutMonitor : NSObject

- (void) registerShortcut: (MASShortcut*) shortcut withAction: (dispatch_block_t) action;
- (BOOL) isShortcutRegistered: (MASShortcut*) shortcut;
- (void) unregisterShortcut: (MASShortcut*) shortcut;

@end
