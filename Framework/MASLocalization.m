#import "MASLocalization.h"
#import "MASShortcut.h"

// The CocoaPods trickery here is needed because when the code
// is built as a part of CocoaPods, it won’t make a separate framework
// and the Localized.strings file won’t be bundled correctly.
// See https://github.com/shpakovski/MASShortcut/issues/74
NSString *MASLocalizedString(NSString *key, NSString *comment) {
    static NSBundle *localizationBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *cocoaPodsBundleURL = [[NSBundle mainBundle] URLForResource:@"MASShortcut" withExtension:@"bundle"];
        localizationBundle = cocoaPodsBundleURL ?
            [NSBundle bundleWithURL:cocoaPodsBundleURL] :
            [NSBundle bundleForClass:[MASShortcut class]];
    });
    return [localizationBundle localizedStringForKey:key value:@"XXX" table:@"Localizable"];
}
