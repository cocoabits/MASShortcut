#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, assign) IBOutlet MASShortcutView *shortcutView;
@end

@implementation AppDelegate

- (void) awakeFromNib
{
    [super awakeFromNib];

    static NSString *const ShortcutKey = @"customShortcut";

    // Bind the shortcut recorder view’s value to user defaults.
    // Run “defaults read com.shpakovski.mac.Demo” to see what’s stored
    // in user defaults.
    [_shortcutView setAssociatedUserDefaultsKey:ShortcutKey];

    // Play a ping sound when the shortcut stored in user defaults is pressed.
    // Note that when the shortcut stored in user defaults changes, you don’t have
    // to update anything: the old shortcut will automatically stop working and
    // the sound will play after pressing the new one.
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:ShortcutKey toAction:^{
        [[NSSound soundNamed:@"Ping"] play];
    }];
}

#pragma mark NSApplicationDelegate

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) sender
{
    return YES;
}

@end
