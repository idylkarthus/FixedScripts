if myHero.charName ~= "Ryze" then return end
require("UPL")
UPL = UPL()
require "VPrediction"
local VP = VPrediction()
damagecombo = true
dontQ = false
function OnLoad()
    Config = scriptConfig("Ryze Basic", "basicbasicryze")
    Config:addParam("shoot", "Shoot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Config:addParam("clear", "Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    Config:addSubMenu("Shield Combo Settings", "shieldsettings")
    Config.shieldsettings:addParam("shieldenable", "Enable Shield Combo", SCRIPT_PARAM_ONOFF, true)
    Config.shieldsettings:addParam("shieldforce", "Force Shield/gank Combo if Enabled", SCRIPT_PARAM_ONOFF, false)
    Config.shieldsettings:addParam("rootforce", "On = Long Root, Off = Q damage", SCRIPT_PARAM_ONOFF, true)
    Config:addSubMenu("Clear Settings", "clearsettings")
    Config.clearsettings:addParam("clearenable", "Enable Wave Clear", SCRIPT_PARAM_ONOFF, true)
    Config.clearsettings:addParam("clearQ", "(Q) Wave Clear", SCRIPT_PARAM_ONOFF, true)
    Config.clearsettings:addParam("clearE", "(E) Wave Clear", SCRIPT_PARAM_ONOFF, true)
    targetSelector = TargetSelector(TARGET_LESS_CAST, 1000, DAMAGE_MAGIC, true)


    UPL:AddToMenu(Config)

    UPL:AddSpell(_Q, { speed = 1400, delay = 0.25, range = 1000, width = 55, collision = true, aoe = false, type = "linear" })
end

function OnTick()
    	targetSelector:update()
	Target = targetSelector.target 
	if Config.shoot then
		Combo()
	end
	if Config.clear and Config.clearsettings.clearenable then
		LaneClear()
	end
	Qspell = myHero:GetSpellData(_Q)

end

function OnDraw()

end

function Combo()
	if Target then
		if Target.health > myHero.health then
			damagecombo = false
		else
			damagecombo = true
		end
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 1000 then
			CastQ()
		end
		if (damagecombo and Config.shieldsettings.shieldforce == false) or Config.shieldsettings.shieldenable == false then
			if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) ~= READY and GetDistance(Target) < 550 then
				CastE()
			end
			if myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY and GetDistance(Target) < 550 then
				CastW()
			end
		else
			if Config.shieldsettings.rootforce == true then
				if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) ~= READY and GetDistance(Target) < 550 then
					CastE()
					if myHero:CanUseSpell(_W) == READY then
						CastW()
					end
				end
				if myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY and GetDistance(Target) < 550 then
					CastW()
				end
			else
				if myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_Q) ~= READY and GetDistance(Target) < 550 then
					CastW()
					if myHero:CanUseSpell(_E) == READY then
						CastE()
					end
				end
				if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_W) ~= READY and GetDistance(Target) < 550 then
					CastE()
				end
			end
		end
	end
end

function LaneClear()
	for _, minion in pairs(minionManager(MINION_ENEMY, 500, myHero, MINION_SORT_HEALTH_ASC).objects) do
		local Elvl = myHero:GetSpellData(_E).level
		local EDmgAmp = {0.38, 0.53, 0.68, 0.83, 0.98}

		local qDmg = GetQDamage(minion)
		local eDmg = GetEDamage(minion)
		local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/1400 + 0.250)
		if (myHero:CanUseSpell(_E) == READY and hp < eDmg) and Config.clearsettings.clearE then
			CastSpell(_E, minion)
			dontQ = true
		elseif Elvl >= 1 and not TargetHaveBuff("RyzeE", minion) then
			if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) == READY and hp < eDmg + qDmg+(qDmg*EDmgAmp[Elvl]) then
				CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, minion)
				if CastPosition and HitChance > 0 and Config.clearsettings.clearE then
					CastSpell(_E, minion)
				end
	      		end
      		end
		if Config.clearsettings.clearQ then
			LaneClearQ()
		end
    	end
end

function LaneClearQ()
	if DontQ == true then return end
	for _, minion in pairs(minionManager(MINION_ENEMY, 500, myHero, MINION_SORT_HEALTH_ASC).objects) do
		if not ValidTarget(minion, 550) or minion.dead then return end
		local qDmg = GetQDamage(minion)
		local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/1400 + 0.250)
		if (myHero:CanUseSpell(_Q) == READY) and TargetHaveBuff("RyzeE", minion) then
        		CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, minion)
			if CastPosition and HitChance > 0 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
      		end
	end
end


function GetQDamage(unit)
	local Qlvl = myHero:GetSpellData(_Q).level
	if Qlvl < 1 then return 0 end
	local Elvl = myHero:GetSpellData(_E).level
	local QDmg = {60, 85, 110, 135, 160, 185}
	local EDmgAmp = {0.38, 0.53, 0.68, 0.83, 0.98}
	local QDmgMod = 0.45
	local QmanaDmgMod = 0.03
	local DmgRaw = QDmg[Qlvl] + (myHero.ap * QDmgMod) + (myHero.maxMana * QmanaDmgMod)
	if TargetHaveBuff("RyzeE", unit) then
		DmgRaw = DmgRaw + DmgRaw*EDmgAmp[Elvl]
	end
	local Dmg = myHero:CalcMagicDamage(unit, DmgRaw)
	return Dmg
end

function GetEDamage(unit)
	local Elvl = myHero:GetSpellData(_E).level
	if Elvl < 1 then return 0 end
	local EDmg = {50, 75, 100, 125, 150}
	local EDmgMod = 0.30
	local EmanaDmgMod = 0.02
	local DmgRaw = EDmg[Elvl] + (myHero.ap * EDmgMod) + (myHero.maxMana * EmanaDmgMod)
	local Dmg = myHero:CalcMagicDamage(unit, DmgRaw)
	return Dmg
end


function CastQ()
	if Target == nil then 
		return 
	end
	CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, targetSelector.target)
	if CastPosition and HitChance > 0 then
		CastSpell(_Q, CastPosition.x, CastPosition.z)
	else
		if Config.shieldsettings.rootforce == true then
			if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 550 then
				CastE()
				if myHero:CanUseSpell(_W) == READY then
					CastW()
				end
			end
			if myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_E) ~= READY and GetDistance(Target) < 550 then
				CastW()
			end
		else
			if myHero:CanUseSpell(_W) == READY and GetDistance(Target) < 550 then
				CastW()
				if myHero:CanUseSpell(_E) == READY then
					CastE()
				end
			end
			if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_W) ~= READY and GetDistance(Target) < 550 then
				CastE()
			end
		end
	end
end


function CastW()
	CastSpell(_W, Target)
end

function CastE()
	CastSpell(_E, Target)
end

function OnUpdateBuff(Src, Buff, iStacks)
	if Src == myHero then
	end
end

function DoQ()
	DontQ = false
end

function OnCreateObj(object)

end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		if spell.name == "RyzeE" then
			DontQ = true
			DelayAction(function() DoQ() end, 0.5)
		end
	end
end

function OnDeleteObj(object)

end
