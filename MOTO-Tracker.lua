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
--   Helper Functions
--###################################

-- Initializes the DB
function A:SetupDB()
	self:SetupDefaults()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", A.defaults, true)
end

-- Updates/Adds guild memeber to our db
local function updateGuildMemeberFromRoster( index )
	local name, rank, rankIndex, level, _, zone, note, officernote, _, _, class = GetGuildRosterInfo(index)

	local P = A.db.global.guilds[I.guildName].players[name]
	
	-- Update guild info
	P.name, P.rank, P.rankIndex, P.level, P.zone, P.note, P.class = name, rank, rankIndex, level, zone, note, class

	if I.canViewOfficerNote then
		P.officerNote = officerNote
	end

end

-- Checks local guild DB against roster and
-- removes members no longer in the guild
local function removeNoLongerGuildMemebers()
	local players = A.db.global.guilds[I.guildName].players
	
	-- Create a roster table with name as key
	local playersInGuild = {}
	for i = 1, GetNumGuildMembers() do
		playersInGuild[GetGuildRosterInfo(i)] = true
	end

	for playerName, playerData in pairs(players) do
		if not playersInGuild[playerName] then
			players[playerName] = nil
		end
	end
end


--###################################
--   Event functions
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
	
	-- Request guild roster from server
	GuildRoster()

	-- Static values
	I.hasGuild = IsInGuild()

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
function A:OnGuildRosterUpdate( event, change )
	if not I.hasGuild then return end

	-- We only need to update our DB if a change did occur
	-- or if this is first update after login.
	if change == nil and firstRosterUpdate ~= true then return end
	
	-- Do once update on login
	if firstRosterUpdate then
		-- Get guild specific info now, as it should all be loaded
		I.guildName, _ = GetGuildInfo("player")
		I.canViewOfficerNote = CanViewOfficerNote()

		removeNoLongerGuildMemebers()
	end

	firstRosterUpdate = false

	local numGuildMembers, _ = GetNumGuildMembers()

	for i = 1, numGuildMembers do
		updateGuildMemeberFromRoster( i )
	end
end
