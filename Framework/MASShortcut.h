#import "MASKeyCodes.h"

@interface MASShortcut : NSObject <NSSecureCoding>

@property (nonatomic) NSUInteger keyCode;
@property (nonatomic) NSUInteger modifierFlags;
@property (nonatomic, readonly) UInt32 carbonKeyCode;
@property (nonatomic, readonly) UInt32 carbonFlags;
@property (nonatomic, readonly) NSString *keyCodeString;
@property (nonatomic, readonly) NSString *keyCodeStringForKeyEquivalent;
@property (nonatomic, readonly) NSString *modifierFlagsString;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) BOOL shouldBypass;

- (id)initWithKeyCode:(NSUInteger)code modifierFlags:(NSUInteger)flags;

+ (MASShortcut *)shortcutWithKeyCode:(NSUInteger)code modifierFlags:(NSUInteger)flags;
+ (MASShortcut *)shortcutWithEvent:(NSEvent *)anEvent;
+ (MASShortcut *)shortcutWithData:(NSData *)aData;

@end
