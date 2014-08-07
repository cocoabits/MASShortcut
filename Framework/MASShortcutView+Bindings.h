#import "MASShortcutView.h"

/**
    @brief A simplified interface to bind the recorder value to user defaults.

    You can bind the @p shortcutValue to user defaults using the standard
    @p bind:toObject:withKeyPath:options: call, but since that’s a lot to type
    and read, here’s a simpler option.

    Setting the @p associatedUserDefaultsKey binds the view’s shortcut value
    to the given user defaults key. You can supply a value transformer to convert
    values between user defaults and @p MASShortcut. If you don’t supply
    a transformer, the @p NSUnarchiveFromDataTransformerName will be used
    automatically.

    Set @p associatedUserDefaultsKey to @p nil to disconnect the binding.
*/
@interface MASShortcutView (Bindings)

@property(copy) NSString *associatedUserDefaultsKey;

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformer: (NSValueTransformer*) transformer;
- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformerName: (NSString*) transformerName;

@end
