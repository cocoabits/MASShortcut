#import "MASLocalization.h"
#import "MASShortcut.h"

// The CocoaPods trickery here is needed because when the code
// is built as a part of CocoaPods, it won’t make a separate framework
// and the Localized.strings file won’t be bundled correctly.
// See https://github.com/shpakovski/MASShortcut/issues/74
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
