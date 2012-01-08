local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")

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

-- Shows the main frame, also creates it if it doesn't exist yet.
function A.GUI:ShowMainFrame()
	-- No point in creating it before we want to show it
	-- And since it is realease on close we need to
	-- create it every time.
	self:CreateMainFrame()
	self.mainFrame:Show()
end

function A.GUI:CreateMainFrame()
	self.mainFrame = AceGUI:Create("Frame")
	local f = self.mainFrame
	
	-- Main frame settings
	f:Hide()
	f:SetTitle( format(L['MOTO Tracker, version: %s'], I.versionName) )
	f:SetLayout("Fill")
	f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

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
		{text=L['Something Else'], value="SomethingElse"} 
	})
	tab:SetCallback("OnGroupSelected", SelectGroup)
	tab:SelectTab("rosterInfo")

	f:AddChild(tab)
end

-- Will get called by main addon when an event 
-- that could affect the roster triggers. Max every 10 sec.
function A.GUI:OnRosterUpdate()
	-- Update if our frame is shown
	if self.mainFrame and self.mainFrame.IsVisible and self.mainFrame:IsVisible() then
		if I.hasGuild then
			local f = self.mainFrame
			local numMembers = GetNumGuildMembers()
			f:SetStatusText(I.guildName .. ' - ' .. numMembers .. ' ' .. L['Members'].. ' - ' .. L['updated at: '] .. date("%H:%M:%S") )
		else
			f:SetStatusText(L['<Not in a guild>'])
		end

		if shownTab == 'rosterInfo' then
			A.GUI.tabs.rosterInfo:OnRosterUpdate()
		end
	end
end

