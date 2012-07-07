#import "MASShortcut+UserDefaults.h"

@interface MASShortcutHotKey : NSObject

@property (nonatomic, readonly) NSString *userDefaultsKey;
@property (nonatomic, readonly, copy) void (^handler)();
@property (nonatomic, readonly) EventHotKeyRef carbonHotKey;
@property (nonatomic, readonly) UInt32 carbonHotKeyID;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;

+ (void)uninstallEventHandler;

@end

#pragma mark -

@implementation MASShortcut (UserDefaults)

+ (NSMutableDictionary *)registeredHotKeys
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
    MASShortcutHotKey *hotKey = [[MASShortcutHotKey alloc] initWithUserDefaultsKey:userDefaultsKey handler:handler];
    [[self registeredHotKeys] setObject:hotKey forKey:userDefaultsKey];
}

+ (void)unregisterGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSMutableDictionary *registeredHotKeys = [self registeredHotKeys];
    [registeredHotKeys removeObjectForKey:userDefaultsKey];
    if (registeredHotKeys.count == 0) {
        [MASShortcutHotKey uninstallEventHandler];
    }
}

@end

#pragma mark -

@implementation MASShortcutHotKey

@synthesize carbonHotKeyID = _carbonHotKeyID;
@synthesize handler = _handler;
@synthesize userDefaultsKey = _userDefaultsKey;
@synthesize carbonHotKey = _carbonHotKey;

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
    [self uninstallExisitingHotKey];
}

#pragma mark -

- (void)userDefaultsDidChange:(NSNotification *)note
{
    [self uninstallExisitingHotKey];
    [self installHotKeyFromUserDefaults];
}

#pragma mark - Carbon events

static EventHandlerRef sEventHandler = NULL;

+ (BOOL)installCommonEventHandler
{
    if (sEventHandler == NULL) {
        EventTypeSpec hotKeyPressedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed };
        OSStatus status = InstallEventHandler(GetEventDispatcherTarget(), CarbonCallback, 1, &hotKeyPressedSpec, NULL, &sEventHandler);
        if (status != noErr) {
            sEventHandler = NULL;
            return NO;
        }
    }
    return YES;
}

+ (void)uninstallEventHandler
{
    if (sEventHandler) {
        RemoveEventHandler(sEventHandler);
        sEventHandler = NULL;
    }
}

#pragma mark -

- (void)uninstallExisitingHotKey
{
    if (_carbonHotKey) {
        UnregisterEventHotKey(_carbonHotKey);
        _carbonHotKey = NULL;
    }
}

FourCharCode const kMASShortcutSignature = 'MASS';

- (void)installHotKeyFromUserDefaults
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:_userDefaultsKey];
    MASShortcut *shortcut = [MASShortcut shortcutWithData:data];
    if ((shortcut == nil) || ![[self class] installCommonEventHandler]) return;

    static UInt32 sCarbonHotKeyID = 0;
    _carbonHotKeyID = ++ sCarbonHotKeyID;
	EventHotKeyID hotKeyID = { .signature = kMASShortcutSignature, .id = _carbonHotKeyID };
    if (RegisterEventHotKey(shortcut.carbonKeyCode, shortcut.carbonFlags, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &_carbonHotKey) != noErr) {
        _carbonHotKey = NULL;
    }
}

static OSStatus CarbonCallback(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
	if (GetEventClass(inEvent) != kEventClassKeyboard) return noErr;

	EventHotKeyID hotKeyID;
	OSStatus status = GetEventParameter(inEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	if (status != noErr) return status;

	if (hotKeyID.signature != kMASShortcutSignature) return noErr;

    [[MASShortcut registeredHotKeys] enumerateKeysAndObjectsUsingBlock:^(id key, MASShortcutHotKey *hotKey, BOOL *stop) {
        if (hotKeyID.id == hotKey.carbonHotKeyID) {
            if (hotKey.handler) {
                hotKey.handler();
            }
            *stop = YES;
        }
    }];

	return noErr;
}

@end