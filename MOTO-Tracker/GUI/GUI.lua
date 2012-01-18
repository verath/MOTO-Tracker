--###################################
--	Main Frame
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local AceHook = LibStub("AceHook-3.0")

-- Local LUA functions is faster
local sFormat = string.format
local date = date

-- Local vars
local shownTab = nil
local updateRosterTimer

-- Setup GUI part of the addon var
A.GUI = { 
	tabs = {
		rosterInfo = {},
		eventsInfo = {},
	}, 
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
	end

	A.GUI.mainFrame:Release()
	A.GUI.mainFrame = nil
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
		self.mainFrame.frame:SetWidth( s.width )
		self.mainFrame.frame:SetHeight(s.height )
		self.mainFrame.frame:SetPoint( s.point, s.relativeTo, s.relativePoint, s.xOfs, s.yOfs );
	end
	
	-- Update GuildRoster as soon as we can (min time now, max in 10 sec)
	GuildRoster()
	if updateRosterTimer then AceTimer:CancelTimer(updateRosterTimer, true)	end
	updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 10)
end

function A.GUI:ToggleMainFrame()
	if self.mainFrame then 
		self:HideMainFrame()
	else
		self:ShowMainFrame()
	end
end

-- Updates/Sets the status bar of our main frame
local function setMainFrameStatusBar()
	if I.hasGuild then
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

		A.GUI.mainFrame:SetStatusText(I.guildName .. ' - ' .. numMembers .. ' ' .. L['Members'].. ' - ' .. GREEN_FONT_COLOR_CODE .. numOnline .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Online'] .. ' ' .. LIGHTYELLOW_FONT_COLOR_CODE .. numAfk .. FONT_COLOR_CODE_CLOSE .. ' ' .. L['Away'])
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
	setMainFrameStatusBar()

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

function A.GUI:SetupGUI()
	-- Set up bindings for toggeling the frame
	BINDING_HEADER_MOTOTracker = L['MOTO Tracker']
	BINDING_NAME_MOTOTracker_TOGGLE = L['Toggle Main Frame']
end

-- Will get called when an event that could affect 
-- the roster triggers. Max once every 10 secs.
function A.GUI:OnRosterUpdate()
	-- Cancel the timer
	if updateRosterTimer then AceTimer:CancelTimer(updateRosterTimer, true)	end

	-- Update if our frame is shown
	if self.mainFrame and self.mainFrame.IsVisible and self.mainFrame:IsVisible() then
		-- Update status
		setMainFrameStatusBar()

		if shownTab == 'rosterInfo' then
			A.GUI.tabs.rosterInfo:OnRosterUpdate()
		end

		-- Make sure we do update it at least every minute if our window is open
		updateRosterTimer = AceTimer:ScheduleTimer(GuildRoster, 60)
	end
end
