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

# Non-ARC Version

If you like retain/release, please check out these forks: [heardrwt/MASShortcut](https://github.com/heardrwt/MASShortcut) and [chendo/MASShortcut](https://github.com/chendo/MASShortcut).

# Copyright

MASShortcut is licensed under the 2-clause BSD license.
