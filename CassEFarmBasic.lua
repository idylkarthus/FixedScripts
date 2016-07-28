if myHero.charName ~= "Cassiopeia" then return end
require "VPrediction"
local VP = VPrediction()

function OnLoad()
    Config = scriptConfig("Cass E Farm Basic", "basicryze")
    Config:addParam("clear", "Last hit E Key One", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    Config:addParam("harras", "Last hit E Key two", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    Config:addSubMenu("E Settings", "clearsettings")
    Config.clearsettings:addParam("clearE", "Last hit with E (E)", SCRIPT_PARAM_ONOFF, true)
end

function OnTick()
	if Config.clear or Config.harras then
		LaneClear()
	end
end

function OnDraw()

end


function LaneClear()
	for _, minion in pairs(minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC).objects) do
		local eDmg = GetEDamage(minion)
		local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/5000 + 0.250)

		if (myHero:CanUseSpell(_E) == READY and hp < eDmg and hp > 0) and Config.clearsettings.clearE then
			CastSpell(_E, minion)
      		end
    	end
end

function GetEDamage(unit)
	local Elvl = myHero:GetSpellData(_E).level
	if Elvl < 1 then return 0 end
	local EDmgMod = 0.10
	local EDmg = 48 + (4 * myHero.level) + (myHero.ap * EDmgMod) 
	
	local EDmgBonusBase = {10, 40, 70, 100, 130}
	local EDmgBonusMod = 0.35
	local EDmgBonus = EDmgBonusBase[Elvl] + (myHero.ap * EDmgBonusMod)

	local DmgRaw = EDmg
	if TargetHaveBuff("cassiopeiawpoison", unit) or TargetHaveBuff("cassiopeiaqdebuff", unit) then
		DmgRaw = EDmg + EDmgBonus
	end
	local Dmg = myHero:CalcMagicDamage(unit, DmgRaw)
	return Dmg
end

function OnUpdateBuff(Src, Buff, iStacks)
	if Src == myHero then
	end
end
