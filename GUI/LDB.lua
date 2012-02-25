--###################################
--	LibDataBroker Feed
--###################################


local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceTimer = LibStub("AceTimer-3.0")

local tinsert = tinsert
local sSub = string.sub


local activezone, inactivezone = {r=0.13, g=1.0, b=0.13}, {r=0.65, g=0.65, b=0.65}
local numOnlineAwayString = GREEN_FONT_COLOR_CODE .. "%d" .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Online'] .. ' - ' ..LIGHTYELLOW_FONT_COLOR_CODE .. "%d".. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Away']
local awayString = LIGHTYELLOW_FONT_COLOR_CODE .. '(' .. L['Away'] .. ')' .. FONT_COLOR_CODE_CLOSE
local dndString = RED_FONT_COLOR_CODE .. '(' .. L['DND'] .. ')' .. FONT_COLOR_CODE_CLOSE
local levelNameAltStatusString = "|cff%02x%02x%02x%d|r %s".. YELLOW_FONT_COLOR_CODE .. "%s|r %s"

local dataobj
local flashTimer
-- For tracking changes since last update of ldb
local charsNowBack, charsNowAFK, charsNowOnline = {},{},{}
local charsNowOffline, charsNowJoined, charsNowLeft = {},{},{}

-- Turns a list into a set, used for comparing
local function Set( list )
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end


local function cc( str, color )
	if color == "r" then
		return RED_FONT_COLOR_CODE .. str .. FONT_COLOR_CODE_CLOSE
	elseif color == "g" then
		return GREEN_FONT_COLOR_CODE .. str .. FONT_COLOR_CODE_CLOSE
	elseif color == "ly" then
		return LIGHTYELLOW_FONT_COLOR_CODE .. str .. FONT_COLOR_CODE_CLOSE
	else
		return str
	end
end

-- Compare an update to the previous and sets changes
local prevMembers, prevOnline, prevAFK, prevTimestamp
local function updateStatusChanges()
	local members, online, AFK = Set(I.guildMembers), Set(I.guildOnline), Set(I.guildAFK)

	if prevMembers == nil or prevOnline == nil or prevAFK == nil then
		prevMembers, prevOnline, prevAFK = members, online, AFK
		return false
	end

	-- Only update once every 10 sec max.
	if prevTimestamp and (time() - prevTimestamp) < 10 then 
		return false 
	end
	prevTimestamp = time()

	charsNowBack, charsNowAFK, charsNowOnline = {},{},{}
	charsNowOffline, charsNowJoined, charsNowLeft = {},{},{}
	-- Chars that are back
	for k,_ in pairs( prevAFK ) do
		if not AFK[k] and online[k] then
			tinsert(charsNowBack, k)
		end
	end

	-- Chars gone afk
	for k,_ in pairs( AFK ) do
		if not prevAFK[k] then
			tinsert(charsNowAFK, k)
		end
	end

	-- Chars gone offline
	for k,_ in pairs( prevOnline ) do
		if not online[k] then
			tinsert(charsNowOffline, k)
		end
	end

	-- Chars comming online
	for k,_ in pairs( online ) do
		if not prevOnline[k] then
			tinsert(charsNowOnline, k)
		end
	end

	-- Chars left the guild
	for k,_ in pairs( prevMembers ) do
		if not members[k] then
			tinsert(charsNowLeft, k)
		end
	end

	-- Chars joined the guild
	for k,_ in pairs( members ) do
		if not prevMembers[k] then
			tinsert(charsNowJoined, k)
		end
	end

	prevMembers, prevOnline, prevAFK = members, online, AFK

	return true
end

-- Converts a list of chars to a string
local function charsToString( list, displayMain )
	s = ''

	for _,v in pairs( list ) do
		if displayMain then
			v = A.db.global.guilds[I.guildName].chars[v].main or v
		end
		
		s = s .. v .. ', '
	end

	return sSub(s, 1, -3)
end

-- flashes the datatext 2 times
local function flashLDBText( text )
	if flashTimer then AceTimer:CancelTimer(flashTimer, true) end

	local flashCount = 0
	flashTimer = AceTimer:ScheduleRepeatingTimer(function(text)
		dataobj.text = (flashCount % 2 == 0 ) and L['MOTO Tracker'] or text
		
		if flashCount >= 3 then 
			dataobj.text = L['MOTO Tracker']
			AceTimer:CancelTimer(flashTimer, true)
		end
		
		flashCount = flashCount + 1
	end, 4, text)
end


-- Set up the basic layout for LDB
function A.GUI.LDB:SetupLDB()
	dataobj = LibStub("LibDataBroker-1.1"):NewDataObject(L['MOTO Tracker'], {
		type = 'data source',
		text = L['MOTO Tracker'],
	})

	function dataobj:OnClick( clickedframe, button )
		if IsControlKeyDown() then
			InterfaceOptionsFrame_OpenToCategory(A.ConfigFrame)
		else
			A.GUI:ToggleMainFrame()
		end
	end

	function dataobj:OnTooltipShow()
		GuildRoster()
		
		if I.numGuildAFK ~= nil and I.numGuildOnline ~= nil and I.numGuildMembers ~= nil then
			self:AddLine('<' .. I.guildName .. '>')
			self:AddDoubleLine(I.numGuildMembers .. ' ' .. L['Members'], format(numOnlineAwayString, I.numGuildOnline - I.numGuildAFK, I.numGuildAFK) )
		
		end

		-- List of online chars
		-- This part is inspired by the guild data text in ElvUI (http://www.curse.com/addons/wow/elvui)
		self:AddLine(' ')
		local displayMain = A.db.global.settings.GUI.LDBDefaultMain
		if IsShiftKeyDown() then
			displayMain = not displayMain
		end
		
		for i,v in ipairs(I.guildOnline) do
			-- Don't display more than 30
			if i > 30 then
				self:AddLine("...")
				break
			end

			local hasMain = A.db.global.guilds[I.guildName].chars[v].main and false or true
			local name = (displayMain and hasMain) and A.db.global.guilds[I.guildName].chars[v].main or v
			local altStatus = (displayMain and hasMain) and ' (A)' or ''
			-- Name is alt/main, v is always the current online
			local class =  A.db.global.guilds[I.guildName].chars[name].class
			local level = A.db.global.guilds[I.guildName].chars[name].level
			local status = A.db.global.guilds[I.guildName].chars[v].status
			local zone = A.db.global.guilds[I.guildName].chars[v].zone
			
			if GetRealZoneText() == zone then zonec = activezone else zonec = inactivezone end
			local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
			local status = (status == 1) and awayString or ((status == 2) and dndString or '')
			
			self:AddDoubleLine( format(levelNameAltStatusString, levelc.r*255, levelc.g*255, levelc.b*255, level, name, altStatus, status), zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b )
		end
	
		-- List of recent events
		if #charsNowLeft > 0 or #charsNowJoined > 0 or #charsNowOnline > 0 or #charsNowOffline > 0 or #charsNowBack > 0 or #charsNowAFK > 0 then
			self:AddLine(' ')
			if #charsNowLeft > 0 then
				self:AddLine(L['Left: '] .. cc(charsToString(charsNowLeft, displayMain), 'r') )
			end				
			if #charsNowJoined > 0 then
				self:AddLine(L['Joined: '] .. cc(charsToString(charsNowJoined, displayMain), 'g') )
			end	
			if #charsNowOnline > 0 then
				self:AddLine(L['Online: '] .. cc(charsToString(charsNowOnline, displayMain), 'g') )
			end
			if #charsNowOffline > 0 then
				self:AddLine(L['Offline: '] .. cc(charsToString(charsNowOffline, displayMain), 'r') )
			end	
			if #charsNowBack > 0 then
				self:AddLine(L['Back: '] .. cc(charsToString(charsNowBack, displayMain), 'g') )
			end	
			if #charsNowAFK > 0 then
				self:AddLine(L['Away: '] .. cc(charsToString(charsNowAFK, displayMain), 'ly') )
			end
		end
	end
end

-- Update our LDB feed
function A.GUI.LDB:Update()
	if not A.db.global.settings.GUI.LDBShowEvents then return end

	-- Guild info not yet available or not in a guild
	if I.numGuildMembers == 0 then return end

	-- Calculate changes
	if not updateStatusChanges() then return end
	
	if #charsNowLeft > 0 then
		local change = #charsNowLeft
		local plural = (change > 1) and 's' or ''
		dataobj.text = string.format('-%s %s', cc(change, "r"), L['Member'.. plural])
	elseif #charsNowJoined > 0 then
		local change = #charsNowJoined
		local plural = (change > 1) and 's' or ''
		dataobj.text = string.format('+%s %s', cc(change, "g"), L['Member'.. plural])
	elseif #charsNowOffline > 0 then
		local change = #charsNowOffline
		dataobj.text = string.format('-%s %s', cc(change, "r"), L['Online'])
	elseif #charsNowOnline > 0 then
		local change = #charsNowOnline
		dataobj.text = string.format('+%s %s', cc(change, "g"), L['Online'])
	elseif #charsNowBack > 0 then
		local change = #charsNowBack
		dataobj.text = string.format('%s %s', cc(change, "g"), L['Back'])
	elseif #charsNowAFK > 0 then
		local change = #charsNowAFK
		dataobj.text = string.format('%s %s', cc(change, "ly"), L['Away'])
	else
		return
	end

	flashLDBText(dataobj.text)

end
