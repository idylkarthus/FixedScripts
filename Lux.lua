if myHero.charName ~= "Lux" then return end
require("UPL")
UPL = UPL()
require "VPrediction"
local VP = VPrediction()

function OnLoad()
    Config = scriptConfig("Lux", "JJ")
    Config:addParam("shoot", "Shoot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))


    targetSelector = TargetSelector(TARGET_LESS_CAST, 900, DAMAGE_MAGICAL, true)


    UPL:AddToMenu(Config)
    UPL:AddSpell(_Q, { speed = 1200, delay = 0.25, range = 1200, width = 70, collision = false, aoe = false, type = "linear" })
    UPL:AddSpell(_W, { speed = math.huge, delay = 0.25, range = 1075, width = 75, collision = false, aoe = true, type = "linear" })
    UPL:AddSpell(_E, { speed = 1300, delay = 0.25, range = 1100, width = 350, collision = false, aoe = true, type = "circular" })
    UPL:AddSpell(_R, { speed = math.huge, delay = 0.50, range = 3340, width = 325, collision = false, aoe = true, type = "linear" })
end

function OnTick()
	targetSelector:update()
	Target = targetSelector.target
	if Config.shoot then
		Combo()
	end
end


function OnDraw()
	DrawCircle(myHero.x, myHero.y, myHero.z, 1175, ARGB(255,255,255,255))
        DrawCircle(myHero.x, myHero.y, myHero.z, 1100, ARGB(255,255,255,255))
end


function Combo()
	if Target then
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 1200 then
			CastQ()
		end
		if myHero:CanUseSpell(_W) == READY and GetDistance(Target) < 1200 then
			CastW()
		end
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 1100 then
			CastE()
		end
		if myHero:CanUseSpell(_R) == READY and GetDistance(Target) < 3340 then
			CastR()
		end		
	end
end


function CastQ()
	if Target then 
		CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, Target)
		if CastPosition and HitChance > 0 then
			if myHero:CanUseSpell(_Q) == READY then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end


function CastW()
	if Target then 
		if myHero:CanUseSpell(_W) == READY then
			CastSpell(_W, mousePos.x, mousePos.z)
		end
	end
end

function CastE()
	if Target then 
		CastPosition, HitChance, HeroPosition = UPL:Predict(_E, myHero, Target)
		if CastPosition and HitChance > 0 then
			if myHero:CanUseSpell(_E) == READY then
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function CastR()
	if Target then 
		CastPosition, HitChance, HeroPosition = UPL:Predict(_R, myHero, Target)
		if CastPosition and HitChance > 0 then
			if myHero:CanUseSpell(_R) == READY then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end



