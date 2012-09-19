#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

@interface MASShortcutUserDefaultsHotKey : NSObject

@property (nonatomic, readonly) NSString *userDefaultsKey;
@property (nonatomic, copy) void (^handler)();
@property (nonatomic, weak) id monitor;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;

@end

#pragma mark -

@implementation MASShortcut (UserDefaults)

+ (NSMutableDictionary *)registeredUserDefaultsHotKeys
{
    static NSMutableDictionary *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [NSMutableDictionary dictionary];
    });
    return shared;
}

+ (void)registerGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;
{
    MASShortcutUserDefaultsHotKey *hotKey = [[MASShortcutUserDefaultsHotKey alloc] initWithUserDefaultsKey:userDefaultsKey handler:handler];
    [[self registeredUserDefaultsHotKeys] setObject:hotKey forKey:userDefaultsKey];
}

+ (void)unregisterGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSMutableDictionary *registeredHotKeys = [self registeredUserDefaultsHotKeys];
    [registeredHotKeys removeObjectForKey:userDefaultsKey];
}

@end

#pragma mark -

@implementation MASShortcutUserDefaultsHotKey

@synthesize monitor = _monitor;
@synthesize handler = _handler;
@synthesize userDefaultsKey = _userDefaultsKey;

#pragma mark -

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler
{
    self = [super init];
    if (self) {
        _userDefaultsKey = userDefaultsKey.copy;
        _handler = [handler copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
        [self installHotKeyFromUserDefaults];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
    [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
}

#pragma mark -

- (void)userDefaultsDidChange:(NSNotification *)note
{
    [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
    [self installHotKeyFromUserDefaults];
}

- (void)installHotKeyFromUserDefaults
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:_userDefaultsKey];
    MASShortcut *shortcut = [MASShortcut shortcutWithData:data];
    if (shortcut == nil) return;
    self.monitor = [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:self.handler];
}

@end
