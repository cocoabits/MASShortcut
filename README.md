# Intro

Some time ago Cocoa developers used a brilliant framework [ShortcutRecorder](http://wafflesoftware.net/shortcut/) for managing keyboard shortcuts in application preferences. However, it became incompatible with the new plugin architecture of Xcode 4.

The MASShortcut project introduces a modern API and user interface for recording, storing and using system-wide keyboard shortcuts. All code is compatible with recent Xcode & OS X versions and the sandboxed environment.

# Usage

I hope, it is really easy:

```objective-c
// Drop a custom view into XIB, set its class to MASShortcutView
// and its height to 19. If you select another appearance style,
// look up the correct height values in MASShortcutView.h.
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;

// Pick a preference key to store the shortcut between launches
static NSString *const kPreferenceGlobalShortcut = @"GlobalShortcut";

// Associate the shortcut view with user defaults
self.shortcutView.associatedUserDefaultsKey = kPreferenceGlobalShortcut;

// Associate the preference key with an action
[[MASShortcutBinder sharedBinder]
    bindShortcutWithDefaultsKey:kPreferenceGlobalShortcut
    toAction:^{
    // Let me know if you find a better or a more convenient API.
}];
```

You can see a real usage example in the Demo target. Enjoy!

# Notifications

By registering for KVO notifications from `NSUserDefaultsController`, you can get a callback whenever a user changes the shortcut, allowing you to perform any UI updates, or other code handling tasks.

This is just as easy to implement:
    
```objective-c
// Declare an ivar for key path in the user defaults controller
NSString *_observableKeyPath;
    
// Make a global context reference
void *kGlobalShortcutContext = &kGlobalShortcutContext;
    
// Implement when loading view
_observableKeyPath = [@"values." stringByAppendingString:kPreferenceGlobalShortcut];
[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:_observableKeyPath
                                                             options:NSKeyValueObservingOptionInitial
                                                             context:kGlobalShortcutContext];

// Capture the KVO change and do something
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)obj
                        change:(NSDictionary *)change context:(void *)ctx
{
    if (ctx == kGlobalShortcutContext) {
        NSLog(@"Shortcut has changed");
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:obj change:change context:ctx];
    }
}

// Do not forget to remove the observer
[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                             forKeyPath:_observableKeyPath
                                                                context:kGlobalShortcutContext];
```

# Non-ARC Version

If you like retain/release, please check out these forks: [heardrwt/MASShortcut](https://github.com/heardrwt/MASShortcut) and [chendo/MASShortcut](https://github.com/chendo/MASShortcut). However, the preferred way is to enable the `-fobjc-arc` in Xcode source options.

# Copyright

MASShortcut is licensed under the 2-clause BSD license.
