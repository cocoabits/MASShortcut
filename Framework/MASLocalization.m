#import "MASLocalization.h"
#import "MASShortcut.h"

NSString *MASLocalizedString(NSString *key, NSString *comment) {
    NSBundle *frameworkBundle = nil;
#ifdef COCOAPODS
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"MASShortcut" withExtension:@"bundle"];
    frameworkBundle = [NSBundle bundleWithURL:bundleURL];
#else
    frameworkBundle = [NSBundle bundleForClass:[MASShortcut class]];
#endif
    return [frameworkBundle localizedStringForKey:key value:@"XXX" table:@"Localizable"];
}
