local L = LibStub("AceLocale-3.0"):NewLocale(
	"MOTOTracker", 
	"enUS"
	--@debug@
	,true
	--@end-debug@
)

if L then
	-- Class Names
	L['WARRIOR'] = true
	L['DEATHKNIGHT'] = true
	L['PALADIN'] = true
	L['PRIEST'] = true
	L['SHAMAN'] = true
	L['DRUID'] = true
	L['ROGUE'] = true
	L['MAGE'] = true
	L['WARLOCK'] = true
	L['HUNTER'] = true
	-- Spec names
	L['FURY'] = true
	L['ARMS'] = true
	L['PROTECTION'] = true
	L['BLOOD'] = true
	L['FROST'] = true
	L['UNHOLY'] = true
	L['HOLY'] = true
	L['RETRIBUTION'] = true
	L['SHADOW'] = true
	L['DISCIPLINE'] = true
	L['ELEMENTAL'] = true
	L['ENHANCEMENT'] = true
	L['RESTORATION'] = true
	L['BALANCE'] = true
	L['FERAL COMBAT'] = true
	L['FERAL CAT'] = true -- Our own
	L['FERAL BEAR'] = true -- Our own
	L['COMBAT'] = true
	L['ASSASSINATION'] = true
	L['SUBTLETY'] = true
	L['FIRE'] = true
	L['FROST'] = true
	L['ARCANE'] = true
	L['AFFLICTION'] = true
	L['DEMONOLOGY'] = true
	L['DESTRUCTION'] = true
	L['BEAST MASTERY'] = true
	L['SURVIVAL'] = true
	L['MARKSMANSHIP'] = true
	--
	L['Fury'] = true
	L['Arms'] = true
	L['Protection'] = true
	L['Blood'] = true
	L['Frost'] = true
	L['Unholy'] = true
	L['Holy'] = true
	L['Retribution'] = true
	L['Shadow'] = true
	L['Discipline'] = true
	L['Elemental'] = true
	L['Enhancement'] = true
	L['Restoration'] = true
	L['Balance'] = true
	L['Feral (Cat)'] = true
	L['Feral (Bear)'] = true
	L['Combat'] = true
	L['Assassination'] = true
	L['Subtlety'] = true
	L['Fire'] = true
	L['Frost'] = true
	L['Arcane'] = true
	L['Affliction'] = true
	L['Demonology'] = true
	L['Destruction'] = true
	L['Beast Mastery'] = true
	L['Survival'] = true
	L['Marksmanship'] = true
	L['NONE'] = true


	-- Options
	L['Sync Settings'] = true
	L['Show load message'] = true
	L['Display a message when the addon is loaded or enabled.'] = true
	L['Character Specific Settings'] = true
	L['General Settings'] = true
	L['Restore Defaults'] = true
	L['Restores ALL settings to their default values. Does not clear the database.'] = true
	L['Are you sure you want to restore ALL settings?'] = true
	L['Reset Database'] = true
	L['Resets the whole database (including settings).'] = true
	L['Are you sure you want to reset the whole database? This can not be undone!'] = true
	L['Auto update own specs'] = true
	L['Automatically updates your characters main spec and off spec to your current talent specs when loggin in and/or changing specs.'] = true
	L['Enabled'] = true
	L['Enable or disable syncing.'] = true
	L['Only receive when open'] = true
	L['Only show popoups about sharing if the addon frame is opened.'] = true
	L['Use auto-complete'] = true
	L['Use auto-complete for a few fields in the addon (mostly when entering character names).'] = true
	L['Only my rank or higher'] = true
	L['Only receive data from players with the same or higher guild rank.'] = true
	L['Layout Settings'] = true
	L['Reset Frame'] = true
	L['Resets the position and size of the main frame.'] = true
	L['Frame position reset.'] = true
	L['LDB Settings'] = true
	L['LDB (LibDataBroker) is used by many addons to display data and provide shortcuts. Make sure you also assign MOTO Tracker a field within your LDB display addon.'] = true
	L['Display Events'] = true
	L['Flashes the LDB text when a member event occurs (going online, offline, etc.'] = true

	
	-- Core
	L['MOTO Tracker'] = true
	L['MOTO Tracker enabled.'] = true
	L['Version'] = true
	L['Name'] = true
	L['Main Spec'] = true
	L['Off Spec'] = true
	L['Guild Rank'] = true
	L['Level'] = true
	L['Class'] = true

	-- GUI
	L['A-Z'] = true
	L['Z-A'] = true
	L['High'] = true
	L['Low'] = true
	L['MOTO Tracker, version: %s'] = true
	L['(Update Available!)'] = true
	L['Members'] = true
	L['<Not in a guild>'] = true
	L['Roster Info'] = true
	L['Something Else'] = true
	L['Primary sort by'] = true
	L['Secondary sort by'] = true
	L['Only 85s'] = true
	L['Hide offline'] = true
	L['Search'] = true
	L['General'] = true
	L['Guild Note'] = true
	L['Officer Note'] = true
	L['Private Note'] = true
	L['Online'] = true
	L['Offline'] = true
	L['Away'] = true
	L['Refresh'] = true
	L['Main'] = true
	L['Alts'] = true
	L['Currently in'] = true
	L['Last seen in'] = true
	L['Main Spec/Off Spec'] = true
	L['Share Char'] = true
	L['Toggle Main Frame'] = true
	L['years'] = true
	L['months'] = true
	L['days'] = true
	L['hours'] = true
	L['year'] = true
	L['month'] = true
	L['day'] = true
	L['hour'] = true
	L['ago'] = true
	L['less than an hour ago'] = true
	L['Invite'] = true
	L['Player actions'] = true
	L['Roster actions'] = true
	L['Make Main'] = true
	L['Events'] = true
	L['Main Spec/Off Spec DPS'] = true
	L['DPS from current Skada view'] = true
	L['Import As MS'] = true
	L['Import As OS'] = true
	L['Away'] = true
	L['DND'] = true

	-- Tooltips
	L['Name of this character\'s main.'] = true
	L['The character\'s alts. Edit the alts\' main-value to change this.'] = true
	L['The character\'s main spec and off spec.'] = true
	L['The character\'s DPS in main spec and off spec.'] = true
	L['The guild note for the character.'] = true
	L['The officer note for the character.'] = true
	L['Your own note for the character. This is note never shared.'] = true
	L['Action that alters the addon\'s guild roster database.']= true
	L[' * Make Main - Sets the selected character as the player\'s main character.'] = true

	-- LDB
	L['Member'] = true
	L['Members'] = true
	L['Back'] = true
	L['Click to open frame.'] = true
	L['Ctrl + click to open options.'] = true
	L['Left: '] = true
	L['Joined: '] = true
	L['Online: '] = true
	L['Offline: '] = true
	L['Back: '] = true
	L['Away: '] = true


	-- Sync
	L['%s is sharing data for %s.|n|nDo you want to recceive this data (this will overwrite your own data for this character)?'] = true
	L['Already sharing a character!|n|nPlease wait at least 20 seconds after sending a character before sending another one.'] = true
	L['Sharing %s for 20 seconds.'] = true
	L['Sent data for %s to %s.'] = true
end
