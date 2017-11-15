#import "MASHotKey.h"

FourCharCode const MASHotKeySignature = 'MASS';

@interface MASHotKey ()
@property(assign) EventHotKeyRef hotKeyRef;
@property(assign) UInt32 carbonID;
@property(assign) UInt32 carbonKeyCode;
@property(assign) UInt32 carbonFlags;
@end

@implementation MASHotKey

- (instancetype) initWithShortcut: (MASShortcut*) shortcut
{
    self = [super init];

    static UInt32 CarbonHotKeyID = 0;

    _carbonID = ++CarbonHotKeyID;
    _carbonKeyCode = [shortcut carbonKeyCode];
    _carbonFlags = [shortcut carbonFlags];
    
    if (![self activate])
        return nil;

    return self;
}

+ (instancetype) registeredHotKeyWithShortcut: (MASShortcut*) shortcut
{
    return [[self alloc] initWithShortcut:shortcut];
}

- (void) dealloc
{
    [self deactivate];
}

- (BOOL) activate {
    if (_hotKeyRef)
        return YES;
    
    EventHotKeyID hotKeyID = { .signature = MASHotKeySignature, .id = _carbonID };
    OSStatus status = RegisterEventHotKey(_carbonKeyCode, _carbonFlags, hotKeyID,
                                          GetEventDispatcherTarget(), 0, &_hotKeyRef);
    return status == noErr;
}

- (void) deactivate {
    if (_hotKeyRef) {
        UnregisterEventHotKey(_hotKeyRef);
        _hotKeyRef = NULL;
    }
}

@end
