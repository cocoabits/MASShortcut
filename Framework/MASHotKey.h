#import "MASShortcut.h"

NS_ASSUME_NONNULL_BEGIN

extern FourCharCode const MASHotKeySignature;

@interface MASHotKey : NSObject

@property(readonly) UInt32 carbonID;
@property(copy) dispatch_block_t action;

+ (nullable instancetype) registeredHotKeyWithShortcut: (MASShortcut*) shortcut;

@end

NS_ASSUME_NONNULL_END
