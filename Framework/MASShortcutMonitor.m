#import "MASShortcutMonitor.h"
#import "MASHotKey.h"

@interface MASShortcutMonitor ()
@property(assign) EventHandlerRef eventHandlerRef;
@property(strong) NSMutableDictionary *hotKeys;
@end

static OSStatus MASCarbonEventCallback(EventHandlerCallRef, EventRef, void*);

@implementation MASShortcutMonitor

- (instancetype) init
{
    self = [super init];
    [self setHotKeys:[NSMutableDictionary dictionary]];
    EventTypeSpec hotKeyPressedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed };
    OSStatus status = InstallEventHandler(GetEventDispatcherTarget(), MASCarbonEventCallback,
        1, &hotKeyPressedSpec, (__bridge void*)self, &_eventHandlerRef);
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

#pragma mark Registration

- (void) registerShortcut: (MASShortcut*) shortcut withAction: (dispatch_block_t) action
{
    MASHotKey *hotKey = [MASHotKey registeredHotKeyWithShortcut:shortcut];
    [hotKey setAction:action];
    [_hotKeys setObject:hotKey forKey:shortcut];
}

- (void) unregisterShortcut: (MASShortcut*) shortcut
{
    [_hotKeys removeObjectForKey:shortcut];
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
