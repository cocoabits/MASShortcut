#import "MASKeyCodes.h"

@interface MASShortcut : NSObject <NSCoding>

@property (nonatomic) NSUInteger keyCode;
@property (nonatomic) NSUInteger modifierFlags;
@property (nonatomic, readonly) UInt32 carbonKeyCode;
@property (nonatomic, readonly) UInt32 carbonFlags;
@property (nonatomic, readonly) NSString *keyCodeString;
@property (nonatomic, readonly) NSString *keyCodeStringForKeyEquivalent;
@property (nonatomic, readonly) NSString *modifierFlagsString;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) BOOL shouldBypass;

- (instancetype)initWithKeyCode:(NSUInteger)code modifierFlags:(NSUInteger)flags;

+ (instancetype)shortcutWithKeyCode:(NSUInteger)code modifierFlags:(NSUInteger)flags;
+ (instancetype)shortcutWithEvent:(NSEvent *)anEvent;
+ (instancetype)shortcutWithData:(NSData *)aData;

@end
