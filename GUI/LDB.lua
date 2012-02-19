--###################################
--	LibDataBroker Feed
--###################################


local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceTimer = LibStub("AceTimer-3.0")

local dataobj
local flashTimer


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
		
		self:AddLine(L['MOTO Tracker'])
		self:AddLine('-----')
		self:AddLine(L['Click to open frame.'])
		self:AddLine(L['Ctrl + click to open options.'])

		if I.numGuildAFK ~= nil and I.numGuildOnline ~= nil and I.numGuildMembers ~= nil then
			self:AddLine('-----')
			self:AddLine('<' .. I.guildName .. '>')
			self:AddLine(I.numGuildMembers .. ' ' .. L['Members'])
			self:AddLine(GREEN_FONT_COLOR_CODE .. I.numGuildOnline .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Online'] .. ' - ' ..LIGHTYELLOW_FONT_COLOR_CODE .. I.numGuildAFK .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Away'])
		end
	end
end

-- Update our LDB feed
function A.GUI.LDB:Update( oldOnline, oldAFK, oldMembers, online, AFK, members )
	if not A.db.global.settings.GUI.LDBShowEvents then return end
	if oldMembers == nil or oldOnline == nil or oldAFK == nil then return end
	
	oldOnline = oldOnline + oldAFK
	online = online + AFK
	
	if oldMembers ~= members then
		if oldMembers > members then
			local change = oldMembers - members
			local plural = (change > 1) and 's' or ''
			dataobj.text = string.format('%s-%d%s %s', RED_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Member'.. plural])
		else
			local change = members - oldMembers
			local plural = (change > 1) and 's' or ''
			dataobj.text = string.format('%s+%d%s %s', GREEN_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Member'.. plural])
		end
	elseif oldOnline ~= online then
		if oldOnline > online then
			local change = oldOnline - online
			dataobj.text = string.format('%s-%d%s %s', RED_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Online'])
		else
			local change = online - oldOnline
			dataobj.text = string.format('%s+%d%s %s', GREEN_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Online'])
		end
	elseif oldAFK ~= AFK then
		if oldAFK > AFK then
			local change = oldAFK - AFK
			dataobj.text = string.format('%s%d%s %s', GREEN_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Back'])
		else
			local change = AFK - oldAFK
			dataobj.text = string.format('%s%d%s %s', LIGHTYELLOW_FONT_COLOR_CODE, change, FONT_COLOR_CODE_CLOSE, L['Away'])
		end
	end

	flashLDBText(dataobj.text)

end
