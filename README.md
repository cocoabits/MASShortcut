# Intro

Some time ago Cocoa developers used a brilliant framework [ShortcutRecorder](http://wafflesoftware.net/shortcut/) for managing keyboard shortcuts in application preferences. However, it became incompatible with a new plugin architecture of Xcode 4.

The project MASShortcut introduces modern API and user interface for recording, storing and using global keyboard shortcuts. All code is compatible with Xcode 4.3, Mac OS X 10.7 and the sandboxed environment.

# Usage

I hope, it is really easy:

	// Drop a custom view into XIB and set its class to MASShortcutView
	@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
	
	// Think up a preference key to store a global shortcut between launches
	NSString *const kPreferenceGlobalShortcut = @"GlobalShortcut";

	// Assign the preference key and the shortcut view will take care of persistence
	self.shortcutView.associatedUserDefaultsKey = kPreferenceGlobalShortcut;

	// Execute your block of code automatically when user triggers a shortcut from preferences
	[MASShortcut registerGlobalShortcutWithUserDefaultsKey:kPreferenceGlobalShortcut handler:^{
		
		// Let me know if you find a better or more convenient API.
	}];

To set an example, I made a  demo project: [MASShortcutDemo](https://github.com/shpakovski/MASShortcutDemo). Enjoy!

#Notification of Change
By registering for NSNotifications from NSUserDefaults observing, you can get a callback whenever a user changes the shortcut, allowing you to perform any UI updates, or other code handling needs. 

This is just as easy to implement:
    //implement when loading view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:kPreferenceGlobalShortcut
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    //capture the KVO change and do something
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        NSLog(@"KVO changed");
    }


    //don't forget to remove the observer
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:kPreferenceGlobalShortcut];

# Non-ARC Version

If you like retain/release, please check out these forks: [heardrwt/MASShortcut](https://github.com/heardrwt/MASShortcut) and [chendo/MASShortcut](https://github.com/chendo/MASShortcut).

# Copyright

MASShortcut is licensed under the 2-clause BSD license.
