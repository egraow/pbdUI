--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF
local config = {}
mod.padding = 2
mod.units = {}
mod.custom_layout = {}

--===============================================
-- Config callback
--===============================================
function mod:config_callback()
	local config = mod._config

	for unit, self in pairs(mod.units) do
		mod.custom_layout[unit](self, unit)
	end
end
--===============================================
-- Core functionality
-- place core functionality here
--===============================================

mod.additional_elements = {
	castbar = function(self, unit, align)
		if (self.Castbar) then return end

		local font_size = math.restrict(config.castbarheight * 0.85, 8, 14)

		self.Castbar = CreateFrame("StatusBar", nil, self)
		self.Castbar:SetFrameLevel(3)
		self.Castbar:SetStatusBarTexture(bdUI.media.flat)
		self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
		
		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetFont(bdUI.media.font, font_size, "OUTLINE")
		self.Castbar.Text:SetJustifyV("MIDDLE")

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetDrawLayer('ARTWORK')
		self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
		self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.border, bdUI.border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.SafeZone:SetVertexColor(0.85, 0.10, 0.10, 0.20)
		self.Castbar.SafeZone:SetTexture(bdUI.media.flat)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetFont(bdUI.media.font, font_size, "OUTLINE")

		-- Positioning
		if (align == "right") then
			self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
			self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar,"TOPRIGHT", mod.padding*2, 0)
			self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
		else
			self.Castbar.Time:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
			self.Castbar.Time:SetJustifyH("LEFT")
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
			self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -mod.padding*2, 0)
			self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
		end

		bdUI:set_backdrop(self.Castbar)
	end,

	resting = function(self, unit)
		if (self.RestingIndicator) then return end

		local size = math.restrict(self:GetHeight() * 0.75, 8, 14)

		-- Resting indicator
		self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.RestingIndicator:SetPoint("LEFT", self.Health, mod.padding, 2)
		self.RestingIndicator:SetSize(size, size)
		self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)
	end,

	combat = function(self, unit)
		if (self.CombatIndicator) then return end

		local size = math.restrict(self:GetHeight() * 0.75, 8, 14)

		-- Resting indicator
		self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.CombatIndicator:SetPoint("RIGHT", self.Health, -mod.padding, 2)
		self.CombatIndicator:SetSize(size, size)
		self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.CombatIndicator:SetTexCoord(.5, 1, 0, .49)
	end,

	power = function(self, unit)
		if (self.Power) then return end

		-- Power
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetStatusBarTexture(bdUI.media.flat)
		self.Power:ClearAllPoints()
		self.Power:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, bdUI.border)
		self.Power:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border)
		self.Power:SetHeight(config.playertargetpowerheight)
		self.Power.frequentUpdates = true
		self.Power.colorPower = true
		self.Power.Smooth = true
		bdUI:set_backdrop(self.Power)
	end,

	buffs = function(self, unit)
		if (self.Buffs) then return end

		-- Auras
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Buffs:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Buffs:SetSize(config.playertargetwidth, 60)
		self.Buffs.size = 18
		self.Buffs.initialAnchor  = "BOTTOMLEFT"
		self.Buffs.spacing = bdUI.border
		self.Buffs.num = 20
		self.Buffs['growth-y'] = "UP"
		self.Buffs['growth-x'] = "RIGHT"
		self.Buffs.PostCreateIcon = function(buffs, button)
			bdUI:set_backdrop_basic(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button:SetAlpha(0.8)
		end
	end,

	debuffs = function(self, unit)
		if (self.Debuffs) then return end

		-- Auras
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Debuffs:SetSize(config.playertargetwidth, 60)
		self.Debuffs.size = 18
		self.Debuffs.initialAnchor  = "BOTTOMRIGHT"
		self.Debuffs.spacing = bdUI.border
		self.Debuffs.num = 20
		self.Debuffs['growth-y'] = "UP"
		self.Debuffs['growth-x'] = "LEFT"
		self.Debuffs.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop_basic(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			-- button:SetAlpha(0.8)
		end
	end,

	auras = function(self, unit)
		if (self.Auras) then return end

		-- Auras
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Auras:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Auras:SetSize(config.playertargetwidth, 60)
		self.Auras.size = 18
		self.Auras.initialAnchor  = "BOTTOMLEFT"
		self.Auras.spacing = bdUI.border
		self.Auras.num = 20
		self.Auras['growth-y'] = "UP"
		self.Auras['growth-x'] = "RIGHT"
		self.Auras.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop_basic(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			-- button:SetAlpha(0.8)
		end
	end
}

local function layout(self, unit)
	mod.units[unit] = self
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorSmooth = true
	self.Health.Smooth = true
	bdUI:set_backdrop(self.Health)

	-- Name & Text
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(bdUI.media.font, 13, "OUTLINE")

	self.Status = self.Health:CreateFontString(nil, "OVERLAY")
	self.Status:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Status:SetPoint("CENTER", self.Health, "CENTER")
	
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Curhp.frequentUpdates = 0.1

	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 1)
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint('CENTER', self, 0, 0)

	-- Tags
	oUF.Tags.Events['curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (not UnitIsPlayer(unit) and LMH) then
			hp, hpMax = math.max(LMH:GetUnitCurrentHP(unit), hp), math.max(LMH:GetUnitMaxHP(unit), hpMax)
		end
		local hpPercent = hp / hpMax
		if hpMax == 0 then return end
		local r, g, b = bdUI:ColorGradient(hpPercent, 1,0,0, 1,1,0, 1,1,1)
		local hex = RGBPercToHex(r, g, b)
		local perc = table.concat({"|cFF", hex, bdUI:round(hpPercent * 100, 2), "|r"}, "")

		return table.concat({bdUI:numberize(hp), "-", perc}, " ")
	end

	oUF.Tags.Events["status"] = "UNIT_HEALTH  UNIT_CONNECTION  CHAT_MSG_SYSTEM"
	oUF.Tags.Methods["status"] = function(unit)
		if not UnitIsConnected(unit) then
			return "offline"		
		elseif UnitIsDead(unit) then
			return "dead"		
		elseif UnitIsGhost(unit) then
			return "ghost"
		end
	end

	self:Tag(self.Curhp, '[curhp]')
	self:Tag(self.Name, '[name]')
	self:Tag(self.Status, '[status]')

	-- frame specific layouts
	mod.custom_layout[unit](self, unit)
end

function mod:create_unitframes()
	config = mod._config

	oUF:RegisterStyle("bdUnitFrames", layout)
	oUF:SetActiveStyle("bdUnitFrames")

	-- player
	local player = oUF:Spawn("player")
	player:SetPoint("RIGHT", bdParent, "CENTER", -(config.playertargetwidth/2+2), -220)
	bdMove:set_moveable(player)

	-- target
	local target = oUF:Spawn("target")
	target:SetPoint("LEFT", UIParent, "CENTER", (config.playertargetwidth/2+2), -220)
	bdMove:set_moveable(target)

	-- targetoftarget
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("LEFT", UIParent, "CENTER", (config.playertargetwidth/2+2), -220-config.playertargetheight-config.castbarheight-20)
	bdMove:set_moveable(targettarget)

	-- pet
	local pet = oUF:Spawn("pet")
	pet:SetPoint("LEFT", UIParent, "CENTER", -(config.playertargetwidth/2+2), -220-config.playertargetheight-config.castbarheight-20)
	pet:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -config.castbarheight-2)
	bdMove:set_moveable(pet)

	-- focus
	local focus = oUF:Spawn("focus")
	focus:SetPoint("TOP", UIParent, "TOP", 0, -30)
	bdMove:set_moveable(focus)
end