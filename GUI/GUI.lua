local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")

A.GUI = { DrawTab = {}, mainFrame = {} }


--###################################
--	Main Frame
--###################################

-- Callback function for OnGroupSelected
function SelectGroup(container, event, group)
	container:ReleaseChildren()
	if group == 'rosterInfo' then
		A.GUI.DrawTab['RosterInfo']( container )
	end
end

-- Shows the main frame, also creates it if it doesn't exist yet.
function A:ShowMainFrame()
	-- No point in creating it before we want to show it
	-- And since it is realease on close we need to
	-- create it every time.
	self:CreateMainFrame()
	self.GUI.mainFrame:Show()
end

function A:CreateMainFrame()
	A.GUI.mainFrame = AceGUI:Create("Frame")
	local f = A.GUI.mainFrame
	
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
