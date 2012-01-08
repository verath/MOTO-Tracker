--###################################
--   Set Up
--###################################
MOTOTracker = {
	addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0"),
	locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true),
	info = { -- Static global values
		versionName = '0.01a',
		addonName = 'MOTOTracker',
	}
}

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info




--###################################
--	Helper Functions
--###################################

-- Initializes the DB
function A:SetupDB()
	self:SetupDefaults()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", A.defaults, true)
end

-- Updates/Adds guild memeber to our db
function A:UpdateGuildMemeberFromRoster( index )
	local name, rank, rankIndex, level, _, zone, note, officerNote, online, status, class = GetGuildRosterInfo(index)

	local P = A.db.global.guilds[I.guildName].chars[name]
	
	-- Update guild info
	P.name, P.rank, P.rankIndex, P.level, P.zone, P.note, P.class, P.guildIndex, P.online, P.status = name, rank, rankIndex, level, zone, note, class, index, online, status

	if I.canViewOfficerNote then
		P.officerNote = officerNote
	end

end

-- Updates the entier guild roster (Do not use too much...)
function A:UpdateGuildRoster()
	local numGuildMembers, _ = GetNumGuildMembers()

	for i = 1, numGuildMembers do
		A:UpdateGuildMemeberFromRoster( i )
	end
end

-- Checks local guild DB against roster and
-- removes members no longer in the guild
local function removeNoLongerGuildMemebers()
	local chars = A.db.global.guilds[I.guildName].chars
	
	-- Create a roster table with name as key
	local charsInGuild = {}
	for i = 1, GetNumGuildMembers() do
		charsInGuild[GetGuildRosterInfo(i)] = true
	end

	for charName, charData in pairs(chars) do
		if not charsInGuild[charName] then
			chars[charName] = nil
		end
	end
end


--###################################
--	Event functions
--###################################

-- Called by ace3 once saved variables are available
function A:OnInitialize()
	self:SetupDB()
end

-- Gets called during the PLAYER_LOGIN event or
-- when addon is enabled.
function A:OnEnable()
	if self.db.char.settings.loadMessage then
		A:Print(L['MOTO Tracker enabled.'])
	end

	-- Start listening for events
	A:RegisterEvent('GUILD_ROSTER_UPDATE', 'OnGuildRosterUpdate')
	A:RegisterEvent('PLAYER_GUILD_UPDATE', 'OnGuildRosterUpdate')
	
	-- Request guild roster from server
	GuildRoster()

	-- Static values
	I.hasGuild = IsInGuild()
	I.guildSortableBy = {name = L['Name'], mainSpec = L['Main Spec'], offSpec = L['Off Spec'], rankIndex = L['Guild Rank']}

	-- Set up the options UI
	self:SetupOptions()
end

-- Gets called if the addon is disabled
function A:OnDisable()

	-- Unregister Events
	A:UnregisterEvent('GUILD_ROSTER_UPDATE')
end


-- When guild roster is updated
local firstRosterUpdate = true
function A:OnGuildRosterUpdate( event,_ )
	if not I.hasGuild then return end
	
	-- Do once update on login
	if firstRosterUpdate or event == 'PLAYER_GUILD_UPDATE' then
		-- Get guild specific info now, as it should all be loaded
		I.guildName, _ = GetGuildInfo("player")
		I.canViewOfficerNote = CanViewOfficerNote() ~= nil and true or false
		I.canEditOfficerNote = CanEditOfficerNote() ~= nil and true or false
		I.canEditPublicNote = CanEditPublicNote() ~= nil and true or false

		removeNoLongerGuildMemebers()
	end

	if event == 'GUILD_ROSTER_UPDATE' then
		A:UpdateGuildRoster()
	end


	if firstRosterUpdate then A:ShowMainFrame() end
	firstRosterUpdate = false
end


