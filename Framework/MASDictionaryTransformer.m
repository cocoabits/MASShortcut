#import "MASDictionaryTransformer.h"
#import "MASShortcut.h"

static NSString *const MASKeyCodeKey = @"keyCode";
static NSString *const MASModifierFlagsKey = @"modifierFlags";

@implementation MASDictionaryTransformer

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

- (NSDictionary*) reverseTransformedValue: (MASShortcut*) shortcut
{
    return @{
        MASKeyCodeKey: @([shortcut keyCode]),
        MASModifierFlagsKey: @([shortcut modifierFlags])
    };
}

- (MASShortcut*) transformedValue: (NSDictionary*) dictionary
{
    // We have to be defensive here as the value may come from user defaults.
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    id keyCodeBox = [dictionary objectForKey:MASKeyCodeKey];
    id modifierFlagsBox = [dictionary objectForKey:MASModifierFlagsKey];

    SEL integerValue = @selector(integerValue);
    if (![keyCodeBox respondsToSelector:integerValue] || ![modifierFlagsBox respondsToSelector:integerValue]) {
        return nil;
    }

    return [MASShortcut
        shortcutWithKeyCode:[keyCodeBox integerValue]
        modifierFlags:[modifierFlagsBox integerValue]];
}

@end
