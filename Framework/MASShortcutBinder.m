#import "MASShortcutBinder.h"
#import "MASShortcut.h"

@interface MASShortcutBinder ()
@property(strong) NSMutableDictionary *actions;
@property(strong) NSMutableDictionary *shortcuts;
@end

@implementation MASShortcutBinder

#pragma mark Initialization

- (id) init
{
    self = [super init];
    [self setActions:[NSMutableDictionary dictionary]];
    [self setShortcuts:[NSMutableDictionary dictionary]];
    [self setShortcutMonitor:[MASShortcutMonitor sharedMonitor]];
    [self setBindingOptions:@{NSValueTransformerNameBindingOption: NSKeyedUnarchiveFromDataTransformerName}];
    return self;
}

- (void) dealloc
{
    for (NSString *bindingName in [_actions allKeys]) {
        [self unbind:bindingName];
    }
}

#pragma mark Bindings

- (void) bindShortcutWithDefaultsKey: (NSString*) defaultsKeyName toAction: (dispatch_block_t) action
{
    [_actions setObject:[action copy] forKey:defaultsKeyName];
    [self bind:defaultsKeyName toObject:[NSUserDefaultsController sharedUserDefaultsController]
        withKeyPath:[@"values." stringByAppendingString:defaultsKeyName] options:_bindingOptions];
}

- (void) breakBindingWithDefaultsKey: (NSString*) defaultsKeyName
{
    [_shortcutMonitor unregisterShortcut:[_shortcuts objectForKey:defaultsKeyName]];
    [_shortcuts removeObjectForKey:defaultsKeyName];
    [_actions removeObjectForKey:defaultsKeyName];
    [self unbind:defaultsKeyName];
}

- (BOOL) isRegisteredAction: (NSString*) name
{
    return !![_actions objectForKey:name];
}

- (id) valueForUndefinedKey: (NSString*) key
{
    return [self isRegisteredAction:key] ?
        [_shortcuts objectForKey:key] :
        [super valueForUndefinedKey:key];
}

- (void) setValue: (id) value forUndefinedKey: (NSString*) key
{
    if (![self isRegisteredAction:key]) {
        [super setValue:value forUndefinedKey:key];
        return;
    }

    MASShortcut *newShortcut = value;
    MASShortcut *currentShortcut = [_shortcuts objectForKey:key];

    // Unbind previous shortcut if any
    if (currentShortcut != nil) {
        [_shortcutMonitor unregisterShortcut:currentShortcut];
    }

    // Just deleting the old shortcut
    if (newShortcut == nil) {
        return;
    }

    // Bind new shortcut
    [_shortcuts setObject:newShortcut forKey:key];
    [_shortcutMonitor registerShortcut:newShortcut withAction:[_actions objectForKey:key]];
}

@end
