#import "MASShortcutMonitor.h"
#import "MASHotKey.h"

@interface MASShortcutMonitor ()
@property(assign) EventHandlerRef eventHandlerRef;
@property(strong) NSMutableDictionary *hotKeys;
@end

static OSStatus MASCarbonEventCallback(EventHandlerCallRef, EventRef, void*);

@implementation MASShortcutMonitor

#pragma mark Initialization

- (instancetype) init
{
    self = [super init];
    [self setHotKeys:[NSMutableDictionary dictionary]];

    OSStatus status = [self installEventHandlersWithKeyup:NO];

    if (status != noErr) {
        return nil;
    }
    return self;
}

- (instancetype) initWithKeyUp
{
    self = [super init];
    [self setHotKeys:[NSMutableDictionary dictionary]];

    OSStatus status = [self installEventHandlersWithKeyup:YES];

    if (status != noErr) {
        return nil;
    }
    return self;
}

- (void) dealloc
{
    if (_eventHandlerRef) {
        RemoveEventHandler(_eventHandlerRef);
        _eventHandlerRef = NULL;
    }
}

+ (instancetype) sharedMonitor
{
    static dispatch_once_t once;
    static MASShortcutMonitor *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype) sharedMonitorWithKeyUp
{
    static dispatch_once_t once;
    static MASShortcutMonitor *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithKeyUp];
    });
    return sharedInstance;
}

- (OSStatus) installEventHandlersWithKeyup: (BOOL) keyUp
{
    EventTypeSpec hotKeyPressedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed };
    

    OSStatus status;
    
    if (keyUp) {
        EventTypeSpec hotKeyReleasedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyReleased };
        struct EventTypeSpec *eventTypeSpecs = malloc(sizeof(struct EventTypeSpec) * 2);
        eventTypeSpecs[0] = hotKeyPressedSpec;
        eventTypeSpecs[1] = hotKeyReleasedSpec;
        
        status = [self installEventHandlers:2 withEventTypeSpecs:eventTypeSpecs];
    } else {
        status = [self installEventHandlers:1 withEventTypeSpecs:&hotKeyPressedSpec];
    }
    
    return status;
}

- (OSStatus) installEventHandlers: (int) itemCount withEventTypeSpecs: (EventTypeSpec *) eventTypeSpecs
{
    OSStatus status = InstallEventHandler(GetEventDispatcherTarget(),
                                          MASCarbonEventCallback,
                                          itemCount,
                                          eventTypeSpecs,
                                          (__bridge void*)self,
                                          &_eventHandlerRef);
    
    return status;
}


#pragma mark Registration

- (BOOL) registerShortcut: (MASShortcut*) shortcut withAction: (dispatch_block_t) action
{
    MASHotKey *hotKey = [MASHotKey registeredHotKeyWithShortcut:shortcut];
    if (hotKey) {
        [hotKey setAction:action];
        [_hotKeys setObject:hotKey forKey:shortcut];
        return YES;
    } else {
        return NO;
    }
}

- (void) unregisterShortcut: (MASShortcut*) shortcut
{
    if (shortcut) {
        [_hotKeys removeObjectForKey:shortcut];
    }
}

- (void) unregisterAllShortcuts
{
    [_hotKeys removeAllObjects];
}

- (BOOL) isShortcutRegistered: (MASShortcut*) shortcut
{
    return !![_hotKeys objectForKey:shortcut];
}

#pragma mark Event Handling

- (void) handleEvent: (EventRef) event
{
    if (GetEventClass(event) != kEventClassKeyboard) {
        return;
    }

    EventHotKeyID hotKeyID;
    OSStatus status = GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
    if (status != noErr || hotKeyID.signature != MASHotKeySignature) {
        return;
    }

    [_hotKeys enumerateKeysAndObjectsUsingBlock:^(MASShortcut *shortcut, MASHotKey *hotKey, BOOL *stop) {
        if (hotKeyID.id == [hotKey carbonID]) {
            if ([hotKey action]) {
                dispatch_async(dispatch_get_main_queue(), [hotKey action]);
            }
            *stop = YES;
        }
    }];
}

@end

static OSStatus MASCarbonEventCallback(EventHandlerCallRef _, EventRef event, void *context)
{
    MASShortcutMonitor *dispatcher = (__bridge id)context;
    [dispatcher handleEvent:event];
    return noErr;
}
