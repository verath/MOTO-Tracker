local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

-- Options
function A:SetupOptions()
	A.options = {
		name = "MOTO Tracker",
		type = 'group',
		args = {},
	}


	A.options.args = {
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
			get = function(info) return A.db.char.loadMessage end,
			set = function(info, value) A.db.char.loadMessage = value end,
		},
	}


	LibStub("AceConfig-3.0"):RegisterOptionsTable(I.addonName, A.options)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(I.addonName, A.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(I.addonName, L['MOTO Tracker'], nil)
end
