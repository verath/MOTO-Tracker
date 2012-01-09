local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")

local sFormat = string.format
local date = date

A.GUI = { 
	tabs = {
		rosterInfo = {},
	}, 
	mainFrame = {},
}

--###################################
--	Main Frame
--###################################

-- Callback function for OnGroupSelected
local shownTab = nil
function SelectGroup(container, event, group)
	container:ReleaseChildren()
	shownTab = group
	if group == 'rosterInfo' then
		A.GUI.tabs.rosterInfo:DrawTab( container )
	end
end

-- 
function A.GUI:HideMainFrame()
	A.GUI.mainFrame:Release()
	A.GUI.mainFrame = nil
end

-- Shows the main frame, also creates it if it doesn't exist yet.
function A.GUI:ShowMainFrame()
	-- Only show if it isn't shown already
	if A.GUI.mainFrame ~= nil then return end

	-- No point in creating it before we want to show it
	-- And since it is realease on close we need to
	-- create it every time.
	self:CreateMainFrame()
	self.mainFrame:Show()
	
	-- Update GuildRoster as soon as we can (min time now, max in 10 sec)
	GuildRoster()
	AceTimer:ScheduleTimer(GuildRoster, 10)
end

function A.GUI:CreateMainFrame()
	self.mainFrame = AceGUI:Create("Frame")
	local f = self.mainFrame
	
	-- Main frame settings
	f:Hide()
	f:SetTitle( format(L['MOTO Tracker, version: %s'], I.versionName) )
	f:SetLayout("Fill")
	f:SetCallback("OnClose", A.GUI.HideMainFrame)

	if I.hasGuild then
		local numMembers = GetNumGuildMembers()
		f:SetStatusText(I.guildName .. ' - ' .. numMembers .. ' '.. L['Members'])
	else
		f:SetStatusText(L['<Not in a guild>'])
	end



	-- Create the TabGroup
	local tab = AceGUI:Create("TabGroup")
	tab:SetLayout("Flow")
	tab:SetTabs({
		{text=L['Roster Info'], value="rosterInfo"}, 
	})
	tab:SetCallback("OnGroupSelected", SelectGroup)
	tab:SelectTab("rosterInfo")

	f:AddChild(tab)
end

-- Will get called by main addon when an event 
-- that could affect the roster triggers. Max every 10 sec.
local updateRosterTimer
function A.GUI:OnRosterUpdate()
	-- Update if our frame is shown
	if self.mainFrame and self.mainFrame.IsVisible and self.mainFrame:IsVisible() then
		if I.hasGuild then
			local f = self.mainFrame
			local numMembers = GetNumGuildMembers()

			-- Get numOnline and numAfk
			local numOnline, numAfk = 0, 0
			for i = 1, numMembers do
				local _, _, _, _, _, _, _, _, online, status = GetGuildRosterInfo(i)
				if online then 
					if status == '<Away>' then 
						numAfk = numAfk+1 
					else
						numOnline = numOnline+1
					end 
				end
			end

			f:SetStatusText(I.guildName .. ' - ' .. numMembers .. ' ' .. L['Members'].. ' - ' .. GREEN_FONT_COLOR_CODE .. numOnline .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Online'] .. ' ' .. LIGHTYELLOW_FONT_COLOR_CODE .. numAfk .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Away'])
		else
			f:SetStatusText(L['<Not in a guild>'])
		end

		if shownTab == 'rosterInfo' then
			A.GUI.tabs.rosterInfo:OnRosterUpdate()
		end

		-- Make sure we do update it every 10 sec if our window is open
		if updateRosterTimer then AceTimer:CancelTimer(updateRosterTimer, true)	end
		updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 10)

	end
end
