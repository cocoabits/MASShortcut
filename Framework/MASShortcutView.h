@class MASShortcut, MASShortcutValidator;

typedef enum {
    MASShortcutViewAppearanceDefault = 0,  // Height = 19 px
    MASShortcutViewAppearanceTexturedRect, // Height = 25 px
    MASShortcutViewAppearanceRounded,      // Height = 43 px
    MASShortcutViewAppearanceFlat
} MASShortcutViewAppearance;

@interface MASShortcutView : NSView

@property (nonatomic, strong) MASShortcut *shortcutValue;
@property (nonatomic, strong) MASShortcutValidator *shortcutValidator;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^shortcutValueChange)(MASShortcutView *sender);
@property (nonatomic) MASShortcutViewAppearance appearance;

/// Returns custom class for drawing control.
+ (Class)shortcutCellClass;

@end
