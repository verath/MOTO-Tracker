local L = LibStub("AceLocale-3.0"):NewLocale("MOTOTracker", "enUS", true)

if L then
	-- Options
	L['Show load message'] = true
	L['Display a message when the addon is loaded or enabled.'] = true
	L['Character Specific Settings'] = true
	L['Global Settings'] = true
	L['Restore Defaults'] = true
	L['Restores ALL settings to their default values. Does not clear the database.'] = true
	L['Are you sure you want to restore ALL settings?'] = true
	L['Reset Database'] = true
	L['Resets the whole database (including settings).'] = true
	L['Are you sure you want to reset the whole database? This can not be undone!'] = true
	
	-- Core
	L['MOTO Tracker'] = true
	L['MOTO Tracker enabled.'] = true
	L['Version'] = true


	-- GUI
	L['MOTO Tracker, version: %s'] = true
	L['Members'] = true
	L['<Not in a guild>'] = true
	L['Main/Alt Tracker'] = true
	L['Something Else'] = true
end
