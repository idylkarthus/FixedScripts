if myHero.charName ~= "Kled" then return end
require("UPL")
UPL = UPL()
require "VPrediction"
TITANIC = false
TITANICSLOT = nil
TIAMAT = false
TIAMATSLOT = nil
Mount = true
local VP = VPrediction()

function OnLoad()
    Config = scriptConfig("Jarvan Dude", "JJ")
    Config:addParam("shoot", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Config:addSubMenu("Combo", "combo")
    Config.combo:addParam("comboQm", "Use Mounted Q in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboQ", "Use Gun Q in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboE1", "Use First (E) dash in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboE2", "Use Second(E) dash in combo", SCRIPT_PARAM_ONOFF, true)
    Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    Config:addSubMenu("Harass", "poke")
    Config.poke:addParam("harassQm", "Use Mounted (Q) in harass", SCRIPT_PARAM_ONOFF, false)
    Config.poke:addParam("harassQ", "Use Gun (Q) in harass", SCRIPT_PARAM_ONOFF, true)
    Config.poke:addParam("harassE1", "Use First (E) dash in harass", SCRIPT_PARAM_ONOFF, false)
    Config.poke:addParam("harassE2", "Use Second(E) dash in harass", SCRIPT_PARAM_ONOFF, false)
    Config:addParam("rangetest", "Champion Circle", SCRIPT_PARAM_SLICE, 500, 0, 2000, 1)
    targetSelector = TargetSelector(TARGET_LESS_CAST, 900, DAMAGE_PHYSICAL, true)


    UPL:AddToMenu(Config)
    UPL:AddSpell(_Q, { speed = 1000, delay = 0.25, range = 750, width = 70, collision = false, aoe = false, type = "linear" })
    UPL:AddSpell(_W, { speed = 2000, delay = 0.25, range = 750, width = 70, collision = false, aoe = true, type = "cone" })
    UPL:AddSpell(_E, { speed = 1400, delay = 0.25, range = 550, width = 70, collision = false, aoe = true, type = "linear" })
end

function OnTick()
	GetTiamat()
	GetTitanic()
	targetSelector:update()
	--print(myHero:GetSpellData(_Q).name)
	Target = targetSelector.target
	if Config.shoot then
		Combo()
	end
	if Config.harass then
		Harass()
	end
	RSteal()
	ignitedmg = 50 + 20*myHero.level
	if ignite == nil then
		smite = Slot("SummonerDot")
	else
		ksIgnite()
	end
	if Target then

	end
end


function ksIgnite()
    if ignite then
        for i, enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy, 500) then
                if enemy.health < igniteDmg then
                    CastSpell(ignite, enemy)
                end
            end
        end
    end
end

function Slot(name)
    if myHero:GetSpellData(SUMMONER_1).name == name then
        return SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name == name then
        return SUMMONER_2
    end
end



function OnDraw()
	DrawCircle(myHero.x, myHero.y, myHero.z, Config.rangetest, ARGB(255,255,255,255))
end

function FindSlotByName(name)
  	if name ~= nil then
    	for i=0, 12 do
      		if string.lower(myHero:GetSpellData(i).name) == string.lower(name) then
        		return i
      		end
    	end
  	end  
  	return nil
end

function GetItem(name)
  	local slot = FindSlotByName(name)
  	return slot 
end


function CastTiamat()
  	if TIAMAT then
    	if (myHero:CanUseSpell(TIAMATSLOT) == READY) then
     		CastSpell(TIAMATSLOT)
    	end
  	end
end

function CastTITANIC()
  	if TITANIC then
    	if (myHero:CanUseSpell(TITANICSLOT) == READY) then
      		CastSpell(TITANICSLOT)
    	end
  	end
end

function GetTiamat()
  	local slot = GetItem("ItemTiamatCleave")
  	if (slot ~= nil) then
    	TIAMAT = true
    	TIAMATSLOT = slot
  	else
    	TIAMAT = false
  	end
end

function GetTitanic()
  	local slot = GetItem("ItemTitanicHydraCleave")
  	if (slot ~= nil) then
    	TITANIC = true
    	TITANICSLOT = slot
  	else
    	TITANIC = false
  	end
end

function Harass()
	if Target then
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 750 then		
			if Config.poke.harassQm == true and myHero:GetSpellData(_Q).name == "KledQ" then
				CastQ(Target)
			end
			if Config.poke.harassQ == true and myHero:GetSpellData(_Q).name == "KledRiderQ" then
				CastQ(Target)
			end
		end
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 550 then
			if Config.poke.harassE1 == true and myHero:GetSpellData(_E).name == "KledE" then
				CastE(Target)
			end
			if Config.poke.harassE2 == true and myHero:GetSpellData(_E).name == "KledE2" then
				CastE(Target)
			end
		end
	end
end

function Combo()
	if Target then
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 750 then
			if Config.combo.comboQm == true and myHero:GetSpellData(_Q).name == "KledQ" then
				CastQ(Target)
			end
			if Config.combo.comboQ == true and myHero:GetSpellData(_Q).name == "KledRiderQ" then
				CastQ(Target)
			end
		end
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 550 then
			if Config.combo.comboE1 == true and myHero:GetSpellData(_E).name == "KledE" then
				CastE(Target)
			end
			if Config.combo.comboE2 == true and myHero:GetSpellData(_E).name == "KledE2" then
				CastE(Target)
			end
		end
		if GetDistance(Target) < 440 and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY then
			CastTiamat()
		end
		if GetDistance(Target) < 440 and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY then
			CastTITANIC()
		end	
	end
end

function GetEDamage(unit)
	local Elvl = myHero:GetSpellData(_E).level
	if Elvl < 1 then return 0 end
	local EDmg = {20, 45, 70, 95, 120}
	local EDmgMod = 0.60
	local DmgRaw = EDmg[Elvl] + (myHero.damage * EDmgMod)
	local Dmg = myHero:CalcDamage(unit, DmgRaw)
	return Dmg
end

function GetQDamage(unit)
	if myHero:GetSpellData(_Q).name == "KledQ" then
		local Qlvl = myHero:GetSpellData(_Q).level
		if Qlvl < 1 then return 0 end
		local QDmg = {25, 50, 75, 100, 125}
		local QDmgMod = 0.60
		local DmgRaw = QDmg[Qlvl] + (myHero.damage * QDmgMod)
		local Dmg = myHero:CalcDamage(unit, DmgRaw)
		return Dmg
	elseif myHero:GetSpellData(_Q).name == "KledRiderQ" then
		local Qlvl = myHero:GetSpellData(_Q).level
		if Qlvl < 1 then return 0 end
		local QDmg = {30, 45, 60, 75, 90}
		local QDmgMod = 0.80
		local DmgRaw = QDmg[Qlvl] + (myHero.damage * QDmgMod)
		local Dmg = myHero:CalcDamage(unit, DmgRaw)
		return Dmg
	end
end


function CastQ(target)
	if target == nil then 
		return 
	end
	if myHero:GetSpellData(_Q).name == "KledQ" and myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 750 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_Q) == READY then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	elseif myHero:GetSpellData(_Q).name == "KledRiderQ" and myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 700 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_W, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_Q) == READY then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end


function CastE(target)
	if target == nil then 
		return 
	end
	if myHero:GetSpellData(_E).name == "KledE" and myHero:CanUseSpell(_E) == READY and GetDistance(target) < 550 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_E, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_E) == READY then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	elseif myHero:GetSpellData(_E).name == "KledE2" and myHero:CanUseSpell(_E) == READY and GetDistance(target) < 625 then
		CastSpell(_E)
	end
end


function RSteal() 
	for i,enemy in pairs(GetEnemyHeroes()) do
    		if not enemy.dead and enemy.visible then
			if myHero:CanUseSpell(_Q) == READY then
				if ValidTarget(enemy, 770) then
					if enemy.health < GetQDamage(enemy) then
						CastQ(target)
					end
				end
			end
			if myHero:CanUseSpell(_E) == READY then
				if ValidTarget(enemy, 830) then
					if enemy.health < GetEDamage(enemy)*2 then
						CastE(target)
					end
				end
			end
		end
	end
end


function OnUpdateBuff(Src, Buff, iStacks)
	if Src == myHero then
		--print(Buff.name)
	end
end

function OnCreateObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
end


function OnDeleteObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		--print(spell.name)
	end
end
