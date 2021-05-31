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
        localizationBundle = SWIFTPM_MODULE_BUNDLE;
    });
    return [localizationBundle localizedStringForKey:key
        value:MASPlaceholderLocalizationString
        table:MASLocalizationTableName];
}
