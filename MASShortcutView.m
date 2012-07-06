#import "MASShortcutView.h"
#import "MASShortcut.h"

#define HINT_BUTTON_WIDTH 23.0f
#define BUTTON_FONT_SIZE 11.0f

#pragma mark -

@interface MASShortcutCell : NSButtonCell @end

#pragma mark -

@interface MASShortcutView () // Private accessors

@property (nonatomic, getter = isHinting) BOOL hinting;
@property (nonatomic, copy) NSString *shortcutPlaceholder;

@end

#pragma mark -

@implementation MASShortcutView {
    NSButtonCell *_shortcutCell;

    NSInteger _shortcutToolTipTag;
    NSInteger _hintToolTipTag;
    NSTrackingArea *_hintArea;
}

- (id)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _shortcutCell = [[MASShortcutCell alloc] init];
        [_shortcutCell setFont:[[NSFontManager sharedFontManager] convertFont:_shortcutCell.font toSize:BUTTON_FONT_SIZE]];
        _enabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [self activateEventMonitoring:NO];
    [self activateResignObserver:NO];
}

#pragma mark - Public accessors

- (void)setEnabled:(BOOL)flag
{
    if (_enabled != flag) {
        _enabled = flag;
        [self updateTrackingAreas];
        self.recording = NO;
        [self setNeedsDisplay:YES];
    }
}

- (void)setRecording:(BOOL)flag
{
    // Only one recorder can be active at the moment
    static MASShortcutView *currentRecorder = nil;
    if (flag && (currentRecorder != self)) {
        currentRecorder.recording = NO;
        currentRecorder = self;
    }
    
    // Only enabled view supports recording
    if (flag && !self.enabled) return;
    
    if (_recording != flag) {
        _recording = flag;
        self.shortcutPlaceholder = nil;
        [self resetToolTips];
        [self activateEventMonitoring:_recording];
        [self activateResignObserver:_recording];
        [self setNeedsDisplay:YES];
    }
}

- (void)setShortcutValue:(MASShortcut *)shortcutValue
{
    _shortcutValue = shortcutValue;
    [self resetToolTips];
    [self setNeedsDisplay:YES];
}

- (void)setShortcutPlaceholder:(NSString *)shortcutPlaceholder
{
    _shortcutPlaceholder = shortcutPlaceholder.copy;
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawInRect:(CGRect)frame withTitle:(NSString *)title alignment:(NSTextAlignment)alignment state:(NSInteger)state
{
    _shortcutCell.title = title;
    _shortcutCell.alignment = alignment;
    _shortcutCell.state = state;
    _shortcutCell.enabled = self.enabled;
    [_shortcutCell drawWithFrame:frame inView:self];
}

- (void)drawRect:(CGRect)dirtyRect
{
    if (self.shortcutValue) {
        [self drawInRect:self.bounds withTitle:MASShortcutChar(self.recording ? kMASShortcutGlyphEscape : kMASShortcutGlyphDeleteLeft)
               alignment:NSRightTextAlignment state:NSOffState];
        
        CGRect shortcutRect;
        [self getShortcutRect:&shortcutRect hintRect:NULL];
        NSString *title = (self.recording
                           ? (_hinting
                              ? NSLocalizedString(@"Use old shortuct", @"Cancel action button for non-empty shortcut in recording state")
                              : (self.shortcutPlaceholder.length > 0
                                 ? self.shortcutPlaceholder
                                 : NSLocalizedString(@"Type new shortcut", @"Non-empty shortcut button in recording state")))
                           : _shortcutValue ? _shortcutValue.description : @"");
        [self drawInRect:shortcutRect withTitle:title alignment:NSCenterTextAlignment state:self.isRecording ? NSOnState : NSOffState];
    }
    else {
        if (self.recording)
        {
            [self drawInRect:self.bounds withTitle:MASShortcutChar(kMASShortcutGlyphEscape) alignment:NSRightTextAlignment state:NSOffState];
            
            CGRect shortcutRect;
            [self getShortcutRect:&shortcutRect hintRect:NULL];
            NSString *title = (_hinting
                               ? NSLocalizedString(@"Click to cancel", @"Cancel action button in recording state")
                               : (self.shortcutPlaceholder.length > 0
                                  ? self.shortcutPlaceholder
                                  : NSLocalizedString(@"Type shortcut", @"Empty shortcut button in recording state")));
            [self drawInRect:shortcutRect withTitle:title alignment:NSCenterTextAlignment state:NSOnState];
        }
        else
        {
            [self drawInRect:self.bounds withTitle:NSLocalizedString(@"Click to record", @"Empty shortcut button in normal state")
                   alignment:NSCenterTextAlignment state:NSOffState];
        }
    }
}

#pragma mark - Mouse handling

- (void)getShortcutRect:(CGRect *)shortcutRectRef hintRect:(CGRect *)hintRectRef
{
    CGRect shortcutRect, hintRect;
    CGRectDivide(self.bounds, &hintRect, &shortcutRect, HINT_BUTTON_WIDTH, CGRectMaxXEdge);
    if (shortcutRectRef)  *shortcutRectRef = shortcutRect;
    if (hintRectRef) *hintRectRef = hintRect;
}

- (BOOL)locationInShortcutRect:(CGPoint)location
{
    CGRect shortcutRect;
    [self getShortcutRect:&shortcutRect hintRect:NULL];
    return CGRectContainsPoint(shortcutRect, [self convertPoint:location fromView:nil]);
}

- (BOOL)locationInHintRect:(CGPoint)location
{
    CGRect hintRect;
    [self getShortcutRect:NULL hintRect:&hintRect];
    return CGRectContainsPoint(hintRect, [self convertPoint:location fromView:nil]);
}

- (void)mouseDown:(NSEvent *)event
{
    if (self.enabled) {
        if (self.shortcutValue) {
            if (self.recording) {
                if ([self locationInHintRect:event.locationInWindow]) {
                    self.recording = NO;
                }
            }
            else {
                if ([self locationInShortcutRect:event.locationInWindow]) {
                    self.recording = YES;
                }
                else {
                    self.shortcutValue = nil;
                }
            }
        }
        else {
            if (self.recording) {
                if ([self locationInHintRect:[event locationInWindow]]) {
                    self.recording = NO;
                }
            }
            else {
                self.recording = YES;
            }
        }
    }
    else {
        [super mouseDown:event];
    }
}

#pragma mark - Handling mouse over

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    if (_hintArea) {
        [self removeTrackingArea:_hintArea];
        _hintArea = nil;
    }
    
    // Forbid hinting if view is disabled
    if (self.enabled) return;
    
    CGRect hintRect;
    [self getShortcutRect:NULL hintRect:&hintRect];
    NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside);
    _hintArea = [[NSTrackingArea alloc] initWithRect:hintRect options:options owner:self userInfo:nil];
    [self addTrackingArea:_hintArea];
}

- (void)setHinting:(BOOL)flag
{
    if (_hinting != flag) {
        _hinting = flag;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    self.hinting = YES;
}

- (void)mouseExited:(NSEvent *)event
{
    self.hinting = NO;
}

void *kUserDataShortcut = &kUserDataShortcut;
void *kUserDataHint = &kUserDataHint;

- (void)resetToolTips
{
    if (_shortcutToolTipTag) {
        [self removeToolTip:_shortcutToolTipTag], _shortcutToolTipTag = 0;
    }
    if (_hintToolTipTag) {
        [self removeToolTip:_hintToolTipTag], _hintToolTipTag = 0;
    }
    
    if ((self.shortcutValue == nil) || self.recording || !self.enabled) return;
    
    CGRect shortcutRect, hintRect;
    [self getShortcutRect:&shortcutRect hintRect:&hintRect];
    _shortcutToolTipTag = [self addToolTipRect:shortcutRect owner:self userData:kUserDataShortcut];
    _hintToolTipTag = [self addToolTipRect:hintRect owner:self userData:kUserDataHint];
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(CGPoint)point userData:(void *)data
{
    if (data == kUserDataShortcut) {
        return NSLocalizedString(@"Click to record new shortcut", @"Tooltip for non-empty shortcut button");
    }
    else if (data == kUserDataHint) {
        return NSLocalizedString(@"Delete shortcut", @"Tooltip for hint button near the non-empty shortcut");
    }
    return nil;
}

#pragma mark - Event monitoring

- (void)activateEventMonitoring:(BOOL)shouldActivate
{
    static BOOL isActive = NO;
    if (isActive == shouldActivate) return;
    isActive = shouldActivate;
    
    static id eventMonitor = nil;
    if (shouldActivate) {
        eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {

            MASShortcut *shortcut = [MASShortcut shortcutWithEvent:event];
            if ((shortcut.keyCode == kVK_Delete) || (shortcut.keyCode == kVK_ForwardDelete)) {
                // Delete shortcut
                self.shortcutValue = nil;
                self.recording = NO;
                event = nil;
            }
            else if (shortcut.keyCode == kVK_Escape) {
                // Cancel recording
                self.recording = NO;
                event = nil;
            }
            else if (shortcut.shouldBypass) {
                // Command + W, Command + Q, ESC should deactivate recorder
                self.recording = NO;
            }
            else {
                // Verify possible shortcut
                if (shortcut.keyCodeString.length > 0) {
                    if (shortcut.hasRequiredModifierFlags) {
                        // Verify that shortcut is not used
                        NSError *error = nil;
                        if ([shortcut isTakenError:&error]) {
                            // Prevent cancel of recording when Alert window is key
                            [self activateResignObserver:NO];
                            [self activateEventMonitoring:NO];
                            NSString *format = NSLocalizedString(@"The key combination %@ cannot be used",
                                                                 @"Title for alert when shortcut is already used");
                            NSRunCriticalAlertPanel([NSString stringWithFormat:format, shortcut], error.localizedDescription,
                                                    NSLocalizedString(@"OK", @"Alert button when shortcut is already used"),
                                                    nil, nil);
                            self.shortcutPlaceholder = nil;
                            [self activateResignObserver:YES];
                            [self activateEventMonitoring:YES];
                        }
                        else {
                            self.shortcutValue = shortcut;
                            self.recording = NO;
                        }
                    }
                    else {
                        // Key press with or without SHIFT is not valid input
                        NSBeep();
                    }
                }
                else {
                    // User is playing with modifier keys
                    self.shortcutPlaceholder = shortcut.modifierFlagsString;
                }
                event = nil;
            }
            return event;
        }];
    }
    else {
        [NSEvent removeMonitor:eventMonitor];
    }
}

- (void)activateResignObserver:(BOOL)shouldActivate
{
    static BOOL isActive = NO;
    if (isActive == shouldActivate) return;
    isActive = shouldActivate;
    
    static id observer = nil;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (shouldActivate) {
        __weak MASShortcutView *weakSelf = self;
        observer = [notificationCenter addObserverForName:NSWindowDidResignKeyNotification object:self.window
                                                queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
                                                    weakSelf.recording = NO;
                                                }];
    }
    else {
        [notificationCenter removeObserver:observer];
    }
}

@end

#pragma mark -

@implementation MASShortcutCell

- (id)init
{
    self = [super init];
    if (self) {
        self.buttonType = NSPushOnPushOffButton;
        self.bezelStyle = NSRoundRectBezelStyle;
    }
    return self;
}

- (void)drawBezelWithFrame:(CGRect)frame inView:(NSView *)controlView
{
    [super drawBezelWithFrame:frame inView:controlView];
    if ([self state] == NSOnState) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.0f, 1.0f) xRadius:NSHeight(frame) / 2.0f yRadius:NSHeight(frame) / 2.0f];
        [[[self class] fillGradient] drawInBezierPath:path angle:90.0f];
    }
}

+ (NSGradient *)fillGradient
{
    static NSGradient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.88f green:0.94f blue:1.00f alpha:0.35f]
                                               endingColor:[NSColor colorWithDeviceRed:0.55f green:0.60f blue:0.65f alpha:0.65f]];
    });
    return shared;
}

@end
