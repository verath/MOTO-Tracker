local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

-- Options
function A:SetupOptions()
	
	A.options = {
		name = L["MOTO Tracker"],
		type = 'group',
		args = {
			MOTO_Header = {
				order = 1,
				type = "header",
				name = L["Version"] .. ": " .. I.versionName,
				width = "Full",
			},

			LoadMessage = {
				order = 2,
				type = 'toggle',
				name = L['Show load message'],
				desc = L['Display a message when the addon is loaded or enabled.'],
				get = function(info) return A.db.char.settings.loadMessage end,
				set = function(info, value) A.db.char.settings.loadMessage = value end,
			},

			RestoreDefaults = {
				order = 3,
				type = 'execute',
				name = L['Restore Defaults'],
				desc = L['Restores ALL settings to their default values. Does not clear the database.'],
				confirm = function() return L['Are you sure you want to restore ALL settings?'] end,
				func = function() A.db.char.settings = nil; A.db.global.settings = nil; A:SetupDB() end,
			},

			ResetDB = {
				order = 4,
				type = 'execute',
				name = L['Reset Database'],
				desc = L['Resets the whole database (including settings).'],
				confirm = function() return L['Are you sure you want to reset the whole database? This can not be undone!'] end,
				func = function() A.db:ResetDB('Default'); A:SetupDB() end,
			},
			
			Global = {
				name = L['General Settings'],
				type = "group",
				args = {
					UpdateOwnSpec = {
						order = 1,
						type = 'toggle',
						name = L['Auto update own specs'],
						desc = L['Automatically updates your characters main spec and off spec to your current talent specs when loggin in and/or changing specs.'],
						get = function(info) return A.db.global.settings.general.updateOwnSpec end,
						set = function(info, value) A.db.global.settings.general.updateOwnSpec = value end,
					},
				},
				order = 20,
			},

			Sync = {
				name = L['Sync Settings'],
				type = "group",
				args = {
					SyncEnabled = {
						order = 1,
						type = 'toggle',
						name = L['Enabled'],
						desc = L['Enable or disable syncing.'],
						get = function(info) return A.db.global.settings.general.updateOwnSpec end,
						set = function(info, value) A.db.global.settings.general.updateOwnSpec = value end,
					},
				},
				order = 21,
			},

			CharSpecific = {
				name = L["Character Specific Settings"],
				type = "group",
				args = {
					
				},
				order = 25,
			},
		},
	}
	


	LibStub("AceConfig-3.0"):RegisterOptionsTable(I.addonName, A.options)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(I.addonName, A.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(I.addonName, L['MOTO Tracker'], nil)
end
