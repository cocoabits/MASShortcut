# Intro

Some time ago Cocoa developers used a brilliant framework [ShortcutRecorder](http://wafflesoftware.net/shortcut/) for managing keyboard shortcuts in application preferences. However, it became incompatible with a new plugin architecture of Xcode 4.

The project MASShortcut introduces modern API and user interface for recording, storing and using global keyboard shortcuts. All code is compatible with Xcode 4.3, Mac OS X 10.7 and the sandboxed environment.

# Usage for the branch ‘32-bit’

	// Make a raw keyboard shortcut
	MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_F1 modifierFlags:NSCommandKeyMask];

	// Execute your block of code automatically when user triggers a shortcut
	[MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
		
		// Let me know if you find a better or more convenient API.
	}];

To set an example, I made a  demo project: [MASShortcutDemo](https://github.com/shpakovski/MASShortcutDemo). Enjoy!

# Copyright

MASShortcut is licensed under the BSD license.