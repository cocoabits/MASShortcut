#import "MASShortcut+Monitoring.h"

NSMutableDictionary *MASRegisteredHotKeys();
BOOL InstallCommonEventHandler();
void UninstallEventHandler();
void InstallHotkeyWithShortcut(MASShortcut *shortcut, UInt32 *outCarbonHotKeyID, EventHotKeyRef *outCarbonHotKey);

#pragma mark -

@interface MASShortcutHotKey : NSObject {
    MASShortcut *_shortcut;
    void (^_handler)();
    EventHotKeyRef _carbonHotKey;
    UInt32 _carbonHotKeyID;
}

@property (nonatomic, readonly) MASShortcut *shortcut;
@property (nonatomic, readonly, copy) void (^handler)();
@property (nonatomic, readonly) EventHotKeyRef carbonHotKey;
@property (nonatomic, readonly) UInt32 carbonHotKeyID;

- (id)initWithShortcut:(MASShortcut *)shortcut handler:(void (^)())handler;

@end

#pragma mark -

@implementation MASShortcut (Monitoring)

+ (id)addGlobalHotkeyMonitorWithShortcut:(MASShortcut *)shortcut handler:(void (^)())handler
{
    NSString *monitor = [NSString stringWithFormat:@"%p: %@", shortcut, shortcut.description];
    MASShortcutHotKey *hotKey = [[[MASShortcutHotKey alloc] initWithShortcut:shortcut handler:handler] autorelease];
    [MASRegisteredHotKeys() setObject:hotKey forKey:monitor];
    return monitor;
}

+ (void)removeGlobalHotkeyMonitor:(id)monitor
{
    if (monitor == nil) return;
    NSMutableDictionary *registeredHotKeys = MASRegisteredHotKeys();
    [registeredHotKeys removeObjectForKey:monitor];
    if (registeredHotKeys.count == 0) {
        UninstallEventHandler();
    }
}

@end

#pragma mark -

@implementation MASShortcutHotKey

@synthesize carbonHotKeyID = _carbonHotKeyID;
@synthesize handler = _handler;
@synthesize shortcut = _shortcut;
@synthesize carbonHotKey = _carbonHotKey;

#pragma mark -

- (id)initWithShortcut:(MASShortcut *)shortcut handler:(void (^)())handler
{
    self = [super init];
    if (self) {
        _shortcut = [shortcut retain];
        _handler = [handler copy];
        InstallHotkeyWithShortcut(shortcut, &_carbonHotKeyID, &_carbonHotKey);
    }
    return self;
}

- (void)dealloc
{
    [self uninstallExisitingHotKey];
    [_shortcut release];
    [_handler release];
    [super dealloc];
}

- (void)uninstallExisitingHotKey
{
    if (_carbonHotKey) {
        UnregisterEventHotKey(_carbonHotKey);
        _carbonHotKey = NULL;
    }
}

@end

#pragma mark - Carbon magic

NSMutableDictionary *MASRegisteredHotKeys()
{
    static NSMutableDictionary *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NSMutableDictionary alloc] init];
    });
    return shared;
}

#pragma mark -

FourCharCode const kMASShortcutSignature = 'MASS';

void InstallHotkeyWithShortcut(MASShortcut *shortcut, UInt32 *outCarbonHotKeyID, EventHotKeyRef *outCarbonHotKey)
{
    if ((shortcut == nil) || !InstallCommonEventHandler()) return;

    static UInt32 sCarbonHotKeyID = 0;
	EventHotKeyID hotKeyID = { .signature = kMASShortcutSignature, .id = ++ sCarbonHotKeyID };
    EventHotKeyRef carbonHotKey = NULL;
    if (RegisterEventHotKey(shortcut.carbonKeyCode, shortcut.carbonFlags, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &carbonHotKey) != noErr) {
        carbonHotKey = NULL;
    }

    if (outCarbonHotKeyID) *outCarbonHotKeyID = hotKeyID.id;
    if (outCarbonHotKey) *outCarbonHotKey = carbonHotKey;
}

static OSStatus CarbonCallback(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
	if (GetEventClass(inEvent) != kEventClassKeyboard) return noErr;

	EventHotKeyID hotKeyID;
	OSStatus status = GetEventParameter(inEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	if (status != noErr) return status;

	if (hotKeyID.signature != kMASShortcutSignature) return noErr;

    [MASRegisteredHotKeys() enumerateKeysAndObjectsUsingBlock:^(id key, MASShortcutHotKey *hotKey, BOOL *stop) {
        if (hotKeyID.id == hotKey.carbonHotKeyID) {
            if (hotKey.handler) {
                hotKey.handler();
            }
            *stop = YES;
        }
    }];

	return noErr;
}

#pragma mark -

static EventHandlerRef sEventHandler = NULL;

BOOL InstallCommonEventHandler()
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

void UninstallEventHandler()
{
    if (sEventHandler) {
        RemoveEventHandler(sEventHandler);
        sEventHandler = NULL;
    }
}
