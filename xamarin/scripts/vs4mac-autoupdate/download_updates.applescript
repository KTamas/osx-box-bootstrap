tell application "Visual Studio"
	delay 1
	activate
	delay 1
end tell
delay 5
tell application "System Events"
	delay 1
	tell process "Visual Studio Community"
		delay 1
		click menu item 2 of menu 2 of menu bar 1
		delay 240
		key code 53
	end tell
end tell

delay 1

tell application "Visual Studio" to quit