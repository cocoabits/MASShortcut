#import "MASShortcutBinder.h"

static NSString *const SampleDefaultsKey = @"sampleShortcut";

@interface MASShortcutBinderTests : XCTestCase
@property(strong) MASShortcutBinder *binder;
@property(strong) MASShortcutMonitor *monitor;
@property(strong) NSUserDefaults *defaults;
@end

@implementation MASShortcutBinderTests

- (void) setUp
{
    [super setUp];

    [self setBinder:[[MASShortcutBinder alloc] init]];
    [self setMonitor:[[MASShortcutMonitor alloc] init]];
    [_binder setShortcutMonitor:_monitor];

    [self setDefaults:[[NSUserDefaults alloc] init]];
    [_defaults removeObjectForKey:SampleDefaultsKey];
}

- (void) tearDown
{
    [self setMonitor:nil];
    [self setDefaults:nil];
    [self setBinder:nil];
    [super tearDown];
}

- (void) testInitialValueReading
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:1 modifierFlags:1];
    [_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shortcut] forKey:SampleDefaultsKey];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    XCTAssertTrue([_monitor isShortcutRegistered:shortcut],
        @"Pass the initial shortcut from defaults to shortcut monitor.");
}

- (void) testValueChangeReading
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:1 modifierFlags:1];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    [_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shortcut] forKey:SampleDefaultsKey];
    XCTAssertTrue([_monitor isShortcutRegistered:shortcut],
        @"Pass the shortcut from defaults to shortcut monitor after defaults change.");
}

- (void) testValueClearing
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:1 modifierFlags:1];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    [_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shortcut] forKey:SampleDefaultsKey];
    [_defaults removeObjectForKey:SampleDefaultsKey];
    XCTAssertFalse([_monitor isShortcutRegistered:shortcut],
        @"Unregister shortcut from monitor after value is cleared from defaults.");
}

- (void) testBindingRemoval
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:1 modifierFlags:1];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    [_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shortcut] forKey:SampleDefaultsKey];
    [_binder breakBindingWithDefaultsKey:SampleDefaultsKey];
    XCTAssertFalse([_monitor isShortcutRegistered:shortcut],
        @"Unregister shortcut from monitor after binding was removed.");
}

- (void) testRebinding
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:1 modifierFlags:1];
    [_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shortcut] forKey:SampleDefaultsKey];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    [_binder breakBindingWithDefaultsKey:SampleDefaultsKey];
    [_binder bindShortcutWithDefaultsKey:SampleDefaultsKey toAction:^{}];
    XCTAssertTrue([_monitor isShortcutRegistered:shortcut],
        @"Bind after unbinding.");
}

@end
