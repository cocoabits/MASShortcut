#import "AppDelegate.h"
#import <MASShortcut/Shortcut.h>

NSString *const MASPreferenceKeyShortcut = @"MASDemoShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASDemoShortcutEnabled";
NSString *const MASPreferenceKeyConstantShortcutEnabled = @"MASDemoConstantShortcutEnabled";

@implementation AppDelegate {
    __weak id _constantShortcutMonitor;
}

@synthesize window = _window;
@synthesize shortcutView = _shortcutView;

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Checkbox will enable and disable the shortcut view
    [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
}

- (void)dealloc
{
    // Cleanup
    [self.shortcutView unbind:@"enabled"];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Uncomment the following lines to make Command-Shift-D the default shortcut
//    MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:0x2 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
//    [MASShortcut setGlobalShortcut:defaultShortcut forUserDefaultsKey:MASPreferenceKeyShortcut];

    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;

    // Activate the global keyboard shortcut if it was enabled last time
    [self resetShortcutRegistration];

    // Activate the shortcut Command-F1 if it was enabled
    [self resetConstantShortcutRegistration];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark - Custom shortcut

- (BOOL)isShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled];
}

- (void)setShortcutEnabled:(BOOL)enabled
{
    if (self.shortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyShortcutEnabled];
        [self resetShortcutRegistration];
    }
}

- (void)resetShortcutRegistration
{
    if (self.shortcutEnabled) {
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut handler:^{
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Global hotkey has been pressed.", @"Alert message for custom shortcut")
                             defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on custom shortcut")
                           alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
        }];
    }
    else {
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut];
    }
}

#pragma mark - Constant shortcut

- (BOOL)isConstantShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyConstantShortcutEnabled];
}

- (void)setConstantShortcutEnabled:(BOOL)enabled
{
    if (self.constantShortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyConstantShortcutEnabled];
        [self resetConstantShortcutRegistration];
    }
}

- (void)resetConstantShortcutRegistration
{
    if (self.constantShortcutEnabled) {
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_F2 modifierFlags:NSCommandKeyMask];
        _constantShortcutMonitor = [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
            [[NSAlert alertWithMessageText:NSLocalizedString(@"⌘F2 has been pressed.", @"Alert message for constant shortcut")
                             defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on constant shortcut")
                           alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
        }];
    }
    else {
        [MASShortcut removeGlobalHotkeyMonitor:_constantShortcutMonitor];
    }
}

@end
