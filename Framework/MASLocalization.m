#import "MASLocalization.h"
#import "MASShortcut.h"

static NSString *const MASLocalizationTableName = @"Localizable";
static NSString *const MASPlaceholderLocalizationString = @"XXX";

// The CocoaPods trickery here is needed because when the code
// is built as a part of CocoaPods, it won’t make a separate framework
// and the Localized.strings file won’t be bundled correctly.
// See https://github.com/shpakovski/MASShortcut/issues/74
NSString *MASLocalizedString(NSString *key, NSString *comment) {
    static NSBundle *localizationBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[MASShortcut class]];
        NSURL *cocoaPodsBundleURL = [[NSBundle mainBundle] URLForResource:@"MASShortcut" withExtension:@"bundle"];
        if (cocoaPodsBundleURL) {
            NSBundle *cocoaPodsBundle = [NSBundle bundleWithURL:cocoaPodsBundleURL];
            NSString *testingString = [cocoaPodsBundle
                localizedStringForKey:@"Cancel"
                value:MASPlaceholderLocalizationString
                table:MASLocalizationTableName];
            if (![testingString isEqualToString:MASPlaceholderLocalizationString]) {
                // We have a CocoaPods bundle and it works, use it.
                localizationBundle = cocoaPodsBundle;
            } else {
                // We have a CocoaPods bundle, but it doesn’t contain
                // the localization files. Let’s use the framework bundle instead.
                localizationBundle = frameworkBundle;
            }
        } else {
            // CocoaPods bundle not present, use the framework bundle.
            localizationBundle = frameworkBundle;
        }
    });
    return [localizationBundle localizedStringForKey:key
        value:MASPlaceholderLocalizationString
        table:MASLocalizationTableName];
}
