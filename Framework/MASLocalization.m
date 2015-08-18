#import "MASLocalization.h"
#import "MASShortcut.h"

NSString *MASLocalizedString(NSString *key, NSString *comment) {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[MASShortcut class]];
    return [frameworkBundle localizedStringForKey:key value:@"XXX" table:@"Localizable"];
}
