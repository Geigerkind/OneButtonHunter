local GT = GetTime

OBH = {}
OBH.t = CreateFrame("GameTooltip", "OBH_T", UIParent, "GameTooltipTemplate")
OBH.f = CreateFrame("Frame", "OBH_Events", UIParent)
OBH.f:RegisterEvent("START_AUTOREPEAT_SPELL")
OBH.f:RegisterEvent("STOP_AUTOREPEAT_SPELL")
OBH.auto = false
OBH.next = nil;
OBH.f:SetScript("OnEvent", function(self, event) 
	if OBH.auto then
		OBH.auto = false
		OBH.next = nil
	else
		OBH.next = GT() + UnitRangedDamage("player")
		OBH.auto = true
	end
end)
OBH.f:SetScript("OnUpdate", function(self, elapsed) 
	if OBH.auto then
		local time = GT()
		if OBH.next<time then
			OBH.next = time + UnitRangedDamage("player")
		end
	end
end)
if GetLocale() == "deDE" then
	OBH.name = {
		[1] = "Schnellfeuer",
		[2] = "Schnelle Schüsse",
		[3] = "Gezielter Schuss",
		[4] = "Mehrfachschuss",
		[5] = "Automatischer Schuss"
	}
else
	OBH.name = {
		[1] = "Rapid Fire",
		[2] = "Quick Shots",
		[3] = "Aimed Shot",
		[4] = "Multi-Shot",
		[5] = "Auto Shot"
	}
end
OBH.Quiver = nil
function OBH:GetQuiverSpeed()
	OBH_T:SetOwner(UIParent, "ANCHOR_NONE")
	OBH_T:ClearLines()
	OBH_T:SetInventoryItem("player", 23)
	local msg = OBH_TTextLeft4:GetText()
	if msg then
		for a in string.gfind(msg, "Equip: Increases ranged attack speed by (%d+)%%%.") do
			self.Quiver = 1 + tonumber(a)/100;
		end
	end
	OBH_T:Hide()
end

function OBH:Active(a)
	for i=0, 32 do
		OBH_T:SetOwner(UIParent, "ANCHOR_NONE")
		OBH_T:ClearLines()
		OBH_T:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local buff = OBH_TTextLeft1:GetText()
		OBH_T:Hide()
		if (not buff) then break end
		if string.find(buff, a) then
			return true
		end
	end
	return false
end

function OBH:GetActionSlot(a)
	for i=1, 100 do
		OBH_T:SetOwner(UIParent, "ANCHOR_NONE")
		OBH_T:ClearLines()
		OBH_T:SetAction(i)
		local ab = OBH_TTextLeft1:GetText()
		OBH_T:Hide()
		if ab == a then
			return i;
		end
	end
	return 2;
end

OBH.rf = 1
OBH.qs = 1
OBH.as = 3
OBH.autoSlot = nil
OBH.asSlot = nil
function OBH:Run()
	if not self.autoSlot then self.autoSlot = self:GetActionSlot(self.name[5]) end
	if not self.asSlot then self.asSlot = self:GetActionSlot(self.name[3]) end
	if self.next then
		if self:Active(self.name[1]) then self.rf = 1.4 else self.rf = 1 end
		if self:Active(self.name[2]) then self.qs = 1.3 else self.qs = 1 end
		if not self.Quiver then self:GetQuiverSpeed() end
		self.as = 3/((self.Quiver or 1)*(self.rf or 1)*(self.qs or 1))
		local time = GT();
		if (self.next-time)<self.as and GetActionCooldown(self.asSlot)==0 then
			CastSpellByName(self.name[3])
			return
		end
		CastSpellByName(self.name[4])
	else
		UseAction(self.autoSlot)
	end
end