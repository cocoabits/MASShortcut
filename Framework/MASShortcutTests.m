#import "MASShortcut.h"

@interface MASShortcutTests : XCTestCase
@end

@implementation MASShortcutTests

- (void) testShortcutRecorderCompatibility
{
    MASShortcut *key = [MASShortcut shortcutWithKeyCode:87 modifierFlags:1048576];
    XCTAssertEqualObjects([key description], @"⌘5", @"Basic compatibility with the keycode & modifier combination used by Shortcut Recorder.");
}

@end
