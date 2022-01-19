#import "MASShortcutView+Bindings.h"
#import "MASSettings.h"
#import "MASSecureDataTransformer.h"

@implementation MASShortcutView (Bindings)

- (NSString*) associatedUserDefaultsKey
{
    NSDictionary* bindingInfo = [self infoForBinding:MASShortcutBinding];
    if (bindingInfo != nil) {
        NSString *keyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
        NSString *key = [keyPath stringByReplacingOccurrencesOfString:@"values." withString:@""];
        return key;
    } else {
        return nil;
    }
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformer: (NSValueTransformer*) transformer
{
    // Break previous binding if any
    NSString *currentKey = [self associatedUserDefaultsKey];
    if (currentKey != nil) {
        [self unbind:currentKey];
    }

    // Stop if the new binding is nil
    if (newKey == nil) {
        return;
    }

    NSDictionary *options = transformer ?
        @{NSValueTransformerBindingOption:transformer} :
        nil;

    NSUserDefaultsController *userDefaultsController = [MASSettings userDefaultsController];

    @try
    {
        [self bind:MASShortcutBinding
          toObject:userDefaultsController
       withKeyPath:[@"values." stringByAppendingString:newKey]
           options:options];
    }
    @catch (NSException *exception)
    {
        @try
        {
            // Attempt to use previous transformer to decode the value.
            NSData *oldData = [userDefaultsController.values valueForKey:newKey];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSValueTransformer *oldTransformer = [NSValueTransformer valueTransformerForName:NSKeyedUnarchiveFromDataTransformerName];
#pragma clang diagnostic pop
            MASShortcut *oldValue = [oldTransformer transformedValue:oldData];
            NSData *newData = [transformer reverseTransformedValue:oldValue];
            [userDefaultsController.values setValue:newData forKey:newKey];
        }
        @catch (NSException *exception)
        {
            // Things got really bad - remove old value.
            [userDefaultsController.values setValue:nil forKey:newKey];
        }

        [self bind:MASShortcutBinding
          toObject:userDefaultsController
       withKeyPath:[@"values." stringByAppendingString:newKey]
           options:options];
    }
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformerName: (NSString*) transformerName
{
    [self setAssociatedUserDefaultsKey:newKey withTransformer:[NSValueTransformer valueTransformerForName:transformerName]];
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey
{
    [MASSecureDataTransformer registerIfNeeded];
    
    [self setAssociatedUserDefaultsKey:newKey withTransformerName:MASSecureDataTransformerName];
}

@end
