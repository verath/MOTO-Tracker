--###################################
--	Main Frame
--###################################

-- addon, locale, info
local A,L,I = unpack(select(2, ...))

local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local AceHook = LibStub("AceHook-3.0")

-- Local LUA functions is faster
local sFormat = string.format
local date = date

-- Local vars
local shownTab = nil
local updateRosterTimer
local showTooltipTimer

-- Setup GUI part of the addon var
A.GUI = { 
	tabs = {
		rosterInfo = {},
		eventsInfo = {},
	},
	LDB = {},
	mainFrame = nil,
}

-- Callback function for OnGroupSelected
function SelectGroup(container, event, group)
	container:ReleaseChildren()
	shownTab = group
	if group == 'rosterInfo' then
		A.GUI.tabs.rosterInfo:DrawTab( container )
	elseif group == 'eventsInfo' then
		A.GUI.tabs.eventsInfo:DrawTab( container )
	end
end

-- Local function to show the tooltip, displayed after delay
local function displayTooltip(text, color)
	local frame = A.GUI.mainFrame.frame
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    color = color or {r = 0, g = 1, b = 0}
    
    if type(text) == "string" then
    	GameTooltip:AddLine(text, color.r, color.g, color.b, 1)
    elseif type(text) == "table" then
    	for _,v in ipairs(text) do
    		local color = v.color or color
    		local text = v.text or v
    		GameTooltip:AddLine(text, color.r, color.g, color.b, 1)
    	end
    else
    	--@debug@
		error('Invalid argument!')
		--@end-debug@
    	return
    end
    
    GameTooltip:Show()
end

-- Shows a tooltip with text and color after delay seconds
function A.GUI:ShowTooltip( text, color, delay )
	delay = delay or 0.5

	AceTimer:CancelTimer(showTooltipTimer, true)
	showTooltipTimer = AceTimer:ScheduleTimer(function()
		displayTooltip(text, color)
	end, delay)
end

-- Hides our tooltip if we have one
function A.GUI:HideTooltip()
	AceTimer:CancelTimer(showTooltipTimer, true)
	if GameTooltip:IsOwned(A.GUI.mainFrame.frame) then
    	GameTooltip:Hide()
    end
end

-- Releases our frame back to the Ace GUI and unsets our reference to it
function A.GUI:HideMainFrame()
	-- Save pos/width/height for next time we open the frame
	if self.mainFrame then
		local point, relativeTo, relativePoint, xOfs, yOfs = self.mainFrame.frame:GetPoint()
		local width = self.mainFrame.frame:GetWidth()
		local height = self.mainFrame.frame:GetHeight()

		A.db.char.GUI.savedMainFramePos = {
			point = point,
			relativeTo = relativeTo,
			relativePoint = relativePoint,
			xOfs = xOfs,
			yOfs = yOfs,
			width = width,
			height = height		
		}

		A.GUI.mainFrame:Release()
		A.GUI.mainFrame = nil
	end
end

-- Shows and creates the main frame.
function A.GUI:ShowMainFrame()
	-- Only show if it isn't shown already
	if self.mainFrame then return end

	-- Since it is released on close, we need to
	-- recreate it every time.
	self:CreateMainFrame()
	self.mainFrame:Show()

	-- Load position from db
	if A.db.char.GUI.savedMainFramePos then
		local s = A.db.char.GUI.savedMainFramePos
		self.mainFrame.frame:ClearAllPoints()
		self.mainFrame.frame:SetWidth( s.width )
		self.mainFrame.frame:SetHeight(s.height )
		self.mainFrame.frame:SetPoint( s.point, s.relativeTo, s.relativePoint, s.xOfs, s.yOfs );
	end
	
	-- Update GuildRoster as soon as we can (min time now, max in 10 sec)
	GuildRoster()
	if updateRosterTimer then AceTimer:CancelTimer(updateRosterTimer, true)	end
	updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 10)
end

-- Toggles the main frame
function A.GUI:ToggleMainFrame()
	if A.GUI.mainFrame then 
		A.GUI:HideMainFrame()
	else
		A.GUI:ShowMainFrame()
	end
end
-- Global reference used in bindings.xml
ToggleMOTOTFrame = A.GUI.ToggleMainFrame

-- Updates/Sets the status bar of our main frame
local function updateMainFrameStatusBar()
	if I.hasGuild and I.numGuildMembers then
		A.GUI.mainFrame:SetStatusText(I.guildName .. ' - ' .. I.numGuildMembers .. ' ' .. L['Members'].. ' - ' .. GREEN_FONT_COLOR_CODE .. (I.numGuildOnline - I.numGuildAFK) .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Online'] .. ' ' .. LIGHTYELLOW_FONT_COLOR_CODE .. I.numGuildAFK .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Away'])
	else
		A.GUI.mainFrame:SetStatusText(L['<Not in a guild>'])
	end
end

local old_CloseSpecialWindows
-- Creates the main frame, tabs, and other elements needed for it.
function A.GUI:CreateMainFrame()
	self.mainFrame = AceGUI:Create("Frame")
	local f = self.mainFrame

	-- Close frame on escape
	if not old_CloseSpecialWindows then
		old_CloseSpecialWindows = CloseSpecialWindows
		CloseSpecialWindows = function()
			local found = old_CloseSpecialWindows()
			if A.GUI.mainFrame then
				A.GUI:HideMainFrame()
				return true
			end
			return found
		end
	end

	-- If there is a new update available
	local canUpdate, newVersion = A:CheckVersion()

	-- Main frame settings
	f:Hide()
	if canUpdate and newVersion then
		f:SetTitle( format(L['MOTO Tracker, version: %s'], I.versionName) .. ' ' .. GREEN_FONT_COLOR_CODE .. L['(Update Available!)'] .. FONT_COLOR_CODE_CLOSE )
	else
		f:SetTitle( format(L['MOTO Tracker, version: %s'], I.versionName) )
	end
	f:SetLayout("Fill")
	f:SetCallback("OnClose", function() A.GUI:HideMainFrame() end)

	-- Set the status bar
	updateMainFrameStatusBar()

	-- Create the TabGroup
	local tab = AceGUI:Create("TabGroup")
	tab:SetLayout("Flow")
	tab:SetTabs({
		{text=L['Roster Info'], value="rosterInfo"},
		--{text=L['Events'], value='eventsInfo'} 
	})
	tab:SetCallback("OnGroupSelected", SelectGroup)
	tab:SelectTab("rosterInfo")

	f:AddChild(tab)


end

-- Init the UI
function A.GUI:SetupGUI()
	-- Set up key bindings tooltip for toggeling the frame
	BINDING_HEADER_MOTOTracker = L['MOTO Tracker']
	BINDING_NAME_MOTOTracker_TOGGLE = L['Toggle Main Frame']

	-- Set up our LDB feed
	A.GUI.LDB:SetupLDB()
end

-- Will get called when an event that could affect 
-- the roster triggers. Max once every 10 secs.
function A.GUI:OnRosterUpdate( event, arg1, ... )
	-- Cancel the timer
	if updateRosterTimer then AceTimer:CancelTimer(updateRosterTimer, true)	end

	-- Update the LDB feed
	self.LDB:Update()

	-- If our frame is shown
	if self.mainFrame and self.mainFrame.IsVisible and self.mainFrame:IsVisible() then
		
		-- Make sure we do an update at least every minute if our window is open
		updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 60)

		-- Update status
		updateMainFrameStatusBar()

		-- Update shown tab
		if shownTab == 'rosterInfo' then
			A.GUI.tabs.rosterInfo:OnRosterUpdate()
		end
	else
		-- Update every 2 min if not shown
		updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 120)
	end
end
