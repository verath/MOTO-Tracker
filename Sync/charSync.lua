--###################################
--   Character syncing
--###################################

-- addon, locale, info
local A,L,I = unpack(select(2, ...))

-- Init our sync.char object
A.sync.char = {}

-- Load libs
local AceTimer = LibStub("AceTimer-3.0")

-- Local version of lua functions are faster
local sSub = string.sub

-- "global" Local vars
local sharedCharDataString = ''
local sharedCharName = ''
local isSharingChar = false
local stopSharingTimer

do -- Popups
	StaticPopupDialogs['MOTOTracker_Sync_Char_Confirm_Receive'] = {
		text = L['%s is sharing data for %s.|n|nDo you want to recceive this data (this will overwrite your own data for this character)?'],
		button1 = YES,
		button2 = NO,
		OnAccept = function() end,
		OnCancel = function() end,
		timeout = 15,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	StaticPopupDialogs['MOTOTracker_Sync_Char_Already_Sharing'] = {
		text = L['Already sharing a character!|n|nPlease wait at least 20 seconds after sending a character before sending another one.'],
		button1 = OKAY,
		timeout = 20,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 4,
	}

	StaticPopupDialogs['MOTOTracker_Sync_Char_Sharing'] = {
		button1 = CANCEL,
		text = L['Sharing %s for 20 seconds.'],
		timeout = 20,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 5,
	}
end


--###################################
--   Helper Functions
--###################################

local function colorCode(str, color)
	if color == "green" then
		return GREEN_FONT_COLOR_CODE .. str .. FONT_COLOR_CODE_CLOSE
	elseif color == "lightyellow" then
		return LIGHTYELLOW_FONT_COLOR_CODE .. str .. FONT_COLOR_CODE_CLOSE
	end

	return str
end

-- Asks user for confirmation for reccieving a char from another player
local function confirmReceiveChar( charName, sentBy, OnAccept, OnCancel )
	-- If user only want to sync when frame is open
	if A.GUI.mainFrame == nil and A.db.global.settings.sync.onlyWhenFrame then 
		OnCancel(); 
		return 
	end
	
	StaticPopupDialogs['MOTOTracker_Sync_Char_Confirm_Receive'].OnAccept = OnAccept
	StaticPopupDialogs['MOTOTracker_Sync_Char_Confirm_Receive'].OnCancel = OnCancel
	
	StaticPopup_Show('MOTOTracker_Sync_Char_Confirm_Receive', 
		colorCode(sentBy, "lightyellow"), 
		colorCode(charName, "green"))
end


--###################################
--   Char Sending
--###################################

-- Starts sharing a character
local function startSharingChar()
	-- Brodcast to guild that we are sharing
	A:SendCommMessage('MOTOTChar', 'Sharing|' .. sharedCharName, 'GUILD', '', 'NORMAL')
	isSharingChar = true
end

-- Stops listening for requests for the char we were sharing
function A.sync.char:StopSharingChar()
	isSharingChar = false
	-- If cancled by user, cancel the timer
	if stopSharingTimer then AceTimer:CancelTimer(stopSharingTimer, true) end
end

-- Called when user clicks the share button in the ui.
function A.sync.char:SendChar( charName )
	local syncSettings = A.db.global.settings.sync
	if not syncSettings.enabled then return end

	if isSharingChar then
		-- We only allow sharing of one char at a time,
		-- not going to spam data.
		StaticPopup_Show('MOTOTracker_Sync_Char_Already_Sharing')
		return
	end

	do -- Display info pop-up while we are sharing.
		StaticPopup_Hide('MOTOTracker_Sync_Char_Sharing')
		-- OnAccept is on button one, and we only have one button.
		StaticPopupDialogs['MOTOTracker_Sync_Char_Sharing'].OnAccept = function() A.sync.char:StopSharingChar() end
		StaticPopup_Show('MOTOTracker_Sync_Char_Sharing', colorCode(charName, "green"))
	end

	local charData = A.db.global.guilds[I.guildName].chars[charName]
	-- TODO: Ask user for what to send
	local keysToSend = {'name', 'alts', 'main', 'mainSpec', 'offSpec', 'mainSpecDPS', 'offSpecDPS'}

	local dataToSend = {}
	for _, key in ipairs(keysToSend) do
		dataToSend[key] = charData[key]
	end
	
	-- Serializes and compresses the object into a more
	-- easily/faster sharable string
	sharedCharDataString = A.sync:CompressObject(dataToSend)
	sharedCharName = charName
	
	-- Brodcast that we are sharing
	startSharingChar()
	
	-- Stop sharing after 20 sec
	if stopSharingTimer then AceTimer:CancelTimer(stopSharingTimer, true) end
	stopSharingTimer = AceTimer:ScheduleTimer( function() A.sync.char:StopSharingChar() end, 20)
end

-- Sends a shared char object to a player that requested it
local function sendSharedCharTo( target )
	if not isSharingChar then return end
	A:Print( format(L['Sent data for %s to %s.'], sharedCharName, target) )
	A:SendCommMessage('MOTOTCharData', sharedCharDataString, 'WHISPER', target, 'NORMAL')
end



--###################################
--   Char Receiving
--###################################

-- User wants the shared char, request it from the player sharing it
local function requestSharedChar(charName, sharer)
	local message = 'WantChar' .. charName
	A:SendCommMessage('MOTOTChar', message, 'WHISPER', sharer, 'NORMAL')
end

-- Someone is sharing a char, ask user if we want it
local function charSharedWithMe( charName, sharedBy )
	local syncSettings = A.db.global.settings.sync
	if not syncSettings.enabled then return end
	
	if syncSettings.onlyHighOrSameRank == true then 
		local lowestRank = GuildControlGetNumRanks()
		local _,senderRank = A:GetPlayerCharByCompareValue(charName, 'guildIndex', lowestRank, true )
		local _,myRank = A:GetPlayerCharByCompareValue(charName, 'guildIndex', lowestRank, true )

		if senderRank < myRank then return end
	end

	confirmReceiveChar( charName, sharedBy, function() requestSharedChar(charName, sharedBy) end)
end


--###################################
--   CommHandlers
--###################################

-- General handler, handles all but the actuall receiving of chars
function A.sync.char:HandleCommChar(message, distribution, sender)
	if distribution == 'GUILD' then
		if #message > 8 and sSub(message, 1, 8) == 'Sharing|' then 
			-- Someone is sharing a char
			charSharedWithMe( sSub(message, 9), sender )
		end
	elseif distribution == 'WHISPER' then
		if isSharingChar and message == 'WantChar' .. sharedCharName then
			-- Someone want the char we are sharing
			sendSharedCharTo( sender )
		end
	end
end

--Handler for receiving charData (that is someone sent an entier char array)
function A.sync.char:HandleCommCharData(message, distribution, sender)
	
	local data = A.sync:DecompressString(message)
	if data == nil then return end

	local charName = data.name
	local localData = A.db.global.guilds[I.guildName].chars[charName]
	
	do-- Handle alt/main
		-- Remove our local char from any alt/main relations
		if localData.main then
			local mainName = localData.main
			A:RemoveAltFromMain(charName, mainName)
		end

		-- If our local char has any alt data, unset them
		if localData.alts then
			for i, altName in ipairs(localData.alts) do
				A:RemoveAltFromMain(altName, charName)
			end
		end

		-- If char received has alts
		if data.alts then
			for _,alt in ipairs(data.alts) do
				-- Set each alt to the char
				A:ChangeCharMain(alt, charName)
			end
		elseif data.main then
			-- If char received is an alt
			A:ChangeCharMain(charName, data.main)	
		end

		-- Remove from our data table
		data.main = nil
		data.alts = nil
	end
	
	-- Just loop trough the rest and set the values
	for k,v in pairs(data) do
		localData[k] = v
	end

	-- Update our frame
	A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end


--###################################
--   Set Up
--###################################

-- Called when setting up sync
function A.sync.char:SetupCharSync()
	-- Got nothing to do here really, but might in the future.
end
