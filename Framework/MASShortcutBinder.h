#import "MASShortcutMonitor.h"

/**
    @brief Binds actions to user defaults keys.

    If you store shortcuts in user defaults (for example by binding
    a @p MASShortcutView to user defaults), you can use this class to
    connect an action directly to a user defaults key. If the shortcut
    stored under the key changes, the action will get automatically
    updated to the new one.

    This class is mostly a wrapper around a @p MASShortcutMonitor. It
    watches the changes in user defaults and updates the shortcut monitor
    accordingly with the new shortcuts.
*/
@interface MASShortcutBinder : NSObject

/**
    @brief A convenience shared instance.

    You may use it so that you don’t have to manage an instance by hand,
    but it’s perfectly fine to allocate and use a separate instance instead.
*/
+ (instancetype) sharedBinder;

/**
    @brief The underlying shortcut monitor.
*/
@property(strong) MASShortcutMonitor *shortcutMonitor;

/**
    @brief Binding options customizing the access to user defaults.

    As an example, you can use @p NSValueTransformerNameBindingOption to customize
    the storage format used for the shortcuts. By default the shortcuts are converted
    from @p NSData (@p NSKeyedUnarchiveFromDataTransformerName). Note that if the
    binder is to work with @p MASShortcutView, both object have to use the same storage
    format.
*/
@property(copy) NSDictionary *bindingOptions;

/**
    @brief Binds given action to a shortcut stored under the given defaults key.

    In other words, no matter what shortcut you store under the given key,
    pressing it will always trigger the given action.
*/
- (void) bindShortcutWithDefaultsKey: (NSString*) defaultsKeyName toAction: (dispatch_block_t) action;

/**
    @brief Disconnect the binding between user defaults and action.

    In other words, the shortcut stored under the given key will no longer trigger an action.
*/
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
