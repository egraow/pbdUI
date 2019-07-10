--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")
local config = {}

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
local function setUnit(self)
	if (self:IsForbidden()) then return end -- don't mess with forbidden frames, which sometimes randomly happens

	local name, unit = self:GetUnit()
	if not unit then
		unit = GetMouseFocus() and GetMouseFocus():GetAttribute("unit")
	end
	if not unit then return end

	-- now lets modify the tooltip
	local numLines = self:NumLines()

	local line = 1;
	local name, realm = UnitName(unit)
	local guild, rank = GetGuildInfo(unit)
	local race = UnitRace(unit) or ""
	local classification = UnitClassification(unit)
	local creatureType = UnitCreatureType(unit)
	local factionGroup = select(1, UnitFactionGroup(unit))
	local reactionColor = mod:getReactionColor(unit)

	-- REALM
	if (config.showrealm and realm) then
		name = name.." - "..realm
	end
	
	-- LEVEL
	local level = UnitLevel(unit)
	local levelColor = GetQuestDifficultyColor(level)
	if level == -1 then
		level = '??'
		levelColor = {r = 1, g = 0, b = 0}
	end

	-- FRIENDLY COLORING
	local isFriend = UnitIsFriend("player", unit)
	local friendColor = {r = 1, g = 1, b = 1}
	if (factionGroup == 'Horde' or not isFriend) then
		friendColor = {
			r = 1, 
			g = 0.15,
			b = 0
		}
	else
		friendColor = {
			r = 0, 
			g = 0.55, 
			b = 1
		}
	end

	-- Tags
	local dnd = function()
		return UnitIsAFK(unit) and "|cffAAAAAA<AFK>|r " or UnitIsDND(unit) and "|cffAAAAAA<DND>|r " or ""
	end

	-- build the tooltip and its lines
	local lines = {}
	lines[1] = GameTooltipTextLeft1:GetText()
	
	if UnitIsPlayer(unit) then
		GameTooltipTextLeft1:SetFormattedText('%s%s', dnd(), name)
		if guild then
			GameTooltipTextLeft2:SetFormattedText('%s <%s>', rank, guild)
			GameTooltipTextLeft3:SetFormattedText('|cff%s%s|r |cff%s%s|r', RGBPercToHex(levelColor), level, RGBPercToHex(friendColor), race)
		else
			GameTooltip:AddLine("",1,1,1)
			GameTooltipTextLeft2:SetFormattedText('|cff%s%s|r |cff%s%s|r', RGBPercToHex(levelColor), level, RGBPercToHex(friendColor), race)
		end
	else
		for i = 2, numLines do
			local line = _G['GameTooltipTextLeft'..i]
			if not line or not line:GetText() then break end
			if (level and line:GetText():find('^'..LEVEL) or (creatureType and line:GetText():find('^'..creatureType))) then
				line:SetFormattedText('|cff%s%s%s|r |cff%s%s|r', RGBPercToHex(levelColor), level, classification, RGBPercToHex(friendColor), creatureType or 'Unknown')
			end
		end
	end

	if (UnitExists(unit..'target')) then
		local r, g, b = mod:getReactionColor(unit..'target')
		GameTooltip:AddDoubleLine("Target", UnitName(unit..'target'), .7, .7, .7, r, g, b)
	end
	
	-- Update hp values on the bar
	local hp = UnitHealth(unit)
	local max = UnitHealthMax(unit)
	
	GameTooltipStatusBar.unit = unit
	GameTooltipStatusBar:SetMinMaxValues(0, max)
	GameTooltipStatusBar:SetValue(hp)
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
	GameTooltipStatusBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 6)

	-- Set Fonts
	for i = 1, 20 do
		local line = _G['GameTooltipTextLeft'..i]
		if not line then break end
		line:SetFont(bdUI.media.font, 14)
	end

	
	-- add text to the healthbar on tooltips
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil)
	GameTooltipStatusBar.text:SetFont(bdUI.media.font, 11, "THINOUTLINE")
	GameTooltipStatusBar.text:SetAllPoints()
	GameTooltipStatusBar.text:SetJustifyH("CENTER")
	GameTooltipStatusBar.text:SetJustifyV("MIDDLE")
	GameTooltipStatusBar:SetStatusBarTexture(bdUI.media.smooth)
	bdUI:set_backdrop(GameTooltipStatusBar)

	-- this sucks at updating while you are hovering
	GameTooltipStatusBar:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	GameTooltipStatusBar:RegisterEvent("UNIT_HEALTH")
	GameTooltipStatusBar:SetScript("OnEvent", function(self)
		if (not self.unit) then return end

		local hp, max = UnitHealth(self.unit), UnitHealthMax(self.unit)
		self:SetMinMaxValues(0, max)
		self:SetValue(hp)
		self:SetStatusBarColor( mod:getReactionColor(self.unit))

		local perc = 0
		if (hp > 0 and max > 0) then
			perc = math.floor((hp / max) * 100)
		end
		if (not max) then
			perc = ''
		end
		self.text:SetText(perc)
	end)
end

function mod:create_tooltips()
	config = mod._config

	---------------------------------------------
	--	Modify default position
	---------------------------------------------
	local tooltipanchor = CreateFrame("frame","bdTooltip",UIParent)
	tooltipanchor:SetSize(150, 100)
	tooltipanchor:SetPoint("LEFT", UIParent, "CENTER", 450, -200)
	bdMove:set_moveable(tooltipanchor)

	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", tooltipanchor)

		mod:skin(self)
	end)

	-- for skinning all the tooltips in the UI
	local tooltips = {
		'GameTooltip',
		'ItemRefTooltip',
		'ItemRefShoppingTooltip1',
		'ItemRefShoppingTooltip2',
		'ShoppingTooltip1',
		'ShoppingTooltip2',
		'DropDownList1MenuBackdrop',
		'DropDownList2MenuBackdrop',
	}

	
	-- 	local frame = _G[tooltips[i]]
	-- 	-- mod:skin(frame)

	-- 	if (not frame.hooked) then
	-- 		frame:SetScript("OnShow", function()
	-- 		-- frame:SetScript("OnShow", function()
	-- 			-- mod:strip(frame)
	-- 		end)

	-- 		frame.hooked = true
	-- 	end
	-- end


	--=================================
	-- Override blizzard defaults so
	-- we don't fight them on everything
	--=================================
	TOOLTIP_DEFAULT_COLOR = CreateColor(unpack(bdUI.media.border))
	TOOLTIP_DEFAULT_BACKGROUND_COLOR = CreateColor(unpack(bdUI.media.backdrop))
	TOOLTIP_AZERITE_BACKGROUND_COLOR = TOOLTIP_DEFAULT_BACKGROUND_COLOR

	GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT = {
		bgFile = bdUI.media.flat,
		edgeFile = bdUI.media.flat,
		edgeSize = 2,
	
		backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
		backdropColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR,
		padding = { left = 2, right = 2, top = 2, bottom = 2 }
	};

	GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED = Mixin({}, GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT)
	GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM = Mixin({}, GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT)
	GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.overlayAtlasTop = "AzeriteTooltip-Topper"
	GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.overlayAtlasTopScale = .75
	GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.overlayAtlasBottom = "AzeriteTooltip-Bottom"

	for i = 1, #tooltips do
		local frame = _G[tooltips[i]]
		frame.SetPadding = frame.SetPadding or noop
		GameTooltip_SetBackdropStyle(frame, GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT)
	end

	-- delete lines in the "hide" table
	local hide = {}
	hide["Horde"] = true
	hide["Alliance"] = true
	hide["PvE"] = true
	hide["PvP"] = true
	for k, v in pairs(hide)do
		GameTooltip:DeleteLine(k, true)
	end

	---------------------------------------------------------------------
	-- hook main styling functions
	---------------------------------------------------------------------
	GameTooltip:HookScript('OnTooltipSetUnit', setUnit)
	function GameTooltip_UnitColor(unitToken) return mod:getReactionColor(unitToken) end
end