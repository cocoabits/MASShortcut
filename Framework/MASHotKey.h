#import "MASShortcut.h"

extern FourCharCode const MASHotKeySignature;

@interface MASHotKey : NSObject

@property(readonly) UInt32 carbonID;
@property(copy) dispatch_block_t action;
@property(copy) dispatch_block_t actionUp;

+ (instancetype) registeredHotKeyWithShortcut: (MASShortcut*) shortcut;

@end
